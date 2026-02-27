/**
 * @file    bcm2835_raw_uart.c
 * @brief   Raw UART driver for HomeMatic (OpenCCU)
**/
/*-----------------------------------------------------------------------------
 * Copyright (c) 2015 by eQ-3 Entwicklung GmbH
 * Author: Heiko Thole
 *         Markus Willenborg
 *         Jens Maus <mail@jens-maus.de>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *---------------------------------------------------------------------------*/


/*
 *  Includes ------------------------------------------------------------------
 */
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/device.h>
#include <linux/clk-provider.h>
#include <linux/clkdev.h>
#include <linux/clk.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/poll.h>
#include <linux/spinlock.h>
#include <linux/circ_buf.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/wait.h>
#include <linux/interrupt.h>
#include <linux/sched.h>
#include <linux/amba/serial.h>
#include <linux/version.h>
#include <asm/ioctls.h>
#include <asm/termios.h>

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,9,0)
  #define CLK_IS_ROOT 0
  #define UART0_BASE  (0x3f201000) /* RaspberryPi2/Pi3 default */
#else
  #include <../arch/arm/mach-bcm2709/include/mach/platform.h>
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,3,0)
  #define IRQ_UART 87 /* RaspberryPi2/3 default */
#endif

/*
 *  Module paramters ----------------------------------------------------------
 */

static long uart0_base = UART0_BASE;
module_param(uart0_base, long, 0444);
MODULE_PARM_DESC(uart0_base, "The base address of the UART");

static int uart0_irq = IRQ_UART;
module_param(uart0_irq, int, 0444);
MODULE_PARM_DESC(uart0_irq, "The IRQ number of the UART");

/*
 *  Definitions ---------------------------------------------------------------
 */
#define MODNAME "bcm2835-raw-uart"
#define DRVNAME "raw-uart"
#define CIRCBUF_SIZE 1024
#define CON_DATA_TX_BUF_SIZE 4096
#define PROC_DEBUG  1
#define BAUD 115200
#define TX_CHUNK_SIZE 11
#define IOCTL_MAGIC 'u'
#define IOCTL_MAXNR 2
#define MAX_CONNECTIONS 3
#define UART0_CLK_RATE 48000000
#define IOCTL_IOCSPRIORITY _IOW(IOCTL_MAGIC,  1, unsigned long) /* Set the priority for the current channel */
#define IOCTL_IOCGPRIORITY _IOR(IOCTL_MAGIC,  2, unsigned long) /* Get the priority for the current channel */



/*
 *  Prototypes ----------------------------------------------------------------
 */
struct per_connection_data;
struct bcm2835_raw_uart_port_s;
static int bcm2835_raw_uart_probe( struct platform_device *pdev );
static int bcm2835_raw_uart_remove( struct platform_device *pdev );
static ssize_t bcm2835_raw_uart_read(struct file *filep, char __user *buf, size_t count, loff_t *offset);
static ssize_t bcm2835_raw_uart_write(struct file *filep, const char __user *buf, size_t count, loff_t *offset);
static int bcm2835_raw_uart_open(struct inode *inode, struct file *filep);
static int bcm2835_raw_uart_close(struct inode *inode, struct file *filep);
static unsigned int bcm2835_raw_uart_poll(struct file* filep, poll_table* wait);
static long bcm2835_raw_uart_ioctl(struct file *filep, unsigned int cmd, unsigned long arg);
static int bcm2835_raw_uart_startup(void);
static int bcm2835_raw_uart_acquire_sender( struct per_connection_data *conn );
static int bcm2835_raw_uart_send_completed( struct per_connection_data *conn );
static void bcm2835_raw_uart_shutdown(void);
static void bcm2835_raw_uart_stop_txie(void);
static inline void bcm2835_raw_uart_tx_chars(void);
static void bcm2835_raw_uart_start_tx(void);
static void bcm2835_raw_uart_rx_chars(void);
static irqreturn_t bcm2835_raw_uart_irq_handle(int irq, void *context);
static void bcm2835_raw_uart_reset(void);
static int __init bcm2835_raw_uart_init(void);
static void __exit bcm2835_raw_uart_exit(void);
#ifdef PROC_DEBUG
static int bcm2835_raw_uart_proc_show(struct seq_file *m, void *v);
static int bcm2835_raw_uart_proc_open(struct inode *inode, struct  file *file);
#endif /*PROC_DEBUG*/


/*
 *  Typedefs ------------------------------------------------------------------
 */
/*Information for the hardware uart.*/
struct bcm2835_raw_uart_port_s
{
  struct clk *clk;                            /*System clock assigned to the UART device*/
  struct device *dev;                         /*System device*/
  dev_t devnode;                              /*Major/minor of /dev entry*/
  struct cdev cdev;                           /*character device structure*/
  struct class * class;                       /*driver class*/
  unsigned long mapbase;                      /*physical address of UART registers*/
  void __iomem* membase;                      /*logical address of UART registers*/
  unsigned long irq;                          /*interrupt number*/
  spinlock_t lock_tx;                         /*TX lock for accessing tx_connection*/
  struct semaphore sem;                       /*semaphore for accessing this struct*/
  wait_queue_head_t readq;                    /*wait queue for read operations*/
  wait_queue_head_t writeq;                   /*wait queue for write operations*/
  struct circ_buf rxbuf;                      /*RX buffer*/
  int open_count;                             /*number of open connections*/
  struct per_connection_data* tx_connection;  /*connection which is currently sending*/
  struct termios termios;                     /*dummy termios for emulating ttyp ioctls*/
  int count_tx;                               /*Statistic counter: Number of bytes transmitted*/
  int count_rx;                               /*Statistic counter: Number of bytes received*/
  int count_brk;                              /*Statistic counter: Number of break conditions received*/
  int count_parity;                           /*Statistic counter: Number of parity errors*/
  int count_frame;                            /*Statistic counter: Number of frame errors*/
  int count_overrun;                          /*Statistic counter: Number of RX overruns in hardware FIFO*/
  int count_buf_overrun;                      /*Statistic counter: Number of RX overruns in user space buffer*/
};

