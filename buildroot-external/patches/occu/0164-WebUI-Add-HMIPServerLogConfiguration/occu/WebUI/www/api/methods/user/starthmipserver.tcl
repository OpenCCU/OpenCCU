##
# User.startHmIPServer
# Startet den HMIPServer
#
# Parameter:
#   keine
#
# R�ckgabewert: true

exec monit start HMIPServer >/dev/null &
jsonrpc_response true
