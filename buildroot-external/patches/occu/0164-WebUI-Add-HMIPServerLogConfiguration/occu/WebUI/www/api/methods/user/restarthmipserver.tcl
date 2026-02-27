##
# User.restartHmIPServer
# Restartet den HMIPServer
#
# Parameter:
#   keine
#
# Rückgabewert: true

exec /usr/bin/monit restart HMIPServer >/dev/null &
jsonrpc_response true