/* Information about a single connection from user space */
struct per_connection_data
{
  unsigned char txbuf[CON_DATA_TX_BUF_SIZE];
  size_t tx_buf_length;                 /*length of tx frame transmitted from userspace*/
  size_t tx_buf_index;                  /*index into txbuf*/
  unsigned long priority;               /*priority of the corresponding channel*/
  struct semaphore sem;                 /*semaphore for accessing this struct.*/
};

static struct platform_driver m_bcm2835_raw_uart_driver =
{
  .probe = bcm2835_raw_uart_probe,
  .remove = bcm2835_raw_uart_remove,
  .driver =
  {
    .name = MODNAME,
  },
};

static struct file_operations m_bcm2835_raw_uart_fops =
{
  .owner = THIS_MODULE,
  .llseek = no_llseek,
  .read = bcm2835_raw_uart_read,
  .write = bcm2835_raw_uart_write,
  .open = bcm2835_raw_uart_open,
  .release = bcm2835_raw_uart_close,
  .poll = bcm2835_raw_uart_poll,
  .unlocked_ioctl = bcm2835_raw_uart_ioctl,
};

#ifdef PROC_DEBUG
static const struct file_operations m_bcm2835_raw_uart_proc_fops =
{
  .owner = THIS_MODULE,
  .open = bcm2835_raw_uart_proc_open,
  .read = seq_read,
  .llseek = seq_lseek,
  .release = single_release,
};
#endif /*PROC_DEBUG*/

static struct bcm2835_raw_uart_port_s *m_bcm2835_raw_uart_port = NULL;


/*
 *  Functions -----------------------------------------------------------------
 */

/*!
 ******************************************************************************
 * @brief The read function for the user space
 *
 * @param filep Pointer to the user space file
 * @param buf Pointer to the user space buffer where the data should be copied to
 * @param count Max number of bytes to read
 * @param offset Unused
 * @return Number of bytes read or error
**/
static ssize_t bcm2835_raw_uart_read(struct file *filep, char __user *buf, size_t count, loff_t *offset)
{
  if( down_interruptible( &m_bcm2835_raw_uart_port->sem ))
  {
    return -ERESTARTSYS;
  }

  while( !CIRC_CNT( m_bcm2835_raw_uart_port->rxbuf.head, m_bcm2835_raw_uart_port->rxbuf.tail, CIRCBUF_SIZE )) /* Wait for data, if there's currently nothing to read */
  {
    up( &m_bcm2835_raw_uart_port->sem );
    if( filep->f_flags & O_NONBLOCK )
    {
      return -EAGAIN;
    }

    if( wait_event_interruptible(m_bcm2835_raw_uart_port->readq, CIRC_CNT(m_bcm2835_raw_uart_port->rxbuf.head, m_bcm2835_raw_uart_port->rxbuf.tail, CIRCBUF_SIZE )) )
    {
      return -ERESTARTSYS;
    }

    if( down_interruptible( &m_bcm2835_raw_uart_port->sem ))
    {
      return -ERESTARTSYS;
    }
  }

  count = min( (int)count, CIRC_CNT_TO_END(m_bcm2835_raw_uart_port->rxbuf.head, m_bcm2835_raw_uart_port->rxbuf.tail, CIRCBUF_SIZE) );
  if( copy_to_user(buf, m_bcm2835_raw_uart_port->rxbuf.buf + m_bcm2835_raw_uart_port->rxbuf.tail, count) )
  {
    up( &m_bcm2835_raw_uart_port->sem );
    return -EFAULT;
  }

  smp_mb();
  m_bcm2835_raw_uart_port->rxbuf.tail += count;
  if( m_bcm2835_raw_uart_port->rxbuf.tail >= CIRCBUF_SIZE )
  {
    m_bcm2835_raw_uart_port->rxbuf.tail -= CIRCBUF_SIZE;
  }
  up( &m_bcm2835_raw_uart_port->sem );

  return count;
}



/*!
 ******************************************************************************
 * @brief The read function for the user space
 * Waits until count bytes have been transferred to the TX FIFO. May return less than count if send was interrupted by a higher priority write operation
 *
 * @param filep Pointer to the user space file
 * @param buf Pointer to the user space buffer where the data should be read from
 * @param count Number of bytes to write
 * @param offset Unused
 * @return Number of bytes written or error
**/
static ssize_t bcm2835_raw_uart_write(struct file *filep, const char __user *buf, size_t count, loff_t *offset)
{
  struct per_connection_data *conn = filep->private_data;
  int ret = 0;

  if( down_interruptible(&conn->sem) )
  {
    ret = -ERESTARTSYS;
    goto exit;
  }

  if( count > sizeof(conn->txbuf)  )
  {
    printk( KERN_ERR "bcm2835_raw_uart: bcm2835_raw_uart_write(): Error message size.\n" );
    ret = -EMSGSIZE;
    goto exit_sem;
  }

  if( copy_from_user(conn->txbuf, buf, count) )
  {
    printk( KERN_ERR "bcm2835_raw_uart: bcm2835_raw_uart_write(): Copy from user.\n" );
    ret = -EFAULT;
    goto exit_sem;
  }

  conn->tx_buf_index = 0;
  conn->tx_buf_length = count;
  smp_wmb();  /*Wait until completion of all writes*/

  if( wait_event_interruptible(m_bcm2835_raw_uart_port->writeq, bcm2835_raw_uart_acquire_sender(conn)) )
  {
    ret = -ERESTARTSYS;
    goto exit_sem;
  }

  /*wait for sending to complete*/
  if( wait_event_interruptible(m_bcm2835_raw_uart_port->writeq, bcm2835_raw_uart_send_completed(conn)) )
  {
    ret = -ERESTARTSYS;
    goto exit_sem;
  }

  /*return number of characters actually sent*/
  ret = conn->tx_buf_index;

exit_sem:
  up( &conn->sem );

exit:
  return ret;
}



