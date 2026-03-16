#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010,SC3014 source=/dev/null

# source all data from /var/hm_mode
[[ -r /var/hm_mode ]] && . /var/hm_mode

# Command run on power loss
#: ${POWER_LOSS_CMD:=/sbin/poweroff}
: "${POWER_LOSS_CMD:=/bin/triggerAlarm.tcl 'Power Loss' 'WatchDog: picoups-powerloss' true}"

# File descriptors
: "${GPIO_PULSE:=22}"
: "${GPIO_CLOCK:=27}"

# Debounce time in while loop
: "${DEBOUNCE_TIME:=0.3s}"

## Initialize GPIO file descriptor
# $1: File descriptor Value: decimal
# $2: Direction       Value: in|out
initFD() {
    eval "[ -e /sys/class/gpio/gpio\$$1/direction ]" || {
        eval "echo \$$1 > /sys/class/gpio/export || exit 1"
        sleep 0.1s
    }
    eval "echo $2 > /sys/class/gpio/gpio\$$1/direction || exit 1"
}

## Set GPIO Value
# $1: File descriptor Value: decimal
# $2: Value           Value: 0|1
setFDvalue() {
    eval "echo $2 > /sys/class/gpio/gpio\$$1/value || exit 1"
}

## get GPIO Value
# $1: File descriptor       Value: decimal
# $2: Target variable name  Value: 0|1
getFDvalue() {
    eval "read $2 < /sys/class/gpio/gpio\$$1/value || exit 1"
}

# Initialize GPIO_CLOCK file descriptor
initFD GPIO_CLOCK in

# Initialize GPIO_PULSE file descriptor
initFD GPIO_PULSE out
setFDvalue GPIO_PULSE 1

# Listen for falling edge of GPIO_CLOCK
getFDvalue GPIO_CLOCK GPIO_CLOCK_VALUE

while getFDvalue GPIO_CLOCK GPIO_CLOCK_VALUE_NEW; do
    if [[ ${GPIO_CLOCK_VALUE_NEW} -lt ${GPIO_CLOCK_VALUE} ]]; then

        # Debouncing in software
        sleep "$DEBOUNCE_TIME"

        # Save state of GPIO_PULSE
        getFDvalue GPIO_PULSE GPIO_PULSE_VALUE

        # Invert GPIO_PULSE_VALUE
        [[ ${GPIO_PULSE_VALUE:-0} == 0 ]] && GPIO_PULSE_VALUE=1 || GPIO_PULSE_VALUE=0

        # Set GPIO_PULSE_VALUE to low before switching to input mode
        setFDvalue GPIO_PULSE 0

        # Switch GPIO_PULSE to input
        initFD GPIO_PULSE in

        # Check for power loss (=0)
        getFDvalue GPIO_PULSE POWER_STATE
        [[ 0 -eq "${POWER_STATE}" ]] && eval "${POWER_LOSS_CMD}" &

        # Set GPIO_PULSE to flipped state
        initFD GPIO_PULSE out
        setFDvalue GPIO_PULSE "$GPIO_PULSE_VALUE"
    fi

    # Save new GPIO clock value for while loop comparison
    GPIO_CLOCK_VALUE=$GPIO_CLOCK_VALUE_NEW
done

# Remove GPIO file descriptors
echo "$GPIO_PULSE" > /sys/class/gpio/unexport
echo "$GPIO_CLOCK" > /sys/class/gpio/unexport
