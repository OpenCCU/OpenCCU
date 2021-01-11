##
# CCU.systemLanguage
# Setzt die Systemsprache der CCU in /etc/config/systemLanguage
#
# Parameter:
#  lang         : [string] Die gewaehlte Systemsprache (de, en)
#
# R�ckgabewert: immer true
##

catch {exec echo $args(lang) > /etc/config/systemLanguage}

jsonrpc_response true