/*!
 ******************************************************************************
 * @brief The open function for the user space
 * If necessary, perform initialization and enable port for reception.
 *
 * @param inode Unused
 * @param filep Pointer to the user space file
 * @return 0 or error
**/
static int bcm2835_raw_uart_open(struct inode *inode, struct file *filep)
{
  int ret;
  struct per_connection_data *conn;

  if( m_bcm2835_raw_uart_port == NULL )
  {
    return -ENODEV;
  }

  /*Get semaphore*/
  if( down_interruptible(&m_bcm2835_raw_uart_port->sem) )
  {
    return -ERESTARTSYS;
  }

  /* check for the maximum number of connections */
  if( m_bcm2835_raw_uart_port->open_count >= MAX_CONNECTIONS )
  {
    printk(KERN_ERR "bcm2835_raw_uart: bcm2835_raw_uart_open(): too many open connections\n");

    /*Release semaphore*/
    up( &m_bcm2835_raw_uart_port->sem );

    return -EMFILE;
  }


  if( !m_bcm2835_raw_uart_port->open_count )  /*Enable HW for the first connection.*/
  {
    ret = bcm2835_raw_uart_startup( );
    if( ret )
    {
      /*Release semaphore*/
      up( &m_bcm2835_raw_uart_port->sem );
      return ret;
    }

    init_waitqueue_head( &m_bcm2835_raw_uart_port->writeq );
    init_waitqueue_head( &m_bcm2835_raw_uart_port->readq );
  }

  m_bcm2835_raw_uart_port->open_count++;

  /*Release semaphore*/
  up( &m_bcm2835_raw_uart_port->sem );

  conn = kmalloc( sizeof( struct per_connection_data ), GFP_KERNEL );
  memset( conn, 0, sizeof( struct per_connection_data ) );

  sema_init( &conn->sem, 1 );

  filep->private_data = (void *)conn;

  return 0;
}



/*!
 ******************************************************************************
 * @brief Disable the UART hardware
 *
**/
static void bcm2835_raw_uart_shutdown(void)
{
  /*If uart is enabled, wait until it is not busy*/
  while( (readl(m_bcm2835_raw_uart_port->membase + UART011_CR) & UART01x_CR_UARTEN) && (readl(m_bcm2835_raw_uart_port->membase + UART01x_FR) & UART01x_FR_BUSY) )
  {
    schedule();
  }

  writel( 0, m_bcm2835_raw_uart_port->membase + UART011_CR );  /*Disable UART*/

  writel( 0, m_bcm2835_raw_uart_port->membase + UART011_IMSC );  /*Disable interrupts*/

  free_irq( m_bcm2835_raw_uart_port->irq, m_bcm2835_raw_uart_port );
  clk_disable_unprepare( m_bcm2835_raw_uart_port->clk );
}



/*!
 ******************************************************************************
 * @brief The release function for the user space
 *
 * @param inode Unused
 * @param filep Pointer to the user space file
 * @return 0 or error
**/
static int bcm2835_raw_uart_close(struct inode *inode, struct file *filep)
{
  struct per_connection_data *conn = filep->private_data;

  if( down_interruptible(&conn->sem) )
  {
    return -ERESTARTSYS;
  }

  kfree( conn );

  if( down_interruptible(&m_bcm2835_raw_uart_port->sem) )
  {
    return -ERESTARTSYS;
  }

  if( m_bcm2835_raw_uart_port->open_count )
  {
    m_bcm2835_raw_uart_port->open_count--;
  }

  if( !m_bcm2835_raw_uart_port->open_count )
  {
    bcm2835_raw_uart_shutdown( );
  }

  up( &m_bcm2835_raw_uart_port->sem );

  return 0;
}



/*!
 ******************************************************************************
 * @brief The poll function for the user space
 *
 * @param filep Pointer to the user space file
 * @param wait Pointer to poll_table structure
 * @return 0 or error
**/
static unsigned int bcm2835_raw_uart_poll(struct file* filep, poll_table* wait)
{
  struct per_connection_data *conn = filep->private_data;
  unsigned long lock_flags = 0;
  unsigned int mask = 0;

  poll_wait( filep, &m_bcm2835_raw_uart_port->readq, wait );
  poll_wait( filep, &m_bcm2835_raw_uart_port->writeq, wait );

  spin_lock_irqsave( &m_bcm2835_raw_uart_port->lock_tx, lock_flags );
  if( (m_bcm2835_raw_uart_port->tx_connection == NULL ) || ( m_bcm2835_raw_uart_port->tx_connection->priority < conn->priority ))
  {
    mask |= POLLOUT | POLLWRNORM;
  }
  spin_unlock_irqrestore( &m_bcm2835_raw_uart_port->lock_tx, lock_flags );

  if( CIRC_CNT( m_bcm2835_raw_uart_port->rxbuf.head, m_bcm2835_raw_uart_port->rxbuf.tail, CIRCBUF_SIZE) > 0 )
  {
    mask |= POLLIN | POLLRDNORM;
  }

  return mask;
}



