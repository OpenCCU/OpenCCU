##
# Device.get
# Liefert Detailinformationen zu einem Gerät.
#
# Parameter:
#   id: [string] Id des Geräts
#
# Rückgabewert: [object]
#   Folgende Felder sind definiert:
#     name:      [string] Bezeichnung des Geräts
#     address:   [string] Seriennummer des Geräts
#     interface: [string] Bezeichnung der Schnittstelle, über die das Gerät angeschlossen ist
#     type:      [string] Bezeichnung des Gerätetyps
#     channels:  [array]  Liste mit den IDs (Zeichenketten) der Kanäle
##

set script {
  var MODE_DEFAULT = "MODE_DEFAULT";
  var MODE_AES     = "MODE_AES";

  var CATEGORY_NONE     = "CATEGORY_NONE";
  var CATEGORY_SENDER   = "CATEGORY_SENDER";
  var CATEGORY_RECEIVER = "CATEGORY_RECEIVER";

  var device = dom.GetObject(id);
  if (device)
  {
    var interface = dom.GetObject(device.Interface());

    Write("ID {" # device.ID() # "}");
    Write(" NAME {" # device.Name() # "}");
    Write(" ADDRESS {" # device.Address() # "}"); 
    Write(" INTERFACE {"# interface.Name() # "}"); 
!   Write(" DEVICE_TYPE {"# device.HssType() # "}"); 
    Write(" DEVICE_TYPE {"# device.Label() # "}");
    Write(" GROUP_ONLY {"# device.MetaData("operateGroupOnly") # "}");
 
    Write(" SERVICE_MSG {");
    if (device.MetaData("enabledServiceMsg") == null) {
      Write("true");
    } else {
      Write(device.MetaData("enabledServiceMsg"));
    }
    Write("}");
 
    Write(" CHANNELS {"); 
    if (device.TypeName() == "DEVICE")
    {
      var first = true;
      string channelId;

      foreach(channelId, device.Channels())
      {
        var channel = dom.GetObject(channelId);
        if (false == channel.Internal())
        {
          if (true != first) { Write(" "); } else { first = false; }
          Write("{");
          
          var readable  = false;
          var writable  = false;
          var eventable = false;
          var logable   = false;
      
          string dpId;
          foreach (dpId, channel.DPs())
          {
            var dp         = dom.GetObject(dpId);
            var operations = dp.Operations();
        
            if (!dp.Internal())
            {
              logable = true;
              if (OPERATION_READ  & operations) { readable  = true; }
              if (OPERATION_WRITE & operations) { writable  = true; }
              if (OPERATION_EVENT & operations) { eventable = true; }
            }
          }
          
          var isUsable = false;
          if (channel.UserAccessRights(iulOtherThanAdmin) == iarFullAccess)
          {
            isUsable = true;
          }
        
          var category = CATEGORY_NONE;
          if (channel.ChnDirection() == 1) { category = CATEGORY_SENDER; }
          if (channel.ChnDirection() == 2) { category = CATEGORY_RECEIVER; }
        
          var mode = MODE_DEFAULT;
          if (channel.ChnAESActive())
          {
            mode = MODE_AES;
          }
              
          var isAesAvailable = false;
          if (channel.ChnAESOperation() > 0)
          {
            isAesAvailable = true;
          }
        
          var isVirtual = false;
          if (channel.ChannelType() == 29)
          {
            isVirtual = true;
          }
        
          Write("ID {" # channelId # "}");
          Write(" NAME {" # channel.Name() # "}");
          Write(" ADDRESS {" # channel.Address() # "}");
          Write(" DEVICE {" # channel.Device() # "}");
          Write(" INDEX {" # channel.ChnNumber() # "}");
          Write(" GROUP_PARTNER_ID {" # channel.ChnGroupPartnerId() # "}");
          Write(" READY_CONFIG {" # channel.ReadyConfig() # "}");
          Write(" MODE {" # mode # "}");
          Write(" CATEGORY {" # category # "}");
          Write(" USABLE {" # isUsable # "}");
          Write(" LOGGED {" # channel.ChnArchive() # "}");
          Write(" VISIBLE {" # channel.Visible() # "}");
          Write(" LOGABLE {" # logable # "}");
          Write(" READABLE {" # readable # "}");
          Write(" WRITABLE {" # writable # "}");
          Write(" EVENTABLE {" # eventable # "}");
          Write(" AES_AVAILABLE {" # isAesAvailable # "}");
          Write(" VIRTUAL {" # isVirtual # "}");
          Write(" CHANNEL_TYPE {" # channel.HssType() # "}");
          Write("}");
        }
      }
    }
    Write("}");
  }
}

array set device [hmscript $script args]

if { ![info exists device(NAME)] } then {
	jsonrpc_error 501 "device not found"
}

set result "\{"

append result "\"id\":[json_toString $device(ID)]"
append result ",\"name\":[json_toString $device(NAME)]"
append result ",\"address\":[json_toString $device(ADDRESS)]"
append result ",\"interface\":[json_toString $device(INTERFACE)]"
append result ",\"type\":[json_toString $device(DEVICE_TYPE)]"
append result ",\"operateGroupOnly\":[json_toString $device(GROUP_ONLY)]"
append result ",\"enabledServiceMsg\":[json_toString $device(SERVICE_MSG)]"

set first 1
append result ",\"channels\":\["
foreach _channel $device(CHANNELS) {
	array set channel $_channel
	if {1 != $first} then { append result "," } else { set first 0 }
	
	set partnerId $channel(GROUP_PARTNER_ID)
	if {"65535" == $partnerId} then { set partnerId "" }
	
	append result "\{"
	append result "\"id\":[json_toString $channel(ID)]"
	append result ",\"name\":[json_toString $channel(NAME)]"
	append result ",\"address\":[json_toString $channel(ADDRESS)]"
	append result ",\"deviceId\":[json_toString $channel(DEVICE)]"
	append result ",\"index\":$channel(INDEX)"
	append result ",\"partnerId\":[json_toString $partnerId]"
  append result ",\"mode\":[json_toString $channel(MODE)]"
	append result ",\"category\":[json_toString $channel(CATEGORY)]"
  append result ",\"isReady\":$channel(READY_CONFIG)"
	append result ",\"isUsable\":$channel(USABLE)"
	append result ",\"isVisible\":$channel(VISIBLE)"
	append result ",\"isLogged\":$channel(LOGGED)"
	append result ",\"isLogable\":$channel(LOGABLE)"
	append result ",\"isReadable\":$channel(READABLE)"
	append result ",\"isWritable\":$channel(WRITABLE)"
	append result ",\"isEventable\":$channel(EVENTABLE)"
	append result ",\"isAesAvailable\":$channel(AES_AVAILABLE)"
	append result ",\"isVirtual\":$channel(VIRTUAL)"
	append result ",\"channelType\":[json_toString $channel(CHANNEL_TYPE)]"
	append result "\}"
	
	array_clear channel
}
append result "\]"

append result "\}"

jsonrpc_response $result