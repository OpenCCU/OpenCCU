##
# CCU.restartReGa
# Restartet ReGa
#
# Parameter: kein
#
# R�ckgabewert: kein
##

catch {exec /usr/bin/monit restart ReGaHss}

jsonrpc_response ""