/*!
 ******************************************************************************
 * @brief The ioctl function for the user space
 *
 * @param filep Pointer to the user space file
 * @param cmd
 * @param arg
 * @return 0 or error
**/
static long bcm2835_raw_uart_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
{
  struct per_connection_data *conn = filep->private_data;
  long ret = 0;
  int err = 0;
  unsigned long temp;

  if( _IOC_TYPE(cmd) == IOCTL_MAGIC )
  {
    /*
     * extract the type and number bitfields, and don't decode
     * wrong cmds: return ENOTTY (inappropriate ioctl) before access_ok()
     */
    if( _IOC_NR(cmd) > IOCTL_MAXNR )
    {
      return -ENOTTY;
    }

    /*
     * the direction is a bitmask, and VERIFY_WRITE catches R/W
     * transfers. `Type' is user-oriented, while
     * access_ok is kernel-oriented, so the concept of "read" and
     * "write" is reversed
     */
    if( _IOC_DIR(cmd) & _IOC_READ )
    {
      err = !access_ok( VERIFY_WRITE, (void __user *)arg, _IOC_SIZE(cmd) );
    }
    else if( _IOC_DIR(cmd) & _IOC_WRITE )
    {
      err =  !access_ok(VERIFY_READ, (void __user *)arg, _IOC_SIZE(cmd));
    }
    if( err )
    {
      return -EFAULT;
    }
  }

  if( down_interruptible(&conn->sem) )
  {
    return -ERESTARTSYS;
  }

  switch( cmd )
  {

  /* Set connection priority */
  case IOCTL_IOCSPRIORITY: /* Set: arg points to the value */
    ret = __get_user( temp,  (unsigned long __user *)arg );
    if( ret )
    {
      break;
    }
    conn->priority = temp;
    break;

    /* Get connection priority */
  case IOCTL_IOCGPRIORITY: /* Get: arg is pointer to result */
    ret = __put_user( conn->priority, (unsigned long __user *)arg );
    break;

    /* Emulated TTY ioctl: Get termios struct */
  case TCGETS:
    if( access_ok(VERIFY_READ, (void __user *)arg, sizeof(struct termios) ) )
    {
      if( down_interruptible(&m_bcm2835_raw_uart_port->sem) )
      {
        ret = -ERESTARTSYS;
      }
      else
      {
        ret = copy_to_user( (void __user *)arg, &m_bcm2835_raw_uart_port->termios, sizeof(struct termios) );
        up(&m_bcm2835_raw_uart_port->sem);
      }
    }
    else
    {
      ret = -EFAULT;
    }
    break;

    /* Emulated TTY ioctl: Set termios struct */
  case TCSETS:
    if( access_ok(VERIFY_WRITE, (void __user *)arg, sizeof(struct termios) ) )
    {
      if( down_interruptible(&m_bcm2835_raw_uart_port->sem) )
      {
        ret = -ERESTARTSYS;
      }
      else
      {
        ret = copy_from_user( &m_bcm2835_raw_uart_port->termios, (void __user *)arg, sizeof(struct termios) );
        up(&m_bcm2835_raw_uart_port->sem);
      }
    }
    else
    {
      ret = -EFAULT;
    }
    break;

    /* Emulated TTY ioctl: Get receive queue size */
  case TIOCINQ:
    if( access_ok(VERIFY_WRITE, (void __user *)arg, sizeof(temp) ) )
    {
      if( down_interruptible(&m_bcm2835_raw_uart_port->sem) )
      {
        ret = -ERESTARTSYS;
      }
      else
      {
        temp = CIRC_CNT( m_bcm2835_raw_uart_port->rxbuf.head, m_bcm2835_raw_uart_port->rxbuf.tail, CIRCBUF_SIZE );
        up( &m_bcm2835_raw_uart_port->sem );
        ret = __put_user( temp, (int __user *)arg );
      }
    }
    else
    {
      ret = -EFAULT;
    }
    break;

    /* Emulated TTY ioctl: Get send queue size */
  case TIOCOUTQ:
    if( access_ok(VERIFY_WRITE, (void __user *)arg, sizeof(temp) ) )
    {
      temp = 0;
      ret = __put_user( temp, (int __user *)arg );
    }
    else
    {
      ret = -EFAULT;
    }
    break;

    /* Emulated TTY ioctl: Exclusive use */
  case TIOCEXCL:
    break;

    /* Emulated TTY ioctl: Flush */
  case TCFLSH:
    break;

    /* Emulated TTY ioctl: Get states of modem control lines */
  case TIOCMGET:
    if( access_ok(VERIFY_WRITE, (void __user *)arg, sizeof(temp) ) )
    {
      temp = TIOCM_DSR | TIOCM_CD | TIOCM_CTS;
      ret = __put_user( temp, (int __user *)arg );
    }
    else
    {
      ret = -EFAULT;
    }
    break;

    /* Emulated TTY ioctl: Set states of modem control lines */
  case TIOCMSET:
    break;

  default:
    ret = -ENOTTY;
  }

  up( &conn->sem );
  return ret;
}



/*!
 ******************************************************************************
 * @brief Disable TX interrupts for the UART
 *
**/
static void bcm2835_raw_uart_stop_txie(void)
{
  unsigned long imsc;

  /*Diable TX interrupts*/
  imsc = readl( m_bcm2835_raw_uart_port->membase + UART011_IMSC );
  imsc &= ~(UART011_DSRMIM | UART011_DCDMIM | UART011_RIMIM); /*Set all RO bit to 0*/
  imsc &= ~(UART011_TXIM); /*disable TX interrupt*/

  writel( imsc, m_bcm2835_raw_uart_port->membase + UART011_IMSC );
}



