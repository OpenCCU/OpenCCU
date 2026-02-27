##
# Device.listAllDetail
# Liefert die Detaildaten aller fertig konfigurierten Geräte.
#
# Parameter:
#   <keine>
#
# Rückgabewert: [array]
#   Jedes Element ist eine Zeichenkette, welche die Id des Geräts symbolisiert.
##

set deviceDescrScript {
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
    Write(" READY_CONFIG {" # device.ReadyConfig() # "}");

    if (device.MetaData("operateGroupOnly") == null) {
      device.AddMetaData("operateGroupOnly", false);
    }

    Write(" GROUP_ONLY {"# device.MetaData("operateGroupOnly") # "}");
    Write(" CHANNELS {");

    var first = true;
    string channelId;
    boolean noMoreDaliChannels = false;
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
        if ((channel.ChannelType() == 29) || (channel.Label() == "HmIP-RCV-50"))
        {
          isVirtual = true;
        }

        string chnType = channel.HssType();
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
        Write(" CHANNEL_TYPE {" # chnType # "}");
        Write(" CHANNEL_NAME {" # channel.Label() # "}");

        ! BLIND_* is necessary e. g. the HmIPW-DRBL4, which can be used as a BLIND or a SHUTTER. The metadata channelMode determines the current state.

        if ( (chnType == "MULTI_MODE_INPUT_TRANSMITTER") || (chnType == "BLIND_TRANSMITTER") || (chnType == "BLIND_VIRTUAL_RECEIVER") ) {
          object chnAddress = dom.GetObject(channel.Address());
          if (chnAddress) {
            string modeMultiChannel = chnAddress.MetaData('channelMode');
            if (modeMultiChannel) {
              Write(" MODE_MULTI_MODE_CHANNEL {" # modeMultiChannel # "}");
            } else {
              Write(" MODE_MULTI_MODE_CHANNEL {--}");
            }
          } else {
            string modeMultiChannel = channel.MetaData('channelMode');
            if (modeMultiChannel) {
              Write(" MODE_MULTI_MODE_CHANNEL {" # modeMultiChannel # "}");
            } else {
              Write(" MODE_MULTI_MODE_CHANNEL {--}");
            }
          }
        }

        if ((channel.Label() == "HmIP-DRG-DALI") && (chnType == "UNIVERSAL_LIGHT_RECEIVER")) {
          integer maxCap = channel.MetaData('maxCap');
          if (maxCap) {
            Write(" DALI_MAX_CAPABILITIES {" # maxCap # "}");
          } else {
            channel.MetaData("maxCap","--");
            Write(" DALI_MAX_CAPABILITIES {--}");
          }
        }

        if (((channel.Label() == "HmIP-FALMOT-C8") || (channel.Label() == "HmIP-FALMOT-C12")) && (chnType == "CLIMATECONTROL_FLOOR_TRANSCEIVER")) {
          integer chnActive = channel.MetaData('chnActive');

          if (chnActive) {
            Write(" FALMOT_CHN_ACTIVE {" # chnActive # "}");
          } else {
            channel.AddMetaData("chnActive", "false");
            Write(" FALMOT_CHN_ACTIVE {false}");
          }
        }

        Write("}");
      }
    }
    Write("}");
  }
}

set deviceIdsScript {
  string id;
  boolean first = true;
  foreach(id, root.Devices().EnumIDs())
  {
    var device = dom.GetObject(id);
    if (true == device.ReadyConfig() && dom.GetObject(device.Interface()))
    {
      if (true != first) { Write(" "); } else { first = false; }
    Write("{" # id # "}");
    }
  }
}



# exec echo "Start devicelistdetail: " > /tmp/devicelistdetail.log

set deviceIds [hmscript $deviceIdsScript args]

#foreach id $deviceIds {
#  exec echo "Device: $id" >> /tmp/log_wowi
#  exec echo $deviceDescr >> /tmp/log_wowi
#}

set result "\["
set first  1

foreach id $deviceIds {
  set myargs(id) $id
  set deviceStr [hmscript $deviceDescrScript myargs]

#
# ignore invalid devices: CCU1 ==> CCU2 (Wired) Gateway has no interface
  if {[catch {array set device $deviceStr}]} {
#    exec echo "Error setting device description: " $id >> /tmp/devicelistdetail.log
#    exec echo "Description: " $deviceStr >> /tmp/devicelistdetail.log
    continue
  }

#
# device attributes
#

  if { 1 != $first } then { append result "," } else { set first 0 }
  append result "\{"
  append result "\"id\":[json_toString $device(ID)]"
  append result ",\"name\":[json_toString $device(NAME)]"
  append result ",\"address\":[json_toString $device(ADDRESS)]"
  append result ",\"interface\":[json_toString $device(INTERFACE)]"
  append result ",\"type\":[json_toString $device(DEVICE_TYPE)]"
  append result ",\"operateGroupOnly\":[json_toString $device(GROUP_ONLY)]"
  append result ",\"isReady\":[json_toString $device(READY_CONFIG)]"


#
# channel
#
  set firstChannel 1
  append result ",\"channels\":\["
  foreach _channel $device(CHANNELS) {
    array set channel $_channel
    if {1 != $firstChannel} then { append result "," } else { set firstChannel 0 }

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

    if {[info exists channel(MODE_MULTI_MODE_CHANNEL)] == 1} {
     append result ",\"mode_multi_mode\":[json_toString $channel(MODE_MULTI_MODE_CHANNEL)]"
    }

    if {($channel(CHANNEL_NAME) == "HmIP-DRG-DALI") && ($channel(CHANNEL_TYPE) == "UNIVERSAL_LIGHT_RECEIVER")} {
      if {[info exists channel(DALI_MAX_CAPABILITIES)] == 1} {
       append result ",\"daliMaxCapabilities\":[json_toString $channel(DALI_MAX_CAPABILITIES)]"
      }
    }

    if {([string first "HmIP-FALMOT" $channel(CHANNEL_NAME)] != -1) && ($channel(CHANNEL_TYPE) == "CLIMATECONTROL_FLOOR_TRANSCEIVER")} {
      append result ",\"isChannelActive\":$channel(FALMOT_CHN_ACTIVE)"
    }

    append result "\}"

    array_clear channel
  }
  append result "\]"

  append result "\}"

}

append result "\]"

# exec echo "End devicelistdetail: " >> /tmp/devicelistdetail.log

jsonrpc_response $result