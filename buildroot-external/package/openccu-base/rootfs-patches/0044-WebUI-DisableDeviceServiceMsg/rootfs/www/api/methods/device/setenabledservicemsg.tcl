##
# Device.setEnabledServiceMsg
# Legt fest, ob das Gerät Servicemeldungen erzeugt oder nicht
#
# Parameter:
#   id:        [string] Id des Gerätes
#   isEnabled: [bool]   Gerät erzeugt Servicemeldungen (true) oder nicht (false)
##

set script {
  boolean bResult = false;
  object oDevice = dom.GetObject(id);
  if(oDevice != null)
  {
    boolean bEnabled = false;
    if(isEnabled == "true")
    {
      bEnabled = true;
    }

    if(oDevice.MetaData("enabledServiceMsg") == null)
    {
      if(bEnabled == false)
      {
        oDevice.AddMetaData("enabledServiceMsg", bEnabled);
      }
    }
    else
    {
      oDevice.MetaData("enabledServiceMsg", bEnabled);
    }
    bResult = true;

    object oLastAlarmDP = null;
    object oServices = dom.GetObject(ID_SERVICES);
    string sAID;
    foreach( sAID, oServices.EnumIDs() )
    {
      object oAlarm = dom.GetObject(sAID);
      if(oAlarm != null)
      {
        object oAlarmTrigger = dom.GetObject(oAlarm.AlTriggerDP());
        if(oAlarmTrigger != null)
        {
          object oChannel = dom.GetObject(oAlarmTrigger.Channel());
          if(oChannel != null)
          {
            var device = oChannel.Device();
            if(device == oDevice.ID())
            {
              oAlarm.Enabled(bEnabled);
              oLastAlarmDP = oAlarm;
            }
          }
        }
      }
    }

    if(oLastAlarmDP != null)
    {
      oLastAlarmDP.State(oLastAlarmDP.Value());
      dom.RTUpdate(0);
    }
  }
  Write(bResult);
}

set result [hmscript $script args]

if {("true" == $result) || ("false" == $result)} then {
  jsonrpc_response $result
} else {
  jsonrpc_error 500 "homematic script error"
}