/*!
 ******************************************************************************
 * @brief Transfer the next chunk of characters from the sending connection to the TX FIFO
 *
**/
static inline void bcm2835_raw_uart_tx_chars(void)
{
  int tx_count = 0;

  while( (tx_count < TX_CHUNK_SIZE) && (!(readl(m_bcm2835_raw_uart_port->membase + UART01x_FR) & UART01x_FR_TXFF)) &&
       (m_bcm2835_raw_uart_port->tx_connection != NULL) && (m_bcm2835_raw_uart_port->tx_connection->tx_buf_index < m_bcm2835_raw_uart_port->tx_connection->tx_buf_length) )
  {
    writel( m_bcm2835_raw_uart_port->tx_connection->txbuf[m_bcm2835_raw_uart_port->tx_connection->tx_buf_index], m_bcm2835_raw_uart_port->membase + UART01x_DR );
    m_bcm2835_raw_uart_port->tx_connection->tx_buf_index++;
    smp_wmb();
    tx_count++;
    #ifdef PROC_DEBUG
    m_bcm2835_raw_uart_port->count_tx++;
    #endif /*PROC_DEBUG*/
  }

  if( (m_bcm2835_raw_uart_port->tx_connection != NULL) && (m_bcm2835_raw_uart_port->tx_connection->tx_buf_index >= m_bcm2835_raw_uart_port->tx_connection->tx_buf_length) )
  {
    bcm2835_raw_uart_stop_txie( );
    m_bcm2835_raw_uart_port->tx_connection = NULL;
    smp_wmb();
    wake_up_interruptible( &m_bcm2835_raw_uart_port->writeq );
  }

}



/*!
 ******************************************************************************
 * @brief Start sending
 *
**/
static void bcm2835_raw_uart_start_tx(void)
{
  unsigned long imsc;

  /*Clear TX interrupts*/
  writel( UART011_TXIC, m_bcm2835_raw_uart_port->membase + UART011_ICR );

  /*Enable TX interrupts*/
  imsc = readl( m_bcm2835_raw_uart_port->membase + UART011_IMSC );
  imsc &= ~(UART011_DSRMIM | UART011_DCDMIM | UART011_RIMIM); /*Set all RO bit to 0*/
  imsc |= UART011_TXIM; /*enable TX interrupt*/

  writel( imsc, m_bcm2835_raw_uart_port->membase + UART011_IMSC );

  bcm2835_raw_uart_tx_chars( );
}



/*!
 ******************************************************************************
 * @brief Try to become the current sender and start sending. Fails if a higher priority send is in progress.
 *
 * @param conn Pointer to the struct with the connection data
 * @return 1: success; else 0
**/
static int bcm2835_raw_uart_acquire_sender( struct per_connection_data *conn )
{
  int ret = 0;
  unsigned long lock_flags;
  int sender_idle;

  spin_lock_irqsave( &m_bcm2835_raw_uart_port->lock_tx, lock_flags );
  sender_idle = m_bcm2835_raw_uart_port->tx_connection == NULL;
  if( (m_bcm2835_raw_uart_port->tx_connection == NULL) || (m_bcm2835_raw_uart_port->tx_connection->priority < conn->priority) )
  {
    m_bcm2835_raw_uart_port->tx_connection = conn;
    ret = 1;
    if( sender_idle )
    {
      bcm2835_raw_uart_start_tx( );
    }
    else
    {
      wake_up_interruptible( &m_bcm2835_raw_uart_port->writeq );
    }
  }
  spin_unlock_irqrestore(&m_bcm2835_raw_uart_port->lock_tx, lock_flags);
  return ret;
}



/*!
 ******************************************************************************
 * @brief Check if sending by the given connection was completed.
 * Sending was completed if the sending connection has changed
 *
 * @param conn Pointer to the connection data
 * @return 1: Sending was completed (connection has changed); else 0
**/
static int bcm2835_raw_uart_send_completed( struct per_connection_data *conn )
{
  int ret = 0;
  unsigned long lock_flags;

  spin_lock_irqsave( &m_bcm2835_raw_uart_port->lock_tx, lock_flags );
  ret = m_bcm2835_raw_uart_port->tx_connection != conn;
  spin_unlock_irqrestore( &m_bcm2835_raw_uart_port->lock_tx, lock_flags );

  return ret;
}



/*!
 ******************************************************************************
 * @brief Read all available chars from UART and save them in rxbuf
 *
**/
static void bcm2835_raw_uart_rx_chars(void)
{
  unsigned long status;
  unsigned long data;
  unsigned int cnt=0;

  while( 1 )
  {
    status = readl( m_bcm2835_raw_uart_port->membase + UART01x_FR );

    if( status & UART01x_FR_RXFE )
    {
      break;
    }

    data = readl( m_bcm2835_raw_uart_port->membase + UART01x_DR );

    m_bcm2835_raw_uart_port->count_rx++;
    cnt++;

    /* Error handling */
    if( data & UART011_DR_BE )
    {
      m_bcm2835_raw_uart_port->count_brk++;
    }
    else
    {
      if( data & UART011_DR_PE )
      {
        m_bcm2835_raw_uart_port->count_parity++;
      }
      if( data & UART011_DR_FE )
      {
        m_bcm2835_raw_uart_port->count_frame++;
      }
      if( data & UART011_DR_OE )
      {
        m_bcm2835_raw_uart_port->count_overrun++;
      }

      if( CIRC_SPACE( m_bcm2835_raw_uart_port->rxbuf.head, m_bcm2835_raw_uart_port->rxbuf.tail, CIRCBUF_SIZE ))
      {
        m_bcm2835_raw_uart_port->rxbuf.buf[m_bcm2835_raw_uart_port->rxbuf.head] = (unsigned char)data;
        smp_wmb();

        if( ++(m_bcm2835_raw_uart_port->rxbuf.head) >= CIRCBUF_SIZE )
        {
          m_bcm2835_raw_uart_port->rxbuf.head = 0;
        }
      }
      else
      {
        printk(KERN_ERR "bcm2835_raw_uart: bcm2835_raw_uart_rx_chars(): rx fifo full\n");
      }
    }
  }

  wake_up_interruptible( &m_bcm2835_raw_uart_port->readq );
}



