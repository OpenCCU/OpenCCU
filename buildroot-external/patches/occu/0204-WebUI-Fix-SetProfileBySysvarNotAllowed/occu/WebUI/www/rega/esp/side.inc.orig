<%

  boolean showChannelParam = true;

  integer iDP = oSD.DestinationDP();
  integer iCH = oSD.DestinationChannel();
  integer iP = oSD.DestinationParam();
  integer iV = oSD.DestinationValue();
  integer iVT = oSD.DestinationValueType();
  integer iVP = oSD.DestinationValueParam();
  integer iVPT = oSD.DestinationValueParamType();

  string hm_ouled16 =  "HM-OU-LED16";
  string hm_oucfm = "HM-OU-CFM-Pl";
  string hm_oucfmTW = "HM-OU-CFM-TW";
  string hm_oucmpcb = "HM-OU-CM-PCB";
  string hm_partyDialog = "HM-CC-RT-DN HM-TC-IT-WM-W-EU HM-CC-VG-1";
  string hm_statusDisplay = "HM-Dis-WM55";
  string hm_statusDisplayEPaper = "HM-Dis-EP-WM55";
  string hm_rgbw_controller = "HM-LC-RGBW-WM";
  string hm_jalousieActor = "HM-LC-Ja1PBU";
  string hmip_wrcd = "HmIP-WRCD";
  string hmip_mp3p = "HmIP-MP3P";
  string hmip_bsl = "HmIP-BSL";
  string hmip_drg_dali = "HmIP-DRG-DALI";
  string hmip_lsc = "HmIP-LSC";

  string hmipwID = "HmIPW-";
  string wrc6 = "-WRC6";
  string hmip_smi55 = "HmIP-SMI55";
  string hmip_smi55_a = "HmIP-SMI55-A";
  string hmip_smi55_2 = "HmIP-SMI55-2";
  string wgd = "-WGD";
  string wgd_pl = "-WGD-PL";
  string hmip_wgs = "HmIP-WGS";
  string udi_pb2 = "-UDI-PB2";
  string udi_smi55 = "-UDI-SMI55";

  string heatingClimateControlTransceiver =  "HEATING_CLIMATECONTROL_TRANSCEIVER";

  string acousticSignalVirtualReceiver = "ACOUSTIC_SIGNAL_VIRTUAL_RECEIVER";
  string accessReceiver = "ACCESS_RECEIVER";
  string alarmSwitchVirtualReceiver = "ALARM_SWITCH_VIRTUAL_RECEIVER";
  string backLightingReceiver = "BACKLIGHTING_RECEIVER";
  string blindVirtualReceiver = "BLIND_VIRTUAL_RECEIVER";
  string dimmerVirtualReceiver = "DIMMER_VIRTUAL_RECEIVER";
  string opticalSignaReceiver = "OPTICAL_SIGNAL_RECEIVER";
  string servoVirtualReceiver = "SERVO_VIRTUAL_RECEIVER";
  string switchVirtualReceiver = "SWITCH_VIRTUAL_RECEIVER";
  string universalLightReceiver = "UNIVERSAL_LIGHT_RECEIVER";
  string weatherDisplayReceiver = "WEATHER_DISPLAY_RECEIVER";


  string windowDriveReceiver = "WINDOW_DRIVE_RECEIVER";

  string maintenance = "MAINTENANCE";

  ! e. g. DIMMER_WEEK_PROFILE, SWITCH_WEEK_PROFILE
  string hmIPWeekProfile = "_WEEK_PROFILE";

  string s_vir_lg_rgb_dim = "VIR-LG-RGB-DIM";
  string s_vir_lg_rgbw_dim = "VIR-LG-RGBW-DIM";
  string s_vir_lg_white_dim = "VIR-LG-WHITE-DIM";
  string s_vir_lg_group = "VIR-LG-GROUP";
  string s_vir_lg_onoff = "VIR-LG-ONOFF";

  string excludePARTY = "PARTY_";
  string includePARTY = "PARTY_MODE_SUBMIT";

  string excludeSoundFileList = "SOUNDFILE_LIST_";
  string excludeColorList = "COLOR_LIST_";
  string excludeOntimeList = "ON_TIME_LIST_";
  string excludeOutputSelectSize = "OUTPUT_SELECT_SIZE";
  string excludeCombinedParameter = "_COMBINED_PARAMETER";
  string excludeRepetitions = "REPETITIONS=";

  string excludeHmIPCDT =  "CONTROL_DIFFERENTIAL_TEMPERATURE";
  string excludeHmIPSmokeDetCommandReservedAlarmOff = "SMOKE_DETECTOR_COMMAND=RESERVED_ALARM_OFF";
  string excludeHmIPLevel2 = "xx";

  object oCH = dom.GetObject( iCH );

  if (oCH) {
    ! A wired blind actor (e. g. HmIPW-DRBL4) can act as a shutter or a blind.
    ! When acting as a shutter the parameter slat position (LEVEL_2) shouldn't be visible
    if (oCH.HssType().Find("BLIND_VIRTUAL_RECEIVER") != -1) {
      object oMode = dom.GetObject(oCH.Address());
      if (oMode.MetaData("channelMode") == "shutter") {
        string excludeHmIPLevel2 = "LEVEL_2";
      }
    }

    if (oCH.HssType().Find("UNIVERSAL_LIGHT_RECEIVER") != -1) {
      object oDevice = dom.GetObject(oCH.Device());
      object oMaintenance = dom.GetObject(oDevice.Channels().GetAt(0));

      if (oMaintenance.MetaData("deviceMode") == 3) {
        dimmerVirtualReceiver = "UNIVERSAL_LIGHT_RECEIVER";
      }
    }
  }

  string sSelected = "";

  Write( '<select class="SelectBox" onchange="DestinationParamSelectChange(this.selectedIndex,'#oSD.ID()#');">' );
  if( iP == ivtEmpty ) { sSelected = " selected"; } else { sSelected = ""; }
  Write( '<option'#sSelected#'></option>' );
  if( iP == ivtObjectId ) { sSelected = " selected"; } else { sSelected = ""; }
  !Write( '<option'#sSelected#'>Ger&auml;teauswahl</option>' );
  Write( '<option'#sSelected#'>${ruleActivitySelectDeviceList}</option>' );
  if( iP == ivtSystemId ) { sSelected = " selected"; } else { sSelected = ""; }
  !Write( '<option'#sSelected#'>Systemzustand</option>' );
  Write( '<option'#sSelected#'>${ruleActivitySelectSystemState}</option>' );
  !if( (iP == ivtString) || (iP == "string") ) { sSelected = " selected"; } else { sSelected = ""; }
  if( iP == ivtString  ) { sSelected = " selected"; } else { sSelected = ""; }
  !Write( '<option'#sSelected#'>Skript</option>' );
  Write( '<option'#sSelected#'>${ruleActivitySelectScript}</option>' );
  Write( '</select>' );

  if( (iP == ivtObjectId) || ( iP == ivtSystemId ) )
  {
    if( iP == ivtObjectId )
    {
      object oCH = dom.GetObject( iCH );
      if( oCH )
      {
      Write( ' <b class="CLASS02400" onclick="ShowDestinationChannelChooser2('#oSD.ID()#');">'#oCH.Name()#'</b> ' );
      }
      else
      {
        !Write( ' <input type="button" class="SelectBox" value="Ger&auml;teauswahl" onclick="ShowDestinationChannelChooser2('#oSD.ID()#');" /> ' );
        Write( ' <input type="button" class="SelectBox" value="Ger&auml;teauswahl" name="ruleActivityButtonDeviceList" onclick="ShowDestinationChannelChooser2('#oSD.ID()#');" /> ' );
      }
    }
    if( iP == ivtSystemId )
    {
      object oDP = dom.GetObject( iDP );
      if( oDP )
      {
        Write( ' <b class="CLASS02400" onclick="ShowDestinationSysVarChooser('#oSD.ID()#');">'#oDP.Name()#'</b> ' );
      }
      else
      {
        Write( ' <input type="button" class="SelectBox" value="Systemvariablenauswahl" name="ruleActivityButtonSystemState" onclick="ShowDestinationSysVarChooser('#oSD.ID()#');" /> ' );
      }
    }
  }
  if( (iP == ivtString) || (iP == "string") )
  {
    if( (iVT == ivtString) || (iVT == "string") )
    {
      string sScript = iV.Substr(0,60);
      sScript = sScript#"...";
      Write( ' <b class="CLASS02400" onclick="EditScript('#oSD.ID()#');">'#sScript#'</b> ' );
    }
    else
    {
      Write( ' <input type="button" class="SelectBox" value="Skript erstellen" name="ruleActivityButtonCreateScript" onclick="EditScript('#oSD.ID()#');" /> ' );
    }
  }
  if( (iP==ivtString) || (iP==ivtObjectId) || (iP==ivtSystemId) )
  {
    Write( '<select onchange="iseSingleDestination.SetValueParamType('#oSD.ID()#',this.value);" class="SelectBox">' );
    string sSelected = "";
    if( iVPT == ivtEmpty ) { sSelected = " selected"; } else { sSelected = ""; }
    !Write( '<option value="'#ivtEmpty#'"'#sSelected#'>sofort</option>' );
    Write( '<option value="'#ivtEmpty#'"'#sSelected#'>${ruleActivitySelectImmediately}</option>' );
    if( iVPT == ivtDelay ) { sSelected = " selected"; } else { sSelected = ""; }
    !Write( '<option value="'#ivtDelay#'"'#sSelected#'>verzögert um</option>' );
    Write( '<option value="'#ivtDelay#'"'#sSelected#'>${ruleActivitySelectDelayed}</option>' );
    Write( '</select>' );
    if( iVPT == ivtDelay )
    {
      integer iHours = iVP.ToString().Substr(11,2).ToInteger();
      integer iMinutes = iVP.ToString().Substr(14,2).ToInteger();
      integer iSeconds = iVP.ToString().Substr(17,2).ToInteger();
      integer iVal = 0;
      if( iSeconds > 0 ) { iVal = iSeconds + (iMinutes*60) + (iHours*3600); iMinutes = 0; iHours = 0; }
      if( iMinutes > 0 ) { iVal = iMinutes + (iHours*60); iHours = 0; }
      if( iHours > 0 ) { iVal = iHours; }
      Write( ' <input type="text" size="10" class="SelectBox" value="'#iVal#'" id="delay'#oSD.ID()#'" onchange="SetDelay('#oSD.ID()#',this.value);" /> ' );
      Write( '<select id="tm'#oSD.ID()#'unit" class="SelectBox" onchange="ChangeDelayUnit('#oSD.ID()#');">' );
      string sSelected = "";
      if( iSeconds > 0 ) { sSelected = " selected"; } else { sSelected = ""; }
      !Write( '<option'#sSelected#'>Sekunden</option>' );
      Write( '<option'#sSelected#'>${ruleActivitySelectSeconds}</option>' );
      if( iMinutes > 0 ) { sSelected = " selected"; } else { sSelected = ""; }
      !Write( '<option'#sSelected#'>Minuten</option>' );
      Write( '<option'#sSelected#'>${ruleActivitySelectMinutes}</option>' );
      if( iHours > 0 ) { sSelected = " selected"; } else { sSelected = ""; }
      !Write( '<option'#sSelected#'>Stunden</option>' );
      Write( '<option'#sSelected#'>${ruleActivitySelectHours}</option>' );
      Write( '</select>' );
    }
  }
  if( iP == ivtObjectId )
  {
    object oCH = dom.GetObject( iCH );
    if( oCH )
    {
      boolean isVirLG_ONOFF = false;
      if( oCH.Label().Find(s_vir_lg_onoff) != -1 ) {
        isVirLG_ONOFF = true;
      }
      Write( ' <select id="setDestinationDPSelectChange'#oSD.ID()#'" onchange="SetDestinationDPSelectChange('#oSD.ID()#',this);" class="SelectBox">' );
      boolean bFound = false;
      integer iFirstID = ID_ERROR;
      string sDP;
      foreach( sDP, oCH.DPs().EnumEnabledVisibleIDs() )
      {
        object oDP = dom.GetObject( sDP );
        if( oDP )
        {
          boolean bSetDefault = false;
          if( !iV )
          {
            if( iDP == ID_ERROR )
            {
              bSetDefault = true;
            }
          }
          if( oDP.Operations() & OPERATION_WRITE )
          {
            integer iDPvt = oDP.ValueType();
            integer iDPst = oDP.ValueSubType();
            if( iFirstID == ID_ERROR ) { iFirstID = oDP.ID(); }
            string sSelected = "";
            if( oDP.ID() == iDP ) { sSelected = " selected"; bFound = true; } else { sSelected = ""; }
            string sIdx = "";
            if( (iDPvt == ivtInteger) && (iDPst == istEnum) )
            {
              integer iVLCount = web.webGetValueListCount( oDP.ValueList() );
              iVLCount = iVLCount - 1;
              string sVLKey;
              foreach( sVLKey, system.GenerateEnum(0,iVLCount) )
              {
                string sVLValue = web.webGetValueFromList( oDP.ValueList(), sVLKey );
                if( sVLValue.Length() )
                {
                  string optionVal = "";
                  if( !oDP.IsTypeOf( OT_VARDP ) ) {
                    optionVal = oDP.HSSID()#"="#sVLValue;
                  }
                  if ((optionVal != excludeHmIPSmokeDetCommandReservedAlarmOff)
                    && (optionVal.Find(excludeSoundFileList) == -1)
                    && (optionVal.Find(excludeRepetitions) == -1)
                    && (optionVal.Find(excludeColorList) == -1)
                    && (optionVal.Find(excludeOntimeList) == -1)
                  ) {
                    ! Some parameter shouldn´t be visible - this is the new way to hide certain parameters
                    Call("/esp/functions.fn::destinationIsParameterVisible()");
                    if(showChannelParam == true) {

                      if( (oDP.ID() == iDP) && (iV == sVLKey) ) { sSelected = " selected"; } else { sSelected = ""; }
                      Write( '<option value="'#oDP.ID()#':'#sVLKey#'"'#sSelected#'>' );
                      string sValue = oDP.Name()#": "#sVLValue;
                      if( (!oDP.IsTypeOf(OT_VARDP)) && (!oDP.IsTypeOf(OT_ALARMDP)) )
                      {
                        string sLongKey = oCH.ChnLabel()#"|"#oDP.HSSID()#"="#sVLValue;
                        string sShortKey = oDP.HSSID()#"="#sVLValue;
                        sValue = web.webKeyFromStringTable(sLongKey);
                        if( !sValue.Length() )
                        {
                          sValue = web.webKeyFromStringTable(sShortKey);
                          if( !sValue.Length() )
                          {
                            sValue = sShortKey;
                          }
                        }
                      }
                      Call("/esp/functions.fn::getSpecialTranslationPrgDest()");
                      Write( sValue );
                      Write( '</option>' );
                    }
                  }
                }
              }
            }
            else
            {
              if( ((iDPvt == ivtBinary) && (iDPst != istAction)) || (isVirLG_ONOFF) )
              {
                ! Some parameter shouldn´t be visible
                Call("/esp/functions.fn::destinationIsParameterVisible()");
                if (showChannelParam == true) {
                  string sValue = "not set";
                  if( (oDP.ID() == iDP) && (iV == 1) ) { sSelected = " selected"; } else { sSelected = ""; }
                  Write( '<option value="'#oDP.ID()#':1"'#sSelected#'>' );
                  sValue = oDP.Name()#": "#oDP.ValueName1();
                  if( (!oDP.IsTypeOf(OT_VARDP)) && (!oDP.IsTypeOf(OT_ALARMDP)) )
                  {
                    string sLongKey = oCH.ChnLabel()#"|"#oDP.HSSID()#"=TRUE";
                    string sShortKey = oDP.HSSID()#"=TRUE";
                    sValue = web.webKeyFromStringTable(sLongKey);
                    if( !sValue.Length() )
                    {
                      sValue = web.webKeyFromStringTable(sShortKey);
                      if( !sValue.Length() )
                      {
                        sValue = sShortKey;
                      }
                    }
                  }
                  Call("/esp/functions.fn::getSpecialTranslationPrgDest()");
                  Write( sValue );
                  Write( '</option>' );
                  if( (oDP.ID() == iDP) && (iV == 0) ) { sSelected = " selected"; } else { sSelected = ""; }
                  Write( '<option value="'#oDP.ID()#':0"'#sSelected#'>' );
                  sValue = oDP.Name()#": "#oDP.ValueName0();
                  if( (!oDP.IsTypeOf(OT_VARDP)) && (!oDP.IsTypeOf(OT_ALARMDP)) )
                  {
                    string sLongKey = oCH.ChnLabel()#"|"#oDP.HSSID()#"=FALSE";
                    string sShortKey = oDP.HSSID()#"=FALSE";
                    sValue = web.webKeyFromStringTable(sLongKey);
                    if( !sValue.Length() )
                    {
                      sValue = web.webKeyFromStringTable(sShortKey);
                      if( !sValue.Length() )
                      {
                        sValue = sShortKey;
                      }
                    }
                  }
                  Call("/esp/functions.fn::getSpecialTranslationPrgDest()");
                  Write( sValue );
                  Write( '</option>' );
                }
              }
              else
              {
                ! Some parameter shouldn´t be visible
                if ( ((oDP.HSSID().Find(excludePARTY) == -1) || (oDP.HSSID().Find(includePARTY) != -1))
                && (oDP.HSSID().Find(excludeHmIPCDT) == -1)
                && (oDP.HSSID().Find(excludeHmIPLevel2) == -1)
                && (oDP.HSSID().Find(excludeOutputSelectSize) == -1)
                && (oDP.HSSID().Find(excludeCombinedParameter) == -1)
                || ((oCH.Label().Find(hmip_wrcd) != -1) && (oDP.HSSID().Find(excludeCombinedParameter) != -1))
                ) {
                  ! Some parameter shouldn´t be visible - this is the new way to hide certain parameters
                  Call("/esp/functions.fn::destinationIsParameterVisible()");
                  if (showChannelParam == true) {
                    Write( '<option value="'#oDP.ID()#':0|'#oDP.Name()#'"'#sSelected#'>' );
                    string sValue = oDP.Name();
                    if( (!oDP.IsTypeOf(OT_VARDP)) && (!oDP.IsTypeOf(OT_ALARMDP)) )
                    {
                      string sLongKey = oCH.ChnLabel()#"|"#oDP.HSSID();
                      string sShortKey = oDP.HSSID();
                      sValue = web.webKeyFromStringTable(sLongKey);
                      if( !sValue.Length() )
                      {
                        sValue = web.webKeyFromStringTable(sShortKey);
                        if( !sValue.Length() )
                        {
                          sValue = sShortKey;
                          if( !sValue.Length() )
                          {
                            sValue = oDP.Name();
                          }
                        }
                      }
                    }
                    Call("/esp/functions.fn::getSpecialTranslationPrgDest()");
                    Write( sValue );
                    Write( '</option>' );
                  }
                }
              }
            }
          }
          string sEnumSpecial = "";
          if( oDP.IsTypeOf( OT_HSSDP ) ) { sEnumSpecial = oDP.EnumSpecialIDs().ToString(); };
          if( sEnumSpecial == "65535" ) { sEnumSpecial = ""; }
          string s;
          foreach(s,sEnumSpecial)
          {
            if( (oDP.ID()==iDP) && (s==iV.ToString()) && (iVT == ivtSpecialValue) ) { sSelected = " selected"; } else { sSelected = ""; }
            Write( '<option value="'#oDP.ID()#':[SV]'#s#'"'#sSelected#'>' );
            string sKey = oCH.ChnLabel()#"|"#oDP.HSSID()#"="#s;
            string sValue = web.webKeyFromStringTable(sKey);
            if( !sValue.Length() )
            {
              sValue = sKey;
            }
            Write( sValue );
            Write( '</option>' );
          }
        }
      }
      Write( '</select> ' );

      ! Help for the channel type MOTIONDETECTOR_TRANSCEIVER, config parameter PERMANENT_FULL_RX (SMI55)
      if ((oCH.Label().Find(hmip_smi55) != -1) || (oCH.Label().Find(hmip_smi55_a) != -1) || (oCH.Label().Find(hmip_smi55_2) != -1)) {
        object dev = dom.GetObject(oCH.Device());
        if (dev.MetaData("permanentFullRX") != 1) {
          Write( "<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:18px; height:18px; position:relative; top:2px\" onclick=\"showParamHelp(translateKey('helpPrgPermanentFullRX'), 400, 150)\">" );
        }
      }

      ! Help for the channel type ACCESS_RECEIVER (DLD)
      if (oCH.HssType().Find(accessReceiver) != -1) {
        Write( "<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:18px; height:18px; position:relative; top:2px\" onclick=\"showParamHelp(translateKey('helpPrgAccessReceiver'), 400, 150)\">" );
      }

      if( (!bFound) && (iFirstID != ID_ERROR) )
      {
        oSD.DestinationDP( iFirstID );
        oSD.DestinationValue( 1 );
        iDP = oSD.DestinationDP();
        iCH = oSD.DestinationChannel();
        iP = oSD.DestinationParam();
        iV = oSD.DestinationValue();
        iVT = oSD.DestinationValueType();
        iVP = oSD.DestinationValueParam();
        iVPT = oSD.DestinationValueParamType();
      }

      object oDP = dom.GetObject( iDP );
      if( oDP )
      {
        if( oDP.Operations() & OPERATION_WRITE )
        {
          !Write( "SD:["#oSD.ID()#"] " );
          !Write( "DP:["#oDP.ID()#"] " );

          integer iDPvt = oDP.ValueType();
          integer iDPst = oDP.ValueSubType();

          !Write( "VT:["#iDPvt#"] " );
          !Write( "ST:["#iDPst#"] " );

          if( ((iVT == ivtInteger) && (iDPst == istEnum)) || (iVT == ivtBinary) )
          {
            !Write( "i" );
          }

          if( (iVT == ivtInteger) || (iVT == ivtFloat) || (iVT == ivtScaling) || (iVT == ivtRelScaling) || (iVT == ivtBitMask) || (iVT == ivtWord) || (iVT == ivtDWord) )
          {
            if ((!oDP.IsTypeOf(OT_VARDP)) && (!oDP.IsTypeOf(OT_ALARMDP)) && (oDP.HSSID().Find("WHITE") == 0)) {
                ! e. g. OSRAM device
                string sUnit = "K";
                real rMin = oDP.ValueMin();
                real rMax = oDP.ValueMax();

                if( iV < rMin)
                {
                  iV = rMin.ToInteger().ToString();
                }

                iV = iV.ToString(0);
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" type="text" class="SelectBox alignCenter" size="10" value="'#iV#'" onfocus="Set_VIR_LG_WHITEController('#oSD.ID()#','#rMin#','#rMax#','#iV#');" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value);" /><span>'#sUnit#'</span>' );
                Write( '<span id="setWhiteController'#oSD.ID()#'" class="CLASS02401" onclick="Set_VIR_LG_WHITEController('#oSD.ID()#','#rMin#','#rMax#','#iV#');"><img src="/ise/img/notepad.png" /></span>' );
            } else {

              if( (iDPst != istEnum) && (! isVirLG_ONOFF) )
              {
                Write( ' <i>${ruleDescrSetValueA}</i> ' );

                ! Label() presents the type id of the channel, e.g. HM-OU-LED16 or  HM-OU-CFM-Pl
                string chLabel = oCH.Label();

                integer hmipWth = oCH.HssType().Find(heatingClimateControlTransceiver);

                if (hmipWth != -1) {
                  hmipWth = 1;
                }

                string sUnit = oDP.ValueUnit().ToString();

                real rMin = oDP.ValueMin();
                real rMax = oDP.ValueMax();

                integer iPercentPos = sUnit.Find("%");

                if( iPercentPos != -1 )
                {
                  iV = 100.0 * iV;
                  sUnit = sUnit.Substr(iPercentPos,1);
                }

                if( iV.Type() == "real" )
                {
                  if( iV < rMin)
                  {
                    iV = rMin.ToInteger().ToString() + rMin.ToString().Substr(rMin.Find("."),3);
                  }
                  iV = iV.ToString(2);
                }

                string sRange = " (" + rMin.ToInteger().ToString() + rMin.ToString().Substr(rMin.Find("."),3) + " - " + rMax.ToInteger().ToString() + rMax.ToString().Substr(rMax.Find("."),3) + ")";

                ! Add more exceptions
                if (hmipWth != -1) {
                  boolean showGenericElem = true;

                  if ((oDP.HSSID().Find("CONTROL_MODE") != -1) || (oDP.HSSID().Find("SET_POINT_MODE") != -1)) {
                    ! The maximal valid value is 3, but 3 is reserved (AUTO,MANU,PARTY,RESERVED), so we restrict the maximal value to 2
                    ! Write( '<input id="valSD_'#oSD.ID()#'" type="text" class="SelectBox alignCenter" size="6" value="'#iV#'" onfocus="SetWTHControlMode('#oSD.ID()#',\''#oDP.HSSID()#'\');" onchange="iseSingleDestination.SetValueMinMax('#oSD.ID()#',this.value,\''#sUnit#'\','#oDP.ValueMin()#',2);" />' );
                    Write( '<input id="valSD_'#oSD.ID()#'" type="text" class="CLASS02401 SelectBox alignCenter" size="6" value="'#iV#'" onfocus="SetWTHControlMode('#oSD.ID()#',\''#oDP.HSSID()#'\');" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');"/>' );
                    Write('<span id="wthControlMode'#oSD.ID()#'" class="CLASS02401" onclick="SetWTHControlMode('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span>' );

                    showGenericElem = false;
                  }

                  if (showGenericElem) {
                    Write( '<input id="valSD_'#oSD.ID()#'" type="text" class="A SelectBox" size="6" value="'#iV#'" onchange="iseSingleDestination.SetValueMinMax('#oSD.ID()#',this.value,\''#sUnit#'\','#oDP.ValueMin()#','#oDP.ValueMax()#');" />' );
                    Write( sUnit );
                    if (oDP.HSSID().Find("ACTIVE_PROFILE") == -1) {
                      Write( '<span class="CLASS02401" onclick="ChangeDestinationValue('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span>' );
                    }
                  }

                } else {
                  Write( '<input id="valSD_'#oSD.ID()#'" type="text" class="SelectBox" size="6" value="'#iV#'" onchange="iseSingleDestination.SetValueMinMax('#oSD.ID()#',this.value,\''#sUnit#'\','#oDP.ValueMin()#','#oDP.ValueMax()#');" />' );
                  Write( sUnit );

                  ! Hide the notepad for e. g. HmIP-WSC
                  if ((oCH.HssType().Find(servoVirtualReceiver) == -1) || (oDP.HSSID().Find("RAMP_TIME") == -1)) {
                    ! See SPHM-692
                    Write( '<span class="CLASS02401" onclick="ChangeDestinationValue('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span>' );
                  }

                  ! SPHM-365 - Help for the LEVEL_2 parameter of blind actors
                  if ((oCH.HssType().Find(blindVirtualReceiver) != -1) && (oDP.HSSID().Find("LEVEL_2") != -1)) {
                    Write( "<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:18px; height:18px; position:relative; top:2px\" onclick=\"showParamHelp(translateKey('helpBlindParamLevel2'), 400, 150)\">" );
                  }

                  if ((oCH.HssType().Find(alarmSwitchVirtualReceiver) != -1) && (oDP.HSSID().Find("DURATION_VALUE") != -1)) {
                    Write( "<img src=\"/ise/img/help.png\" style=\"cursor: pointer; width:18px; height:18px; position:relative; top:2px\" onclick=\"showParamHelp(translateKey('helpAlarmSwitchParamDurationValue'), 400, 100)\">" );
                  }
                }
              }
            }
          }
          if( (iVT == ivtString) || (iVT == "string") )
          {
            ! Label() presents the type id of the channel, e.g. HM-OU-LED16 or  HM-OU-CFM-Pl
            string chLabel = oCH.Label();

            integer ouled16 = chLabel.Find(hm_ouled16);
            integer oucfm = chLabel.Find(hm_oucfm);
            integer oucfmTW = chLabel.Find(hm_oucfmTW);
            integer oucmpcb = chLabel.Find(hm_oucmpcb);
            integer partyDialogDevice = hm_partyDialog.Find(chLabel);
            integer statusDisplayDevice = hm_statusDisplay.Find(chLabel);
            integer statusDisplayEPaperDevice = hm_statusDisplayEPaper.Find(chLabel);
            integer rgbw_controller = chLabel.Find(hm_rgbw_controller);
            integer i_vir_lg_rgb_dim = chLabel.Find(s_vir_lg_rgb_dim);
            integer i_vir_lg_rgbw_dim = chLabel.Find(s_vir_lg_rgbw_dim);
            integer i_vir_lg_group = chLabel.Find(s_vir_lg_group);
            integer jalousieActor = chLabel.Find(hm_jalousieActor);
            integer i_acousticSignalVirtualReceiver = oCH.HssType().Find(acousticSignalVirtualReceiver);
            integer i_dimmerVirtualReceiver = oCH.HssType().Find(dimmerVirtualReceiver);
            integer i_universalLightReceiver = oCH.HssType().Find(universalLightReceiver);
            integer i_opticalSignalReceiver = oCH.HssType().Find(opticalSignaReceiver);
            integer i_switchVirtualReceiver = oCH.HssType().Find(switchVirtualReceiver);
            integer i_blindVirtualReceiver = oCH.HssType().Find(blindVirtualReceiver);
            integer i_servoVirtualReceiver = oCH.HssType().Find(servoVirtualReceiver);
            integer i_hmip_mp3p = chLabel.Find(hmip_mp3p);
            integer i_windowDriveReceiver = oCH.HssType().Find(windowDriveReceiver);
            integer i_hmip_WeekProfile = oCH.HssType().Find(hmIPWeekProfile);
            integer i_maintenance = oCH.HssType().Find(maintenance);
            integer i_backLightingReceiver = oCH.HssType().Find(backLightingReceiver);
            integer i_weatherDisplayReceiver = oCH.HssType().Find(weatherDisplayReceiver);

            integer ePaperAcousticDisplay = chLabel.Find(hmip_wrcd);

            if ((statusDisplayDevice != -1)
              || (statusDisplayEPaperDevice != -1)
              || (ePaperAcousticDisplay != -1)
              || (rgbw_controller != -1)
              || ((jalousieActor != - 1) && (oDP.HSSID().Find("LEVEL_COMBINED") != -1))
              || (((i_vir_lg_rgb_dim != - 1) && (oDP.HSSID().Find("RGB") != -1))
              || ((i_vir_lg_rgbw_dim != - 1) && (oDP.HSSID().Find("RGBW") != -1))
              || (( i_vir_lg_group != - 1) && (oDP.HSSID().Find("RGBW") != -1))
              || (i_hmip_mp3p != -1)
              || (i_blindVirtualReceiver != -1)
              || (i_dimmerVirtualReceiver != -1)
              || (i_universalLightReceiver != -1)
              || (i_opticalSignalReceiver != -1)
              || (i_switchVirtualReceiver != -1)
              || (i_backLightingReceiver != -1)
              || (i_servoVirtualReceiver != -1)
              || (i_windowDriveReceiver != -1)
              || (i_weatherDisplayReceiver != -1)
              || (i_hmip_WeekProfile != -1)
              || (i_maintenance != -1))
              ) {
              if (statusDisplayDevice != -1) {
                if(iV == "0") {
                  ! This is the default string for 'all values not used'
                  iV = "0x02,0x0A,0x0A,0x0A,0x0A,0x0A,0x0A,0x03";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="SetStatusDisplay('#oSD.ID()#',\'DIS\');" type="text" class="SelectBox CLASS00012" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if (statusDisplayEPaperDevice != -1) {
                if(iV == "1") {
                  ! This is the default string for 'all values not used'
                  iV = "0x02,0x0A,0x0A,0x0A,0x0A,0x0A,0x14,0xC0,0x1C,0xD0,0x16,0x,0x1D,0xE0F0,0x03";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="SetStatusDisplay('#oSD.ID()#',\'DIS-EP\');" type="text" class="SelectBox CLASS00012" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if (ePaperAcousticDisplay != -1) {
                if(iV == "0") {
                  ! This is the default string for 'all values not used'
                  iV = "{DDBC=WHITE,DDTC=BLACK,DDI=0,DDA=CENTER,DDS=Zeile 1,DDID=1},{DDBC=WHITE,DDTC=BLACK,DDI=0,DDA=CENTER,DDS=Zeile 2,DDID=2},{DDBC=WHITE,DDTC=BLACK,DDI=0,DDA=CENTER,DDS=Zeile 3,DDID=3},{DDBC=WHITE,DDTC=BLACK,DDI=0,DDA=CENTER,DDS=Zeile 4,DDID=4},{DDBC=WHITE,DDTC=BLACK,DDI=0,DDA=CENTER,DDS=Zeile 5,DDID=5}";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="SetStatusDisplay('#oSD.ID()#',\'ACOUSTIC_DIS-EP\');" type="text" class="SelectBox" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if (rgbw_controller != -1) {

                if (iV == "0") {

                  if (oDP.HSSID().Find("USER_COLOR") != -1) {
                    ! deprecated iV = "0,200,0.5,0";
                    iV = "{'ACT_HSV_COLOR_VALUE_STORE':0,'ACT_BRIGHTNESS_STORE':200,'RAMP_TIME_STORE':0.5,'ON_TIME_STORE':0}";
                  }

                  if (oDP.HSSID().Find("USER_PROGRAM") != -1) {
                    ! deprecated iV = "0,200,0.5,0,0,199";
                    iV = "{'ACT_COLOR_PROGRAM_STORE':0,'ACT_BRIGHTNESS_STORE':200,'RAMP_TIME_STORE':0.5,'ON_TIME_STORE':0, 'ACT_MIN_BORDER_STORE':0, 'ACT_MAX_BORDER_STORE':199}";
                  }
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="SetRGBWController('#oSD.ID()#',\''#oDP.HSSID()#'\');" type="text" class="SelectBox CLASS00012" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if ((jalousieActor != - 1) && (oDP.HSSID().Find("LEVEL_COMBINED") != -1)) {
                if (iV == "0") {
                  iV = "0X00,0X00";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="SetJalousieActor('#oSD.ID()#',\''#oDP.HSSID()#'\');" type="text" class="SelectBox CLASS00012" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if ((i_vir_lg_rgb_dim != -1) && (oDP.HSSID().Find("RGB") != -1)) {

                if(iV.Find("rgb") == -1) {
                  iV = "rgb(255, 255, 255)";
                }

                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="Set_VIR_LG_RGBWController('#oSD.ID()#',\'RGB\');" type="text" class="SelectBox CLASS00012" size="20" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if (((i_vir_lg_rgbw_dim != -1) || ( i_vir_lg_group != -1)) && (oDP.HSSID().Find("RGBW") != -1)) {
                if(iV.Find("rgb") == -1) {
                  iV = "rgb(255, 255, 255, 255)";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="Set_VIR_LG_RGBWController('#oSD.ID()#',\'RGBW\');" type="text" class="SelectBox CLASS00012" size="20" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if (((i_hmip_mp3p != -1) && (i_acousticSignalVirtualReceiver != -1)) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("SL=") == -1) {
                  iV = "L=100,DU=2,DV=31,RTU=0,RTV=0,R=0,SL=0";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setAcousticSignalController('#oSD.ID()#',\'COMBINED_PARAMETER\');;" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if ((i_hmip_WeekProfile != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                object oUser = dom.GetObject( system.GetSessionVar('sessionUserID'));
                boolean noExpertMode = false;
                if (oUser) {
                  noExpertMode = oUser.UserEasyLinkMode();
                }
                object oCH = dom.GetObject( iCH );
                if (iV.Find("WPTCL=") == -1) {
                  iV = " WPTCLS=0,WPTCL=2";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setHmIPWeeklyProgramController('#oSD.ID()#',\''#oCH.Address()#'\','#noExpertMode#');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );

              }


              if ((i_dimmerVirtualReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("L=") == -1) {
                  if ((oCH.Label().Find(hmip_mp3p) == -1) && (oCH.Label().Find(hmip_bsl) == -1)) {
                    iV = "L=100,OT=0, RT=0";
                  } else {
                    iV = "L=100,DV=31,DU=2,RTV=0, RTU=1,C=7";
                  }
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setDimmerLevelController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if ((i_universalLightReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                object oDevice = dom.GetObject(oCH.Device());
                object oMaintenance = dom.GetObject(oDevice.Channels().GetAt(0));

                if ((oMaintenance.MetaData("deviceMode") == 0) || (oMaintenance.MetaData("deviceMode") == 1)) {
                  if (iV.Find("L=") == -1) {
                      iV = "L=100,OT=0,RT=0,H=0,SAT=100,RTTDV=0,RTTDU=0";
                  }
                  Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setHmipRGBWController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="45" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
                }

                if (oMaintenance.MetaData("deviceMode") == 2) {
                  if (iV.Find("L=") == -1) {
                      iV = "L=100,OT=0,RT=0,TC=4500,RTTDV=0,RTTDU=0";
                  }
                  ! Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setHmipRGBWTunableWhiteController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
                  Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setDALI_CombinedParameter('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );

                }
              }

              ! Exclude HmIP-DRG-DALI
              if ((oCH.Label().Find(hmip_drg_dali) == -1) && (i_opticalSignalReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("L=") == -1) {
                  if ((oCH.Label().Find(hmip_mp3p) == -1) && (oCH.Label().Find(hmip_bsl) == -1)) {
                    iV = "L=100,DV=31,DU=2,RTV=0,RTU=0,C=7,CB=1,RTTOV=0,RTTOU=3";
                  } else {
                    iV = "L=100,DV=31,DU=2,RTV=0, RTU=1,C=7";
                  }
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setDimmerLevelController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              ! HmIP-DRG-DALI
              if ((oCH.Label().Find(hmip_drg_dali) != -1) && (i_universalLightReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                 string chnAddress = oCH.Address();
                 integer chnIndex = chnAddress.StrValueByIndex(":",1).ToInteger();
                 if ((chnIndex > 0) && (chnIndex <= 48)) {
                   integer maxCap = oCH.MetaData("maxCap").ToInteger();
                   if (maxCap >= 0) {
                     if (maxCap == 0) {if (iV.Find("L=") == -1) {iV = "L=100";}}
                     if (maxCap == 1) {if (iV.Find("L=") == -1) {iV = "L=100,OT=0,RT=0";}}
                     if (maxCap == 2) {if (iV.Find("L=") == -1) {iV = "L=100,OT=0,RT=0,TC=4500,RTTDV=0,RTTDU=0";}}
                     if ((maxCap == 3) || (maxCap == 4)) {if (iV.Find("L=") == -1) {iV = "L=100,OT=0,RT=0,H=0,SAT=100";}}
                   } else {iV = 0;}
                 }

                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setDALI_CombinedParameter('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

             ! HmIP-LSC
             if ((oCH.Label().Find(hmip_lsc) != -1) && (i_universalLightReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
               if (iV.Find("L=") == -1) {iV = "L=100,OT=0,RT=0,H=0,SAT=100";}
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setDALI_CombinedParameter('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
             }

              if ((i_switchVirtualReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("S=") == -1) {
                  iV = "S=true";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setCombinedParameter('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\', \'switchState\');" type="text" class="SelectBox CLASS00012" size="20" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

             if ((i_backLightingReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {

               if (iV.Find("L=") == -1) {
                 if ((oCH.Label().Find(hmip_mp3p) == -1) && (oCH.Label().Find(hmip_bsl) == -1) && (oCH.Label().Find(hmip_wgs) == -1)) {
                   iV = "L=100,DV=31,DU=2,RTV=0,RTU=0,C=7,CB=1,RTTOV=0,RTTOU=3";
                 } else {
                   if (oCH.Label().Find(hmip_wgs) == -1) {
                    iV = "L=100,DV=31,DU=2,RTV=0, RTU=1,C=7";
                   } else {
                     iV = "L=100,OT=0";
                   }
                 }
               }

             !  Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setCombinedParameter('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\', \'switchState\');" type="text" class="SelectBox CLASS00012" size="20" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setDimmerLevelController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="20" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if (((i_blindVirtualReceiver != -1)) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("L=") == -1) {
                  iV = "L=100,L2=100";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setBlindLevelController('#oSD.ID()#',\'COMBINED_PARAMETER\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="20" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if ((i_servoVirtualReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("L=") == -1) {
                  iV = "L=100,RT=0";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setDimmerLevelController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="35" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if ((i_windowDriveReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("VL=") == -1) {
                  iV = "VL=1,OT=0";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setWindowDriveReceiverLevelController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              if ((i_weatherDisplayReceiver != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                if (iV.Find("DDI=") == -1) {
                  iV = "DDI=0,DDS=Text";
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setWeatherDisplayReceiverController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');" type="text" class="SelectBox CLASS00012" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

              ! SPHM-767
              if (((oCH.Label().Find(hmipwID) != -1) || (oCH.Label().Find(wrc6) != -1) || (oCH.Label().Find(hmip_drg_dali) != -1) || (oCH.Label().Find(hmip_bsl) != -1) || (oCH.Label().Find(hmip_wgs) != -1) || (oCH.Label().Find(wgd) != -1) || (oCH.Label().Find(wgd_pl) != -1) || (oCH.Label().Find(udi_pb2) != -1) || (oCH.Label().Find(udi_smi55) != -1)  ) && (i_maintenance != -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                ! IMTL(Level) 0 = OFF - 1 = ON
                ! Some devices doesn't habe a display (e. g. HmIPW-WRC6). Therefore we check for a key visual (IMKV)
                if (iV.Find("IMKV=") == -1) {
                  if (((oCH.Label().Find(wrc6) == -1)) && (oCH.Label().Find(wgd) == -1) && (oCH.Label().Find(wgd_pl) == -1) && (oCH.Label().Find(hmip_wgs) == -1) && (oCH.Label().Find(udi_pb2) == -1)  && (oCH.Label().Find(udi_smi55) == -1)) {
                    iV = "IMLB=true,IMKV=true,IMTL=1,IMDU=60";
                  } else {
                    iV = "IMKV=true,IMTL=1,IMDU=60";
                  }
                }
                Write( '<input id="prgStringOptionValue'#oSD.ID()#'" onfocus="setCombinedParameter('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\', \'wiredDisplaySysKey\');" type="text" class="SelectBox CLASS00012" size="20" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" /> ' );
              }

            } else {
              Write('<input id="prgStringOptionValue'#oSD.ID()#'" type="text" class="SelectBox" size="10" value="'#iV#'" onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value,\'STRING\');" />' );
            }

            if((ouled16 == -1)
              && (oucfm == -1)
              && (oucfmTW == -1)
              && (oucmpcb == -1)
              && (partyDialogDevice == -1)
              && (statusDisplayDevice == -1)
              && (statusDisplayEPaperDevice == -1)
              && (ePaperAcousticDisplay == -1)
              && (rgbw_controller == -1)
              && (jalousieActor == -1)
              && (i_vir_lg_rgb_dim == -1)
              && (i_vir_lg_rgbw_dim == -1)
              && (i_vir_lg_group == -1)
              && (i_acousticSignalVirtualReceiver == -1)
              && (i_blindVirtualReceiver == -1)
              && (i_dimmerVirtualReceiver == -1)
              && (i_opticalSignalReceiver == -1)
              && (i_switchVirtualReceiver == -1)
              && (i_hmip_WeekProfile == -1)
              && (((i_maintenance == -1) && (oDP.HSSID().Find("COMBINED_PARAMETER") == -1)))
              ) {
              Write( '<span class="CLASS02401" onclick="ChangeDestinationValue('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span>' );
            } else {
              if(ouled16 != -1) {
                Write( '<span class="CLASS02401" onclick="ChangeOULED16Value('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span>' );
              }
              if((oucfm != -1) || (oucfmTW != -1) || (oucmpcb != -1)) {
                Write( '<span class="CLASS02401" onclick="ChangeOUCFMValue('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span>' );
              }
              if (partyDialogDevice != -1) {
                Write( '<span id="setPartyMode" class="CLASS02401" onclick="SetPartyMode(this);"><img src="/ise/img/notepad.png" /></span>' );
              }
              if (statusDisplayDevice != -1) {
                Write( '<span id="setStatusDisplay'#oSD.ID()#'" class="CLASS02401" onclick="SetStatusDisplay('#oSD.ID()#',\'DIS\');"><img src="/ise/img/notepad.png" /></span>' );
              }
              if (statusDisplayEPaperDevice != -1) {
                Write( '<span id="setStatusDisplayEPaper'#oSD.ID()#'" class="CLASS02401" onclick="SetStatusDisplay('#oSD.ID()#',\'DIS-EP\');"><img src="/ise/img/notepad.png" /></span>' );
              }
              if (ePaperAcousticDisplay != -1) {
                Write( '<span id="ePaperAcousticDisplay'#oSD.ID()#'" class="CLASS02401" onclick="SetStatusDisplay('#oSD.ID()#',\'ACOUSTIC_DIS-EP\');"><img src="/ise/img/notepad.png" /></span>' );
              }
              if (rgbw_controller != -1) {
                Write( '<span id="setRGBWController'#oSD.ID()#'" class="CLASS02401" onclick="SetRGBWController('#oSD.ID()#',\''#oDP.HSSID()#'\');"><img src="/ise/img/notepad.png" /></span>' );
              }

              if ((jalousieActor != - 1) && (oDP.HSSID().Find("LEVEL_COMBINED") != -1)) {
                Write( '<span id="setJalousieActor'#oSD.ID()#'" class="CLASS02401" onclick="SetJalousieActor('#oSD.ID()#',\''#oDP.HSSID()#'\');"><img src="/ise/img/notepad.png" /></span>' );
              }

              if ((i_vir_lg_rgb_dim != -1) && (oDP.HSSID().Find("RGB") != -1)) {
                Write( '<span id="setRGBWController'#oSD.ID()#'" class="CLASS02401" onclick="Set_VIR_LG_RGBWController('#oSD.ID()#',\'RGB\');"><img src="/ise/img/notepad.png" /></span>' );
              }

              if (((i_vir_lg_rgbw_dim != -1) || ( i_vir_lg_group != -1)) && (oDP.HSSID().Find("RGBW") != -1)) {
                Write( '<span id="setRGBWController'#oSD.ID()#'" class="CLASS02401" onclick="Set_VIR_LG_RGBWController('#oSD.ID()#',\'RGBW\');"><img src="/ise/img/notepad.png" /></span>' );
              }

              if ((i_acousticSignalVirtualReceiver != - 1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                Write( '<span id="setAcousticSignalVirtualReceiver'#oSD.ID()#'" class="CLASS02401" onclick="setAcousticSignalController('#oSD.ID()#',\''#oDP.HSSID()#'\');"><img src="/ise/img/notepad.png" /></span>' );
              }

              if ((i_blindVirtualReceiver != - 1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                Write( '<span id="setBlindVirtualReceiver'#oSD.ID()#'" class="CLASS02401" onclick="setBlindLevelController('#oSD.ID()#',\''#oDP.HSSID()#'\',\''#oCH.Address()#'\');"><img src="/ise/img/notepad.png" /></span>' );
                Write('<img src onerror="setShutterVirtualReceiverInitValue(\'prgStringOptionValue'#oSD.ID()#'\',\''#oCH.Address()#'\');">');
              }

              if ((i_dimmerVirtualReceiver != - 1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                Write( '<span id="setDimmerVirtualReceiver'#oSD.ID()#'" class="CLASS02401" onclick="setDimmerLevelController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');"><img src="/ise/img/notepad.png" /></span>' );
              }
              if ((i_opticalSignalReceiver != - 1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                Write( '<span id="setDimmerVirtualReceiver'#oSD.ID()#'" class="CLASS02401" onclick="setDimmerLevelController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');"><img src="/ise/img/notepad.png" /></span>' );
              }

              if ((i_switchVirtualReceiver != - 1) && (oDP.HSSID().Find("COMBINED_PARAMETER") != -1)) {
                ! Write( '<span id="setSwitchVirtualReceiver'#oSD.ID()#'" class="CLASS02401" onclick="setSwitchStateController('#oSD.ID()#',\''#oCH.Label()#'\',\''#oCH.Address()#'\');"><img src="/ise/img/notepad.png" /></span>' );
              }
            }
          }

          if( iVT == ivtObjectId )
          {

            Write( ' <i>mit</i> ' );
            object oDPTmp = dom.GetObject( iV );
            if( oDPTmp )
            {

              object oCH = dom.GetObject( oDPTmp.Channel() );
              if( oCH )
              {
                Write( ' <span class="CLASS02402" onclick="ChangeDestinationValue('#oSD.ID()#');">'#oCH.Name()#'</span> ' );
                Write( ' <select onchange="iseSingleDestination.SetValue('#oSD.ID()#',this.value);" class="SelectBox">' );
                boolean bFound = false;
                integer iFirstID = ID_ERROR;
                string sDP;
                foreach( sDP, oCH.DPs().EnumEnabledVisibleIDs() )
                {
                  object oDP = dom.GetObject( sDP );
                  if( oDP )
                  {
                    boolean bSetDefault = false;
                    if( !iV )
                    {
                      if( iDP == ID_ERROR )
                      {
                        bSetDefault = true;
                      }
                    }
                    if( oDP.Operations() & OPERATION_READ )
                    {
                      integer iDPvt = oDP.ValueType();
                      integer iDPst = oDP.ValueSubType();
                      if( iFirstID == ID_ERROR ) { iFirstID = oDP.ID(); }
                      ! Some parameter shouldn´t be visible - this is the new way to hide certain parameters
                      Call("/esp/functions.fn::destinationIsParameterVisible()");
                      if (showChannelParam == true) {
                        string sSelected = "";
                        if( oDP.ID() == iV ) { sSelected = " selected"; bFound = true; } else { sSelected = ""; }
                        string sIdx = "";
                        Write( '<option value="'#oDP.ID()#'"'#sSelected#'>' );
                        string sValue = oDP.Name();
                        if( (!oDP.IsTypeOf(OT_VARDP)) && (!oDP.IsTypeOf(OT_ALARMDP)) )
                        {
                          string sLongKey = oCH.ChnLabel()#"|"#oDP.HSSID();
                          string sShortKey = oDP.HSSID();
                          sValue = web.webKeyFromStringTable(sLongKey);
                          if( !sValue.Length() )
                          {
                            sValue = web.webKeyFromStringTable(sShortKey);
                            if( !sValue.Length() )
                            {
                              sValue = sShortKey;
                            }
                          }
                        }
                        Write( sValue );
                        Write( '</option>' );
                      }
                    }
                  }
                }
                Write( '</select> ' );
              } else { Write("(unbekannter Kanal)"); }
            } else { Write("(unbekannter Datenpunkt)"); }
            Write( ' <span class="CLASS02401" onclick="ChangeDestinationValue('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span> ' );
          }

          if( iVT == ivtSystemId )
          {
            Write( ' <i>mit</i> ' );
            object oDPTmp = dom.GetObject( iV );
            string sNameTmp = "";
            if( oDPTmp ) { sNameTmp = oDPTmp.Name(); }
            Write( ' <span class="CLASS02402" onclick="ChangeDestinationValue('#oSD.ID()#');">'#sNameTmp#'</span> ' );
            Write( ' <span class="CLASS02401" onclick="ChangeDestinationValue('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span> ' );
          }
        }
      }
    }
  }
  if( iP == ivtSystemId )
  {
    object oDP = dom.GetObject( iDP );
    if( oDP )
    {
      if( oDP.Operations() & OPERATION_WRITE )
      {
        if( oDP.ValueType() == ivtBinary )
        {
          Write( ' <select class="SelectBox" onchange="SetSysVarDestValue('#oSD.ID()#',this.value);">' );
          if( iV == 1 ) { sSelected = "selected"; } else { sSelected = ""; }
          Write( '<option value="'#oDP.ID()#':1"'#sSelected#'>' );
          Write( oDP.ValueName1() );
          Write( '</option>' );
          if( iV == 0 ) { sSelected = "selected"; } else { sSelected = ""; }
          Write( '<option value="'#oDP.ID()#':0"'#sSelected#'>' );
          Write( oDP.ValueName0() );
          Write( '</option>' );
          Write( '</select> ' );
        }
        if (oDP.ValueSubType() == istChar8859)
        {
          Write( ' <input type="text" class="SelectBox" size="32" value="'#oSD.DestinationValue().ToString()#'" onchange="SetSysVarDestStrValue('#oSD.ID()#',this.value);" /> ' );
          Write( oDP.ValueUnit()#" " );
        }
        if( oDP.ValueSubType() == istGeneric )
        {
          Write('<input id="dest'#oSD.ID()#'" type="hidden" class="SelectBox" size="6" value="'#oSD.DestinationValue().ToString(2)#'" onchange="SetSysVarDestValue('#oSD.ID()#' ,this.value,'#oDP.ValueMin()#' ,'#oDP.ValueMax()#', \''#oDP.ValueUnit()#'\', '#oDP.IsTypeOf( OT_VARDP )#');" /> ' );
          real percVal = oSD.DestinationValue();
          if ((! oDP.IsTypeOf( OT_VARDP )) && (oDP.ValueUnit() == "%")) {
            percVal = oSD.DestinationValue() * 100;
          }
          Write( ' <input id="source'#oSD.ID()#'" type="text" class="SelectBox" size="6" value="'#percVal.ToString(2)#'" onchange="ConvertValueToPercent('#oSD.ID()#');" /> ' );
          Write( oDP.ValueUnit()#" " );
          !Write( '<span class="CLASS02401" onclick="ChangeDestinationValue('#oSD.ID()#');"><img src="/ise/img/notepad.png" /></span>' );
        }
        if( oDP.ValueSubType() == istEnum )
        {
          Write( ' <select class="SelectBox" onchange="SetSysVarDestValue('#oSD.ID()#',this.value);">' );
          integer iVLCount = web.webGetValueListCount( oDP.ValueList() );
          iVLCount = iVLCount - 1;
          string sVLKey;
          foreach( sVLKey, system.GenerateEnum(0,iVLCount) )
          {
            string sVLValue = web.webGetValueFromList( oDP.ValueList(), sVLKey );;
            if( sVLValue.Length() )
            {
              string sSelected = "";
              if( iV == sVLKey.ToInteger() ) { sSelected = "selected"; } else { sSelected = ""; }
              Write( '<option value="'#oDP.ID()#':'#sVLKey#'"'#sSelected#'>' );
              Write( sVLValue );
              Write( '</option>' );
            }
          }
          Write( '</select> ' );
        }
      }
    }
  }
%>
