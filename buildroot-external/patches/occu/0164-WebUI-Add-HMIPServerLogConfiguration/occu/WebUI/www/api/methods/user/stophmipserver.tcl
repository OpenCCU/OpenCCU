##
# User.stopHmIPServer
# Stoppt den HMIPServer
#
# Parameter:
#   keine
#
# R�ckgabewert: true

exec monit stop HMIPServer >/dev/null &
jsonrpc_response true
