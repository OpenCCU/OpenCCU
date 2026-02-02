#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010 source=/dev/null

# source all data from /var/hm_mode
[[ -r /var/hm_mode ]] && . /var/hm_mode

# Command run on power loss
: "${POWER_LOSS_CMD:=/bin/triggerAlarm.tcl 'Power Loss' 'WatchDog: strompi2-powerloss' true}"
: "${POWER_RETURN_CMD:=/bin/triggerAlarm.tcl 'Power Restored' 'WatchDog: strompi2-powerrestore' true}"

# File descriptors
: "${GPIO_POWER:=21}"

# Debounce time in while loop
: "${DEBOUNCE_TIME:=0.3s}"

# source the content of /etc/config/strompi2 which
# can the override certain setting variables above
[[ -r /etc/config/strompi2 ]] && . /etc/config/strompi2

# Initialize GPIO_POWER file descriptor
/usr/bin/gpio -g mode "${GPIO_POWER}" in

POWER_STATE=0
while true; do
  POWER_STATE_NEW=$(/usr/bin/gpio -g read "${GPIO_POWER}")
  if [[ "${POWER_STATE_NEW}" != "${POWER_STATE}" ]]; then

    # execute POWER_LOSS_CMD in case power state is lost
    if [[ "${POWER_STATE_NEW}" -eq 1 ]]; then
      eval "${POWER_LOSS_CMD}" &
    else
      eval "${POWER_RETURN_CMD}" &
    fi

    # save POWER_STATE for next iteration
    POWER_STATE=${POWER_STATE_NEW}

  fi

  # Debouncing in software
  sleep "${DEBOUNCE_TIME}"
done
