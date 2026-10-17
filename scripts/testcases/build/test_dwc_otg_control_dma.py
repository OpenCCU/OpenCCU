#!/usr/bin/env python3
"""Exercise the actual patched dwc_otg helpers with a simulated DMA writer.

Usage: test_dwc_otg_control_dma.py /path/to/patched/linux
This host test checks buffer bounds and lifetime, not controller hardware.
Set CFLAGS='-fsanitize=address,undefined -g' to enable sanitizers.
"""
import argparse
import os
from pathlib import Path
import shlex
import subprocess
import tempfile

prefix = r'''
#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <errno.h>
#include <stdio.h>
#define ALIGN(x,a) (((x)+(a)-1)&~((__typeof__(x))(a)-1))
#define min(a,b) ((a)<(b)?(a):(b))
#define URB_ALIGNED_TEMP_BUFFER 0x00800000
#define URB_NO_TRANSFER_DMA_MAP 4
#define DMA_MAPPED 0x10000
typedef int gfp_t;
struct usb_hcd { bool dma; struct {bool uses_pio_for_control;} self; };
struct urb {
    void *transfer_buffer, *sg;
    int transfer_buffer_length, actual_length, num_sgs, pipe;
    unsigned int transfer_flags;
    bool in;
};
static int outstanding, fail_alloc, fail_map, mapped_length, maps, unmaps;
static bool owned_by_dma;
static size_t cache_alignment = 64;
static size_t dma_get_cache_alignment(void) {return cache_alignment;}
static bool hcd_uses_dma(struct usb_hcd *h) {return h->dma;}
static bool usb_pipecontrol(int pipe) {return pipe == 0;}
static bool usb_urb_dir_in(struct urb *u) {return u->in;}
static void *kmalloc(size_t n, gfp_t flags) {
    (void)flags;
    if (fail_alloc) return NULL;
    void *p = NULL;
    assert(posix_memalign(&p, cache_alignment, n) == 0);
    memset(p, 0xcc, n);
    outstanding++;
    return p;
}
static void kfree(void *p) {assert(!owned_by_dma); outstanding--; free(p);}
static int usb_hcd_map_urb_for_dma(struct usb_hcd *h, struct urb *u, gfp_t f) {
    (void)h; (void)f;
    maps++;
    if (fail_map) return -EAGAIN;
    mapped_length = u->transfer_buffer_length;
    owned_by_dma = true;
    u->transfer_flags |= DMA_MAPPED;
    return 0;
}
static void usb_hcd_unmap_urb_for_dma(struct usb_hcd *h, struct urb *u) {
    (void)h;
    if (!(u->transfer_flags & DMA_MAPPED)) return;
    assert(owned_by_dma);
    assert(u->transfer_buffer_length == mapped_length);
    owned_by_dma = false;
    u->transfer_flags &= ~DMA_MAPPED;
    unmaps++;
}
'''
tests = r'''
static void transfer(int length, int actual) {
    struct usb_hcd h = {.dma=true};
    unsigned char *p = malloc(length + 32);
    memset(p, 0xa5, length+32);
    struct urb u = {.transfer_buffer=p, .transfer_buffer_length=length, .in=true};
    assert(dwc_otg_map_urb_for_dma(&h, &u, 0) == 0);
    assert(u.transfer_buffer_length == length);
    assert(mapped_length == ((length+3)/4)*4);
    assert((u.transfer_buffer != p) == ((length%4)!=0));
    if (actual) memset(u.transfer_buffer, 0x42, ((actual+3)/4)*4);
    u.actual_length=actual;
    dwc_otg_unmap_urb_for_dma(&h, &u);
    assert(u.transfer_buffer == p && u.transfer_buffer_length == length);
    assert(!(u.transfer_flags & URB_ALIGNED_TEMP_BUFFER));
    for (int i=0;i<actual;i++) assert(p[i] == 0x42);
    if (length%4) for (int i=actual;i<length;i++) assert(p[i]==0xa5);
    for (int i=length;i<length+32;i++) assert(p[i] == 0xa5);
    assert(outstanding == 0);
    free(p);
}
int main(void) {
    int lengths[] = {1,2,3,4,7,8,18,63,64,65,255,65535};
    for (cache_alignment=32;cache_alignment<=128;cache_alignment*=2)
        for (size_t i=0;i<sizeof(lengths)/sizeof(*lengths);i++) {
            transfer(lengths[i],lengths[i]);
            transfer(lengths[i],0);
            transfer(lengths[i],1);
        }
    cache_alignment=64;
    struct usb_hcd h = {.dma=true};
    unsigned char original[50];
    memset(original,0xa5,sizeof(original));
    struct urb u = {.transfer_buffer=original,.transfer_buffer_length=18,.in=true};
    fail_alloc=1;
    int before=maps;
    assert(dwc_otg_map_urb_for_dma(&h,&u,0)==-ENOMEM);
    assert(maps==before && outstanding==0 && u.transfer_buffer==original);
    fail_alloc=0; fail_map=1; u.actual_length=18;
    assert(dwc_otg_map_urb_for_dma(&h,&u,0)==-EAGAIN);
    assert(outstanding==0 && u.transfer_buffer==original && u.transfer_flags==0);
    for (size_t i=0;i<sizeof(original);i++) assert(original[i]==0xa5);
    fail_map=0; u.actual_length=0;
    /* Unexpected oversized completion cannot overrun the caller's buffer. */
    assert(dwc_otg_map_urb_for_dma(&h,&u,0)==0);
    memset(u.transfer_buffer,0x42,20); u.actual_length=100;
    dwc_otg_unmap_urb_for_dma(&h,&u);
    for (int i=18;i<50;i++) assert(original[i]==0xa5);
    /* Cancellation/enqueue failure: no received bytes means no copy-back. */
    u.actual_length=0;
    assert(dwc_otg_map_urb_for_dma(&h,&u,0)==0);
    dwc_otg_unmap_urb_for_dma(&h,&u);
    dwc_otg_unmap_urb_for_dma(&h,&u);
    assert(outstanding==0);
    /* Other transfer types and ownership models retain the generic path. */
    for (int mode=0;mode<9;mode++) {
        u=(struct urb){.transfer_buffer=original,.transfer_buffer_length=18,.in=true};
        h=(struct usb_hcd){.dma=true};
        if (mode==0) u.in=false;
        if (mode==1) u.pipe=1;
        if (mode==2) u.transfer_flags=URB_NO_TRANSFER_DMA_MAP;
        if (mode==3) u.num_sgs=1;
        if (mode==4) u.sg=original;
        if (mode==5) h.dma=false;
        if (mode==6) h.self.uses_pio_for_control=true;
        if (mode==7) u.transfer_buffer_length=0;
        if (mode==8) u.transfer_buffer=NULL;
        void *saved=u.transfer_buffer;
        assert(dwc_otg_map_urb_for_dma(&h,&u,0)==0);
        assert(u.transfer_buffer==saved && outstanding==0);
        dwc_otg_unmap_urb_for_dma(&h,&u);
        assert(u.transfer_buffer==saved && outstanding==0);
    }
    printf("PASS: 108 transfer cases plus allocation/mapping failure, cancellation, copy bounds and scope checks (%d unmaps)\n",unmaps);
}
'''

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("kernel", type=Path, help="Patched Raspberry Pi kernel source")
    args = parser.parse_args()
    source = (args.kernel / "drivers/usb/host/dwc_otg/dwc_otg_hcd_linux.c").read_text()
    helpers = source[source.index("#define DWC_OTG_DMA_ALIGN"):source.index("/** @} */")]
    with tempfile.TemporaryDirectory(prefix="dwc-otg-dma-") as directory:
        src = Path(directory) / "test.c"
        binary = Path(directory) / "test"
        src.write_text(prefix + helpers + tests)
        command = shlex.split(os.environ.get("CC", "cc"))
        command += ["-std=gnu11", "-Wall", "-Wextra", "-Werror"]
        command += shlex.split(os.environ.get("CFLAGS", ""))
        subprocess.run(command + [str(src), "-o", str(binary)], check=True)
        subprocess.run([str(binary)], check=True)


if __name__ == "__main__":
    main()