/*!
 ******************************************************************************
 * @brief UART interrupt dispatcher for RX and TX interrupts
 *
 * @param irq Unused
 * @param context Unused
 * @return IRQ_HANDLED
**/
static irqreturn_t bcm2835_raw_uart_irq_handle(int irq, void *context)
{
  u32 istat;

  istat = readl( m_bcm2835_raw_uart_port->membase + UART011_MIS );
  smp_rmb();


  /*Clear interrupts*/
  smp_wmb();

  writel(istat, m_bcm2835_raw_uart_port->membase + UART011_ICR );

  if( istat & (UART011_RXIS | UART011_RTIS))
  {
    bcm2835_raw_uart_rx_chars( );
  }

  if( istat & UART011_TXIS )
  {
    spin_lock( &m_bcm2835_raw_uart_port->lock_tx );
    bcm2835_raw_uart_tx_chars( );
    spin_unlock( &m_bcm2835_raw_uart_port->lock_tx );
  }

  return IRQ_HANDLED;
}



/*!
 ******************************************************************************
 * @brief Enable the UART hardware
 *
 * @return 0 or error
**/
static int bcm2835_raw_uart_startup(void)
{

  int ret = 0;
  unsigned int bauddiv;
  unsigned long uart_cr;

  clk_prepare_enable( m_bcm2835_raw_uart_port->clk );

  /* set baud rate */
  bauddiv = DIV_ROUND_CLOSEST( clk_get_rate(m_bcm2835_raw_uart_port->clk) * 4, BAUD );
  writel( bauddiv & 0x3f, m_bcm2835_raw_uart_port->membase + UART011_FBRD );
  writel( bauddiv >> 6, m_bcm2835_raw_uart_port->membase + UART011_IBRD );

  /* Ensure interrupts from this UART are masked and cleared */
  writel( 0, m_bcm2835_raw_uart_port->membase + UART011_IMSC );
  writel( 0x7ff, m_bcm2835_raw_uart_port->membase + UART011_ICR );

  /*Register interrupt handler*/
  ret = request_irq( m_bcm2835_raw_uart_port->irq, bcm2835_raw_uart_irq_handle, 0, dev_name(m_bcm2835_raw_uart_port->dev), m_bcm2835_raw_uart_port );
  if ( ret )
  {
    goto out;
  }

  /* enable RX and TX, set RX FIFO threshold to lowest and TX FIFO threshold to mid */
  /*If uart is enabled, wait until it is not busy*/
  while( (readl(m_bcm2835_raw_uart_port->membase + UART011_CR) & UART01x_CR_UARTEN) && (readl(m_bcm2835_raw_uart_port->membase + UART01x_FR) & UART01x_FR_BUSY) )
  {
    schedule();
  }

  uart_cr = readl( m_bcm2835_raw_uart_port->membase + UART011_CR );
  uart_cr &= ~(UART011_CR_OUT2 | UART011_CR_OUT1 | UART011_CR_DTR | UART01x_CR_IIRLP | UART01x_CR_SIREN); /*Set all RO bit to 0*/

  /*Disable UART*/
  uart_cr &= ~(UART01x_CR_UARTEN);
  writel( uart_cr, m_bcm2835_raw_uart_port->membase + UART011_CR );

  /*Flush fifo*/
  writel( 0, m_bcm2835_raw_uart_port->membase + UART011_LCRH );

  /*Set RX FIFO threshold to lowest and TX FIFO threshold to mid*/
  writel( UART011_IFLS_RX1_8 | UART011_IFLS_TX4_8, m_bcm2835_raw_uart_port->membase + UART011_IFLS );

  /*enable RX and TX*/
  uart_cr |= UART011_CR_RXE | UART011_CR_TXE ;
  writel( uart_cr, m_bcm2835_raw_uart_port->membase + UART011_CR );

  /*Enable fifo and set to 8N1*/
  writel( UART01x_LCRH_FEN | UART01x_LCRH_WLEN_8, m_bcm2835_raw_uart_port->membase + UART011_LCRH );

  /*Enable UART*/
  uart_cr |= UART01x_CR_UARTEN ;
  writel( uart_cr, m_bcm2835_raw_uart_port->membase + UART011_CR );

  /*Configure interrupts*/
  writel( UART011_OEIM | UART011_BEIM | UART011_FEIM | UART011_RTIM | UART011_RXIM, m_bcm2835_raw_uart_port->membase + UART011_IMSC );


  m_bcm2835_raw_uart_port->rxbuf.head = m_bcm2835_raw_uart_port->rxbuf.tail = 0;

out:
  if( ret < 0 )
  {
    clk_disable( m_bcm2835_raw_uart_port->clk );
  }

  return ret;
}



