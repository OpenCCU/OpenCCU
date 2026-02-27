##
# CCU.setSystemLanguage
# Setzt die Systemsprache der CCU in /etc/config/systemLanguage
# und benennt die Namen aller Gewerke, Raeume und Standard-Systemvariablen
# in die jeweilige Sprache um.
#
# Parameter:
#  lang         : [string] Die gewaehlte Systemsprache (de, en)
#
# Rückgabewert: immer true
##

proc setSystemLanguage {a} {

  array set args $a

  # define rega script
  set script {

    string oID;
    string metaDataID = "trID";

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! Functions
    string funcDefault      = "funcLight;funcHeating;funcClimateControl;funcWeather;funcEnvironment;funcSecurity;funcLock;funcButton;funcCentral;funcEnergy";
    string funcTranslatedDE = "Licht;Heizung;Klima;Wetter;Umwelt;Sicherheit;Verschluss;Taster;Zentrale;Energiemanagement";
    string funcTranslatedEN = "Light;Heating;Climatic conditions;Weather;Environment;Security;Lock;Button;Central;Energy management";

    string funcTranslatedNew;
    string funcTranslatedOld;
    if(lang == "de") {
      funcTranslatedNew = funcTranslatedDE;
      funcTranslatedOld = funcTranslatedEN;
    } else {
      funcTranslatedNew = funcTranslatedEN;
      funcTranslatedOld = funcTranslatedDE;
    }

    object funcs = dom.GetObject(ID_FUNCTIONS);
    foreach(oID, funcs.EnumIDs()) {
      object oObj = dom.GetObject(oID);
      if(oObj) {
        string objName = oObj.Name();
        string trName = oObj.MetaData(metaDataID);

        integer idx = 0;
        string listEntry;
        foreach(listEntry, funcDefault.Split(";")) {
          if(trName && (trName == listEntry)) {
            string oldName = funcTranslatedOld.StrValueByIndex(";", idx);
            if(objName == oldName) {
              string newName = funcTranslatedNew.StrValueByIndex(";", idx);
              oObj.Name(newName);
            }
          } elseif((objName == listEntry) || (objName == "${"#listEntry#"}")) {
            string newName = funcTranslatedNew.StrValueByIndex(";", idx);
            oObj.Name(newName);
            oObj.AddMetaData(metaDataID, listEntry);
          }
          idx = idx + 1;
        }
      }
    }

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! Rooms
    string roomDefault      = "roomLivingRoom;roomKitchen;roomBedroom;roomChildrensRoom1;roomChildrensRoom2;roomOffice;roomBathroom;roomGarage;roomHWR;roomGarden;roomTerrace";
    string roomTranslatedDE = "Wohnzimmer;Küche;Schlafzimmer;Kinderzimmer 1;Kinderzimmer 2;Büro;Badezimmer;Garage;Hauswirtschaftsraum;Garten;Terrasse";
    string roomTranslatedEN = "Living room;Kitchen;Bed room;Children`s room 1;Children`s room 2;Home office;Bathroom;Garage;Utility room;Garden;Terrace";

    string roomTranslatedNew;
    string roomTranslatedOld;
    if(lang == "de") {
      roomTranslatedNew = roomTranslatedDE;
      roomTranslatedOld = roomTranslatedEN;
    } else {
      roomTranslatedNew = roomTranslatedEN;
      roomTranslatedOld = roomTranslatedDE;
    }

    object rooms = dom.GetObject(ID_ROOMS);
    foreach(oID, rooms.EnumIDs()) {
      object oObj = dom.GetObject(oID);
      if(oObj) {
        string objName = oObj.Name();
        string trName = oObj.MetaData(metaDataID);

        integer idx = 0;
        string listEntry;
        foreach(listEntry, roomDefault.Split(";")) {
          if(trName && (trName == listEntry)) {
            string oldName = roomTranslatedOld.StrValueByIndex(";", idx);
            if(objName == oldName) {
              string newName = roomTranslatedNew.StrValueByIndex(";", idx);
              oObj.Name(newName);
            }
          } elseif((objName == listEntry) || (objName == "${"#listEntry#"}")) {
            string newName = roomTranslatedNew.StrValueByIndex(";", idx);
            oObj.Name(newName);
            oObj.AddMetaData(metaDataID, listEntry);
          }
          idx = idx + 1;
        }
      }
    }

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! System variables
    string svDefault       = "sysVarAlarmZone1;sysVarPresence;sysVarAlarmMessages;sysVarServiceMessages;sysVarRainToday;sysVarRainYesterday";
    string svDefaultMsg    = "sysVarAlarmZone1Msg;sysVarPresenceMsg;sysVarAlarmMessagesCount;sysVarServiceMessagesCount;sysVarRainTodayDescr;sysVarRainYesterdayDescr";
    string svDefaultValue0 = "sysVarAlarmZone1NotTriggered;sysVarPresenceNotPresent";
    string svDefaultValue1 = "sysVarAlarmZone1Triggered;sysVarPresencePresent";

    string svTranslatedDE  = "Alarmzone 1;Anwesenheit;Alarmmeldungen;Servicemeldungen;Regen heute;Regen gestern";
    string svTranslatedEN  = "Alarm zone 1;Presence;Alarm messages;Service messages;Rain today;Rain yesterday";
    string svTranslatedMsgDE = "Alarmmeldung Alarmzone 1;Anwesenheit;Anzahl Alarmmeldungen;Anzahl Servicemeldungen;Regenmenge aktueller Tag;Regenmenge vorheriger Tag";
    string svTranslatedMsgEN = "Alarm message alarm zone 1;Presence;Number alarm messages;Number service messages;Rainfall current day;Rainfall previous day";
    string svTranslatedValue0DE = "nicht ausgelöst;nicht anwesend";
    string svTranslatedValue0EN = "not triggered;absent";
    string svTranslatedValue1DE = "ausgelöst;anwesend";
    string svTranslatedValue1EN = "triggered;present";

    string svTranslatedNew;
    string svTranslatedOld;
    string svTranslatedMsgNew;
    string svTranslatedMsgOld;
    string svTranslatedValue0New;
    string svTranslatedValue0Old;
    string svTranslatedValue1New;
    string svTranslatedValue1Old;

    if(lang == "de") {
      svTranslatedNew = svTranslatedDE;
      svTranslatedOld = svTranslatedEN;
      svTranslatedMsgNew = svTranslatedMsgDE;
      svTranslatedMsgOld = svTranslatedMsgEN;
      svTranslatedValue0New = svTranslatedValue0DE;
      svTranslatedValue0Old = svTranslatedValue0EN;
      svTranslatedValue1New = svTranslatedValue1DE;
      svTranslatedValue1Old = svTranslatedValue1EN;
    } else {
      svTranslatedNew = svTranslatedEN;
      svTranslatedOld = svTranslatedDE;
      svTranslatedMsgNew = svTranslatedMsgEN;
      svTranslatedMsgOld = svTranslatedMsgDE;
      svTranslatedValue0New = svTranslatedValue0EN;
      svTranslatedValue0Old = svTranslatedValue0DE;
      svTranslatedValue1New = svTranslatedValue1EN;
      svTranslatedValue1Old = svTranslatedValue1DE;
    }

    object svs = dom.GetObject(ID_SYSTEM_VARIABLES);
    foreach(oID, svs.EnumIDs()) {
      object oObj = dom.GetObject(oID);
      if(oObj) {
        ! Name
        string objName = oObj.Name();
        string trName = oObj.MetaData(metaDataID);
        integer idx = 0;
        string listEntry;
        foreach(listEntry, svDefault.Split(";")) {
          if(trName && (trName == listEntry)) {
            string oldName = svTranslatedOld.StrValueByIndex(";", idx);
            if(objName == oldName) {
              string newName = svTranslatedNew.StrValueByIndex(";", idx);
              oObj.Name(newName);
            }
          } elseif((objName == listEntry) || (objName == "${"#listEntry#"}")) {
            string newName = svTranslatedNew.StrValueByIndex(";", idx);
            oObj.Name(newName);
            oObj.AddMetaData(metaDataID, listEntry);
          }
          idx = idx + 1;
        }

        ! DPInfo
        string objMsg = oObj.DPInfo();
        string trNameMsg = oObj.MetaData(metaDataID # "Msg");
        integer idx = 0;
        string listEntry;
        foreach(listEntry, svDefaultMsg.Split(";")) {
          if(trNameMsg && (trNameMsg == listEntry)) {
            string oldMsg = svTranslatedMsgOld.StrValueByIndex(";", idx);
            if(objMsg == oldMsg) {
              string newMsg = svTranslatedMsgNew.StrValueByIndex(";", idx);
              oObj.DPInfo(newMsg);
            }
          } elseif((objMsg == listEntry) || (objMsg == "${"#listEntry#"}")) {
            string newMsg = svTranslatedMsgNew.StrValueByIndex(";", idx);
            oObj.DPInfo(newMsg);
            oObj.AddMetaData(metaDataID # "Msg", listEntry);
          }
          idx = idx + 1;
        }

        ! ValueName0
        string objValue0 = oObj.ValueName0();
        string trNameValue0 = oObj.MetaData(metaDataID # "Value0");
        integer idx = 0;
        string listEntry;
        foreach(listEntry, svDefaultValue0.Split(";")) {
          if(trNameValue0 && (trNameValue0 == listEntry)) {
            string oldValue0 = svTranslatedValue0Old.StrValueByIndex(";", idx);
            if(objValue0 == oldValue0) {
              string newValue0 = svTranslatedValue0New.StrValueByIndex(";", idx);
              oObj.ValueName0(newValue0);
            }
          } elseif((objValue0 == listEntry) || (objValue0 == "${"#listEntry#"}")) {
            string newValue0 = svTranslatedValue0New.StrValueByIndex(";", idx);
            oObj.ValueName0(newValue0);
            oObj.AddMetaData(metaDataID # "Value0", listEntry);
          }
          idx = idx + 1;
        }

        ! ValueName1
        string objValue1 = oObj.ValueName1();
        string trNameValue1 = oObj.MetaData(metaDataID # "Value1");
        integer idx = 0;
        string listEntry;
        foreach(listEntry, svDefaultValue1.Split(";")) {
          if(trNameValue1 && (trNameValue1 == listEntry)) {
            string oldValue1 = svTranslatedValue1Old.StrValueByIndex(";", idx);
            if(objValue1 == oldValue1) {
              string newValue1 = svTranslatedValue1New.StrValueByIndex(";", idx);
              oObj.ValueName1(newValue1);
            }
          } elseif((objValue1 == listEntry) || (objValue1 == "${"#listEntry#"}")) {
            string newValue1 = svTranslatedValue1New.StrValueByIndex(";", idx);
            oObj.ValueName1(newValue1);
            oObj.AddMetaData(metaDataID # "Value1", listEntry);
          }
          idx = idx + 1;
        }
      }
    }

    ! make sure the changes are saved immediately
    system.Save();

    Write("true");
  }

  set result [hmscript $script args]
  return $result
}

# set the system language to lang
set result [setSystemLanguage [array get args]]

if { $result == "true" } {
  # create /etc/config/systemLanguage with the
  # language as a content
  set fd [open /etc/config/systemLanguage w]
  puts -nonewline $fd $args(lang)
  close $fd
}

jsonrpc_response $result
