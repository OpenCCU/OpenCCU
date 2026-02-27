##
# Device.listProgramIds
# Liefert eine Liste der Ids aller Programme, die mindestens einen
# Kanal des Geräts verwenden.
#
# Parameter:
#   id: [string] Id des Geräts
#
# Rückgabewert: [array]
#  Die Ids der entsprechenden Programme
##

set script {
  var device = dom.GetObject(id);
  var first  = true;

  string channelId;
  foreach(channelId, device.Channels())
  {
    var channel = dom.GetObject(channelId);
    if (false == channel.Internal())
    {
      string programId;
      foreach(programId, channel.ChnEnumDPUsagePrograms())
      {
        if (true != first) { Write(" "); } else { first = false; }
        Write("{" # programId # "}");
      }
    }
  }
}

set ids [rmDoublePrgIds [hmscript $script args]]

set result "\["
set first 1

foreach id $ids {
  if {$first != 1} then { append result ","} else { set first 0 }
  append result [json_toString $id ]
}

append result "\]"

jsonrpc_response $result