/*!
 ******************************************************************************
 * @brief Reset and disable UART
 *
**/
static void bcm2835_raw_uart_reset(void)
{
  unsigned long uart_cr;

  /*If uart is enabled, wait until it is not busy*/
  while( (readl(m_bcm2835_raw_uart_port->membase + UART011_CR) & UART01x_CR_UARTEN) && (readl(m_bcm2835_raw_uart_port->membase + UART01x_FR) & UART01x_FR_BUSY) )
  {
    schedule();
  }

  uart_cr = readl( m_bcm2835_raw_uart_port->membase + UART011_CR );
  uart_cr &= ~(UART011_CR_OUT2 | UART011_CR_OUT1 | UART011_CR_DTR | UART01x_CR_IIRLP | UART01x_CR_SIREN); /*Set all RO bit to 0*/

  /*Disable UART*/
  uart_cr &= ~(UART01x_CR_UARTEN);
  writel( uart_cr, m_bcm2835_raw_uart_port->membase + UART011_CR );

  /*Flush fifo and set to 8N1*/
  writel( UART01x_LCRH_WLEN_8, m_bcm2835_raw_uart_port->membase + UART011_LCRH );

  /*Disable RX and TX*/
  uart_cr &= ~(UART011_CR_TXE | UART011_CR_RXE);
  writel( uart_cr, m_bcm2835_raw_uart_port->membase + UART011_CR );
}



#ifdef PROC_DEBUG
/*!
 ******************************************************************************
 * @brief Show debug data in proc system
 *
 * @param m Filepointer
 * @param v Unused
 * @return 0
**/
static int bcm2835_raw_uart_proc_show(struct seq_file *m, void *v)
{
  seq_printf(m, "open_count=%d\n", m_bcm2835_raw_uart_port->open_count );
  seq_printf(m, "count_tx=%d\n", m_bcm2835_raw_uart_port->count_tx );
  seq_printf(m, "count_rx=%d\n", m_bcm2835_raw_uart_port->count_rx );
  seq_printf(m, "count_brk=%d\n", m_bcm2835_raw_uart_port->count_brk );
  seq_printf(m, "count_parity=%d\n", m_bcm2835_raw_uart_port->count_parity );
  seq_printf(m, "count_frame=%d\n", m_bcm2835_raw_uart_port->count_frame );
  seq_printf(m, "count_overrun=%d\n", m_bcm2835_raw_uart_port->count_overrun );
  seq_printf(m, "rxbuf_size=%d\n", CIRC_CNT(m_bcm2835_raw_uart_port->rxbuf.head, m_bcm2835_raw_uart_port->rxbuf.tail, CIRCBUF_SIZE) );
  seq_printf(m, "rxbuf_head=%d\n", m_bcm2835_raw_uart_port->rxbuf.head );
  seq_printf(m, "rxbuf_tail=%d\n", m_bcm2835_raw_uart_port->rxbuf.tail );
  return 0;
}



/*!
 ******************************************************************************
 * @brief Open function for the proc system
 *
 * @param inode Unuses
 * @param file Filepointer
 * @return 0 or error
**/
static int bcm2835_raw_uart_proc_open(struct inode *inode, struct  file *file)
{
  return single_open( file, bcm2835_raw_uart_proc_show, NULL );
}
#endif /*PROC_DEBUG*/



/*!
 ******************************************************************************
 * @brief Probe function of this driver
 *
 * @param pdev Pointer to platform device struct
 * @return 0 or error
**/
static int bcm2835_raw_uart_probe( struct platform_device *pdev )
{
  struct bcm2835_raw_uart_port_s *port = NULL;
  int ret = 0;
  struct resource *platform_resource;

  /*Allocate memory*/
  port = kzalloc( sizeof(struct bcm2835_raw_uart_port_s), GFP_KERNEL );
  if( !port )
  {
    ret = -ENOMEM;
    goto out;
  }

  /*Get clock*/
  port->clk = clk_get_sys( "dev:f1", NULL );
  if( IS_ERR(port->clk) )
  {
    printk( KERN_ERR "bcm2835_raw_uart: Unable to get device clock\n" );
    ret = PTR_ERR( port->clk );
    goto out_free;
  }

  /*Get resource*/
  platform_resource = platform_get_resource( pdev, IORESOURCE_MEM, 0 );
  if( !platform_resource )
  {
    printk( KERN_ERR "bcm2835_raw_uart: Unable to get platform resource\n" );
    ret = -ENXIO;
    goto out_free_clk;
  }

  /*Create character device*/
  ret = alloc_chrdev_region( &port->devnode, 0, 1, DRVNAME );
  if( ret )
  {
    printk( KERN_ERR "bcm2835_raw_uart: Unable to get device number region\n" );
    goto out_free_clk;
  }
  cdev_init( &port->cdev, &m_bcm2835_raw_uart_fops );
  port->cdev.owner = THIS_MODULE;
  ret = cdev_add( &port->cdev, port->devnode, 1 );
  if( ret )
  {
    printk(KERN_ERR "bcm2835_raw_uart: Unable to add driver\n");
    goto out_unregister_chrdev_region;
  }

  port->class = class_create( THIS_MODULE, DRVNAME );
  if( IS_ERR(port->class) )
  {
    ret = -EIO;
    printk(KERN_ERR "bcm2835_raw_uart: Unable to register driver class\n");
    goto out_cdev_del;
  }

  device_create( port->class, NULL, MKDEV(MAJOR(port->devnode), MINOR(port->devnode)), "%s", DRVNAME );


  port->mapbase = platform_resource->start;
  port->membase = ioremap( platform_resource->start, resource_size(platform_resource) );
  port->dev = get_device( &pdev->dev );
  port->irq = platform_get_irq( pdev, 0 );

  sema_init( &port->sem, 1 );
  spin_lock_init( &port->lock_tx );
  init_waitqueue_head( &port->readq );
  init_waitqueue_head( &port->writeq );

  port->rxbuf.buf = kmalloc( CIRCBUF_SIZE, GFP_KERNEL );

  platform_set_drvdata( pdev, NULL );
  m_bcm2835_raw_uart_port = port; /*Save pointer to the struct with the uart information.*/

  bcm2835_raw_uart_reset();

#ifdef PROC_DEBUG
  proc_create( DRVNAME, 0444, NULL, &m_bcm2835_raw_uart_proc_fops );
#endif

  printk( KERN_INFO "bcm2835_raw_uart: Driver successfully loaded for uart0_base=0x%08lx, uart0_irq=%d.\n", uart0_base, uart0_irq );

  return 0;

out_cdev_del: /*Delete device*/
  m_bcm2835_raw_uart_port = NULL;
  cdev_del( &port->cdev );

out_unregister_chrdev_region: /*Unregister the character device*/
  unregister_chrdev_region( port->devnode, 1 );

out_free_clk: /*Free the clock.*/
  clk_put( port->clk );

out_free: /*Free the allocated memory*/
  kfree( port );

out:  /*No memory allocated -> no need to free something.*/
  return ret;
}



