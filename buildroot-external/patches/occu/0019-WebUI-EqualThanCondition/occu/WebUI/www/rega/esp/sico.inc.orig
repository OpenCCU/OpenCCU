<%
  integer iLV = oSC.LeftVal();
  integer iLVT = oSC.LeftValType();
  integer iRV1 = oSC.RightVal1();
  integer iRV1T = oSC.RightVal1ValType();
  integer iRV2 = oSC.RightVal2();
  integer iRV2T = oSC.RightVal2ValType();
  integer iCT1 = oSC.ConditionType();
  integer iCT2 = oSC.ConditionType2();
  integer iCC = oSC.ConditionChannel();
  string sSelected = "";

  boolean showChannelParam = true;

  Write( '<select class="SelectBox" onchange="LeftValSelectChange(this.selectedIndex,'#oSC.ID()#');">' );
  if( iLVT == ivtEmpty ) { sSelected = " selected"; } else { sSelected = ""; }
  Write( '<option'#sSelected#'></option>' );
  if( iLVT == ivtObjectId ) { sSelected = " selected"; } else { sSelected = ""; }
  !Write( '<option'#sSelected#'>Ger&auml;teauswahl</option>' );
  Write( '<option'#sSelected#'>${ruleConditionSelectDeviceList}</option>' );
  if( iLVT == ivtSystemId ) { sSelected = " selected"; } else { sSelected = ""; }
  !Write( '<option'#sSelected#'>Systemzustand</option>' );
  Write( '<option'#sSelected#'>${ruleConditionSelectSystemState}</option>' );
  if( iLVT == ivtCurrentDate ) { sSelected = " selected"; } else { sSelected = ""; }
  !Write( '<option'#sSelected#'>Zeitsteuerung</option>' );
  Write( '<option'#sSelected#'>${ruleConditionSelectTimeControl}</option>' );
  Write( '</select>' );
  if( (iLVT == ivtObjectId) || (iLVT == ivtSystemId) )
  {
    object oCC = dom.GetObject( iCC );
    object oLV = dom.GetObject( iLV );
    boolean bOK = false;

    string sVLValue = "";

    if( iLVT == ivtObjectId )
    {
      bOK = ( oCC && oLV );
      if( bOK )
      {
        Write( ' <b class="CLASS02201" onclick="ShowChannelChooser2('#oSC.ID()#');">'#oCC.Name()#'</b>' );
      }
      else
      {
        !Write( ' <input type="button" class="SelectBox" value="Ger&auml;teauswahl" onclick="ShowChannelChooser2('#oSC.ID()#');" />' );
        Write( ' <input type="button" class="SelectBox" value="Ger&auml;teauswahl" name="ruleConditionButtonDeviceList" onclick="ShowChannelChooser2('#oSC.ID()#');" />' );
      }
    }
    if( iLVT == ivtSystemId )
    {
      if( oLV ) { bOK = true; }
      if( bOK )
      {
        Write( ' <b class="CLASS02201" onclick="ShowSysVarChooser('#oSC.ID()#');">'#oLV.Name()#'</b>' );
      }
      else
      {
        !Write( ' <input type="button" class="SelectBox" value="Systemvariablen" onclick="ShowSysVarChooser('#oSC.ID()#');" />' );
        Write( ' <input type="button" class="SelectBox" value="Systemvariablen" name="ruleConditionButtonSystemVar" onclick="ShowSysVarChooser('#oSC.ID()#');" />' );
      }
    }

    if( bOK )
    {
      boolean isGenericValueType = ((oLV.ValueType() == ivtFloat) || (oLV.ValueType() == ivtInteger));
      boolean bSysVarGeneric = ( (iLVT == ivtSystemId) && (isGenericValueType)  && (oLV.ValueSubType() == istGeneric ) );
      boolean bSysVarString  = ( (iLVT == ivtSystemId) && (oLV.ValueType() == ivtString) && (oLV.ValueSubType() == istChar8859) );

      if (bSysVarString)
      {
        !Write("<i>bei</i>");
        Write("<i>${ruleConditionLblWhen}</i>");
!        Write("<input type='text' onblur='javascript:alert(\"blur\");' class='SelectBox' />");
        Write("<input type='text' onblur='iseSingleCondition.SetRightValue(" # oSC.ID() # ",this.value);' value='" # iRV1 # "' class='SelectBox' />");

      }

      if( (!bSysVarGeneric) && (!bSysVarString) )
      {
        !Write( ' <i>bei</i> ' );
        Write( ' <i>${ruleConditionLblWhen}</i> ' );
        Write( '<select id="selectConditionWhen'#oSC.ID()#'" name="selectConditionWhen" onchange="SetLeftValue('#oSC.ID()#',this.value); setOptionWidthSelectConditionWhen();" class="SelectBox">' );
      }

      if( iLVT == ivtObjectId )
      {
        string sDP;
        foreach( sDP, oCC.DPs().EnumEnabledVisibleIDs() )
        {
          object oDP = dom.GetObject( sDP );

          if( oDP )
          {
            if( (oDP.Operations() & (OPERATION_READ|OPERATION_EVENT)) != 0 )
            {
              integer iDPvt = oDP.ValueType();
              integer iDPst = oDP.ValueSubType();
              string sSelected = "";

              if( (iDPvt == ivtInteger) && (iDPst == istEnum) )
              {
                integer iVLCount = web.webGetValueListCount( oDP.ValueList() );
                iVLCount = iVLCount - 1;
                string sVLKey;
                foreach( sVLKey, system.GenerateEnum(0,iVLCount) )
                {
                  sVLValue = web.webGetValueFromList( oDP.ValueList(), sVLKey );
                  if( sVLValue.Length())
                  {

                    string optionVal = "";
                    if( !oDP.IsTypeOf( OT_VARDP ) ) {
                      optionVal = oDP.HSSID()#"="#sVLValue;
                    }

                    ! Some parameters shouldn't be visible
                    Call("/esp/functions.fn::conditionIsParameterVisible()");
                    if (showChannelParam == true)
                    {

                      if( (oDP.ID() == iLV) && (iRV1 == sVLKey) ) { sSelected = " selected"; } else { sSelected = ""; }
                      Write( '<option value="'#oDP.ID()#':'#sVLKey#'"'#sSelected#'>' );
                      string sValue = oDP.Name()#": "#sVLValue;
                      if( !oDP.IsTypeOf( OT_VARDP ) )
                      {
                        string sLongKey = oCC.ChnLabel()#"|"#oDP.HSSID()#"="#sVLValue;
                        string sShortKey = oDP.HSSID()#"="#sVLValue;
                        sValue = web.webKeyFromStringTable(sLongKey);
                        if( !sValue.Length() )
                        {
                          string sValue = web.webKeyFromStringTable(sShortKey);
                          if( !sValue.Length() )
                          {
                            sValue = sShortKey;
                          }
                        }
                      }
                      Call("/esp/functions.fn::getSpecialTranslationPrgCond()");
                      Write( sValue );
                      Write( '</option>' );
                    }
                  }
                }
              }
              else
              {
                if( (iDPvt == ivtBinary) && ((iDPst != istAction)))
                {
                  ! Some parameters shouldn't be visible
                  Call("/esp/functions.fn::conditionIsParameterVisible()");
                  if (showChannelParam == true)
                  {
                    if( (oDP.ID() == iLV) && (iRV1 == 1) ) { sSelected = " selected"; } else { sSelected = ""; }
                    Write( '<option value="'#oDP.ID()#':1"'#sSelected#'>' );
                    string sValue = oDP.Name()#": "#oDP.ValueName1();
                    if( (!oDP.IsTypeOf( OT_VARDP )) && (!oDP.IsTypeOf( OT_ALARMDP )) )
                    {
                      string sLongKey = oCC.ChnLabel()#"|"#oDP.HSSID()#"=TRUE";
                      string sShortKey = oDP.HSSID()#"=TRUE";
                      sValue = web.webKeyFromStringTable(sLongKey);
                      if( sValue.Length() == 0 )
                      {
                        string sValue = web.webKeyFromStringTable(sShortKey);
                        if( !sValue.Length() )
                        {
                          sValue = sShortKey;
                        }
                      }
                    }
                    Call("/esp/functions.fn::getSpecialTranslationPrgCond()");
                    Write( sValue );

                    Write( '</option>' );

                    Call("/esp/functions.fn::conditionIsBinaryOptionVisible()");
                    if (showChannelParam == true)
                    {
                      if( (oDP.ID() == iLV) && (iRV1 == 0) ) { sSelected = " selected"; } else { sSelected = ""; }

                      Write( '<option value="'#oDP.ID()#':0"'#sSelected#'>' );
                      string sValue = oDP.Name()#": "#oDP.ValueName0();
                      if( (!oDP.IsTypeOf( OT_VARDP )) && (!oDP.IsTypeOf( OT_ALARMDP )) )
                      {
                        string sLongKey = oCC.ChnLabel()#"|"#oDP.HSSID()#"=FALSE";
                        string sShortKey = oDP.HSSID()#"=FALSE";
                        sValue = web.webKeyFromStringTable(sLongKey);
                        if( sValue.Length() == 0 )
                        {
                          string sValue = web.webKeyFromStringTable(sShortKey);
                          if( !sValue.Length() )
                          {
                            sValue = sShortKey;
                          }
                        }
                      }

                      Call("/esp/functions.fn::getSpecialTranslationPrgCond()");
                      Write( sValue );
                      Write( '</option>' );
                    }
                  }

                }
                else
                {
                  ! Some parameter shouldn´t be visible
                  Call("/esp/functions.fn::conditionIsParameterVisible()");
                  if(showChannelParam == true) {
                    if( oDP.ID() == iLV ) { sSelected = " selected"; } else { sSelected = ""; }
                    Write( '<option value="'#oDP.ID()#':1"'#sSelected#'>' );
                    string sValue = oDP.Name();
                    if( (!oDP.IsTypeOf( OT_VARDP )) && (!oDP.IsTypeOf( OT_ALARMDP )) )
                    {
                      string sLongKey = oCC.ChnLabel()#"|"#oDP.HSSID();
                      string sShortKey = oDP.HSSID();
                      sValue = web.webKeyFromStringTable(sLongKey);
                      if( !sValue.Length() )
                      {
                        string sValue = web.webKeyFromStringTable(sShortKey);
                        if( !sValue.Length() )
                        {
                          sValue = sShortKey;
                        }
                      }
                    }
                    Call("/esp/functions.fn::getSpecialTranslationPrgCond()");
                    Write( sValue );
                    Write( '</option>' );
                  }
                }
              }
            }
            if( oDP.IsTypeOf(OT_HSSDP) )
            {
              string s;
              foreach( s, oDP.EnumSpecialIDs() )
              {
                if( (oDP.ID() == iLV) && (s == iRV1.ToString()) && (iRV1T == ivtSpecialValue) ) { sSelected = " selected"; } else { sSelected = ""; }
                Write( '<option value="'#oDP.ID()#':[SV]'#s#'"'#sSelected#'>' );
                string sLongKey = oCC.ChnLabel()#"|"#oDP.HSSID()#"="#s;
                string sShortKey = oDP.HSSID()#"="#s;
                string sValue = web.webKeyFromStringTable(sLongKey);
                if( !sValue.Length() )
                {
                  string sValue = web.webKeyFromStringTable(sShortKey);
                  if( !sValue.Length() )
                  {
                    sValue = sShortKey;
                  }
                }
                Call("/esp/functions.fn::getSpecialTranslationPrgCond()");
                Write( sValue );
                Write( '</option>' );
              }
            }
          }
        }
      }

      boolean bOptionList = ( (oLV.ValueType() == ivtInteger) && (oLV.ValueSubType() == istEnum) );
      boolean bBinary = ( oLV.ValueType() == ivtBinary );

      if( iLVT == ivtSystemId )
      {
        if( bOptionList )
        {
          integer iVLCount = web.webGetValueListCount( oLV.ValueList() );
          Write( iVLCount );
          iVLCount = iVLCount - 1;
          string sVLKey;
          foreach( sVLKey, system.GenerateEnum(0,iVLCount) )
          {
            sVLValue = web.webGetValueFromList( oLV.ValueList(), sVLKey );
            if( iRV1 == sVLKey ) { sSelected = " selected"; } else { sSelected = ""; }
            Write( '<option value="'#oLV.ID()#':'#sVLKey#'"'#sSelected#'>' );
            Write( sVLValue );
            Write( '</option>' );
          }
        }
        if( bBinary )
        {
          if( iRV1 == 0 ) { sSelected = " selected"; } else { sSelected = ""; }
          Write( '<option value="'#oLV.ID()#':0"'#sSelected#'>' );
          Write( oLV.ValueName0() );
          Write( '</option>' );
          if( iRV1 == 1 ) { sSelected = " selected"; } else { sSelected = ""; }
          Write( '<option value="'#oLV.ID()#':1"'#sSelected#'>' );
          Write( oLV.ValueName1() );
          Write( '</option>' );
        }
      }

      if( (!bSysVarGeneric) && (!bSysVarString) )
      {
        Write( '</select>' );
      }

      boolean bSpecial = (iRV1T==ivtSpecialValue);

      if( (!bOptionList) && (!bBinary) && (!bSpecial) && (!bSysVarString) )
      {
        !Write( ' <i>im Wertebereich</i> ' );
        if (iCT1 != 5) {
          Write( ' <i>${ruleConditionLblWithinValueRange}</i> ' );
        }
        string sCT = "";
        string sValueUnit = oLV.ValueUnit();
        if( sValueUnit == "100%" )
        {
          sValueUnit = "%";
          iRV1 = iRV1*100;
          iRV2 = iRV2*100;
        }

        if( sValueUnit == "°C" )
        {
          ! sValueUnit = "° C";
        }
        else
        {
          sValueUnit = " "#sValueUnit;
        }

        if( sValueUnit == " " )
        {
          sValueUnit = "";
        }

        if( (iCT1 != 5) && (iCT1 != 6) && (iCT1 != 8) && (iCT1 != 10) & (iCT1 != 11) & (iCT1 != 9) )
        {
          oSC.ConditionType(6);
          iCT1 = 6;
        }

        if( iCT1 == 5 ) { sCT = "${ruleConditionLblIsEqual} "#iRV1.ToString(2)#sValueUnit; }
        if( iCT1 == 6 ) {
          if (iRV1 < iRV2) {
            sCT = "${ruleConditionLblRangeFrom} "#iRV1.ToString(2)#sValueUnit#" ${ruleConditionLblRangeLessThan} "#iRV2.ToString(2)#sValueUnit;
          } else {
            sCT = "${ruleConditionLblRangeFrom} "#iRV1.ToString(2)#sValueUnit#" ${ruleConditionLblRangeGreaterThan} "#iRV2.ToString(2)#sValueUnit;
          }
        }
        if( iCT1 == 7 ) { sCT = "${ruleConditionLblRangeFrom} "#iRV1.ToString(2)#sValueUnit#" ${ruleConditionLblRangeGreaterThan} "#iRV2.ToString(2)#sValueUnit; }
        !if( iCT1 == 8 ) { sCT = "größer als "#iRV1.ToString(2)#sValueUnit; }
        if( iCT1 == 8 ) { sCT = "${ruleConditionLblGreaterThan} "#iRV1.ToString(2)#sValueUnit; }
        !if( iCT1 == 10 ) { sCT = "kleiner als "#iRV1.ToString(2)#sValueUnit; }
        if( iCT1 == 10 ) { sCT = "${ruleConditionLblLessThan} "#iRV1.ToString(2)#sValueUnit; }
        !if( iCT1 == 9 ) { sCT = "größer oder gleich "#iRV1.ToString(2)#sValueUnit; }
        if( iCT1 == 9 ) { sCT = "${ruleConditionLblGreaterOrEqualThan} "#iRV1.ToString(2)#sValueUnit; }
        !if( iCT1 == 11 ) { sCT = "kleiner oder gleich "#iRV1.ToString(2)#sValueUnit; }
        if( iCT1 == 11 ) { sCT = "${ruleConditionLblLessOrEqualThan} "#iRV1.ToString(2)#sValueUnit; }

        Write( ' <b class="CLASS02201" onclick="CreatePopup(ID_SET_VALUE_RANGE,'#oSC.ID()#');">'#sCT#'</b>' );
      }
      boolean bAction = ( oLV.ValueSubType() == istAction );
      if( !bAction )
      {
        if( (oSC.ConditionType2() != 15) && (oSC.ConditionType2() != 13) && (oSC.ConditionType2() != 4) )
        {
          oSC.ConditionType2(4);
        }

        Write( '&nbsp;<select class="SelectBox" onchange="iseSingleCondition.SetConditionType2('#oSC.ID()#',this.value);">' );
        string sSelected = "";
        if( oSC.ConditionType2() == 13 ) { sSelected = " selected"; } else { sSelected = ""; }
        !Write( '<option'#sSelected#' value="DP_VALUE_CHECK_UPDATE">auslösen auf Aktualisierung</option>' );
        Write( '<option'#sSelected#' value="DP_VALUE_CHECK_UPDATE">${ruleConditionSelectTriggerWhenUpdated}</option>' );
        if( oSC.ConditionType2() == 15 ) { sSelected = " selected"; } else { sSelected = ""; }
        !Write( '<option'#sSelected#' value="DP_VALUE_CHECK_ONLY">nur prüfen</option>' );
        Write( '<option'#sSelected#' value="DP_VALUE_CHECK_ONLY">${ruleConditionSelectCheckOnly}</option>' );
        if( oSC.ConditionType2() == 4 ) { sSelected = " selected"; } else { sSelected = ""; }
        !Write( '<option'#sSelected#' value="DP_VALUE_CHECK_CHANGE">auslösen auf Änderung</option>' );
        Write( '<option'#sSelected#' value="DP_VALUE_CHECK_CHANGE">${ruleConditionSelectWhenChanged}</option>' );
        Write( '</select>' );
      }
    }
  }
  if( iLVT == ivtCurrentDate )
  {
    if( (iRV1T == ivtObjectId) && (iRV1 > 0) )
    {
      Write( ' <b class="CLASS02201" onclick="ShowTimeEditor('#oSC.ID()#','#iRV1#');">' );
      integer tmid = iRV1;
      string sTm = "";
      Call("/esp/system.fn::TmToString()");
      Write(sTm);
      Write( '</b> ' );

      if( (oSC.ConditionType2() != 15) && (oSC.ConditionType2() != 13) )
      {
        oSC.ConditionType2(13);
      }
      Write( '&nbsp;<select class="SelectBox" onchange="iseSingleCondition.SetConditionType2('#oSC.ID()#',this.value);">' );
      string sSelected = "";
      if( oSC.ConditionType2() == 13 ) { sSelected = " selected"; } else { sSelected = ""; }
      !Write( '<option'#sSelected#' value="DP_VALUE_CHECK_UPDATE">auslösen zu Zeitpunkten</option>' );
      Write( '<option'#sSelected#' value="DP_VALUE_CHECK_UPDATE">${ruleConditionSelectTriggerOnTime}</option>' );
      if( oSC.ConditionType2() == 15 ) { sSelected = " selected"; } else { sSelected = ""; }
      !Write( '<option'#sSelected#' value="DP_VALUE_CHECK_ONLY">nur prüfen</option>' );
      Write( '<option'#sSelected#' value="DP_VALUE_CHECK_ONLY">${ruleConditionSelectCheckOnly}</option>' );
      Write( '</select> ' );
    }
    else
    {
      !Write( ' <input type="button" class="SelectBox" value="Zeitmodul" onclick="ShowTimeEditor('#oSC.ID()#',0);" /> ' );
      Write( ' <input type="button" class="SelectBox" value="Zeitmodul" name="ruleConditionButtonTimeModul" onclick="ShowTimeEditor('#oSC.ID()#',0);" /> ' );
    }
  }
%>
