##
# User.restartHmIPServer
# Restartet den HMIPServer
#
# Parameter:
#   keine
#
# R�ckgabewert: true

#exec /etc/init.d/S62HMServer start &
exec monit restart HMIPServer >/dev/null &
jsonrpc_response true