/*!
 ******************************************************************************
 * @brief Remove function of the driver
 *
 * @param pdev Pointer to the platform device struct
 * @return 0 or error
**/
static int bcm2835_raw_uart_remove( struct platform_device *pdev )
{
#ifdef PROC_DEBUG
  remove_proc_entry( DRVNAME, NULL );
#endif

  if( m_bcm2835_raw_uart_port != NULL )
  {
    device_destroy( m_bcm2835_raw_uart_port->class, MKDEV(MAJOR(m_bcm2835_raw_uart_port->devnode), MINOR(m_bcm2835_raw_uart_port->devnode)) );
    class_destroy( m_bcm2835_raw_uart_port->class );
    cdev_del( &m_bcm2835_raw_uart_port->cdev );
    unregister_chrdev_region( m_bcm2835_raw_uart_port->devnode, 1 );
    clk_put( m_bcm2835_raw_uart_port->clk );
    kfree( m_bcm2835_raw_uart_port->rxbuf.buf );
    kfree( m_bcm2835_raw_uart_port );

    m_bcm2835_raw_uart_port = NULL;

    printk( KERN_INFO "bcm2835_raw_uart: successfully removed platform device\n" );

    /*The driver core clears the driver data to NULL.*/
    return 0;
  }

  m_bcm2835_raw_uart_port = NULL;

  printk( KERN_ERR "bcm2835_raw_uart: Unable to remove platform device\n" );
  return -EFAULT;

}

static struct resource bcm2835_raw_uart_resources[2];

static struct platform_device bcm2709_raw_uart_device = {
    .name = MODNAME,
    .id = 0,
    .resource = bcm2835_raw_uart_resources,
    .num_resources = ARRAY_SIZE(bcm2835_raw_uart_resources),
};

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,3,0)
static int __init bcm2709_init_clocks(void)
{
  struct clk *clk;
  int ret = 0;

  clk = clk_get_sys("dev:f1", NULL);
  if(IS_ERR(clk))
  {
    clk = clk_get_sys("uart0_clk", NULL);
    if(IS_ERR(clk))
    {
      clk = clk_register_fixed_rate(NULL, "uart0_clk", NULL, CLK_IS_ROOT, UART0_CLK_RATE);
      if(IS_ERR(clk))
        pr_err("uart0_clk not registered\n");
    }

    ret = clk_register_clkdev(clk, NULL, "dev:f1");
    if(ret)
      pr_err("uart0_clk alias not registered\n");
  }

  return ret;
}
#endif

/*!
 ******************************************************************************
 * @brief Init function of the driver
 *
 * @return 0 or error
**/
static int __init bcm2835_raw_uart_init(void)
{
  int ret;

  #if LINUX_VERSION_CODE >= KERNEL_VERSION(4,3,0)
  bcm2709_init_clocks();
  #endif

  // dynamic setup of bcm2835_raw_uart_resources
  bcm2835_raw_uart_resources[0].start = uart0_base;       // e.g. 0x3f201000
  bcm2835_raw_uart_resources[0].end = uart0_base + 0xfff; // e.g. 0x3f201fff
  bcm2835_raw_uart_resources[0].flags = IORESOURCE_MEM;
  bcm2835_raw_uart_resources[0].name = MODNAME;
  bcm2835_raw_uart_resources[1].start = uart0_irq;
  bcm2835_raw_uart_resources[1].end = uart0_irq;
  bcm2835_raw_uart_resources[1].flags = IORESOURCE_IRQ;
  bcm2835_raw_uart_resources[1].name = MODNAME;

  ret = platform_device_register( &bcm2709_raw_uart_device );
  if( ret )
  {
    printk(KERN_ERR "bcm2835_raw_uart: Failed to register platform device (%i)\n", ret );
    goto out;
  }

  ret = platform_driver_register( &m_bcm2835_raw_uart_driver );
  if( ret )
  {
    printk(KERN_ERR "bcm2835_raw_uart: Failed to register platform driver (%i)\n", ret );
    goto out;
  }

out:
  return ret;
}



/*!
 ******************************************************************************
 * @brief Exit function of the driver
 *
**/
static void __exit bcm2835_raw_uart_exit(void)
{
    platform_driver_unregister( &m_bcm2835_raw_uart_driver );
    platform_device_unregister( &bcm2709_raw_uart_device );
}

module_init( bcm2835_raw_uart_init );
module_exit( bcm2835_raw_uart_exit );

static const struct of_device_id bcm2835_raw_uart_of_match[] = {
	{.compatible = "brcm,bcm2835-raw-uart",},
	{ /* sentinel */ },
};

MODULE_DEVICE_TABLE(of, bcm2835_raw_uart_of_match);

MODULE_ALIAS("platform:bcm2835-raw-uart");

MODULE_DESCRIPTION( "eQ-3 raw BCM2835 uart driver" );
MODULE_LICENSE( "GPL" );
MODULE_AUTHOR( "eQ-3 Entwicklung GmbH" );
MODULE_VERSION( "1.12" );
