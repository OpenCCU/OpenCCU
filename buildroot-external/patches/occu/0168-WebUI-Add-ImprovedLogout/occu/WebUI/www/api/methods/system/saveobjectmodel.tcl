##
# system.saveObjectModel
# Speichert das Object Model
#
# Parameter:
#   keine
#
# Rückgabewert: true
##


# call system.Save() async to keep WebUI active
set script {
  system.Exec("echo 'load tclrega.so; rega system.Save()' | /bin/tclsh &");
  Write("true");
}

jsonrpc_response [hmscript $script args]