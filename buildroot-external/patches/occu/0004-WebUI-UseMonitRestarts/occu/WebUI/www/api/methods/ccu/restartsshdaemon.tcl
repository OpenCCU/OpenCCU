##
# CCU.restartSSHDaemon
# Restartet den SSH-Daemon
#
# Parameter: kein
#
# R�ckgabewert: kein
##

catch {exec /usr/bin/monit restart sshd}
