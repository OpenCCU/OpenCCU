##
# User.restartLighttpd
# Restartet den Lighttpd Webserver
#
# Parameter:
#   keine
#
# R�ckgabewert: true

exec /usr/bin/monit restart lighttpd

jsonrpc_response true
