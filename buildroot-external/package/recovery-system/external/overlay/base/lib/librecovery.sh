#!/bin/sh
# shellcheck shell=dash disable=SC2169,SC3010
#
# Shared helpers for the CGI scripts and fwinstall.sh of the recovery system
#

# lock directory held by the one recovery action that is allowed to modify
# the storage or reboot the system at a time (firmware update, resets,
# backup creation/restore, storage check, system clone, reboots)
RECOVERY_LOCK=/tmp/.recoveryActionLock

# atomically claim the recovery action lock (mkdir either creates the
# directory or fails if it already exists). Returns non-zero if another
# action is currently holding the lock.
recovery_lock() {
  mkdir "${RECOVERY_LOCK}" 2>/dev/null
}

# release the recovery action lock
recovery_unlock() {
  rmdir "${RECOVERY_LOCK}" 2>/dev/null
  return 0
}

# check if another recovery action is currently holding the lock
recovery_locked() {
  [[ -d "${RECOVERY_LOCK}" ]]
}

# protect the recovery actions against cross-site request forgery (CSRF):
# only accept POST requests whose Origin (or Referer as a fallback) matches
# the host the recovery system is accessed with. Requests without both
# headers are rejected as well, since old browsers omit the Origin header
# for form submissions and a foreign page can suppress the Referer.
# Scripted requests (e.g. curl) therefore have to send a matching Origin
# header (curl -H "Origin: http://<host>").
recovery_check_request() {
  if [[ "${REQUEST_METHOD}" != "POST" ]]; then
    echo "ERROR: invalid request method (${REQUEST_METHOD:-none})"
    return 1
  fi

  req_source="${HTTP_ORIGIN:-${HTTP_REFERER}}"

  # extract the host[:port] part of the origin/referer URL
  req_host="${req_source#*://}"
  req_host="${req_host%%/*}"
  if [[ -z "${req_source}" ]] || [[ "${req_host}" == "${req_source}" ]] ||
     [[ -z "${HTTP_HOST}" ]] || [[ "${req_host}" != "${HTTP_HOST}" ]]; then
    echo "ERROR: cross-site request rejected"
    return 1
  fi

  return 0
}

# BusyBox ash does not run the EXIT trap when terminated by a signal (e.g.
# SIGTERM sent by lighttpd if the client disconnects), which would leave a
# stale lock behind. Exit explicitly on these signals so that the EXIT trap
# releases the lock. The signal traps stay active if a script replaces its
# EXIT trap later on.
recovery_trap_signals() {
  trap 'exit 1' HUP INT QUIT TERM
}

# check the request and claim the recovery action lock for a CGI script.
# The lock is released when the script exits unless the script calls
# recovery_reboot (which keeps it until the system is down).
recovery_cgi_begin() {
  recovery_check_request || exit 1

  if ! recovery_lock; then
    echo "ERROR: another recovery action (e.g. firmware update) is currently running"
    exit 1
  fi
  trap recovery_unlock EXIT
  recovery_trap_signals
}

# reboot the system while keeping the recovery action lock so that no other
# recovery action can be started until the system is down. If the reboot
# fails, the lock is released and an error is returned.
recovery_reboot() {
  trap - EXIT
  if ! /sbin/reboot; then
    recovery_unlock
    echo "ERROR: reboot failed"
    return 1
  fi
  return 0
}
