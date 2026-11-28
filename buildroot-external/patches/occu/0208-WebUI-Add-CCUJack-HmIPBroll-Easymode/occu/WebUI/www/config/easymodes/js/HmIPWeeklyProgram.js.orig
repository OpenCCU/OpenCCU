arBSLMode = [];

checkWPFixedTime = function(thisElm, chn, prn) {
  var sTime = thisElm.value,
    arTime = sTime.split(":"),
    hr = parseInt(arTime[0]),
    min = parseInt(arTime[1]),
    elmHr = jQuery("#separate_CHANNEL_" + chn + "_" + prn),
    elmMin = jQuery("#separate_CHANNEL_" + chn + "_" + (parseInt(prn) + 1));

  hr = ((hr >= 0) && (hr <= 23)) ? hr : 0;
  min = ((min >= 0) && (min <= 59)) ? min : 0;

  elmHr.val(hr);
  elmMin.val(min);

  hr = (hr < 10) ? "0"+hr : hr.toString();
  min = (min < 10) ? "0"+min : min.toString();
  thisElm.value = hr + ":" + min;
};

checkWPMinMaxValue = function(thisElm, min, max) {
  var value = parseInt(thisElm.value);

  if (isNaN(value)) {thisElm.value = 0;} else {thisElm.value = value;}
  if (value < parseInt(min)) thisElm.value = min;
  if (value > parseInt(max)) thisElm.value = max;
};

setWPWeekday = function(thisElm, chn, prn) {
  var targetElm = jQuery("#separate_CHANNEL_"+chn+"_"+prn),
    iActiveWeekdays = parseInt(targetElm.val()),
    selectedVal = parseInt(thisElm.value);

  if (thisElm.checked) {
    iActiveWeekdays += selectedVal;
  } else {
    iActiveWeekdays -= selectedVal;
  }

  this.curWeekdays = iActiveWeekdays;

  targetElm.val(iActiveWeekdays);

};

reverseString = function (str) {
  return str.split("").reverse().join("");
};

setWPTargetChannels = function(targetChkBoxName, chn, prn) {
  var targetElm = jQuery("#separate_CHANNEL_"+chn+"_"+prn),
    chkBoxElems = jQuery("[name='"+targetChkBoxName+"']:checked"),
    selVal = 0;

  jQuery.each(chkBoxElems, function(index, elem) {
    selVal += parseInt(jQuery(elem).val());
  });

  targetElm.val(selVal);

};

getOnlyExpertChannels = function(channelType, channelNr) {
  var result = null;
  if (
    channelType == "DIMMER_VIRTUAL_RECEIVER" ||
    //channelType == "UNIVERSAL_LIGHT_RECEIVER" ||
    channelType == "SWITCH_VIRTUAL_RECEIVER" ||
    channelType == "WATER_SWITCH_VIRTUAL_RECEIVER" ||
    channelType == "BLIND_VIRTUAL_RECEIVER" ||
    channelType == "SHUTTER_VIRTUAL_RECEIVER" ||
    channelType == "ACOUSTIC_SIGNAL_VIRTUAL_RECEIVER" ||
    channelType == "SERVO_VIRTUAL_RECEIVER"
  ) {
    virtChnCounterWP = (virtChnCounterWP >= 3) ? 0 : virtChnCounterWP;
    virtChnCounterWP++;
    if (virtChnCounterWP == 1) {
      return channelNr;
    } else {
      return null;
    }
  } else if (
    (channelType == "ACCESS_RECEIVER")
    || (channelType == "ACCESS_TRANSCEIVER")
    || (channelType == "AUTO_RELOCK_TRANSCEIVER")
    || (channelType == "DOOR_LOCK_STATE_TRANSMITTER")
    || (channelType == "DOOR_LOCK_TRANSCEIVER")
    || (channelType == "OPTICAL_SIGNAL_RECEIVER")
  ) {
    return channelNr;
  }
  return result;
};

setBSLMode = function(elm, devId,  number, chn, isExpert) {
  var nr = addLeadingZero(number),
    oMode = {},
    selectedVal = parseInt(elm.value),
    colorElm = jQuery("#trLevel_" + nr),
    switchElm = jQuery("#trBSLSwitch_" + nr),
    wpLevelElm = jQuery("[name='"+nr+"_WP_LEVEL']").first(),
    bslOnOffElm = jQuery("#bslOnOff_" + nr),
    arTargetChannels = jQuery("[name='targetChannel"+chn+"_"+nr+"']");

  arTargetChannels.hide();
  jQuery(arTargetChannels).prev().hide();
  jQuery(arTargetChannels).prop("checked", false);
  jQuery("[name='"+nr+"_WP_TARGET_CHANNELS']").val(0);

  oMode.number = nr;
  oMode.mode = selectedVal;

  arBSLMode.push(oMode);

  if (selectedVal == 0) {
    var x = (isExpert) ? 3 : 1;
    for (var i = 0; i < x; i++) {
      jQuery(arTargetChannels[i]).prev().show();
      arTargetChannels[i].show();
    }
    colorElm.hide();
    switchElm.show();
    wpLevelElm.val("0");
    bslOnOffElm.val("0");
    showHideDuration("0", nr);
  } else {
    for (var i = (isExpert) ? 3 : 1; i < arTargetChannels.length; i++) {
      jQuery(arTargetChannels[i]).prev().show();
      arTargetChannels[i].show();
    }
    colorElm.show();
    switchElm.hide();
  }


};

setBSLWPLevel = function(val, number) {
  jQuery("[name='"+addLeadingZero(number)+"_WP_LEVEL']").first().val(val);

  if (parseInt(val) > 0) {
    jQuery("#trDurationMode" + addLeadingZero(number)).show();
    jQuery("#durationMode" + addLeadingZero(number)).val("0").change();
  } else {
    jQuery("#trDurationMode" + addLeadingZero(number)).hide();
    jQuery("#trDurationValue" + addLeadingZero(number)).hide();
  }
};

setWGSPanel = function(chn,number,val,prn, isExpert) {
  var number = addLeadingZero(number),
    levelElm = jQuery("[name='"+number+"_WP_LEVEL']").first(),
    modeSelector = parseInt(val),
    relevantElms = [],
    tmpLoop;

  // This is necessary e. g. when changing the mode of a HmIP-WGTC.
  if (isNaN(modeSelector)) {
    modeSelector = 0;
    var modeLevelElm = jQuery("#wgsWPModeSelector"+chn+"_" + number);
    window.setTimeout(function() { modeLevelElm.val(0).change();},50);
  }

  jQuery("[name='targetChannel"+chn+"_"+number+"']").hide().prop("checked", false).prev().hide();

  switch (modeSelector) {
    case 0:
      relevantElms = jQuery("[data='BACKLIGHTING_RECEIVER'][name='targetChannel"+chn+"_"+number+"']");
      levelElm.empty();
      levelElm.append(new Option("Aus",0));
      for (var loop = 0.05; loop < 1; loop += 0.05) {
        tmpLoop = parseInt(loop.toFixed(2) * 100);
        levelElm.append(new Option((tmpLoop )+ " %", loop.toFixed(2)));
      }
      levelElm.append(new Option("100 %",1));
      levelElm.append(new Option("Alter Wert",1.005));
      levelElm.append(new Option("Ignorieren",1.01));
      levelElm.append(new Option("Wert eingeben","freeVal"));
      break;
    case 1:
      if (isExpert) {
        relevantElms = jQuery("[data='SWITCH_VIRTUAL_RECEIVER'][name='targetChannel" + chn + "_" + number + "']");
      } else {
        relevantElms = jQuery("[data='SWITCH_VIRTUAL_RECEIVER'][name='targetChannel"+chn+"_"+number+"']").first();
      }
      levelElm.empty();
      levelElm.append (new Option(translateKey("optionOFF"), 0)).append(new Option(translateKey("optionON"), 1));
      break;
    default: console.log("Hm, here we have a problem");
  }

  jQuery(relevantElms).show().prev().show();
  //jQuery(relevantElms).first().prop("checked", true).change();
  window.setTimeout(function() {jQuery(relevantElms).change();},100);
  jQuery(levelElm).find("option").last().prop("id", "dimOptionFreeValue"+chn+"_" + prn);

};

getWPVirtualChannels = function(channels, expert) {
  var result = [];

  jQuery.each(channels, function(index, chn) {
    var virtualChID = "_VIRTUAL_RECEIVER",
      AccessReceiverID = "ACCESS_RECEIVER", // HmIP-DLD
      AccessTransceiverID = "ACCESS_TRANSCEIVER", // e. g.HmIP-FWI
      DoorLockTransmitterID = "DOOR_LOCK_STATE_TRANSMITTER", // HmIP-DLD
      OpticalSignalID = "OPTICAL_SIGNAL_RECEIVER", // HmIPW-WRC6
      PermissionTranseiverID = "PERMISSION_TRANSCEIVER", // HmIP-FLC/FLD
      SwitchTranseiverID = "SWITCH_TRANSCEIVER", // HmIP-FLC/FLD
      AutoRelock_Transceiver = "AUTO_RELOCK_TRANSCEIVER", // HmIP-DLP
      DoorLockTransceiver = "DOOR_LOCK_TRANSCEIVER", // HmIP-DLP
      expertChn;
    if (
      (chn.channelType.indexOf(virtualChID) !== -1)
      || (chn.channelType.indexOf(AccessReceiverID) !== -1)
      || (chn.channelType.indexOf(AccessTransceiverID) !== -1)
      || (chn.channelType.indexOf(DoorLockTransmitterID) !== -1)
      || (chn.channelType.indexOf(OpticalSignalID) !== -1)
      || (chn.channelType.indexOf(PermissionTranseiverID) !== -1)
      || (chn.channelType.indexOf(SwitchTranseiverID) !== -1)
      || (chn.channelType.indexOf(AutoRelock_Transceiver) !== -1)
      || (chn.channelType.indexOf(DoorLockTransceiver) !== -1)
    ) {
      if (expert == 1) {
        result.push(index);
      } else {
        expertChn = getOnlyExpertChannels(chn.channelType, index);
        if (expertChn) {
          result.push(expertChn);
        }
      }
    }
  });
  return result;
};

HmIPWeeklyProgram = Class.create();

HmIPWeeklyProgram.prototype = {
  initialize: function (address, ps, psDescr, sessionIsExpert, fwVersion, extraParam) {


    self = this;
    this.extraParam = extraParam;
    this.hmIPIFace = "HmIP-RF";
    this.address = address;
    this.arAddress = this.address.split(":");
    this.devAddress = this.arAddress[0];
    this.chn = this.arAddress[1];
    this.device = DeviceList.getDeviceByAddress(this.devAddress);
    this.fwVersion = fwVersion;

    this.anchor = jQuery("#weeklyProgram_" + this.chn);

    // The device is still in the device inbox
    if (typeof this.device == "undefined") {
      this.anchor.css({"text-align": "center"});
      this.anchor.html(translateKey("hintSetReadyWeeklyProgram"));
      return;
    }

    virtChnCounterWP = 0;
    modeWP_DELETE = false;
    this.DIMMER = "DIMMER_WEEK_PROFILE";
    this.UNIVERSAL_LIGHT_RECEIVER = "UNIVERSAL_LIGHT_WEEK_PROFILE";
    this.DIMMER_OUTPUT_BEHAVIOUR = "DIMMER_OUTPUT_BEHAVIOUR_WEEK_PROFILE";
    this.SWITCH = "SWITCH_WEEK_PROFILE";
    this.WATER_SWITCH = "WATER_SWITCH_WEEK_PROFILE";
    this.BLIND = "BLIND_WEEK_PROFILE";
    this.SERVO = "SERVO_WEEK_PROFILE";
    this.WINDOW_DRIVE_RECEIVER = (this._isDeviceType("HmIP-MOD-WD-VK")) ? true : false;

    this.ACCESS_TRANSMITTER_HmIP_FWI = "HmIP-FWI";
    this.ACCESS_TRANSCEIVER_HmIP_WKP = "HmIP-WKP";
    this.UNIVERSAL_LIGHT_RECEIVER_RGBW = "HmIP-RGBW";
    this.UNIVERSAL_LIGHT_RECEIVER_DALI = "HmIP-DRG-DALI";
    this.isWGS = (this.device.deviceType.id.includes("HmIP-WGS")) ? true : false;
    this.isWiredWGS = (this.device.deviceType.id.includes("HmIPW-WGS")) ? true : false;
    this.isWGT = (this.device.deviceType.id.includes("HmIP-WGT")) ? true : false;
    this.isWiredWGT = (this.device.deviceType.id.includes("HmIPW-WGT")) ? true : false;
    this.isWSM = ((this.device.deviceType.id.includes("HmIP-WSM")) || (this.device.deviceType.id.includes("ELV-SH-WSM")))? true : false;
    this.isWRC6230 = (this.device.deviceType.id.includes("HmIP-WRC6-230"))? true : false;
    this.isWGTC = (this.device.deviceType.id.includes("HmIP-WGTC"))? true : false;
    this.isDLP = (this.device.deviceType.id.includes("HmIP-DLP"))? true : false;

    // The device says the type of this channel is BLIND_WEEK_PROFILE but it's a SHUTTER device
    this.isShutter = ((this.device.deviceType.id.includes("HmIP-M-TD15")) || (this.device.deviceType.id.includes("RM-110-45/15"))) ? true : false;

    this.isHmIPLSS = false;

    if (this._isDeviceType("HmIP-LSC")) {
      this.UNIVERSAL_LIGHT_RECEIVER_DALI = "HmIP-LSC";
      this.isHmIPLSS = true;
    }

    this.DIMMER_WEEK_PROFILE_HmIP_WUA = (this._isDeviceType("HmIP-WUA") || (this._isDeviceType("ELV-SH-WUA"))) ? "HmIP-WUA" : "";

    this.ignoreExpertMode = ["HmIP-DLD", "HmIP-DLD-A", "HmIP-DLD-S", "HmIPW-WRC6", "HmIPW-WRC6-A", "HmIP-WRC6-230", "HmIP-WRC6-230-A", "HmIP-WKP", "HmIP-RGBW", "HmIP-DRG-DALI", "HmIP-LSC", "HmIP-FLC", "HmIP-FDC", "HmIP-DLP", "HmIP-DLP-A", "HmIP-DLP-AS", "HmIP-DLP-WS"];
    this.ignoreVirtualChannels = ["HmIP-DLD", "HmIP-DLD-A", "HmIP-DLD-S", "HmIPW-WRC6", "HmIPW-WRC6-A", "HmIP-WRC6-230", "HmIP-WRC6-230-A", "HmIP-FWI", "HmIP-WKP", "HmIP-RGBW", "HmIP-DRG-DALI", "HmIP-LSC", "HmIP-FLC", "HmIP-FDC", "HmIP-WGS", "HmIP-WGS-A", "HmIP-WGT" , "HmIP-WGT-A", "HmIP-DLP", "HmIP-DLP-A", "HmIP-DLP-AS", "HmIP-DLP-WS"];
    this.defaultDoorLockMode = "DoorLockMode";
    this.userDoorLockMode = "UserMode";
    this.selectedMode_RGBW = "";
    this.metaSelectedMode = [];
    //this.arChangedMode_FLC = [];
    this.currentLevel = [];


    this.isWired = (this.device.deviceType.id.split("-")[0] == "HmIPW") ? true : false;

    this.chnType = (this.device.channels[this.chn].channelType == this.DIMMER_OUTPUT_BEHAVIOUR) ? this.DIMMER : this.device.channels[this.chn].channelType;

    // The device type of the HmIP-BSL is DIMMER_WEEK_PROFILE but the weekly program should act as a SWITCH_WEEK_PROFILE
    this.chnType = ((this._isDeviceType("HmIP-BSL") && (this._getFwMajor() < 2)) || this.isWSM) ? this.SWITCH : this.chnType;
    this.isAccessTransmitterHmIP_FWI = this._isDeviceType(this.ACCESS_TRANSMITTER_HmIP_FWI);
    this.isAccessTransceiver_WKP = this._isDeviceType(this.ACCESS_TRANSCEIVER_HmIP_WKP);
    this.isDoorLockDrive = (this._isDeviceType("HmIP-DLD") || this._isDeviceType("HmIP-DLD-A") || this._isDeviceType("HmIP-DLD-S")) ? true : false;
    if (this.isDoorLockDrive) {
      this.arDoorLockMetaData = [];
    }
    this.ps = ps;
    this.psDescr = psDescr;
    this.sessionIsExpert = (
      (! this._isDeviceType(this.UNIVERSAL_LIGHT_RECEIVER_RGBW))
      && (! this._isDeviceType("HmIP-FLC"))
      && (! this._isDeviceType("HmIP-FDC"))
      && (! this.isDLP)
    ) ? sessionIsExpert : 1;

    this.prn = 0;
    this.prnHiddenField = [];
    this.weekDayID = [];
    this.condition = []; // selected value of the parameter WP_CONDITION (_getConditionElm)
    this.activeEntries = []; // active week programs
    this.numberOfActiveEntries = 0;
    this.curWeekdays = 0;
    this.curTargetChannels = 0;
    this.targetChannelTypes = {};
    this.showHintExpertTargetChannel = false;
    this.ulrPrn = []; // Stores the help prn for the UNIVERSAL LIGHT RECEIVER (e. g. HmIP-RGBW)

    this.targetChannelTypesVirtualBlind = [];  // only in use for some wired blinds which can be used as a shutter

    this.DoorLockWPMode = new Array();
    this.DoorLockWPMode[this.devAddress] = new Object();

    this.arColorA = [];
    this.arColorB = [];
    this.blinkMode = [];
    this.maxEntries = this._getMaxEntries();

    // Prüfe, ob im vereinfachten Modus Expertenkanäle aktiv sind. Wenn ja, zeige auch Targetkanäle des Expertenmodus an
    if ((this.sessionIsExpert == 0) && (!this._isDeviceType(this.ACCESS_TRANSMITTER_HmIP_FWI))) {
      var AvailableVirtualChannels = getWPVirtualChannels(this.device.channels, 1),
        val;
      for (var x = 1; x <= this.maxEntries; x++) {
        if (self.sessionIsExpert == 1) {
          break;
        } // When the expert mode has been activated, the check can be left.
        val = this.ps[this._addLeadingZero(x) + "_WP_TARGET_CHANNELS"]; // Get the value of the selected target channel
        if (val > 1) { // The first target channel is always visible (no expert channel)
          jQuery.each(AvailableVirtualChannels, function (index, ch) {
            var y = index / 3;
            if ((y != 0) && (y != parseInt(y))) { // select target channels 1,2,4,5,7,8,10,11.... which are expert channels
              // If the expert target channel is set, switch to the expert mode
              if (isBitSet(val, index) && (! self.isWGS) && (! self.isWGT)) {
                self.sessionIsExpert = 1;
                if (!self.ignoreExpertMode.includes(self.device.deviceType.id)) {
                  self.showHintExpertTargetChannel = true;
                }
                return false; // leave each loop
              }
            }
          });
        }
      }
    } else {
      // Introduced with the HmIP-FWI - show the virtual channels 2 and 3 and a hint when active, even in non-expert mode
      if (this.sessionIsExpert == 0) {
        var val;
        for (var x = 1; x <= this.maxEntries; x++) {
          if (this.sessionIsExpert == 1) {
            break; // leave the loop
          }
          val = this.ps[this._addLeadingZero(x) + "_WP_TARGET_CHANNELS"]; // Get the value of the selected target channels
          if (isBitSet(val, 1) || isBitSet(val, 2)) { // The virtual channels 2 and 3 of the HmIP-FWI
            this.sessionIsExpert = 1;
            this.showHintExpertTargetChannel = true;
          }
        }
      }
    }

    this.virtualChannels = getWPVirtualChannels(this.device.channels, this.sessionIsExpert);

    // The HmIP-BSL consists of SWITCH and DIMMER channels.
    if (this._isDeviceType("HmIP-BSL")) {
      if (this._getFwMajor() < 2) {
        this.virtualChannels = (this.sessionIsExpert) ? [4, 5, 6] : [4];
      } else {
        this.virtualChannels = (this.sessionIsExpert) ? [4, 5, 6, 8, 9, 10, 12, 13, 14] : [4, 8, 12];
      }
    }

    if (this._isDeviceType("HmIP-WKP")) {
      this.virtualChannels =  [1, 3, 5, 7, 9, 11, 13, 15];
    }

    if (this.WINDOW_DRIVE_RECEIVER) {
      this.virtualChannels = [2];
    }

    if ((this._isDeviceType("HmIP-SMO230")) || (this._isDeviceType("HmIP-SMO230-A")) || (this._isDeviceType("HmIPW-SMO230")) || (this._isDeviceType("HmIPW-SMO230-A"))) {
      this.virtualChannels =  [10, 11, 12];
    }

    if (this.isWGS) {
      this.virtualChannels = [7, 9, 10, 11];
    }

    if (this.isWiredWGS) {
      this.virtualChannels = [6];
    }

    if (this.isWGT) {
      this.virtualChannels = [2, 4, 5, 6];
    }
    if (this.isWiredWGT) {
      this.virtualChannels = [2];
    }

    if (this._isDeviceType(this.UNIVERSAL_LIGHT_RECEIVER_RGBW)) {
      // get selected mode - deviceMode
      var chnId = DeviceList.getChannelByAddress(address.split(":")[0] + ":0").id;
      this.selectedMode_RGBW = parseInt(homematic("Interface.getMetadata", {"objectId": chnId, "dataId": "deviceMode"}));
      switch (this.selectedMode_RGBW) {
        case 0:
        case 1:
          this.virtualChannels = [1];
          break;
        case 2:
          this.virtualChannels = [1,2];
          var chnDescription = homematic("Interface.getParamset", {"interface":this.hmIPIFace, "address": this.devAddress + ":1", "paramsetKey": "MASTER"});
          this.sliderTempMin = parseInt(chnDescription.HARDWARE_COLOR_TEMPERATURE_WARM_WHITE);
          this.sliderTempMax = parseInt(chnDescription.HARDWARE_COLOR_TEMPERATURE_COLD_WHITE);
          break;
        default:
          this.virtualChannels = [1, 2, 3, 4];
          this.chnType = this.DIMMER;
      }
    }

    // Collect the target channels. Group channels are always visible. Non group channels are only visible when a DALI device is connected.
    if (this._isDeviceType(this.UNIVERSAL_LIGHT_RECEIVER_DALI) && (! this.isHmIPLSS)) {
      var chnDescr = homematic("Interface.getParamset", {"interface":this.hmIPIFace, "address": this.devAddress + ":1", "paramsetKey": "MASTER"});
      this.sliderTempMin = parseInt(chnDescr.HARDWARE_COLOR_TEMPERATURE_WARM_WHITE);
      this.sliderTempMax = parseInt(chnDescr.HARDWARE_COLOR_TEMPERATURE_COLD_WHITE);

      if (daliTargetChannels == null) {
        jQuery.each(this.device.channels, function(index, channel) {
          if (typeof channel.daliMaxCapabilities != "undefined") {
            if (parseInt(channel.daliMaxCapabilities) < 5) {
              self.virtualChannels.push(channel.index);
            } else {
              return false; // leave each loop
            }
          }
        });

        for (var loop = 33; loop <= 48; loop++) {
          this.virtualChannels.push(loop);
        }
        daliTargetChannels = this.virtualChannels;
      } else {
        this.virtualChannels = daliTargetChannels;
      }
    } else if (this.isHmIPLSS) {
      var chnDescr = homematic("Interface.getParamset", {"interface":this.hmIPIFace, "address": this.devAddress + ":1", "paramsetKey": "MASTER"});
      this.sliderTempMin = parseInt(chnDescr.HARDWARE_COLOR_TEMPERATURE_WARM_WHITE);
      this.sliderTempMax = parseInt(chnDescr.HARDWARE_COLOR_TEMPERATURE_COLD_WHITE);
      this.virtualChannels = [1];
    }

    this._getTargetChannelTypes();

    this.devHasVirtualBlindReceiver = (this.isWired) ? this.hasActiveVirtualBlindReceiver() : true;

    var table = "";
    table += "<table class='ProfileTbl'><tbody>";

    table += "<tr id='weeklyProgramNotActive'><td>" + translateKey('lblWeeklyProgramNotActive') + "</td></tr>";

    table += this._getDelAddElm("ADD_FIRST_ELEM", 0);

    for (var i = 1; i <= this.maxEntries; i++) {
      table += this._getEntry((i < 10) ? "0" + i : i.toString());
    }
    table += "</tbody></table>";

    this.anchor.html(table);

    if (this.showHintExpertTargetChannel) {
      window.setTimeout(function () {
        jQuery("[name='hintWeeklyProgramActiveExpertChannel']").show();
      }, 250);
    }
    window.setTimeout(function () {
      delete virtChnCounterWP;
    }, 5000);

    this._extendFooterButtons();

  },

  hideShowNotActive: function() {
    if ((this.numberOfActiveEntries == 1) && (this.activeEntries["01"] == true)) {
      window.setTimeout(function () {
        jQuery("#weeklyProgramNotActive").hide();
        jQuery("#btnAddNewEntry0").hide();
      }, 250);
    } else if ((this.numberOfActiveEntries == 1) && (this.activeEntries["01"] == false)) {
      window.setTimeout(function () {
        jQuery("#weeklyProgramNotActive").hide();
      }, 250);
    }
  },

  hasActiveVirtualBlindReceiver: function () {
    var result = false,
      self = this;
    jQuery.each(this.virtualChannels, function (index, chnId) {
      var chType = self.device.channels[chnId].virtChannelType;

      self.targetChannelTypesVirtualBlind.push(chType);

      if (chType == "BLIND_VIRTUAL_RECEIVER") {
        result = true;
      }
    });

    return result;
  },


  // Checks if the device type is of a particular kind
  // This is useful for the treatment of special cases (e.g. the HmIP-BSL which is a DIMMER_WEEKLY_PROFILE but must be treated as a SWITCH_WEEKLY_PROFILE
  _isDeviceType: function (devType) {
    return (this.device.deviceType.id == devType) ? true : false;
  },

  _getEntry: function (number) {
    var programEntry = "";
    var extraClass = "hidden";
    var entryVisibilityCSS = "hidden";

    this._setEntryVisibility(number);

    if (this.isDoorLockDrive) {
      if (this.activeEntries[number] == true) {
        this.DoorLockWPMode[this.devAddress][number] = homematic("Interface.getMetadata", {
          "objectId": this.device.id,
          "dataId": "WPDoorLockMode_" + number
        });
        if ((this.DoorLockWPMode[this.devAddress][number] == "No metadata available") || (this.DoorLockWPMode[this.devAddress][number] == "null")) {
          this.DoorLockWPMode[this.devAddress][number] = this.defaultDoorLockMode;
          this.arDoorLockMetaData.push({"number": number, "value": this.DoorLockWPMode[this.devAddress][number]});
        }
      } else {
        this.DoorLockWPMode[this.devAddress][number] = this.defaultDoorLockMode;
      }
    }

    if (this.activeEntries[number] == true) {
      entryVisibilityCSS = "";
      this.numberOfActiveEntries++;
      this.hideShowNotActive();
    }


    showSlatPosHelp = function () {
      var width = 400,
        height = 75;
      MessageBox.show(translateKey("HmIPWPSlatPosHelpTitle"), translateKey("HmIPWPSlatPosHelp"), "", width, height);
    };

    programEntry += "<tr id='entry" + number + "' class=" + entryVisibilityCSS + "><td><table>";
    programEntry += "<tbody>";
    programEntry += "<tr><td colspan='6'><hr class='CLASS10400'></td></tr>";
    programEntry += "<tr><td>" + translateKey('lblWeeklyProgramSwitchpoint') + number + "</td></tr>";
    programEntry += "<tr>";
    programEntry += "<td>";
    if (!this.isDoorLockDrive) {
      // CONDITION
      programEntry += "<tr>";
      programEntry += "<td>" + translateKey('lblWPCondition') + "</td>";
      programEntry += "<td colspan='3'>" + this._getConditionElm(number) + "</td>";
      programEntry += "</tr>";

      if (this.condition[number] != 0) {
        extraClass = "";
      } else {
        extraClass = "hidden";
      }

      // ASTRO / FIXED TIME
      programEntry += "<tr id='astroTypeOffset_" + number + "' class=" + extraClass + ">";
      programEntry += "<td>" + translateKey('lblWPAstroType') + "</td><td>" + this._getAstroType(number) + "</td>";
      programEntry += "<td>" + translateKey('lblWPAstroOffset') + "</td><td>" + this._getAstroOffset(number) + "</td>";
      programEntry += "</tr>";

      if (this.condition[number] == 0 || this.condition[number] > 1) {
        extraClass = "";
      } else {
        extraClass = "hidden";
      }
    } else {
      // For HmIP-DLD - No ASTRO but only FIXED TIME
      extraClass = "";
    }
    // FIXED TIME
    programEntry += "<tr id='fixedTime_" + number + "' class=" + extraClass + ">";
    programEntry += "<td>" + translateKey('lblWPFixedTime') + "</td>";
    programEntry += " <td>" + this._getFixedTime(number) + "</td>";
    programEntry += "</tr>";

    programEntry += "<tr id='hintAstroNotWorking_"+number+"' class='hidden'>";
    programEntry += "<td></td><td colspan='4'>"+translateKey("hintAccessControlAstroNotWorking")+"</td>";
    programEntry += "</tr>";
    programEntry += "</tr>";

    if (this.isAccessTransmitterHmIP_FWI) {
      window.setTimeout(function () {
        var hintAstroNotWorkingElm = jQuery("#hintAstroNotWorking_" + number),
          conditionElm = jQuery("[name='"+number+"_WP_CONDITION']").first();
        if (parseInt(conditionElm.val()) > 0) {
          hintAstroNotWorkingElm.show();
        }
      }, 500);
    }


    programEntry += this._getHR();

    if (this.isDoorLockDrive) {
      programEntry += "<tr>" + this._getDoorLockDriveModeElem(number) + "</tr>";
    }

    if (((this._isDeviceType("HmIP-BSL")) && (this._getFwMajor() >= 2)) || (this.isWRC6230) ) {
      programEntry += "<tr>";
        programEntry += "<td>"+translateKey('lblMode')+"</td>";
        programEntry += "<td>";
          programEntry += "<select id='bslModeSelector_"+number+"' onchange='setBSLMode(this,"+this.device.id+" ,"+number+","+ this.chn +", "+this.sessionIsExpert+");'>";
          programEntry += "<option value='0'>"+translateKey('optionSwitch')+"</option>";
          programEntry += "<option value='1'>"+translateKey('optionColorSignal')+"</option>";
          programEntry += "</select>";
        programEntry += "</td>";
      programEntry += "</tr>";

    // This is for the BSL Fw. >= 2.x.x - Here we can select if the program entry acts for the switch or color mode
      programEntry += "<tr id='trBSLSwitch_" + number + "'>";
        programEntry += "<td>" + translateKey('lblWPState') + "</td>"; // Is Level, but we call it here state because it's only on/off
        programEntry += "<td>";
        programEntry += "<select id='bslOnOff_"+ number +"'  onchange='setBSLWPLevel(this.value, "+number+");'>";
          programEntry += "<option value='0'>"+translateKey('lblOff')+"</option>" ;
          programEntry += "<option value='1.000'>"+translateKey('lblOn')+"</option>" ;
        programEntry += "</select>";
        programEntry += "</td>";
      programEntry += "</tr>";

      if (this.activeEntries[number] == true) {
        window.setTimeout(function () {
          self._setBSLPanel(number);
        }, 1);
      }
    }

    if ((this._isDeviceType("HmIP-FLC")) || (this._isDeviceType("HmIP-FDC"))) {
      programEntry += this._getFLCModeSelector(number);
    }

    if (this.isDLP) {
      programEntry += this._getDLPModeSelector(number);
    }

    // RAMPTIME / LEVEL
    programEntry += "<tr id='trLevel_" + number + "'>";
    if (((this.chnType == this.DIMMER) && (! this.WINDOW_DRIVE_RECEIVER)) || (this.chnType == this.SERVO) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER)) {
      // RAMPTIME
      var lblRamptime = (this.chnType == this.SERVO) ? "lblWPServoRamptime" : "lblWPRamptime";
      programEntry += "<td id='lblWPRamptime_" + number + "'>" + translateKey(lblRamptime) + "</td>";
      programEntry += "<td>" + this._getRampTime(number) + "</td>";
    }

    // LEVEL
    if ((this.chnType == this.DIMMER) || (this.chnType == this.SERVO) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER) || (this.isWiredWGS) || (this.isWiredWGT)) {
      // programEntry += (this.chnType == this.DIMMER) ? "<td id='lblWPBrightness_" + number + "'>" + translateKey('lblWPBrightness') + "</td>" : "<td id='lblWPBrightness_" + number + "'>" + translateKey('lblWPServoPos') + "</td>";

      if ((this.chnType == this.DIMMER) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER) || (this.isWiredWGS) || (this.isWiredWGT)) {
        if (! this.WINDOW_DRIVE_RECEIVER) {
          if (this.DIMMER_WEEK_PROFILE_HmIP_WUA == "") {
            programEntry += "<td id='lblWPBrightness_" + number + "'>" + translateKey('lblWPBrightness') + "</td>";
          } else {
            programEntry += "<td id='lblWPBrightness_" + number + "'>" + translateKey('lblWPWUALevel') + "</td>";
          }
        } else {
          programEntry += "<td>" + translateKey('lblWPPosWindow') + "</td>";
        }
      } else if (this.chnType == this.SERVO) {
        programEntry += "<td id='lblWPBrightness_" + number + "'>" + translateKey('lblWPServoPos') + "</td>";
      }

    } else if (this.chnType == this.SWITCH) {
      if (!this.isDoorLockDrive) {
        if ((! this.isAccessTransmitterHmIP_FWI) && (! this.isAccessTransceiver_WKP)) {
          if (this.isDLP) {
            programEntry += "<td id='lblState_" + number + "'>" + translateKey('lblWPPermission') + "</td>"; // Is Level, but we call it here state because it's only on/off
          } else {
            programEntry += "<td id='lblState_" + number + "'>" + translateKey('lblWPState') + "</td>"; // Is Level, but we call it here state because it's only on/off
          }
        } else {
          if (this.isAccessTransmitterHmIP_FWI) {
            programEntry += "<td>" + translateKey('lblWPState_Access') + "</td>";
          }
          if (this.isAccessTransceiver_WKP) {
            programEntry += "<td>" + translateKey('lblWP_Access') + "</td>";
          }
        }
      } else {
        if (this.DoorLockWPMode[this.devAddress][number] == this.userDoorLockMode) {
          programEntry += "<td id='lblActionPermission_" + number + "'>" + translateKey('lblWPPermission') + "</td>";
        } else {
          programEntry += "<td id='lblActionPermission_" + number + "'>" + translateKey('lblWPAction') + "</td>";
        }
      }
    } else if (this.chnType == this.BLIND) {
      programEntry += "<td>" + translateKey('lblWPBlindLevel') + "</td>";
    }
    if ((! this.isWGS) && (! this.isWGT)) {
      programEntry += "<td>" + this._getLevel(number) + "</td>";
    } else {
      programEntry += "<td>" + this._getLevelWGS(number) + "</td>";
    }

    if (this.isWSM) {
      var arWSMFw = this.fwVersion.split("."),
       wsmFwMajor = parseInt(arWSMFw[0]),
       wsmFwMinor = parseInt(arWSMFw[1]);

      if ((wsmFwMajor >= 1) && (wsmFwMinor >= 4)) {
        isValueValid = function (elm) {
          if (parseInt(elm.value) > 31) {
            elm.value = 31;
          } else if (isNaN(parseInt(elm.value))) {
            elm.value = 0;
          }
        }

        showFlowControlHelp = function () {
          var width = 500,
            height = 75;
          MessageBox.show(translateKey("HelpTitle"), translateKey("helpConditionWaterFlow"), "", width, height);
        };

        this.prn++;
        var outputBehaviourVal = (this.activeEntries[number] == true) ? parseInt(this.ps[number + "_WP_OUTPUT_BEHAVIOUR"]) : 0,
          litersVal = 0, litersUnit = 0, bit = 0;

        for (bit = 0; bit <= 5; bit++) {
          if ((bit == 0) && (isBitSet(outputBehaviourVal, bit))) {
            litersVal += 1;
          }
          if ((bit == 1) && (isBitSet(outputBehaviourVal, bit))) {
            litersVal += 2;
          }
          if ((bit >= 2) && (isBitSet(outputBehaviourVal, bit))) {
            litersVal += Math.pow(2, bit);
          }
        }

        for (bit = 6; bit <= 7; bit++) {
          if (isBitSet(outputBehaviourVal, bit)) {
            litersUnit += Math.pow(2, bit);
          }
        }

        programEntry += "<td name='condWaterFlow" + number + "'>" + translateKey('powerMeasurementA') + "</td>";
        programEntry += "<td><input type='text' id='valueLiters" + number + "' size='4' name='condWaterFlow" + number + "' class='alignCenter' onblur='isValueValid(this)' value='" + litersVal + "'><span name='condWaterFlow" + number + "'> x </span>";

        programEntry += "<select id='unitLiters" + number + "' name='condWaterFlow" + number + "'>"
        programEntry += "<option value='0'>" + translateKey('optionUnit1Ltr') + "</option>";
        programEntry += "<option value='64'>" + translateKey('optionUnit10Ltr') + "</option>";
        programEntry += "<option value='128'>" + translateKey('optionUnit100Ltr') + "</option>";
        programEntry += "<option value='192'>" + translateKey('optionUnit1000Ltr') + "</option>";
        programEntry += "</select>"

        programEntry += "<img id='iconHelp_" + number + "' src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px;' alt='' onclick='showFlowControlHelp();'>";

        programEntry += "<td><input type='text' id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + number + "_WP_OUTPUT_BEHAVIOUR' value='" + outputBehaviourVal + "' size='2' class='hidden'></td>";
        programEntry += "<script>jQuery('\#unitLiters" + number + "').val(" + litersUnit + ")</script>";

        window.setTimeout(function () {
          self._setWSMOutputBehaviour(number);
        }, 50);
      }
    }

    // SLAT LEVEL for Blinds
    if ((this.chnType == this.BLIND) && (this.devHasVirtualBlindReceiver) && (! this.isShutter)) {
      programEntry += "<td name='elmSlatPos_" + number + "'>" + translateKey('lblWPSlatLevel') + "</td>";
      programEntry += "<td name='elmSlatPos_" + number + "'>" + this._getSlatLevel(number);
      if (this.isWired) {
        programEntry += "<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px;' alt='' onclick='showSlatPosHelp();'>";
      }
      programEntry += "</td>";
    }

    // Song no. and color of channel type DIMMER_OUTPUT_BEHAVIOUR
    if (
      (this.device.channels[this.chn].channelType == this.DIMMER_OUTPUT_BEHAVIOUR)
      && (!this._isDeviceType("HmIPW-WRC6"))
      && (!this._isDeviceType("HmIPW-WRC6-A"))
      && (!this.isWRC6230)
      && (!this._isDeviceType("HmIP-BSL"))
    ) {
      this.prn++;
      programEntry += "<td name='lblWPColorSelector_" + number + "' class='hidden'>" + translateKey('lblColorNr') + ": </td></td><td name='lblWPColorSelector_" + number + "' class='hidden'>" + this._getColorSelector(number) + "</td>";
      programEntry += "<td name='lblWPSoundSelector_" + number + "' class='hidden'>" + translateKey('lblSoundFileNr') + ": </td><td name='lblWPSoundSelector_" + number + "' class='hidden'>" + this._getSoundSelector(number) + "</td>";
      programEntry += "<td name='lblWPColorSoundSelector_" + number + "' class='hidden'>" + translateKey('lblColorSongNr') + ": </td><td name='lblWPColorSoundSelector_" + number + "' class='hidden'>" + this._getColorSoundSelector(number) + "</td>";
    } else if (
      (this.device.channels[this.chn].channelType == this.DIMMER_OUTPUT_BEHAVIOUR)
      && ((this._isDeviceType("HmIPW-WRC6")) || (this._isDeviceType("HmIPW-WRC6-A")) || (this.isWRC6230) || ((this._isDeviceType("HmIP-BSL")) && (this._getFwMajor() >= 2)))
      ) {
      // This is for the HmIPW-WRC6
      this.prn++;
      programEntry += "<td>" + this._getColorSelectorA(number, this.chn, this.prn) + "</td>";
      programEntry += "<td>" + this._getBlinkMode(number, this.chn, this.prn) + "</td>";
      programEntry += "<td><input id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' type='text' name='" + number + "_WP_OUTPUT_BEHAVIOUR' class='hidden' value='" + this.ps[number + '_WP_OUTPUT_BEHAVIOUR'] + "'></td>";

    }

    programEntry += "</tr>";

    // DURATION
    if ((this.chnType == this.DIMMER) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER) || ((this.chnType == this.SWITCH) && (! this.isDoorLockDrive)) && (! this.isDLP)) {
      programEntry += "<tr id='trDurationMode" + number + "'>";

      if (! this.WINDOW_DRIVE_RECEIVER) {
        programEntry += "<td>" + translateKey('lblWPDuration') + "</td>";
      } else {
        programEntry += "<td>" + translateKey('lblWPDuration1') + "</td>";
      }

      programEntry += "<td>" + this._getDurationMode(number) + "</td>";
      programEntry += "</tr>";

      programEntry += "<tr id='trDurationValue" + number + "'>";
      programEntry += "<td></td>";
      programEntry += "<td>" + this._getDuration(number) + "</td>";
      programEntry += "</tr>";
    }


    // Here we add the color picker only for active visible entries. The other color picker are added only when a new entry is created
    if (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER) {
      this.ulrPrn[number] = this.prn;
      this.prn += 3;

      if (this._isDeviceType(this.UNIVERSAL_LIGHT_RECEIVER_RGBW)) {

        programEntry += this._getHR();
        // rowULRModeSelector >> ULR = UNIVERSAL_LIGHT_RECEIVER
        programEntry += "<tr id='rowULRModeSelector_" + number + "' class='_hidden'>";
        programEntry += "<td>"+translateKey('lblMode')+"</td>";
        programEntry += "<td>";
        programEntry += "<select id='ulrEffectSelector_"+number+"'>";
        programEntry += "<option value='0'>"+translateKey('optionHueSaturation')+"</option>";
        programEntry += "<option value='1'>"+translateKey('optionColorTemp')+"</option>";
        programEntry += "<option value='2'>"+translateKey('optionEffect')+"</option>";
        //programEntry += "<option value='0'>tr RGBW</option>";
        programEntry += "</select>";
        programEntry += "</td>";
      }

      if (this._isDeviceType(this.UNIVERSAL_LIGHT_RECEIVER_DALI)) {

        programEntry += this._getHR();
        // rowULRModeSelector >> ULR = UNIVERSAL_LIGHT_RECEIVER
        programEntry += "<tr id='rowULRModeSelector_" + number + "' class='hidden'>";
        programEntry += "<td>"+translateKey('lblMode')+"</td>";
        programEntry += "<td>";
          programEntry += "<select id='ulrEffectSelector_"+number+"'>";
            if (! this.isHmIPLSS) {
              programEntry += "<option value='3'>" + translateKey('optionSwitch') + "</option>";
              programEntry += "<option value='4'>" + translateKey('optionDimmer') + "</option>";
            }
            programEntry += "<option value='1'>"+translateKey('optionColorTemp')+"</option>";
            programEntry += "<option value='0'>"+translateKey('optionHueSaturation')+"</option>";
            programEntry += "<option value='2'>"+translateKey('optionEffect')+"</option>";
            //programEntry += "<option value='0'>tr RGBW</option>";
          programEntry += "</select>";
        programEntry += "</td>";
      }
      programEntry += "<tr id='rowColorSelector_" + number + "' class='hidden'></tr>";
      if (this.activeEntries[number] == true) {
        this._getColorTempAndEffect(number);
      }
    }


    programEntry += this._getHR();

    // WEEKDAY
    programEntry += "<tr>";
    programEntry += "<td>" + translateKey('lblWPWeekday') + "</td>";
    programEntry += "<td colspan='3'>" + this._getWeekDay(number) + "</td>";
    programEntry += "</tr>";

    if (this.isWGS || this.isWGT) {
      programEntry += "<tr>";
      programEntry += "<td>Target Select</td>";
        programEntry += "<td>";
          programEntry += "<select id='wgsWPModeSelector" + this.chn + "_" + number + "' onchange='setWGSPanel("+this.chn+","+number+",this.value, "+(this.prn - 3)+","+this.sessionIsExpert+");'>";
            programEntry += "<option value='0'>Backlight</option>";
            if (this.extraParam != "showOnlyBackLightingReceiver") {
              programEntry += "<option value='1'>Switchaktor</option>";
            }
            programEntry += "</select>";
        programEntry += "</td>";
      programEntry += "</tr>";
    }

    // TARGET CHANNELS
    programEntry += "<tr name='panelTargetChannel_" + number + "'>";

    if ((!this.isDoorLockDrive) && (!this.isAccessTransceiver_WKP)) {
      programEntry += "<td>" + translateKey('lblWPTargetChannels') + "</td>";
    } else {
      programEntry += "<td>" + translateKey('lblUser') + "</td>";
    }

    programEntry += "<td colspan='3'>" + this._getTargetChannels(number) + "</td>";
    programEntry += "</tr>";

    if (this.isDoorLockDrive || this.WINDOW_DRIVE_RECEIVER) {
      var switchPointMode = (! this.WINDOW_DRIVE_RECEIVER) ? this.DoorLockWPMode[this.devAddress][number] : "";  //DoorLockMode or UserMode
      window.setTimeout(function () {
        self._showHideTargetChannels(number, switchPointMode);
      }, 1000);
    }

    programEntry += "</td>";
    programEntry += "</tr>";

    if (this.virtualChannels.length > 1) {
      programEntry += "<tr name='hintWeeklyProgramActiveExpertChannel' class='hidden'>";
      programEntry += "<td></td>";
      programEntry += "<td colspan='5'>" + translateKey('hintWeeklyProgramActiveExpertChannel') + "</td>";
      programEntry += "</tr>";

      if ((! this._isDeviceType("HmIP-FLC")) && (! this._isDeviceType("HmIP-FDC")) && (! this.isWGS) && (! this.isWGT) && (! this.isDLP)) {
        programEntry += "<tr name='panelTargetChannel_" + number + "'>";
        if (!this.isAccessTransmitterHmIP_FWI) {
          if ((!this.isDoorLockDrive) && (!this.isAccessTransceiver_WKP)) {
            programEntry += "<td>" + translateKey('lblSelectTargetChannels') + "</td>";
          } else {
            programEntry += "<td>" + translateKey('lblSelectTargetUser') + "</td>";
          }
        }
        programEntry += "<td>" + this._getPanelSelectTargetChannels(this.chn, number, this.prn) + "</td>";

        programEntry += "</tr>";
      }
    }
    programEntry += this._getHR();

    // Is the next entry not active AND it's not the last one? If so, then allow to add a new one.
    if ((this.ps[(this._addLeadingZero(parseInt(number) + 1)) + "_WP_WEEKDAY"] == "0") && (parseInt(number) < this.maxEntries)) {
      programEntry += this._getDelAddElm("DEL ADD", number);
    } else {
      programEntry += this._getDelAddElm("DEL", number);
    }

    programEntry += "</tbody>";
    programEntry += "</table></td></tr>";

    return programEntry;
  },

  _isNextEntryInUse: function (number) {
    var nextEntry = parseInt(number) + 1;
    nextEntry = (nextEntry < 10) ? "0" + nextEntry : nextEntry.toString();
    var val = parseInt(jQuery("#separate_CHANNEL_" + this.weekDayID[nextEntry]).val());
    return ((isNaN(val)) || (val == undefined) || (val == 0)) ? false : true;
  },


  _getConditionElm: function (number) {
    var self = this,
      result = "",
      selected = "",
      arOptions = [
        translateKey("optionWeekPrgFixed"),
        translateKey("optionWeekPrgAstro"),
        translateKey("optionWeekPrgFixedIfBeforeAstro"),
        translateKey("optionWeekPrgAstroIfBeforeFixed"),
        translateKey("optionWeekPrgFixedIfAfterAstro"),
        translateKey("optionWeekPrgAstroIfAfterFixed"),
        translateKey("optionWeekPrgEarliestOfFixedAndAstro"),
        translateKey("optionWeekPrgLatestOfFixedAndAstro")
      ],

      // If the entry is not active the selected value should be 0
      sel = (this.activeEntries[number] == true) ? parseInt(this.ps[number + "_WP_CONDITION"]) : 0;

    this.prn++;
    this.condition[number] = parseInt(sel);

    deactivateTargetAccessTransmitter = function (number, condition, prn, chn) {
      var hintAstroNotWorkingElm = jQuery("#hintAstroNotWorking_" + number),
        targetElm;
      for (var loop = 0; loop <= 7; loop++) {
        targetElm = jQuery("#targetChannel" + number + "_" + loop);
        if (condition == 0) {
          targetElm.off();
          targetElm.removeAttr("onchange");
          targetElm.prop("checked", false).on("click", function () {
            setWPTargetChannels("targetChannel" + chn + "_" + number, chn, self.prnHiddenField[number]);
          });
          hintAstroNotWorkingElm.hide();
        } else {
          targetElm.off();
          targetElm.prop("checked", false).on("click", function () {
            jQuery(this).prop("checked", false);
            alert(translateKey("hintFWITargetNotPossible"));
          });
          hintAstroNotWorkingElm.show();
        }
      }

      setWPTargetChannels("targetChannel" + chn + "_" + number, chn, self.prnHiddenField[number]);
    };

    showAstroFixedInputElm = function (number, condition, prn, chn) {
      number = self._addLeadingZero(number);
      self.condition[number] = condition;
      var fixedTimeElm = jQuery("#fixedTime_" + number),
        astroTypeAndOffset = jQuery("#astroTypeOffset_" + number);

      if (condition == 0) {
        fixedTimeElm.show();
        astroTypeAndOffset.hide();
      } else if (condition == 1) {
        fixedTimeElm.hide();
        astroTypeAndOffset.show();
      } else if (condition > 1) {
        fixedTimeElm.show();
        astroTypeAndOffset.show();
      }

      if (self.isAccessTransmitterHmIP_FWI) {
        deactivateTargetAccessTransmitter(number, condition, prn, chn);
      }

    };

    showConditionHelp = function () {
      var width = 600,
        height = 450;
      MessageBox.show(translateKey("HmIPWPHelpTitle"), translateKey("HmIPWPConditionHelp"), "", width, height);
    };

    result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + number + "_WP_CONDITION' onchange='showAstroFixedInputElm(" + number + ",parseInt(this.value), " + this.prn + ", " + this.chn + ");'>";
    for (var loop = 0; loop < arOptions.length; loop++) {
      selected = (sel == loop) ? "selected='selected'" : "";
      result += "<option value='" + loop + "' " + selected + ">" + arOptions[loop] + "</option>";
    }
    result += "</select>";
    result += "<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px;' alt='' onclick='showConditionHelp();'>";
    return result;
  },

  _getFixedTime: function (number) {
    var result = "",
      valHr = (this.activeEntries[number] == true) ? parseInt(this.ps[number + "_WP_FIXED_HOUR"]) : 0,
      valMin = (this.activeEntries[number] == true) ? parseInt(this.ps[number + "_WP_FIXED_MINUTE"]) : 0,
      curTime = this._addLeadingZero(valHr) + ":" + this._addLeadingZero(valMin);

    result += "<input type='text' id='fixedTime" + number + "' style='text-align:center;' maxlength='5' size='7' value='" + curTime + "'  onblur='checkWPFixedTime(this, " + this.chn + "," + (parseInt(this.prn) + 1) + ")'>";

    result += "<script type='text/javascript'>";
    result += "jQuery( '#fixedTime" + number + "').on( 'keydown', function(event) {";
    result += "    if(event.which == 13)";
    result += "      checkWPFixedTime(this, " + this.chn + "," + (parseInt(this.prn) + 1) + ")";
    result += "  });";
    result += "</script>";

    this.prn++;
    result += "<input type='text' class='hidden' id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + number + "_WP_FIXED_HOUR' value='" + valHr + "' size='2'>";
    this.prn++;
    result += "<input type='text' class='hidden' id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + number + "_WP_FIXED_MINUTE' value='" + valMin + "' size='2'>";
    return result;
  },

  _getAstroType: function (number) {
    var result = "";
    var selected = "";
    var arOptions = [
      translateKey("optionSunrise"),
      translateKey("optionSunset")
    ];

    var sel = (this.activeEntries[number] == true) ? parseInt(this.ps[number + "_WP_ASTRO_TYPE"]) : 0;
    this.prn++;

    result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + number + "_WP_ASTRO_TYPE' >";

    for (var loop = 0; loop < arOptions.length; loop++) {
      selected = (sel == loop) ? "selected='selected'" : "";
      result += "<option value='" + loop + "' " + selected + ">" + arOptions[loop] + "</option>";
    }
    result += "</select";

    return result;
  },

  _getAstroOffset: function (number) {
    var result = "",
      astroMin = this.psDescr.ASTRO_OFFSET_MIN,
      astroMax = this.psDescr.ASTRO_OFFSET_MAX,
      astroUnit = this.psDescr.ASTRO_OFFSET_UNIT,
      val = (this.activeEntries[number] == true) ? parseInt(this.ps[number + "_WP_ASTRO_OFFSET"]) : 0;

    this.prn++;
    result += "<input type='text' id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + number + "_WP_ASTRO_OFFSET' value='" + val + "' size='2' onblur='checkWPMinMaxValue(this," + astroMin + "," + astroMax + ")'> " + astroUnit + " (" + astroMin + " - " + astroMax + ")";

    result += "<script type='text/javascript'>";
    result += "jQuery( '#separate_CHANNEL_" + this.chn + "_" + this.prn + "').on( 'keydown', function(event) {";
    result += "    if(event.which == 13)";
    result += "      checkWPMinMaxValue(this," + astroMin + "," + astroMax + ")";
    result += "  });";
    result += "</script>";
    return result;
  },

  _getDurationMode: function (number) {
    var self = this;

    initDurationMode = function (nr) {
      var number = self._addLeadingZero(nr);
      var valBaseID = number + "_WP_DURATION_BASE",
        valFactorID = number + "_WP_DURATION_FACTOR",
        valBase, valFactor;

      if (!self.isAccessTransceiver_WKP) {
        valBase = (self.activeEntries[number] == true) ? parseInt(self.ps[valBaseID]) : 0;
        valFactor = (self.activeEntries[number] == true) ? parseInt(self.ps[valFactorID]) : 0;
      } else {
        valBase = (self.activeEntries[number] == true) ? parseInt(self.ps[valBaseID]) : 7;
        valFactor = (self.activeEntries[number] == true) ? parseInt(self.ps[valFactorID]) : 31;
        if (self.activeEntries[number] == false) {
          window.setTimeout(function() {
            var elm = jQuery("[name=" + number + "_WP_LEVEL]")[0];
            jQuery(elm).val('1.000').change();

            jQuery("#durationMode"+number).change();

          },50);
        }
      }
      var setDurationValueElm = jQuery('#trDurationValue' + number);
      var setDurationModeElm = jQuery('#durationMode' + number);

      if ((valBase == 7) && (valFactor == 31)) {
        setDurationValueElm.hide();
        setDurationModeElm.val('0');
      } else {
        setDurationValueElm.show();
        setDurationModeElm.val('1');
      }
    };

    showHideUserValue = function (value, number, prn) {
      var setDurationModeElm = jQuery('#trDurationValue' + self._addLeadingZero(number));
      var factorElm = jQuery("#separate_CHANNEL_" + self.chn + "_" + (parseInt(prn) + 1));
      var baseElm = jQuery("#separate_CHANNEL_" + self.chn + "_" + (parseInt(prn) + 2));

      if (parseInt(value) == 0) {
        setDurationModeElm.hide();
        factorElm.val(31);
        baseElm.val(7);
      } else {
        setDurationModeElm.show();
      }
    };

    var result = "";

    result += "<select id='durationMode" + number + "' onchange='showHideUserValue(this.value," + number + "," + this.prn + ")'>";
    result += "<option value='0'>" + translateKey('optionPermanent') + "</option>";
    result += "<option value='1'>" + translateKey('optionEnterValue') + "</option>";
    result += "</select>";
    result += "<script type='text/javascript'>";
    result += "window.setTimeout(function(){";
    result += "initDurationMode(" + number + ");";
    result += "},50)";
    result += "</script>";
    return result;
  },

  _getDuration: function (number) {
    return this._getDurationRamptimeHTML("duration", number);
  },

  _getRampTime: function (number) {
    return this._getDurationRamptimeHTML("ramptime", number);
  },

  _setWGSPanel: function(number) {
    var valModeSelector = parseInt(jQuery("#wgsWPModeSelector" + self.chn + "_" + number).val()),
      relevantElms = [];

    var levelElm = jQuery("#" + number + "_WP_LEVEL");

    jQuery("[name='targetChannel"+self.chn+"_"+number+"']").hide().prev().hide();

    switch (valModeSelector) {
      case 0:
        relevantElms = jQuery("[data='BACKLIGHTING_RECEIVER'][name='targetChannel"+self.chn+"_"+number+"']");
        break;
      case 1:
        relevantElms = jQuery("[data='SWITCH_VIRTUAL_RECEIVER'][name='targetChannel"+self.chn+"_"+number+"']");
        break;
      default: console.log("Hm, here we have a problem");
    }

    jQuery(relevantElms).show().prev().show();
  },

  // This sets the Panel according to the mode (SWITCH or COLOR)
  _setBSLPanel: function(number) {
      var val2clear = 0;
      var WPTargetChannelsElm = jQuery("[name='"+number+"_WP_TARGET_CHANNELS']"),
        bslModeSelectorElm = jQuery("#bslModeSelector_" + number),
        trLevelElm = jQuery("#trLevel_" + number),
        trBSLSwitchElm = jQuery("#trBSLSwitch_" + number),
        bslOnOffElm = jQuery("#bslOnOff_" + number);

      var selectedBSLMode = parseInt(homematic("Interface.getMetadata", {
        "objectId": self.device.id,
        "dataId": "bslMode" + number
      }));
      var wpState = (parseInt(self.ps[number + "_WP_LEVEL"]) == "0.000000") ? "0" : "1.000";
      var arTargetChn = jQuery("[name='targetChannel"+self.chn+"_"+number+"']");
      if (! isNaN(selectedBSLMode)) {
        bslModeSelectorElm.val(selectedBSLMode);
        if (selectedBSLMode == 0) { //  mode SWITCH
          trLevelElm.hide();

          var x = (this.sessionIsExpert) ? 3 : 1;
          for (var i = x; i < arTargetChn.length; i++) {
            jQuery(arTargetChn[i]).prev().hide(); // label of the checkbox
            if (jQuery(arTargetChn[i]).is(':checked')) {val2clear += arTargetChn[i].val();}
            if (isBitSet(parseInt(WPTargetChannelsElm.val()),i)) {
              val2clear += parseInt(jQuery(arTargetChn[i]).val());
            }
            arTargetChn[i].hide(); // the checkbox itself
          }
          WPTargetChannelsElm.val(parseInt(WPTargetChannelsElm.val()) - val2clear);
          trBSLSwitchElm.show();
          bslOnOffElm.val(wpState);
        } else { // mode COLOR DIMMER
          if (this.sessionIsExpert) {
            for (var i = 0; i < 3; i++) {
              if (jQuery(arTargetChn[i]).is(':checked')) {
                val2clear += arTargetChn[i].val();
              }
              if (isBitSet(parseInt(WPTargetChannelsElm.val()), i)) {
                val2clear += parseInt(jQuery(arTargetChn[i]).val());
              }
              jQuery(arTargetChn[i]).prev().hide(); // label
              arTargetChn[i].hide();  // ceckbox
            }
          } else {
            jQuery(arTargetChn[0]).prev().hide(); // label
            arTargetChn[0].hide();  // ceckbox
          }

          WPTargetChannelsElm.val(parseInt(WPTargetChannelsElm.val()) - val2clear);
          trLevelElm.show();
          trBSLSwitchElm.hide();
        }
      } else { // Default mode SWITCH (when metadata is still not set)
        bslModeSelectorElm.val(0);
        trLevelElm.hide();

        bslOnOffElm.val(wpState);

        if (! this.sessionIsExpert) {
          jQuery(arTargetChn).prev().hide(); // label
          arTargetChn.hide();

          jQuery(arTargetChn[0]).prev().show(); // label
          arTargetChn[0].show();
        }

        for (var i = 3; i < arTargetChn.length; i++) {
          jQuery(arTargetChn[i]).prev().hide(); // label
          arTargetChn[i].hide();  // checkbox
        }
        trBSLSwitchElm.show();
      }
  },

  _getColorTempAndEffect: function(number) {
    //var currentEffectType = this.ps[number + "_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_TYPE"],
    var currentEffectType = (this.selectedMode_RGBW < 2) ? 0 : 1,
      currentEffectValue = parseInt(this.ps[number + "_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_VALUE"]),
      selectedWPMode;

    this.currentLevel[number] = this.ps[number + "_WP_LEVEL"];

    var PRN = this.ulrPrn[number];
    var self = this;

    setSelectedWPMode = function (val, number) {
      homematic("Interface.setMetadata", {
        "objectId": self.device.id,
        "dataId": "daliWPMode_" + number,
        "value": val
      });
    };

    setEffectType = function(val, no, chn, prn) {
      var nr = addLeadingZero(no),

        trColorSelector = jQuery("#rowColorSelector_" + nr),

        trRampAndLevel = jQuery("#trLevel_" + nr),

        hueSaturationElm = jQuery("[name='wpHueSaturation_" + nr +"']"),
        colorTempElm = jQuery("[name='wpColorTemp_" + nr +"']"),
        colorTempSwitchElm = jQuery("#colorTempSwitch_" + nr),
        tdEffect = jQuery("[name='wpEffect_" + nr +"']"),
        lblBrightnessElm = jQuery("#lblWPBrightness_" + nr),
        optionBrightnessElm = jQuery(lblBrightnessElm).next().children("select:first"), // option field LEVEL
        freeValueBrightnessElm = jQuery(optionBrightnessElm).nextAll().not(':last'), // Enter free value field LEVEL
        textBrightnessElm = jQuery("#separate_CHANNEL_" + chn + "_" + (parseInt(prn) + 1)), // text LEVEL
        nameBrightnessElm = nr + "_WP_LEVEL",
        brightnessElm = jQuery("[name='" + nameBrightnessElm + "']"),
        valBrightness,
        currentEffectValue = parseInt(self.ps[nr + "_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_VALUE"]);

      var colorHueSatEffectElm = jQuery("[name='"+nr+"_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_VALUE']").first();

      colorTempSwitchElm.val( (parseInt(self.currentLevel[nr] * 100) == 0) ? 0 : 1 );

      jQuery("#separate_CHANNEL_"+chn+"_"+prn).val(val);

      val = parseInt(val);
      switch (val) {
        case 0: // Hue/Saturation
          brightnessElm.attr("disabled", false);
          if ((parseInt(colorHueSatEffectElm.val()) < 0) || ((parseInt(colorHueSatEffectElm.val()) > 362 * 256))) {colorHueSatEffectElm.val(0);}
          jQuery("#valHue_" + nr).val(parseInt(parseInt(colorHueSatEffectElm.val()) / 256));
          jQuery("#valSaturation_" + nr).val(parseInt(parseInt(colorHueSatEffectElm.val()) % 256 / 2));
          jQuery("#valLevel_" + nr).val(parseInt(textBrightnessElm.val() * 100));

          jQuery("#tdHueSaturation_" + nr).show().prev().text(translateKey("lblColorValue"));
          jQuery("#tdColorTempSlider_" + nr).hide();
          jQuery("#tdColorTempSwitch_" + nr).hide();
          tdEffect.hide();

          hueSaturationElm.show();
          colorTempElm.hide();
          //lblBrightnessElm.hide();
          trRampAndLevel.hide();
          optionBrightnessElm.attr('name',''); //.hide();freeValueBrightnessElm.hide();
          textBrightnessElm.attr('name',nameBrightnessElm);

          trColorSelector.show();

          jQuery("#trDurationMode" + nr).show();
          if (parseInt(jQuery("#durationMode" + nr).val()) != 0) {
            jQuery("#trDurationValue" + nr).show();
          }

          break;
        case 1: // Color Temp
          jQuery("#lblEffectType_" + nr).text(translateKey("lblColorTemp"));
          brightnessElm.attr("disabled", false);

          trRampAndLevel.show();
          lblBrightnessElm.show();
          lblBrightnessElm.next().show();
          //if ((parseInt(colorHueSatEffectElm.val()) < 1000) || ((parseInt(colorHueSatEffectElm.val()) > 10000))) {colorHueSatEffectElm.val(self.sliderTempMin);}
          if ((parseInt(colorHueSatEffectElm.val()) < 50) || ((parseInt(colorHueSatEffectElm.val()) > 200))) {colorHueSatEffectElm.val(self.sliderTempMin / 50);}
          //jQuery("#valColorTemp_" + nr).show().val(colorHueSatEffectElm.val()).blur();
          jQuery("#valColorTemp_" + nr).show().val((parseInt(colorHueSatEffectElm.val()) * 50)).blur();
          jQuery("#tdHueSaturation_" + nr).hide();
          jQuery("#tdColorTempSwitch_" + nr).hide();
          jQuery("#tdColorTempSlider_" + nr).show();
          jQuery("[name='wpColorTemp_" + nr + "']").show();

          hueSaturationElm.hide();
          colorTempElm.show();
          tdEffect.hide();
          lblBrightnessElm.show();

          trColorSelector.show();

          valBrightness = (self.activeEntries[nr] == true) ? (1 * self.ps[nameBrightnessElm]).toFixed(3) : "0.000";
          if (parseInt(parseFloat(valBrightness * 1000)) == 0) {
            valBrightness = "0";
          }
          optionBrightnessElm.attr('name', nameBrightnessElm).val(valBrightness).change().show();

          freeValueBrightnessElm.val(parseInt(valBrightness * 100));
          textBrightnessElm.attr('name','');
          break;
        case 2: // Effect
          if ((currentEffectValue == 0) || (currentEffectValue > 20)) {
            colorHueSatEffectElm.val("1");
          } else {
            colorHueSatEffectElm.val(currentEffectValue);
          }

          jQuery("#lblEffectType_" + nr).text(translateKey("lblEffect"));
          jQuery("#valEffectSelector_" + nr).val(colorHueSatEffectElm.val());

          hueSaturationElm.hide();
          colorTempElm.hide();
          jQuery("#tdColorTempSwitch_" + nr).hide();
          jQuery("#tdColorTempSlider_" + nr).hide();
          trRampAndLevel.show();
          tdEffect.show();

          trColorSelector.show();

          valBrightness = (self.activeEntries[nr] == true) ? (1 * self.ps[nameBrightnessElm]).toFixed(3) : "0.000";
          if (parseInt(parseFloat(valBrightness * 1000)) == 0) {
            valBrightness = "0";
          }
          optionBrightnessElm.attr('name', nameBrightnessElm).val(valBrightness).change().show();

          freeValueBrightnessElm.val(parseInt(valBrightness * 100));
          textBrightnessElm.attr('name','');
          setEffectBrightness(nr);
          break;
        case 3: // Switch
          brightnessElm.attr("disabled", false);
          jQuery("#lblEffectType_" + nr).text(translateKey("lblSwitchingState"));
          //lblBrightnessElm.hide();
          //lblBrightnessElm.next().hide();
          trRampAndLevel.hide();
          jQuery("#valColorTemp_" + nr).hide();
          jQuery("[name='wpColorTemp_" + nr + "']").hide();
          jQuery("#tdHueSaturation_" + nr).hide();
          jQuery("#tdColorTempSlider_" + nr).hide();
          tdEffect.hide();
          jQuery("#tdColorTempSwitch_" + nr).change().show();

          trColorSelector.show();

          valBrightness = (self.activeEntries[nr] == true) ? (1 * self.ps[nameBrightnessElm]).toFixed(3) : "0.000";
          optionBrightnessElm.attr('name', nameBrightnessElm).val(valBrightness).change().show();
          freeValueBrightnessElm.val(parseInt(valBrightness * 100));
          setSwitchStatus(nr, self.currentLevel[nr]);

          textBrightnessElm.attr('name','');
          break;
        case 4: // Dimmer
          brightnessElm.attr("disabled", false);
          trColorSelector.hide();
          trRampAndLevel.show();

          valBrightness = (self.activeEntries[nr] == true) ? (1 * self.ps[nameBrightnessElm]).toFixed(3) : "0.000";
          if (parseInt(parseFloat(valBrightness * 1000)) == 0) {
            valBrightness = "0";
          }
          optionBrightnessElm.attr('name', nameBrightnessElm).val(valBrightness).change().show();

          freeValueBrightnessElm.val(parseInt(valBrightness * 100));
          textBrightnessElm.attr('name','');

          break;
        default:
          // Show all elements - no valid value!
          conInfo("ERROR: setEffectType - no valid value");
          hueSaturationElm.show();
          colorTempElm.show();
          //tdEffect.show();  currently not in use
          lblBrightnessElm.show();
          optionBrightnessElm.attr("name", nameBrightnessElm).show();//freeValueBrightnessElm.show();
          textBrightnessElm.attr('name','');
      }

    };

    setHueSatValue2Transmit = function(number, chn, prn) {
      var val2SendElm = jQuery("#separate_CHANNEL_" + chn + "_" + (parseInt(prn) + 2)),
        valHueElm = jQuery("#valHue_" + self._addLeadingZero(number)),
        valSaturationElm = jQuery("#valSaturation_" + self._addLeadingZero(number)),
        valHue = (isNaN(parseInt(valHueElm.val()))) ? 0 : (parseInt(valHueElm.val())),
        valSaturation = (isNaN(parseInt(valSaturationElm.val()))) ? 0 : (parseInt(valSaturationElm.val()));

      valHue =  (valHue > 360) ? 360 : valHue;
      valSaturation =  (valSaturation > 100) ? 100 : valSaturation;
      valHueElm.val(valHue);
      valSaturationElm.val(valSaturation);

      val2SendElm.val((valHue * 256) + (valSaturation * 2));
    };

    setLevelValue2Transmit = function(number, chn, prn, value) {
      var val2SendElm = jQuery("#separate_CHANNEL_" + chn + "_" + prn),
        valLevelElm = jQuery("#valLevel_" + self._addLeadingZero(number)),
        valLevel = (isNaN(parseInt(valLevelElm.val()))) ? 0 : (parseInt(valLevelElm.val()));

      valLevel =  (valLevel > 100) ? 100 : valLevel;
      valLevelElm.val(valLevel);

      val2SendElm.val(valLevel / 100);
    };

    setSwitchStatus = function(number, value) {
      //01_WP_LEVEL
      //var brighnessElm = jQuery("[name="+self._addLeadingZero(number)+"_WP_LEVEL]");
      var brighnessElm = document.getElementsByName(self._addLeadingZero(number)+"_WP_LEVEL");

      if (typeof brighnessElm[0] != "undefined") {
        brighnessElm[0].value = (parseInt(value) == 0) ? "0" : "1.000";
      } else {console.log("ERROR",self._addLeadingZero(number)+"_WP_LEVEL -- not found");}
    };

    setEffectBrightness = function(number) {
      var number = self._addLeadingZero(number),
        val2Send = parseInt(jQuery("[name='"+number+"_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_VALUE']").first().val()),
        brightnessElm = jQuery("#lblWPBrightness_" + number).next().children("select:first");

      if (val2Send == 0) {
        brightnessElm.val("0").attr("disabled", true); // option field LEVEL
      } else {
        brightnessElm.attr("disabled", false);
      }
    };

    // The Tunable White value of the RGB and DALI devices has to be diveded by 50
    adaptValue = function(elm, number) {
      var no = self._addLeadingZero(number);
      if (parseInt(jQuery("#ulrEffectSelector_" + no).val()) == 1) {
        var valColorTempElm = jQuery("[name="+no+"_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_VALUE]").first();
        valColorTempElm.val((parseInt(elm.value) / 50));
      }
    };

    if ((self._isDeviceType(self.UNIVERSAL_LIGHT_RECEIVER_DALI)) || (self._isDeviceType(self.UNIVERSAL_LIGHT_RECEIVER_RGBW))) {
      // modes 0=RGB, 1=Tunable White, 3=SWITCH, 4=DIMMER  > 0 and 1 displays the same elements as the HmIP-RGB, 2 (RGBW) is not in use for DALI. 3 and 4 are DALI only
       selectedWPMode = parseInt(homematic("Interface.getMetadata", {
        "objectId": this.device.id,
        "dataId": "daliWPMode_" + number
      }));

      if (isNaN( selectedWPMode)) {
        selectedWPMode = 0;
        setSelectedWPMode( selectedWPMode, number);
      }
      currentEffectType = selectedWPMode;
      window.setTimeout(function() {
        jQuery("#ulrEffectSelector_" +number).val(selectedWPMode).unbind().change(function() {
          currentEffectType = parseInt(this.value);
          setSelectedWPMode( parseInt(this.value), number);
          setEffectType(parseInt(this.value), parseInt(number), self.chn, (PRN - 2));
        }).change();
        jQuery("#rowULRModeSelector_" + number).show();
      },100);
    }

    var result = "";
    PRN++;
    result += (currentEffectType < 3) ? "<td id='lblEffectType_"+number+"'>" + translateKey('lblColorTemp') + "</td>" : "<td id='lblEffectType_"+number+"'>" + translateKey('lblSwitchingState') + "</td>";

/*
    result += "<td style=''>";
      result += "<select id='separate_CHANNEL_"+this.chn+"_"+PRN+"' value='"+currentEffectType+"' name='"+number+"_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_TYPE' onchange='setEffectType(this.value,"+number+");'>";
        result += "<option value='0'>"+ translateKey('optionHueSaturation')+"</option>";
        result += "<option value='1'>"+translateKey('optionColorTemp')+"</option>";
        //result += "<option value='2'>Effect</option>";
      result += "</select>";
    result += "</td>";
*/
    // Here we collect the value hue/saturation, color or effect
    result += "<td id='tdHueSaturation_" + number +"' name='wpHueSaturation_" +  number + "' class='hidden'>";
      result += "<table>";
        result += "<tr>";

          //result += "<td><input id='colorPicker_" + number + "' class='basic'></td>"; // Anchor Spectrum Color Picker
          result += "<td style='padding-right:20px;'><div id='colorPicker_" + number + "' class='basic'></div></td>"; // Anchor Iro Color Picker

          result += "<td style='padding-bottom:35px;'>";
            result += "<table style='padding:10px;' class='infoBckGnd'>";

              result += "<tr>";
                result += "<td class='alignRight infoBckGnd'>H</td>";
                result += "<td class='infoBckGnd'>";
                  result += "<input id='valHue_" + number +"' type='text' class='alignCenter' size='5' onchange='setHueSatValue2Transmit("+number+","+this.chn+","+PRN+");'>";// Bit 8 -19
                result += "</td>";
                result += "<td class='alignLeft infoBckGnd'>&deg;</td>";
              result += "</tr>";

              result += "<tr>";
                result += "<td class='alignRight infoBckGnd'>S</td>";
                result += "<td class='infoBckGnd'>";
                  result += "<input id='valSaturation_" +number + "' type='text' class='alignCenter' size='5' onchange='setHueSatValue2Transmit("+number+","+this.chn+","+PRN+");'>"; // Bit 0 - 7
                result += "</td>";
                result += "<td class='alignLeft infoBckGnd'>%</td>";
              result += "</tr>";

              result += "<tr>";
                PRN++;
                result += "<td class='alignRight infoBckGnd'>V</td>";
                result += "<td class='infoBckGnd'>";
                  result += "<input id='valLevel_" +number + "' type='text' class='alignCenter' size='5' onchange='setLevelValue2Transmit("+number+","+this.chn+","+PRN+",this.value);'>";
                result += "</td>";
                result += "<td class='alignLeft infoBckGnd'>%</td>";
                result += "<td class='hidden alignRight infoBckGnd'>V</td>";
                result += "<td class='hidden infoBckGnd'>";
                  result += "<input type='text' id='separate_CHANNEL_"+this.chn+"_"+PRN+"' name='"+number+"_WP_LEVEL' value='"+this.currentLevel[number]+"' class='alignCenter' size='5'>";
                result += "</td>";
              result += "</tr>";

            result += "</table>";
          result += "</td>";
        result += "</tr>";
      result += "</table>";
    result += "</td>";

    result += "<td id='tdColorTempSlider_"+number+"' class='hidden'><div id='colorTempSlider_"+number+"'></div></td>";

    result += "<td colspan='3' name='wpColorTemp_" +  number + "' class='hidden'>";
      result += "<table>";
        result += "<tr>";
          result += "<td name='_wpColorTemp_" +  number + "'>&nbsp;</td>";
          result += "<td name='_wpColorTemp_" +  number + "'>";
            result += "<input id='valColorTemp_"+number+"' type='text' class='alignCenter hidden' size='3' onchange='jQuery(\"#separate_CHANNEL_"+this.chn+"_"+(parseInt(PRN) + 1)+"\").val(this.value); adaptValue(this, "+number+")'>&nbspK ("+this.sliderTempMin+" K - "+this.sliderTempMax+" K)";
          result += "</td>";
        result += "</tr>";
      result += "</table>";
    result += "</td>";


    // Effect Selector
    result += "<td colspan='2' name='wpEffect_" +  number + "' class='hidden'><table><tr>";
    //result += "<td name='_wpEffect_" +  number + "' class='_hidden'>Effect</td>";
    result += "<td name='_wpEffect_" +  number + "' class='_hidden'>";
      result += "<select id='valEffectSelector_"+number+"' onchange='jQuery(\"#separate_CHANNEL_"+this.chn+"_"+(parseInt(PRN) + 1)+"\").val(this.value);setEffectBrightness("+number+");'>";
        result += "<option value='1'>"+translateKey('optionNoEffect')+"</option>";
        result += "<option value='3'>"+translateKey('optionRainbow')+"</option>";
        result += "<option value='5'>"+translateKey('Sonnenaufgang')+"</option>";
        result += "<option value='7'>"+translateKey('optionSunset')+"</option>";
        result += "<option value='11'>"+translateKey('optionForrest')+"</option>";
      result += "</select>";
    result += "</td>";
    result += "</tr></table></td>";
    /* END EFFECT */

    // SWITCH
    result += "<td id='tdColorTempSwitch_"+number+"' class='hidden'>";
      result += "<select id='colorTempSwitch_" + number + "' onchange='setSwitchStatus("+number+", this.value);' >";
        result += "<option value='0'>" +translateKey('lblOff')+ "</option>";
        result += "<option value='1'>" +translateKey('lblOn')+ "</option>";
      result += "</select>";
    result += "</td>";
    // END SWITCH

    result += "<td class='hidden'>";
      result += "<select id='separate_CHANNEL_"+this.chn+"_"+(PRN - 1)+"' value='"+currentEffectType+"' name='"+number+"_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_TYPE' onchange='setEffectType(this.value,"+number+");'>";
        result += "<option value='0'>"+ translateKey('optionHueSaturation')+"</option>";
        result += "<option value='1'>"+translateKey('optionColorTemp')+"</option>";
        result += "<option value='2'>"+translateKey('optionEffect')+"</option>";
        result += "<option value='3'>Switch</option>";
        result += "<option value='4'>Dimmer</option>";
        //result += "<option value='2'>Effect</option>";
      result += "</select>";
    result += "</td>";
    // Hidden field, which contains the volue of either the hue/saturation, the color or the effect
    PRN++;
    result += "<td class='hidden'><span>To send</span><input id='separate_CHANNEL_"+this.chn+"_"+PRN+"' name='"+number+"_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_VALUE' value='"+ currentEffectValue +"' size='5'></td>";

    result += "<script type='text/javascript'>";
    if(this.activeEntries[number] == true) {

      result +=
        "window.setTimeout(function() {" +

        "var oDevice = DeviceList.getDeviceByAddress('"+this.devAddress+"')," +
        "effectName, effectNo," +
        "arEffectValue = [0,1,3,5,7,9,11,13,15,17,19]," +
        "effectSelectorElm = jQuery('#valEffectSelector_"+number+"');" +

        "effectSelectorElm.empty().append('<option value=0>"+translateKey('optionStopEffect')+"</option>');" +
        "for (effectNo = 1; effectNo <= 10; effectNo++) {" +
          "effectName =  homematic('Interface.getMetadata', {'objectId': oDevice.id, 'dataId': 'effectName_' + effectNo});" +
          "if ((effectName == '') || (effectName == 'null')) {effectName = translateKey('lblEffect') + ' ' + effectNo;}"+
          "effectSelectorElm.append(\"<option value='\"+arEffectValue[effectNo]+\"'>\"+effectName+\"</option>\");" +
        "}  "+

        "setEffectType(" + currentEffectType + ", " + number + ", " + this.chn + ", " + (parseInt(PRN) - 2) + "); " +

        // Color temp slider"
        "var valColorTempElm = jQuery('#valColorTemp_"+number+"');" +

        "var sliderOpts = {};" +
        "sliderOpts.animate = 'fast';" +
        "sliderOpts.min = "+this.sliderTempMin+";" +
        "sliderOpts.max = "+this.sliderTempMax+";" +
        "sliderOpts.value = parseInt(valColorTempElm.val()) ;" +
        "sliderOpts.step = 50;" +
        "sliderOpts.orientation = 'horizontal';" +


        "var sliderElm = jQuery('#colorTempSlider_"+number+"').slider(sliderOpts)," +
        "sliderHandleElm = jQuery('.ui-slider-handle');" +

        "sliderHandleElm.addClass('ui-state-active');" + // color the slider handle blue

        "sliderElm.on('slide', function (event, ui) {" +
          "valColorTempElm.val(ui.value).change();" +
        "});" +

        "sliderElm.on('slidestop', function (event, ui) {" +
          "sliderHandleElm.addClass('ui-state-active');" +
        "});" +

        "valColorTempElm.keyup(function(event) {" +
          "var val, newVal;" +
           "val = parseInt(jQuery(this).val());" +
          "if (event.keyCode == 13) {" +
            "if (isNaN(val) || val < sliderOpts.min) {newVal = sliderOpts.min;} else if (val > sliderOpts.max) {newVal = sliderOpts.max;} else {newVal = val;}" +
            "val = parseInt(jQuery(this).val(newVal));" +
            "jQuery(this).change();" +
            "sliderElm.slider('value', parseInt(newVal));" +
          "}" +
        "});" +

        "valColorTempElm.blur(function(event) {" +
          "var val, newVal;" +
          "val = parseInt(jQuery(this).val());" +
          "if (isNaN(val) || val < sliderOpts.min) {newVal = sliderOpts.min;} else if (val > sliderOpts.max) {newVal = sliderOpts.max;} else {newVal = val;}" +
          "val = parseInt(jQuery(this).val(newVal));" +
          "jQuery(this).change();" +
          "sliderElm.slider('value', parseInt(newVal));" +
        "});" +

        //  Color picker
        "var colorHueSatEffectElm = jQuery(\"[name='" + number + "_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_VALUE']\").first()," +

        "valHueElm = jQuery('#valHue_" + number + "')," +
        "valSaturationElm = jQuery('#valSaturation_" + number + "')," +
        "valLevelElm = jQuery('#valLevel_" + number + "')," +

        "valHue = parseInt(parseInt(colorHueSatEffectElm.val()) / 256)," +
        "valSat = parseInt(colorHueSatEffectElm.val()) % 256 / 2," +
        "valLevel = " + (parseInt(parseFloat(self.ps[number + '_WP_LEVEL']) * 100)) + ";" +

        "var colorPicker = new iro.ColorPicker('#colorPicker_" + number + "', {"+

        "width: 90," +
        "color: {h: valHue, s: valSat, v: valLevel}," +
        "wheelLightness: false," +

        "handleRadius: 4" +
        "});" +

        "colorPicker.on('input:end', function(color) {"+
        "var valHue = color.$.h, valSat = color.$.s, valLevel = color.$.v;" +
        "valHueElm.val(valHue).change();" +
        "valSaturationElm.val(valSat).change();" +
        "valLevelElm.val(Math.round(valLevel)).change();" +
        "});" +

        "valHueElm.keyup(function(event) {" +
        "if (event.keyCode == 13) {" +
        "jQuery(this).change();" +
        "colorPicker.color.hsv = {h: valHueElm.val(), s: valSaturationElm.val(), v: valLevelElm.val()}" +
        "}" +
        "});" +

        "valHueElm.blur(function(event) {" +
        "jQuery(this).change();" +
        "colorPicker.color.hsv = {h: valHueElm.val(), s: valSaturationElm.val(), v: valLevelElm.val()}" +
        "});" +

        "valSaturationElm.keyup(function(event) {" +
        "if (event.keyCode == 13) {" +
        "jQuery(this).change();" +
        "colorPicker.color.hsv = {h: valHueElm.val(), s: valSaturationElm.val(), v: valLevelElm.val()}" +
        "}" +
        "});" +

        "valSaturationElm.blur(function(event) {" +
        "jQuery(this).change();" +
        "colorPicker.color.hsv = {h: valHueElm.val(), s: valSaturationElm.val(), v: valLevelElm.val()}" +
        "});" +

        "valLevelElm.keyup(function(event) {" +
        "if (event.keyCode == 13) {" +
        "jQuery(this).change();" +
        "colorPicker.color.hsv = {h: valHueElm.val(), s: valSaturationElm.val(), v: valLevelElm.val()}" +
        "}" +
        "});" +

        "valLevelElm.blur(function(event) {" +
        "jQuery(this).change();" +
        "colorPicker.color.hsv = {h: valHueElm.val(), s: valSaturationElm.val(), v: valLevelElm.val()}" +
        "});" +

        "}, 10);";

    }
    result += "</script>";

    window.setTimeout(function() {jQuery("#rowColorSelector_" + number).html(result).hide();},50);
    //return result;
  },

  _getFLCModeSelector: function(number) {
    var self = this,
      result = "",
      selectedMode, switchSelected = "", permissionSelected = "",
      lblState0 = translateKey("lblSwitchingState"), lblState1 = translateKey("lblPermission"),
      lblMode = translateKey("lblMode");

    setFLCMode = function(val, no) {
      // val = 0 > Switch Actor channels, val = 1 > Permission channels
      var nr = self._addLeadingZero(no),
        lblStateElm = jQuery("#lblState_" + nr),
        WPTargetChannelsElm = jQuery("[name='"+nr+"_WP_TARGET_CHANNELS']"),
        arTargetChn = jQuery("[name='targetChannel"+self.chn+"_"+nr+"']"),
        val2Send = 0,
        jChn;

      self.metaSelectedMode[no] = (val == 0) ? "SWITCH" : "PERMISSION";

      // At first unset all target channels
      arTargetChn.prop('checked', false);
      WPTargetChannelsElm.val(0);

      jQuery.each(arTargetChn, function(i, chn) {
        jChn = jQuery(chn);
        if (val == 0) {
          if (chn.attributes.data.value == "SWITCH_TRANSCEIVER") {
            //  lblMode = "SWITCH";
            lblStateElm.text(lblState0);
            jChn.parent().show();
          } else {
            jChn.parent().hide();
          }
        } else if (val == 1) {
          if (chn.attributes.data.value == "PERMISSION_TRANSCEIVER") {
            //  lblMode = "PERMISSION";
            lblStateElm.text(lblState1);
            jChn.parent().show();
          } else {
            jChn.parent().hide();
          }
        }

        window.setTimeout(function () {
          if (chn.checked) {
            val2Send += parseInt(chn.value);
          }
          WPTargetChannelsElm.val(val2Send);
        },50);
      });
    };
    if ((this.activeEntries[number] == true)) {
      selectedMode = homematic("Interface.getMetadata", {"objectId": self.device.id, "dataId": "wpMode_" + number});
      switchSelected =  (selectedMode != "PERMISSION") ? "selected='selected'" : "";
      permissionSelected =  (selectedMode == "PERMISSION") ? "selected='selected'" : "";
    }
    result += "<tr>";
      result += "<td>"+lblMode+"</td>";
      result += "<td>";
        result += "<select id='flcModeSelector_"+number+"' onchange='setFLCMode(parseInt(this.value),"+number+")'>";
          result += "<option value='0' " +switchSelected+ "+>Schaltaktor</option>";
          result += "<option value='1' " +permissionSelected+ ">Berechtigung</option>";
        result += "</select>";
      result += "</td>";
    result += "</tr>";

    window.setTimeout(function() {
      jQuery("#flcModeSelector_" + number).change();
    },50);

    return result;
  },


  _getDLPModeSelector: function(number) {
    var self = this,
      result = "",
      selectedMode, permissionSelected = "", doorLockSelected = "", autoReLockSelected = "",

    /*
      lblState0 = translateKey("lblStatusPermission"),
      lblState1 = translateKey("lblStatusDoorLock"),
      lblState2 = translateKey("lblStatusAutoRelock"),
      lblMode = translateKey("lblMode");
    */

    lblState0 = translateKey("lblStatus"), lblState1 = lblState0, lblState2 = lblState0,
    lblMode = translateKey("lblMode");

    setDLPMode = function(val, no) {
      // val = 0 > Switch Actor channels, val = 1 > Permission channels
      var nr = self._addLeadingZero(no),
        lblStateElm = jQuery("#lblState_" + nr),
        //onOffElm = jQuery("[name='"+nr+"_WP_LEVEL']"), doesn't work because the dirty flag will not be recognized
        onOffElm = document.getElementsByName(nr+"_WP_LEVEL")[0],
        valOnOffElm = onOffElm.value,
        WPTargetChannelsElm = jQuery("[name='"+nr+"_WP_TARGET_CHANNELS']"),
        arTargetChn = jQuery("[name='targetChannel"+self.chn+"_"+nr+"']"),
        val2Send = 0,
        jChn;

      var optOff = translateKey("optionStateOFF"),
      optOn = translateKey("optionStateON"),
        optLocked = translateKey("optionLocked"),
        optUnLocked = translateKey("optionUnlocked");


      switch (val) {
        case 0:
          self.metaSelectedMode[no] = "PERMISSION";
          //onOffElm.empty().append(new Option(optOff,"0")).append(new Option(optOn,"1")); // doesn't work properly because of the dirty flag
          onOffElm.options[0].textContent = optOff;
          onOffElm.options[1].textContent = optOn;
          break;
        case 1:
          self.metaSelectedMode[no] = "DOOR_LOCK";
          //onOffElm.empty().append(new Option(optLocked,"0")).append(new Option(optUnLocked,"1")); // doesn't work because of the dirty flag
          onOffElm.options[0].textContent = optLocked;
          onOffElm.options[1].textContent = optUnLocked;
          break;
        case 2:
          self.metaSelectedMode[no] = "AUTO_RELOCK";
          //onOffElm.empty().append(new Option(optOff,"0")).append(new Option(optOn,"1")); // doesn't work because of the dirty flag
          onOffElm.options[0].textContent = optOff;
          onOffElm.options[1].textContent = optOn;
          break;
      }
      onOffElm.value = valOnOffElm;

      // At first unset all target channels
      arTargetChn.prop('checked', false);
      WPTargetChannelsElm.val(0);

      jQuery.each(arTargetChn, function(i, chn) {
        jChn = jQuery(chn);
        if (val == 0) {
          if (chn.attributes.data.value == "PERMISSION_TRANSCEIVER") {
            lblStateElm.text(lblState0);
            jChn.parent().show();
          } else {
            jChn.parent().hide();
          }
        } else if (val == 1) {
          if (chn.attributes.data.value == "DOOR_LOCK_TRANSCEIVER") {
            lblStateElm.text(lblState1);
            jChn.parent().show();
          } else {
            jChn.parent().hide();
          }
        } else if (val == 2) {
          if (chn.attributes.data.value == "AUTO_RELOCK_TRANSCEIVER") {
            lblStateElm.text(lblState2);
            jChn.parent().show();
          } else {
            jChn.parent().hide();
          }
        }
      });

      window.setTimeout(function () {
        jQuery.each(jQuery("[name='targetChannel"+self.chn+"_"+nr+"']"), function(i, chn) {
          if (jQuery(chn).prop("checked")) {
            val2Send += parseInt(chn.value);
          }
        });
        WPTargetChannelsElm.val(val2Send);
      },150);
    };

    if ((this.activeEntries[number] == true)) {
      selectedMode = homematic("Interface.getMetadata", {"objectId": self.device.id, "dataId": "wpMode_" + number});

      switch (selectedMode) {
        case "PERMISSION":
          permissionSelected = "selected", doorLockSelected = "", autoReLockSelected = "";
          break;
        case "DOOR_LOCK":
          permissionSelected = "", doorLockSelected = "selected", autoReLockSelected = "";
          break;
        case "AUTO_RELOCK":
          permissionSelected = "", doorLockSelected = "", autoReLockSelected = "selected";
          break;
        default:
          permissionSelected = "selected", doorLockSelected = "", autoReLockSelected = "";
      }
    }
    result += "<tr>";
    result += "<td>"+lblMode+"</td>";
    result += "<td>";
    result += "<select id='dlpModeSelector_"+number+"' onchange='setDLPMode(parseInt(this.value),"+number+")'>";
    result += "<option value='0' " +permissionSelected+ "+>"+translateKey('optionPermission')+"</option>";
    result += "<option value='1' " +doorLockSelected+ ">"+translateKey('optionDoorLock')+"</option>";
    result += "<option value='2' " +autoReLockSelected+ ">"+translateKey('optionAutoRelock')+"</option>";
    result += "</select>";
    result += "</td>";
    result += "</tr>";

    return result;
  },

  _showHideWPLevel: function (number, mode) {
    var wpLevelElm = jQuery("[name='" + number + "_WP_LEVEL']");

    if (mode == this.defaultDoorLockMode) {
      wpLevelElm.hide();
      wpLevelElm.parent().parent().hide();
    } else {
      wpLevelElm.show();
      wpLevelElm.parent().parent().show();
    }
  },

  _showHideTargetChannels: function (number, mode, setVal) {
    var panelTargetChannelElms = jQuery("[name='panelTargetChannel_" + number + "']"),
      chBoxElms = jQuery("[name='targetChannel" + self.chn + "_" + number + "']");
    switch (mode) {
      case self.defaultDoorLockMode:
        panelTargetChannelElms.hide(); // Hide the target channel selection
        if (setVal) {
          chBoxElms.first().prop("checked", true).change(); //Set channel 1 active
          chBoxElms.not(":eq(0)").prop("checked", false).change(); // Deactivate all others
        }
        break;
      case self.userDoorLockMode:
        chBoxElms.first().prev("label").hide();  //Deactivate the label of channel 1
        chBoxElms.first().prop("checked", false).hide();  //Deactivate channel 1
        panelTargetChannelElms.show(); // Show the target channel selection
        if (setVal) {
          chBoxElms.not(":eq(0)").prop("checked", true).change(); //Activate channels 2 - 9
        }
        break;
      default:
        // Default is the same as self.defaultDoorLockMode - it will be called when the mode is neither self.defaultDoorLockMode nor self.userDoorLockMode
        panelTargetChannelElms.hide(); // Hide the target channel selection
        if (setVal) {
          chBoxElms.first().prop("checked", true).change(); //Set channel 1 active
          chBoxElms.not(":eq(0)").prop("checked", false).change(); // Deactivate all others
        }
    }
  },

  _getDoorLockDriveModeElem: function (number) {
    setDoorLockDriveMode = function (number, value) {
      var number = self._addLeadingZero(number);
      self.arDoorLockMetaData.push({"number": number, "value": value});
      self._showHideTargetChannels(number, value, true);
      //self._showHideWPLevel(number, value);
      self._setDoorLockMode(number);
    };

    var selectedMode = this.DoorLockWPMode[this.devAddress][number];

    // Default mode = DoorLockMode
    selectedMode = (typeof selectedMode != "undefined") ? selectedMode : this.defaultDoorLockMode;

    var sel0 = (selectedMode == this.defaultDoorLockMode) ? 'selected' : '',
      sel1 = (selectedMode == this.userDoorLockMode) ? 'selected' : '';

    var result = "<td>" + translateKey('lblTypePointOfTime') + "</td>";
    result += "<td>";
    result += "<select id='doorLockDriveModeElm_" + number + "' onchange='setDoorLockDriveMode(" + number + ", this.value)'>";
    result += "<option value='" + this.defaultDoorLockMode + "' " + sel0 + ">" + translateKey('optionDoorLockAction') + "</option>";
    result += "<option value='" + this.userDoorLockMode + "' " + sel1 + " >" + translateKey('optionDoorLockUser') + "</option>";
    result += "</select>";
    result += "&nbsp;<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px' onclick='showParamHelp(\"" + this._getHelp('DLD_Mode') + "\", 600, 70)'>";
    result += "</td>";
    return result;
  },

  _setDoorLockMode: function (number) {
    if (this.DoorLockWPMode[this.devAddress][number] == this.userDoorLockMode || (modeWP_DELETE == true)) {
      // Set Action row including the options of the selectbox
      var actionElm = jQuery("#lblActionPermission_" + number),
        actionSelectBoxElm = jQuery("#doorLockPermissionActionSelector" + this.chn + "_" + number),
        actionSelectBoxHelpElm = jQuery("#doorLockPermissionActionSelector" + this.chn + "_" + number).next();

      actionElm.html(translateKey("lblWPAction"));
      actionSelectBoxElm.empty().append("" +
        "<option value='1'>" + translateKey('optionDLDAction2') + "</option>" +
        "<option value='0' selected>" + translateKey('optionDLDAction1') + "</option>" +
        "<option value='2'>" + translateKey('optionDLDAction3') + "</option>" +
        "<option value='3'>" + translateKey('optionDLDAction4') + "</option>"
      );

      actionSelectBoxElm.removeAttr("onchange");
      actionSelectBoxElm.unbind("change");
      actionSelectBoxElm.bind("change", function () {
        setDoorLockActionValues(number, this.value);
      });
      actionSelectBoxElm.change();

      actionSelectBoxHelpElm.removeAttr("onclick");
      actionSelectBoxHelpElm.unbind("click");
      actionSelectBoxHelpElm.bind("click", function () {
        showParamHelp(self._getHelp("DLD_LockMode"), 600, 120);
      });

      this.DoorLockWPMode[this.devAddress][number] = this.defaultDoorLockMode;
    } else if (this.DoorLockWPMode[this.devAddress][number] == this.defaultDoorLockMode) {
      // Set Permission row including the options of the selectbox
      var permissionElm = jQuery("#lblActionPermission_" + number),
        permissionSelectBoxElm = jQuery("#doorLockPermissionActionSelector" + this.chn + "_" + number),
        permissionSelectBoxHelpElm = jQuery("#doorLockPermissionActionSelector" + this.chn + "_" + number).next();

      permissionElm.html(translateKey("lblWPPermission"));
      permissionSelectBoxElm.empty().append(
        "<option value='0'>" + translateKey('optionPermisionFalse') + "</option>" +
        "<option value='1'>" + translateKey('optionPermissionTrue') + "</option>"
      );
      permissionSelectBoxElm.removeAttr("onchange");
      permissionSelectBoxElm.unbind("change");
      permissionSelectBoxElm.bind("change", function () {
        setDoorLockPermissionValues(number, this.value);
      });
      permissionSelectBoxElm.change();

      permissionSelectBoxHelpElm.removeAttr("onclick");
      permissionSelectBoxHelpElm.unbind("click");
      permissionSelectBoxHelpElm.bind("click", function () {
        showParamHelp(self._getHelp("DLD_UserMode"), 600, 170);
      });

      this.DoorLockWPMode[this.devAddress][number] = this.userDoorLockMode;
    }
  },

  _getLevel: function (number) {
    var result = "",
      paramID = number + "_WP_LEVEL",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]).toFixed(3) : "0.000",
      optionVal;

    // For blinds this has no effect because there is no duration
    showHideDuration = function (val, elmNr) {
      elmNr = self._addLeadingZero(elmNr);
      var durationModeElm = jQuery('#durationMode' + elmNr),
        trDurationModeElm = jQuery('#trDurationMode' + elmNr),
        trDurationValueElm = jQuery('#trDurationValue' + elmNr);

      var condWaterFlowElms = jQuery("[name='condWaterFlow"+elmNr+"']");

      // For the servo control, the value 0 corresponds to the right position, while 100 corresponds to the left position.
      // Therefore, for the servo control, we don't hide the ON_TIME element at a value of 0
      if (((val == "0") || (val == "0.000"))) {
        trDurationModeElm.hide();
        trDurationValueElm.hide();
        condWaterFlowElms.hide();
      } else {
        trDurationModeElm.show();
        condWaterFlowElms.show();
        if (durationModeElm.val() != "0") {
          trDurationValueElm.show();
          condWaterFlowElms.show();
        }
      }
    };

    showFreeValue = function (val, nr) {
      var freeValElm = jQuery("[name='dimFreeValue" + self.chn + "_" + self._addLeadingZero(nr) + "']");
      if (val == "freeVal" || ((val != 1.005) && (val != 1.010) && ((parseInt(val * 100) % 5) != 0))) {
        freeValElm.val(100);
        if ((self._isDeviceType("HmIP-MP3P")) || (self._isDeviceType("HmIPW-WRC6")) || (self._isDeviceType("HmIPW-WRC6-A")) || (self.isWRC6230) ) {
          freeValElm.css("display", "block");
        } else {
          freeValElm.show();
        }
      } else freeValElm.hide();
    };

    setDimFreeVal = function (val, prn, nr) {
      var freeOptionElm = document.getElementById("dimOptionFreeValue" + self.chn + "_" + prn), // Don't use jQuery because of the dirty flag
        freeValElm = jQuery("[name='dimFreeValue" + self.chn + "_" + self._addLeadingZero(nr) + "']");

      val = parseInt(val);
      val = (isNaN(val) || (val > 100)) ? 100 : val;
      val = (val < 0) ? 0 : val;

      jQuery(freeValElm[0]).val(val);
      freeOptionElm.value = (val / 100);
      freeOptionElm.defaultSelected = false;
      freeOptionElm.selected = true;
    };

    setDoorLockPermissionValues = function (number, value) {
      number = self._addLeadingZero(parseInt(number));
      var wpLevelElm = jQuery("[name='" + number + "_WP_LEVEL']").first(),
        wpDurationBaseElm = jQuery("[name='" + number + "_WP_DURATION_BASE']").first(),
        wpDurationFactorElm = jQuery("[name='" + number + "_WP_DURATION_FACTOR']").first();

      wpLevelElm.val(value);
      wpDurationBaseElm.val(7);
      wpDurationFactorElm.val(31);
    };

    setDoorLockActionValues = function (number, value) {
      number = self._addLeadingZero(parseInt(number));
      var wpLevelElm = jQuery("[name='" + number + "_WP_LEVEL']").first(),
        wpDurationBaseElm = jQuery("[name='" + number + "_WP_DURATION_BASE']").first(),
        wpDurationFactorElm = jQuery("[name='" + number + "_WP_DURATION_FACTOR']").first();

      switch (parseInt(value)) {
        case 0:
          wpLevelElm.val("0");
          wpDurationBaseElm.val("7");
          wpDurationFactorElm.val("31");
          break;
        case 1:
          wpLevelElm.val("0");
          wpDurationBaseElm.val("0");
          wpDurationFactorElm.val("0");
          break;
        case 2:
          wpLevelElm.val("1");
          wpDurationBaseElm.val("7");
          wpDurationFactorElm.val("31");
          break;
        case 3:
          wpLevelElm.val("1.01");
          wpDurationBaseElm.val("7");
          wpDurationFactorElm.val("31");
          break;
      }
    };

    this.prn++;
    if (!this.isDoorLockDrive) {
      if (! this.isDLP) {
        result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' onchange='showHideDuration(this.value, " + number + ");showFreeValue(this.value, " + number + ");'>";
      } else {
        result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "'>";
      }
    } else {
      if (this.DoorLockWPMode[this.devAddress][number] == this.userDoorLockMode) {
        result += "<select id='doorLockPermissionActionSelector" + this.chn + "_" + number + "' onchange='setDoorLockPermissionValues(" + number + ", this.value);'>";
      } else {
        result += "<select id='doorLockPermissionActionSelector" + this.chn + "_" + number + "' onchange='setDoorLockActionValues(" + number + ", this.value);'>";
      }
    }

    if ((this.chnType == this.DIMMER) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER) || (this.chnType == this.SERVO) || (this.chnType == this.BLIND) || (this.isWiredWGS) || (this.isWiredWGT)) {
      var loop;
      if ((this.chnType == this.DIMMER) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER) || (this.isWiredWGS) || (this.isWiredWGT) || (this.chnType == this.SERVO)) {
        if (((this.chnType == this.DIMMER) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER) || (this.isWiredWGS) || (this.isWiredWGT)) && (! this.WINDOW_DRIVE_RECEIVER)) {
          result += (val == 0) ? "<option value='0' selected='selected'>" + translateKey('optionOFF') + "</option>" : "<option value='0'>" + translateKey('optionOFF') + "</option>";
          for (loop = 5; loop <= 100; loop += 5) {
            optionVal = (loop / 100).toFixed(3);
            result += (val == optionVal) ? "<option value='" + optionVal + "' selected='selected'>" + loop + " %</options>" : "<option value='" + optionVal + "'>" + loop + " %</options>";
          }
          result += (val == 1.005) ? "<option value='1.005' selected='selected'>" + translateKey('optionOldLevel') + "</option>" : "<option value='1.005'>" + translateKey('optionOldLevel') + "</option>";
          result += (val == 1.01) ? "<option value='1.010' selected='selected'>" + translateKey('optionNoChange') + "</option>" : "<option value='1.010'>" + translateKey('optionNoChange') + "</option>";
          // SPHM. 786
          if ((val != 1.005) && (val != 1.010) && ((parseInt(val * 100) % 5) != 0)) {
            result += "<option id='dimOptionFreeValue" + this.chn + "_" + this.prn + "' value=" + val + " selected='selected'>" + translateKey('optionEnterValue') + "</option>";
            window.setTimeout(function () {
              if ((self._isDeviceType("HmIP-MP3P")) || (self._isDeviceType("HmIPW-WRC6")) || (self._isDeviceType("HmIPW-WRC6-A")) || (self.isWRC6230) ) {
                jQuery("[name='dimFreeValue" + self.chn + "_" + number + "']").css('display', 'block').val(parseInt(val * 100));
              } else {
                jQuery("[name='dimFreeValue" + self.chn + "_" + number + "']").show().val(parseInt(val * 100));
              }
            }, 100);
          } else {
            result += "<option id='dimOptionFreeValue" + this.chn + "_" + this.prn + "' value='freeVal'>" + translateKey('optionEnterValue') + "</option>";
          }
        } else if (this.WINDOW_DRIVE_RECEIVER) {
          val = parseInt(val);
          optOff = translateKey('optionWindowClosed');
          optOn = translateKey('optionWindowOpenTilt');
          result += (val == 0) ? "<option value='0' selected='selected'>" + optOff + "</option>" : "<option value='0'>" + optOff + "</option>";
          result += (val == 1) ? "<option value='1' selected='selected'>" + optOn + "</option>" : "<option value='1'>" + optOn + "</option>";
        }

        if (this.chnType == this.SERVO) {
          for (loop = 0; loop <= 100; loop += 5) {
            optionVal = (loop / 100).toFixed(3);
            result += (val == optionVal) ? "<option value='" + optionVal + "' selected='selected'>" + loop + " %</options>" : "<option value='" + optionVal + "'>" + loop + " %</options>";
          }
        }

      } else {
        for (loop = 0; loop <= 100; loop += 5) {
          optionVal = (loop / 100).toFixed(3);
          result += (val == optionVal) ? "<option value='" + optionVal + "' selected='selected'>" + loop + " %</options>" : "<option value='" + optionVal + "'>" + loop + " %</options>";
        }
      }
    } else if (this.chnType == this.SWITCH) {
      var optOff, optOn;

      if (!this.isDoorLockDrive) {
        optOff = translateKey('optionStateOFF');
        optOn = translateKey('optionStateON');
        result += (val == 0) ? "<option value='0.000' selected='selected'>" + optOff + "</option>" : "<option value='0.000'>" + optOff + "</option>";
        result += (val == 1) ? "<option value='1.000' selected='selected'>" + optOn + "</option>" : "<option value='1.000'>" + optOn + "</option>";
      } else {
        if (this.DoorLockWPMode[this.devAddress][number] == this.userDoorLockMode) {
          optOff = translateKey('optionPermisionFalse');
          optOn = translateKey('optionPermissionTrue');
          result += (val == 0) ? "<option value='0' selected='selected'>" + optOff + "</option>" : "<option value='0.000'>" + optOff + "</option>";
          result += (val == 1) ? "<option value='1' selected='selected'>" + optOn + "</option>" : "<option value='1.000'>" + optOn + "</option>";
        } else {
          var sel0 = "", sel1 = "", sel2 = "", sel3 = "";

          var opt0 = translateKey('optionDLDAction1'), // Verriegeln + Auto-Relock Ende (Default)
            opt1 = translateKey('optionDLDAction2'), // 100% Verriegeln + Auto-Relock - Beginn mit On-Time aus Powerup
            opt2 = translateKey('optionDLDAction3'), // Entriegeln + Auto-Relock Ende
            opt3 = translateKey('optionDLDAction4'); // Auto-Relock Ende

          var tmpWPLevel = parseFloat(this.ps[paramID]),
            tmpWPDurBase = parseInt(this.ps[number + "_WP_DURATION_BASE"]),
            tmpWPDurFactor = parseInt(this.ps[number + "_WP_DURATION_FACTOR"]);

          if (tmpWPLevel == 0 && tmpWPDurBase == 7 && tmpWPDurFactor == 31) {
            sel0 = "selected='selected'", sel1 = "", sel2 = "", sel3 = "";
          }
          if (tmpWPLevel == 0 && tmpWPDurBase == 0 && tmpWPDurFactor == 0) {
            sel0 = "", sel1 = "selected='selected'", sel2 = "", sel3 = "";
          }
          if (tmpWPLevel == 1 && tmpWPDurBase == 7 && tmpWPDurFactor == 31) {
            sel0 = "", sel1 = "", sel2 = "selected='selected'", sel3 = "";
          }
          if (tmpWPLevel == 1.01 && tmpWPDurBase == 7 && tmpWPDurFactor == 31) {
            sel0 = "", sel1 = "", sel2 = "", sel3 = "selected='selected'";
          }

          result += "<option value='1' " + sel1 + ">" + opt1 + "</option>";
          result += "<option value='0' " + sel0 + ">" + opt0 + "</option>";
          result += "<option value='2' " + sel2 + ">" + opt2 + "</option>";
          result += "<option value='3' " + sel3 + ">" + opt3 + "</option>";

        }
      }
    }

    result += "</select>";

    if ((this.chnType == this.DIMMER) || (this.chnType == this.UNIVERSAL_LIGHT_RECEIVER)) {
      result += "<input name='dimFreeValue" + this.chn + "_" + number + "' type='text' size='2' class='hidden' onchange='setDimFreeVal(this.value," + this.prn + "," + number + ");'> ";
      result += "<span name='dimFreeValue" + this.chn + "_" + number + "' class='hidden'>% (0 - 100)</span>";
    }

    if (this.isDoorLockDrive) {
      var durationBaseID = number + "_WP_DURATION_BASE",
        durationFactorID = number + "_WP_DURATION_FACTOR";
      if (this.DoorLockWPMode[this.devAddress][number] == this.defaultDoorLockMode) {
        result += "&nbsp;<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px' onclick='showParamHelp(\"" + this._getHelp('DLD_LockMode') + "\", 600, 120)'>";
      } else {
        result += "&nbsp;<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px' onclick='showParamHelp(\"" + this._getHelp('DLD_UserMode') + "\", 600, 140)'>";
      }
      result +=
        "<input type='text' class='hidden' id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' value=" + this.ps[paramID] + ">" +
        "<input type='text' class='hidden' id='separate_CHANNEL_" + this.chn + "_" + (parseInt(this.prn) + 1) + "' name='" + number + "_WP_DURATION_BASE' value=" + this.ps[durationBaseID] + " >" +
        "<input type='text' class='hidden' id='separate_CHANNEL_" + this.chn + "_" + (parseInt(this.prn) + 2) + "' name='" + number + "_WP_DURATION_FACTOR' value=" + this.ps[durationFactorID] + ">";
      this.prn += 2;
    }

    if (! this.isDLP) {
      result += "<script type='text/javascript'>";
      result += "window.setTimeout(function(){";
        result += "showHideDuration(" + val + "," + number + ");";
      result += "},100);";
      result += "</script>";
    }
    return result;

  },

  _getLevelWGS: function(number) {
    var result = "", self = this,
      paramID = number + "_WP_LEVEL",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]).toFixed(3) : "0.000",
      optionVal,
      level;

    window.setTimeout(function() {
      if (self.activeEntries[number] == true) {
        var optionFreeValElm = jQuery("[name='"+paramID+"']"),
          modeLevelElm = jQuery("#wgsWPModeSelector"+self.chn+"_" + number),
          //arTargetChannels = jQuery("[name='targetChannel" + self.chn + "_" + number + "']"),
          valTargetChannels = parseInt(jQuery("[name='"+number+"_WP_TARGET_CHANNELS']").val()),
          level = (1 * self.ps[paramID]).toFixed(2),
          activeMode;

        activeMode = (valTargetChannels > 1) ? 1 : 0;
        modeLevelElm.val(activeMode).change();
        if (level == "0.00") {level = "0";} else if (level == "1.00") {level = 1;}
          jQuery("[name="+paramID+"]").first().val(level);
        if (val == "freeVal" || ((val != 1.005) && (val != 1.010) && ((parseInt(val * 100) % 5) != 0))) {
          optionFreeValElm.val("freeVal");
        }
      }
    },100);

    showHideDuration = function (val, elmNr) {
      elmNr = self._addLeadingZero(elmNr);
      var durationModeElm = jQuery('#durationMode' + elmNr),
        trDurationModeElm = jQuery('#trDurationMode' + elmNr),
        trDurationValueElm = jQuery('#trDurationValue' + elmNr);

      if (((val == "0") || (val == "0.000"))) {
        trDurationModeElm.hide();
        trDurationValueElm.hide();
      } else {
        trDurationModeElm.show();
        if (durationModeElm.val() != "0") {
          trDurationValueElm.show();
        }
      }
    };

    showFreeValue = function (val, nr) {
      var freeValElm = jQuery("[name='dimFreeValue" + self.chn + "_" + self._addLeadingZero(nr) + "']");

      if (val == "freeVal" || ((val != 1.005) && (val != 1.010) && ((parseInt(val * 100) % 5) != 0))) {
        freeValElm.val(100);
        freeValElm.show();
      } else freeValElm.hide();
    };

    setDimFreeVal = function (val, prn, nr) {
      var freeOptionElm = document.getElementById("dimOptionFreeValue" + self.chn + "_" + prn), // Don't use jQuery because of the dirty flag
        freeValElm = jQuery("[name='dimFreeValue" + self.chn + "_" + self._addLeadingZero(nr) + "']");

      val = parseInt(val);
      val = (isNaN(val) || (val > 100)) ? 100 : val;
      val = (val < 0) ? 0 : val;

      jQuery(freeValElm[0]).val(val);

      var tmpVal = (val / 100);

      freeOptionElm.value = (val / 100);;
      freeOptionElm.defaultSelected = false;
      freeOptionElm.selected = true;
    };


    this.prn++ ;
    result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' onchange='showFreeValue(this.value, " + number + ");'>";
      result += (val == 0) ? "<option value='0' selected='selected'>" + translateKey('optionOFF') + "</option>" : "<option value='0'>" + translateKey('optionOFF') + "</option>";
      for (loop = 5; loop <= 100; loop += 5) {
        optionVal = (loop / 100).toFixed(3);
        result += (val == optionVal) ? "<option value='" + optionVal + "' selected='selected'>" + loop + " %</options>" : "<option value='" + optionVal + "'>" + loop + " %</options>";
      }
      result += (val == 1.005) ? "<option value='1.005' selected='selected'>" + translateKey('optionOldLevel') + "</option>" : "<option value='1.005'>" + translateKey('optionOldLevel') + "</option>";
      result += (val == 1.01) ? "<option value='1.010' selected='selected'>" + translateKey('optionNoChange') + "</option>" : "<option value='1.010'>" + translateKey('optionNoChange') + "</option>";

      if ((val != 1.005) && (val != 1.010) && ((parseInt(val * 100) % 5) != 0)) {
        result += "<option id='dimOptionFreeValue" + this.chn + "_" + this.prn + "' value=" + val + " selected='selected'>" + translateKey('optionEnterValue') + "</option>";
        window.setTimeout(function () {
            jQuery("[name='dimFreeValue" + self.chn + "_" + number + "']").show().val(parseInt(val * 100));
        }, 100);
      } else {
        result += "<option id='dimOptionFreeValue" + this.chn + "_" + this.prn + "' value='freeVal'>" + translateKey('optionEnterValue') + "</option>";
      }

      result += "</select>";

      result += "<input name='dimFreeValue" + this.chn + "_" + number + "' type='text' size='2' class='hidden' onchange='setDimFreeVal(this.value," + this.prn + "," + number + ");'> ";
      result += "<span name='dimFreeValue" + this.chn + "_" + number + "' class='hidden'>% (0 - 100)</span>";

    return result;
  },

  _getArColor: function (index) {
    return (index == 0)
      ?
      [
        translateKey("optionColorBLACK"),
        translateKey("optionColorBLUE"),
        translateKey("optionColorGREEN"),
        translateKey("optionColorTURQUOISE"),
        translateKey("optionColorRED"),
        translateKey("optionColorPURPLE"),
        translateKey("optionColorYELLOW"),
        translateKey("optionColorWHITE")
      ]
      :
      [
        "",
        translateKey("optionColorBLUE"),
        translateKey("optionColorGREEN"),
        translateKey("optionColorTURQUOISE"),
        translateKey("optionColorRED"),
        translateKey("optionColorPURPLE"),
        translateKey("optionColorYELLOW"),
        translateKey("optionColorWHITE")
      ];
  },

  _getBlinkCode: function (index) {
    return [
      translateKey("optionColorOFF"),
      translateKey("optionColorON"),
      translateKey("optionBlinkSlow"),
      translateKey("optionBlinkMiddle"),
      translateKey("optionBlinkFast"),
      translateKey("optionBlinkFlashSlow"),
      translateKey("optionBlinkFlashMiddle"),
      translateKey("optionBlinkFlashFast"),
      translateKey("optionBlinkBillowSlow"),
      translateKey("optionBlinkBillowMiddle"),
      translateKey("optionBlinkBillowFast")
    ];
  },

  _getColorSelector: function (number) {
    var result = "",
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]) : 0;

    if (this.arColorA.length == 0) {
      this.arColorA = this._getArColor(0);
    }

    result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' dataid='color_" + number + "'>";
    if ((!this._isDeviceType("HmIPW-WRC6")) && (!this._isDeviceType("HmIPW-WRC6-A")) && (!this.isWRC6230)) {
      result += (val == 253) ? "<option value='253' selected='selected'>" + translateKey("randomPlayback") + "</option>" : "<option value='253'>" + translateKey("randomPlayback") + "</option>";
    }
    result += (val == 254) ? "<option value='254' selected='selected'>" + translateKey("colorOldValue") + "</option>" : "<option value='254'>" + translateKey("colorOldValue") + "</option>";
    jQuery.each(this.arColorA, function (index, color) {
      result += (val == index) ? "<option  value='" + index + "'  selected='selected'>" + color + "</option>" : "<option  value='" + index + "'>" + color + "</option>";
    });
    result += "</select>";

    return result;
  },

  _getColorSelectorA: function (number, chn, prn) {
    var result = "",
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]) : 0;

    if (this.activeEntries[number] == true) {
      window.setTimeout(function () {
        var color = parseInt(val) & 0xF,
          blink = parseInt(val) >> 4;
        jQuery("#color_" + chn + "_" + prn).val(color);
      }, 100);
    }

    if (this.arColorA.length == 0) {
      this.arColorA = this._getArColor(0);
    }

    // Setting the value to send (nibble 1 (color) corresponds to the first 4 bits, nibble 2 (blink mode) the second 4 bits of the value to send)
    setColorOutputBehaviour = function (val, prn) {
      // val = selected  color (nibble 1)
      var valBlinkElm = jQuery("#blinkMode_" + self.chn + "_" + prn).val(), // Determines the selected blink mode
        elm = jQuery("#separate_CHANNEL_" + self.chn + "_" + prn); // Contains the value to send to the ccu
      elm.val(parseInt(val) + (parseInt(valBlinkElm) * 16)); // This is the value, which contains the selected color (nibble 1) + the selected blink mode (nibble 2)
    };

    result += "<select id='color_" + this.chn + "_" + this.prn + "' dataid='color_" + number + "' onchange='setColorOutputBehaviour(this.value," + this.prn + ");'>";
    result += (val == 14) ? "<option value='14' selected='selected'>" + translateKey("colorOldValue") + "</option>" : "<option value='14'>" + translateKey("colorOldValue") + "</option>";
    jQuery.each(this.arColorA, function (index, color) {
      result += (val == index) ? "<option  value='" + index + "'  selected='selected'>" + color + "</option>" : "<option  value='" + index + "'>" + color + "</option>";
    });
    result += "</select>";

    return result;
  },

  _getBlinkMode: function (number, chn, prn) {
    var result = "",
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]) : 0;

    if (this.activeEntries[number] == true) {
      window.setTimeout(function () {
        var color = parseInt(val) & 0xF,
          blink = parseInt(val) >> 4;
        jQuery("#blinkMode_" + chn + "_" + prn).val(blink);
      }, 100);
    }

    if (this.blinkMode.length == 0) {
      this.blinkMode = this._getBlinkCode();
    }

    // Setting the value to send (nibble 1 (color) corresponds to the first 4 bits, nibble 2 (blink mode) the second 4 bits of the value to send)
    setBlinkOutputBehaviour = function (val, prn) {
      // val = selected  blink mode (nibble 2)
      var valColorElm = jQuery("#color_" + self.chn + "_" + prn).val(), // Determines the selected color
        elm = jQuery("#separate_CHANNEL_" + self.chn + "_" + prn); // contains the value which is send to the ccu
      elm.val((parseInt(val) * 16) + parseInt(valColorElm)); // This is the value, which contains the selected blink mode (nibble 2) + the selected color (nibble 1)
    };

    result += "<select id='blinkMode_" + this.chn + "_" + this.prn + "' dataid='blinkMode_" + number + "' onchange='setBlinkOutputBehaviour(this.value," + this.prn + ");'>";
    result += (val == 14) ? "<option value='14' selected='selected'>" + translateKey("blinkOldValue") + "</option>" : "<option value='14'>" + translateKey("blinkOldValue") + "</option>";
    jQuery.each(this.blinkMode, function (index, mode) {
      result += (val == index) ? "<option  value='" + index + "'  selected='selected'>" + mode + "</option>" : "<option  value='" + index + "'>" + mode + "</option>";
    });
    result += "</select>";

    if (this.sessionIsExpert && (((this._isDeviceType("HmIP-BSL")) && (this._getFwMajor() >= 2))) || (this.isWRC6230)) {
      result += "&nbsp;<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px' onclick='showParamHelp(\"" + this._getHelp('ColorBehaviour') + "\", 450, 60)'>";
    }

    return result;
  },

  _getSoundSelector: function (number) {
    var result = "",
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]) : 0;

    result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' dataid='sound_" + number + "'>";
    result += (val == 0) ? "<option value='0' selected='selected'>" + translateKey("internalSystemSound") + "</option>" : "<option value='0'>" + translateKey("internalSystemSound") + "</option>";
    result += (val == 253) ? "<option value='253' selected='selected'>" + translateKey("randomPlayback") + "</option>" : "<option value='253'>" + translateKey("randomPlayback") + "</option>";
    result += (val == 254) ? "<option value='254' selected='selected'>" + translateKey("soundOldValue") + "</option>" : "<option value='254'>" + translateKey("soundOldValue") + "</option>";

    for (var loop = 1; loop <= 252; loop++) {
      result += (val == loop) ? "<option value='" + loop + "' selected='selected'>" + loop + "</option>" : "<option value='" + loop + "'>" + loop + "</option>";
    }
    result += "</select>";

    return result;

  },

  _getColorSoundSelector: function (number) {
    var result = "",
      paramID = number + "_WP_OUTPUT_BEHAVIOUR",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]) : 0;

    if (this.arColorB.length == 0) {
      this.arColorB = this._getArColor(1);
    }

    result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' dataid='soundColor_" + number + "'>";
    result += (val == 0) ? "<option value='0' selected='selected'>" + translateKey("soundColorInternal") + "</option>" : "<option value='0'>" + translateKey("soundColorInternal") + "</option>";
    result += (val == 253) ? "<option value='253' selected='selected'>" + translateKey("soundColorRandomPlayback") + "</option>" : "<option value='253'>" + translateKey("soundColorRandomPlayback") + "</option>";
    result += "<option value='254'>" + translateKey("soundColorOldValue") + "</option>";
    var loop;

    for (loop = 1; loop <= 7; loop++) {
      result += (val == loop) ? "<option value='" + loop + "' selected='selected'>" + loop + " / " + this.arColorB[loop] + "</option>" : "<option value='" + loop + "'>" + loop + " / " + this.arColorB[loop] + "</option>";
    }

    for (loop = 8; loop <= 252; loop++) {
      result += (val == loop) ? "<option value='" + loop + "' selected='selected'>" + loop + "</option>" : "<option value='" + loop + "'>" + loop + "</option>";
    }
    result += "</select>";
    return result;
  },

  _getSlatLevel: function (number) {
    var result = "",
      paramID = number + "_WP_LEVEL_2",
      val = (this.activeEntries[number] == true) ? (1 * this.ps[paramID]).toFixed(3) : "1.010";

    this.prn++;
    result += "<select id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "'>";

    for (var loop = 0; loop <= 100; loop += 5) {
      result += "<option value='" + (loop / 100).toFixed(3) + "'>" + loop + " %</options>";
    }
    result += "<option value='1.005'>" + translateKey('optionOldLevel') + "</option>";
    result += "<option value='1.010'>" + translateKey('optionNoChange') + "</option>";

    result += "</select>";

    result += "<script type='text/javascript'>";
    result += "window.setTimeout(function(){";
    result += "jElm = jQuery('#separate_CHANNEL_" + this.chn + "_" + this.prn + "');";
    result += "jElm.val('" + val + "');";
    // don`t use jQuery - the dirty flag will not be recognized
    result += "document.getElementById('separate_CHANNEL_" + this.chn + "_" + this.prn + "')[jElm.prop('selectedIndex')].defaultSelected = true;";
    result += "},100);";
    result += "</script>";

    return result;
  },

  _getWeekDay: function (number) {
    var result = "";
    var paramID = number + "_WP_WEEKDAY";
    var val = parseInt(this.ps[paramID]);
    this.curWeekdays = val;
    this.prn++;
    this.weekDayID[number] = this.chn + "_" + this.prn;

    result += "<table><tbody><tr>";
    result += "<td>";
    result += "<label for='weekDayMO" + number + "'>" + translateKey('Mon') + "</label>";
    result += "<input id='weekDayMO" + number + "' type='checkbox' value='2' name='weekDay" + this.chn + "_" + number + "' onchange='setWPWeekday(this," + this.chn + "," + this.prn + ")'>";
    result += "</td>";
    result += "<td>";
    result += "<label for='weekDayTU" + number + "'>" + translateKey('Tue') + "</label>";
    result += "<input id='weekDayTU" + number + "' type='checkbox' value='4' name='weekDay" + this.chn + "_" + number + "' onchange='setWPWeekday(this," + this.chn + "," + this.prn + ")'>";
    result += "</td>";
    result += "<td>";
    result += "<label for='weekDayWED" + number + "'>" + translateKey('Wed') + "</label>";
    result += "<input id='weekDayWED" + number + "' type='checkbox' value='8' name='weekDay" + this.chn + "_" + number + "' onchange='setWPWeekday(this," + this.chn + "," + this.prn + ")'>";
    result += "</td>";
    result += "<td>";
    result += "<label for='weekDayTHU" + number + "'>" + translateKey('Thu') + "</label>";
    result += "<input id='weekDayTHU" + number + "' type='checkbox' value='16' name='weekDay" + this.chn + "_" + number + "' onchange='setWPWeekday(this," + this.chn + "," + this.prn + ")'>";
    result += "</td>";
    result += "<td>";
    result += "<label for='weekDayFR" + number + "'>" + translateKey('Fri') + "</label>";
    result += "<input id='weekDayFR" + number + "' type='checkbox' value='32' name='weekDay" + this.chn + "_" + number + "' onchange='setWPWeekday(this," + this.chn + "," + this.prn + ")'>";
    result += "</td>";
    result += "<td>";
    result += "<label for='weekDaySAT" + number + "'>" + translateKey('Sat') + "</label>";
    result += "<input id='weekDaySAT" + number + "' type='checkbox' value='64' name='weekDay" + this.chn + "_" + number + "' onchange='setWPWeekday(this," + this.chn + "," + this.prn + ")'>";
    result += "</td>";
    result += "<td>";
    result += "<label for='weekDaySUN" + number + "'>" + translateKey('Sun') + "</label>";
    result += "<input id='weekDaySUN" + number + "' type='checkbox' value='1' name='weekDay" + this.chn + "_" + number + "'  onchange='setWPWeekday(this," + this.chn + "," + this.prn + ")'>";
    result += "</td>";
    result += "<td>";
    result += "<input type='text' id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' value='" + val + "' size='3' class='hidden'>";
    result += "</td>";
    result += "</tr></tbody></table>";


    // Init checkboxes
    result += "<script type='text/javascript'>";
    result += "window.setTimeout(function(){";
    result += "var iSelectedDays = " + parseInt(this.curWeekdays) + ";";
    result += "var bSelectedDays = iSelectedDays.toString(2);";
    result += "var tmp = '';";


    result += "for (var loop = 0; loop <= (6 - bSelectedDays.length); loop++) {";
    result += "tmp += '0';";
    result += "}";

    result += "bSelectedDays = tmp + bSelectedDays;";

    result += "jQuery('#weekDayMO" + number + "').prop('checked', (bSelectedDays[5] == '1') ? true : false );";
    result += "jQuery('#weekDayTU" + number + "').prop('checked', (bSelectedDays[4] == '1') ? true : false );";
    result += "jQuery('#weekDayWED" + number + "').prop('checked', (bSelectedDays[3] == '1') ? true : false );";
    result += "jQuery('#weekDayTHU" + number + "').prop('checked', (bSelectedDays[2] == '1') ? true : false );";
    result += "jQuery('#weekDayFR" + number + "').prop('checked', (bSelectedDays[1] == '1') ? true : false );";
    result += "jQuery('#weekDaySAT" + number + "').prop('checked', (bSelectedDays[0] == '1') ? true : false );";
    result += "jQuery('#weekDaySUN" + number + "').prop('checked', (bSelectedDays[6] == '1') ? true : false );";
    result += "},15);";
    result += "</script>";

    return result;
  },

  _getTargetChannels: function (number) {
    var self = this;
    var result = "";
    var paramID = number + "_WP_TARGET_CHANNELS";
    var val = (this.activeEntries[number] == true) ? parseInt(this.ps[paramID]) : 0;

    //console.log(this.activeEntries[number], number);
    //console.log("_getTargetChannels val: " + val);
    //console.log("parseInt(this.ps[paramID])",parseInt(this.ps[paramID]));


    var valCheckBox,
      tmpVal;

    this.curTargetChannels = val;
    this.prn++;

    blindAvailable = function (elm, number) {
      window.setTimeout(function() {
        if (self.isWired) {
          var arActiveChkBoxes = jQuery("[name='" + elm.name + "']:checked");
          var elmSlatPos = jQuery("[name='elmSlatPos_" + self._addLeadingZero(number) + "']");
          var showElmSlatPos = false;

          jQuery.each(arActiveChkBoxes, function (index, elm) {
            var elmIndex = elm.id.split("_")[1];
            if (self.targetChannelTypesVirtualBlind[elmIndex] == "BLIND_VIRTUAL_RECEIVER") {
              showElmSlatPos = true;
            }
          });

          if (showElmSlatPos) {
            elmSlatPos.show();
          } else {
            elmSlatPos.hide();
            jQuery(jQuery("[name='" + self._addLeadingZero(number) + "_WP_LEVEL_2']")[0]).val("1.010");
          }
        }
      },100);
    };

    setDimmerOutputBehaviour = function (elm, number) {
      number = self._addLeadingZero(number);

      var paramID = number + "_WP_OUTPUT_BEHAVIOUR",
        arActiveChkBoxes = jQuery("[name='" + elm.name + "']:checked"),
        chType,
        activeElmID = "",
        elmLblBrightness = jQuery('#lblWPBrightness_' + number),
        hasDimmerVirtReceiver = false,
        hasAcousticVirtReceiver = false,
        hasOpticalSignalReceiver = false,
        elmLblWPColorSelector = jQuery("[name='lblWPColorSelector_" + number + "']"),
        elmLblWPSoundSelector = jQuery("[name='lblWPSoundSelector_" + number + "']"),
        elmLblWPColorSoundSelector = jQuery("[name='lblWPColorSoundSelector_" + number + "']"),
        colorSelector = jQuery("[dataid='color_" + number + "']"),
        soundSelector = jQuery("[dataid='sound_" + number + "']"),
        colorSoundSelector = jQuery("[dataid='soundColor_" + number + "']");

      if (soundSelector.length > 0) {
        if (elmLblWPColorSelector.css("display") != "none") {
          activeElmID = colorSelector[0].id;
        }
        if (elmLblWPSoundSelector.css("display") != "none") {
          activeElmID = soundSelector[0].id;
        }
        if (elmLblWPColorSoundSelector.css("display") != "none") {
          activeElmID = colorSoundSelector[0].id;
        }
      }

      jQuery.each(arActiveChkBoxes, function (index, elm) {
        chType = elm.attributes.data.value;
        if (chType == 'DIMMER_VIRTUAL_RECEIVER') {
          hasDimmerVirtReceiver = true;
        }
        if (chType == 'ACOUSTIC_SIGNAL_VIRTUAL_RECEIVER') {
          hasAcousticVirtReceiver = true;
        }
      });

      if ((self._isDeviceType("HmIPW-WRC6")) || (self._isDeviceType("HmIPW-WRC6-A")) || (self.isWRC6230) || ((self._isDeviceType("HmIP-BSL")) && (self._getFwMajor() >= 2))) {
        hasOpticalSignalReceiver = true;
      }

      if ((hasDimmerVirtReceiver && hasAcousticVirtReceiver) || (!hasDimmerVirtReceiver && !hasAcousticVirtReceiver && !hasOpticalSignalReceiver)) {
        elmLblBrightness.html(translateKey('lblVolume') + '<br/>' + translateKey('stringTableBrightness'));
        soundSelector.prop('id', 'noSound_' + number).prop('name', 'noSound_' + number);
        colorSelector.prop('id', 'noColor_' + number).prop('name', 'noColor_' + number);
        colorSoundSelector.prop('id', activeElmID).prop('name', paramID);

        elmLblWPSoundSelector.hide();
        elmLblWPColorSelector.hide();
        elmLblWPColorSoundSelector.show();

      } else if (!hasDimmerVirtReceiver && hasAcousticVirtReceiver) {
        elmLblBrightness.html(translateKey('lblVolume'));
        soundSelector.prop('id', activeElmID).prop('name', paramID);
        colorSelector.prop('id', 'noColor_' + number).prop('name', 'noColor_' + number);
        colorSoundSelector.prop('id', 'noColorSound_' + number).prop('name', 'noColorSound_' + number);

        elmLblWPSoundSelector.show();
        elmLblWPColorSelector.hide();
        elmLblWPColorSoundSelector.hide();

      } else if (hasDimmerVirtReceiver && !hasAcousticVirtReceiver) {
        elmLblBrightness.html(translateKey('stringTableBrightness'));
        soundSelector.prop('id', 'noSound_' + number).prop('name', 'noSound_' + number);
        colorSelector.prop('id', activeElmID).prop('name', paramID);
        colorSoundSelector.prop('id', 'noColorSound_' + number).prop('name', 'noColorSound_' + number);

        elmLblWPSoundSelector.hide();
        elmLblWPColorSelector.show();
        elmLblWPColorSoundSelector.hide();
      }
    };


    result += "<table><tbody><tr>";

    var cssCounter,
      colorLight = "#e9e9e9",
      colorVeryLight = "#f9f9f9",
      colorDark = "#d9d9d9",
      cssColor = colorDark,
      valHmIP_FWI = [8, 16, 32, 64, 128, 256, 512, 1024, 1, 2, 4],
      click = "";

    jQuery.each(this.virtualChannels, function (index, value) {
      if (!self.ignoreExpertMode.includes(self.device.deviceType.id) && (self.device.deviceType.id != self.ACCESS_TRANSMITTER_HmIP_FWI) && (! self.isWGS) && (! self.isWGT)) {
        if (self.sessionIsExpert) {
          valCheckBox = Math.pow(2, index);
        } else {
          if (index == 0) {
            valCheckBox = 1;
            tmpVal = 1;
          } else {
            valCheckBox = tmpVal << 3;
            tmpVal = valCheckBox;
          }
        }
        if (((! self.isWGS) && (! self.isWGT)) && self.sessionIsExpert && (self.virtualChannels.length > 3)) {
          cssCounter = index / 3;
          if ((cssCounter != 0) && (cssCounter == parseInt(cssCounter))) {
            cssColor = (cssColor == colorLight) ? colorDark : colorLight;
          }
        } else {
          cssColor = "white";
        }
      } else if (self._isDeviceType(self.UNIVERSAL_LIGHT_RECEIVER_DALI)) {
        valCheckBox = Math.pow(2,(self.virtualChannels[index] -1));
      } else {
        if (self._isDeviceType(self.ACCESS_TRANSCEIVER_HmIP_WKP)) {
          cssColor = (value % 2 == 0) ? colorVeryLight : colorDark;
        }
        if (!self._isDeviceType("HmIP-FWI")) {
          if (! self.isWRC6230) {
            // e. g. HmIP-DLD or HmIPW-WRC6 - no virtual channels
            valCheckBox = Math.pow(2, index);
          } else {
            if (self.sessionIsExpert) {
              valCheckBox = Math.pow(2, index);
            } else {
              if (index == 0) {valCheckBox = Math.pow(2, index);} else {valCheckBox = Math.pow(2, index + 2);}
            }
          }
        } else {
          // HmIP-FWI
          valCheckBox = valHmIP_FWI[index];
        }
      }
      result += "<td>";
      if ((!self.isDoorLockDrive) && (!self.isAccessTransceiver_WKP)) {
        result += "<label for='targetChannel" + number + "_" + index + "' style='background-color:" + cssColor + "; display:block; text-align:center;'>" + self.virtualChannels[index] + "</label>";
      } else {
        if (self.isDoorLockDrive) {
          result += "<label for='targetChannel" + number + "_" + index + "' style='background-color:" + cssColor + "; display:block; text-align:center;'>" + index + "</label>";
        } else if (self.isAccessTransceiver_WKP)  {
          result += "<label for='targetChannel" + number + "_" + index + "' style='background-color:" + cssColor + "; display:block; text-align:center;'>" + (index + 1) + "</label>";
        }
      }

      if (self.chnType == self.BLIND) {
        result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypesVirtualBlind[index] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' onchange='setWPTargetChannels(this.name," + self.chn + "," + self.prn + ");blindAvailable(this," + number + ");'>";
      } else if (self.device.channels[self.chn].channelType == self.DIMMER_OUTPUT_BEHAVIOUR) {
        result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypes[value] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' onchange='setWPTargetChannels(this.name," + self.chn + "," + self.prn + ");setDimmerOutputBehaviour(this," + number + ");'>";
      } else if (self._isDeviceType(self.ACCESS_TRANSMITTER_HmIP_FWI)) {
        //AG disable access channels when astro function is active
        if (self.condition[number] == 0) {
          click = "onchange=setWPTargetChannels(this.name," + self.chn + "," + self.prn + ");";
        } else {
          if (index <= 7) {
            click = 'onchange=jQuery(this).prop("checked",false);alert(translateKey("hintFWITargetNotPossible"));';
          } else {
            click = "onchange=setWPTargetChannels(this.name," + self.chn + "," + self.prn + ");";
          }
        }
        result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypes[value] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' " + click + ">";
      } else if (self._isDeviceType(self.UNIVERSAL_LIGHT_RECEIVER_DALI)) {
        result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypes[value] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' onchange='setWPTargetChannels(this.name," + self.chn + "," + self.prn + ");'>";
      } else {
        result += "<input id='targetChannel" + number + "_" + index + "' data='" + self.targetChannelTypes[value] + "' name='targetChannel" + self.chn + "_" + number + "' type='checkbox' value='" + valCheckBox + "' onchange='setWPTargetChannels(this.name," + self.chn + "," + self.prn + ");'>";
      }
      result += "</td>";
    });

    result += "<td>";
    result += "<input type='text' id='separate_CHANNEL_" + this.chn + "_" + this.prn + "' name='" + paramID + "' value='" + val + "' size='3' class='hidden'>";
    this.prnHiddenField[number] = this.prn;
    //result += "&nbsp;<img src='/ise/img/help.png' style='cursor: pointer; width:18px; height:18px; position:relative; top:2px' onclick='showParamHelp(\""+this._getHelp('DLD_TargetChannels')+"\", 600, 400)'>";
    result += "</td>";
    result += "</tr></tbody></table>";

    // Init checkboxes
    result += "<script type='text/javascript'>";
    result += "window.setTimeout(function(){";
      result += "var iSelectedChn = " + parseInt(this.curTargetChannels) + ";";
      result += "var bSelectedChn = iSelectedChn.toString(2);";
      result += "var reversedBinary = reverseString(bSelectedChn);";
      result += "var counter = 1;";
      result += "var tmpLoop;";

      if (!this._isDeviceType(this.UNIVERSAL_LIGHT_RECEIVER_DALI)) {
        if (this.sessionIsExpert) {
          if (!this._isDeviceType(this.ACCESS_TRANSMITTER_HmIP_FWI)) {
            result += "for (var loop = 0; loop < reversedBinary.length; loop++) {";
            result += "jQuery('#targetChannel" + number + "_'+loop).prop('checked', (reversedBinary[loop] == '1') ? true : false );";
            result += "}";
          } else {
            // Special handling for e. g. HmIP-FWI
            // The first 3 bits belong to the last 3 checkboxes
            // Bit 4 - 12 are for the first 8 checkboxes
            result += "for (var loop = 0; loop < reversedBinary.length; loop++) {";
            result += "if (loop < 3) {tmpLoop = loop + 8;} else {tmpLoop = loop - 3;}";
            result += "jQuery('#targetChannel" + number + "_'+tmpLoop).prop('checked', (reversedBinary[loop] == '1') ? true : false );";
            result += "}";
          }
        } else {
          if (!this._isDeviceType(this.ACCESS_TRANSMITTER_HmIP_FWI) && (! this.isWGS) && (! this.isWGT)) {
            result += "jQuery('#targetChannel" + number + "_0').prop('checked', (reversedBinary[0] == '1') ? true : false );";
            result += "for (var loop = 3; loop < reversedBinary.length; loop+=3) {";
            result += "jQuery('#targetChannel" + number + "_'+counter).prop('checked', (reversedBinary[loop] == '1') ? true : false );";
            result += "counter++";
            result += "}";
          } else if (this.isWGS || this.isWGT) {
            result += "var mode = parseInt(jQuery('#wgsWPModeSelector"+self.chn+"_"+number+"').val());";
            result += "jQuery('#targetChannel" + number + "_'+mode).prop('checked', (reversedBinary[mode] == '1') ? true : false );";
          } else {
            // Special handling for e. g. HmIP-FWI
            // The first 3 bits belong to the last 3 checkboxes
            // Bit 4 - 12 are for the first 8 checkboxes
            result += "for (var loop = 0; loop < reversedBinary.length; loop++) {";
            result += "if (loop < 3) {tmpLoop = loop + 8;} else {tmpLoop = loop - 3;}";
            result += "jQuery('#targetChannel" + number + "_'+tmpLoop).prop('checked', (reversedBinary[loop] == '1') ? true : false );";
            result += "}";
          }
        }
      } else {
        // UNIVERSAL_LIGHT_RECEIVER_DALI
        if (this.activeEntries[number]) {
          result += "var arTargetChn = jQuery(\"[name='targetChannel" + self.chn + "_" + number + "']\"),";
          result += "valTargetChn = jQuery(\"[name='" + number + "_WP_TARGET_CHANNELS']\").val();";
          result += "jQuery.each(arTargetChn, function(index, chkBox) {";
            result += "var bit = (parseInt(jQuery(this).prev().text()));"; // In this case the label of the checkbox equals the equivalent bit.
            result += "if (_isBitSet(parseInt(valTargetChn), bit)) {"; // 64 bit possible - using _isBitSet() is necessary (instead of isBitSet())
              result += "jQuery(this).prop('checked', true);";
            result += "}";
          result += "});";
        }
      }
      if (this.isWired && this.activeEntries[number]) {
        // This should make LEVEL_2 invisible when no active target channel of the type BLIND available.
        result += "var arActiveChkBox = jQuery(\"[name='targetChannel" + self.chn + "_" + number + "']:checked\");";
        result += "var elmSlatPos = jQuery(\"[name='elmSlatPos_" + number + "']\");";
        result += "var showElmSlatPos = false;";
        result += "jQuery.each(arActiveChkBox, function(index, elm) {";
        result += "var chType = elm.attributes.data.value;";
        result += "if (chType == 'BLIND_VIRTUAL_RECEIVER') {showElmSlatPos = true;}";
        result += "if (showElmSlatPos) {elmSlatPos.show();} else {elmSlatPos.hide();}";
        result += "});";
      }

      if (this.device.channels[this.chn].channelType == this.DIMMER_OUTPUT_BEHAVIOUR) {
        result += "var arActiveChkBox = jQuery(\"[name='targetChannel" + self.chn + "_" + number + "']:checked\"),";
        result += "elmLblRamptime = jQuery('#lblWPRamptime_" + number + "'),";
        result += "chType,";
        result += "elmLblBrightness = jQuery('#lblWPBrightness_" + number + "'),";

        result += "elmLblWPColorSelector = jQuery(\"[name='lblWPColorSelector_" + number + "']\"),";
        result += "elmLblWPSoundSelector = jQuery(\"[name='lblWPSoundSelector_" + number + "']\"),";
        result += "elmLblWPColorSoundSelector = jQuery(\"[name='lblWPColorSoundSelector_" + number + "']\"),";

        result += "hasDimmerVirtReceiver = false,";
        result += "hasAcousticVirtReceiver = false,";
        result += "hasOpticalSignalReceiver = false;";

        result += "jQuery.each(arActiveChkBox, function(index, elm) {";
        result += "chType = elm.attributes.data.value;";
        result += "if (chType == 'DIMMER_VIRTUAL_RECEIVER') {hasDimmerVirtReceiver = true;}";
        result += "if (chType == 'ACOUSTIC_SIGNAL_VIRTUAL_RECEIVER') {hasAcousticVirtReceiver = true;}";
        result += "});";
        if ((this._isDeviceType("HmIPW-WRC6")) || (this._isDeviceType("HmIPW-WRC6-A")) || (this.isWRC6230) || ((this._isDeviceType("HmIP-BSL")) && (this._getFwMajor() == 2))) {
          result += "hasOpticalSignalReceiver = true;";
        }
        result += "var colorSelector = jQuery(\"[dataid='color_" + number + "']\");";
        result += "var soundSelector = jQuery(\"[dataid='sound_" + number + "']\");";
        result += "var colorSoundSelector = jQuery(\"[dataid='soundColor_" + number + "']\");";
        result += "if ((hasDimmerVirtReceiver && hasAcousticVirtReceiver) || ((! hasDimmerVirtReceiver) && (! hasAcousticVirtReceiver) && (! hasOpticalSignalReceiver))) {";
        result += "elmLblBrightness.html(translateKey('lblVolume') + '<br/>' + translateKey('stringTableBrightness'));";
        result += "soundSelector.prop('id','noSound_" + number + "').prop('name','noSound_" + number + "');";
        result += "colorSelector.prop('id','nocColor_" + number + "').prop('name','noColor_" + number + "');";

        result += "elmLblWPColorSoundSelector.show()";
        result += "} else if (hasAcousticVirtReceiver) {";
        result += "elmLblBrightness.html(translateKey('lblVolume'));";

        result += "colorSelector.prop('id','noColor_" + number + "').prop('name','noColor_" + number + "');";
        result += "colorSoundSelector.prop('id','noColorSound_" + number + "').prop('name','noColorSound_" + number + "');";

        result += "elmLblWPSoundSelector.show();";
        result += "} else {";
        result += "elmLblBrightness.html(translateKey('stringTableBrightness'));";

        result += "soundSelector.prop('id','noSound_" + number + "').prop('name','noSound_" + number + "');";
        result += "colorSoundSelector.prop('id','noColorSound_" + number + "').prop('name','noColorSound_" + number + "');";

        result += "elmLblWPColorSelector.show();";
        result += "}";

      }
    result += "},100);";

    result += "</script>";
    return result;
  },

  _getPanelSelectTargetChannels: function (chn, number, prn) {
    var result = "",
      self = this;

    selectTargetChannel1stVirt = function (chn, number, prn) {
      selectTargetChannelNone(chn, number);
      jQuery("#separate_CHANNEL_" + chn + "_" + prn).val(0);
      self._initTargetChannels(parseInt(number) - 1);

    };

    selectTargetChannelAll = function (chn, number, prn) {
      number = (parseInt(number) < 10) ? "0" + number : number;
      var arTargetChannels;
      arTargetChannels = jQuery("[name='targetChannel" + chn + "_" + number + "']:visible");
      jQuery("#separate_CHANNEL_" + chn + "_" + prn).val(0);
      arTargetChannels.prop("checked", true).change();
    };

    selectTargetChannelNone = function (chn, number, prn) {
      number = (parseInt(number) < 10) ? "0" + number : number;
      var arTargetChannels = jQuery("[name='targetChannel" + chn + "_" + number + "']");
      jQuery("#separate_CHANNEL_" + chn + "_" + prn).val(0);
      arTargetChannels.prop("checked", false).change();
    };

    if (this.sessionIsExpert && (!this.ignoreExpertMode.includes(this.device.deviceType.id)) && ((!this._isDeviceType(this.ACCESS_TRANSMITTER_HmIP_FWI)) && (! this._isDeviceType("HmIP-BSL")) && (!this.isWRC6230))) {
      result += "<input id='btnSelect1stVirtual_" + chn + "' type='button' value='" + translateKey('btnSelect1stVirTargetChannels') + "' style='margin-right: 10px;' onclick='selectTargetChannel1stVirt(" + chn + ", " + number + ", " + prn + ");'>";
    }
    if (!this._isDeviceType(this.ACCESS_TRANSMITTER_HmIP_FWI)) {
      result += "<input type='button' value='" + translateKey('btnSelectAllTargetChannels') + "' style='margin-right: 10px;' onclick='selectTargetChannelAll(" + chn + ", " + number + ", " + prn + ");'>";
      result += "<input type='button' value='" + translateKey('btnSelectNoTargetChannels') + "' onclick='selectTargetChannelNone(" + chn + ", " + number + ", " + prn + ");'>";
    }
    return result;
  },

  _getTargetChannelTypes: function() {
    var self = this;
    jQuery.each(this.virtualChannels, function(index,chn) {
      self.targetChannelTypes[chn] = self.device.channels[chn].channelType;
    });
  },

  // Check if one of the target channels of a given type is active (checked)
  isTargetChOfType: function(chType) {
    var self = this,
      result = false;

    jQuery.each(this.virtualChannels,function(index, chn){
      if (self.targetChannelTypes[chn] == chType) {
        result = true;
        return false; // leave the each loop
      }
    });
    return result;
  },

  _getHR: function() {
    return "<tr><td colspan='6'><hr></td></tr>";
  },

  _getDelAddElm: function(mode, number) {
    var self = this,
      classAddElm = "",
      classDelElm = "";

    deleteEntry = function(number) {
      self.numberOfActiveEntries--;
      if (parseInt(number) == 1) {
        jQuery("#btnDelEntry0").hide();
        jQuery("#btnAddNewEntry0").show();
      }

      if (self.numberOfActiveEntries >= 1) {
        number = self._addLeadingZero(number);
        jQuery("#weeklyProgramNotActive").hide();
        jQuery("#entry" + number).fadeOut();
        self.activeEntries[number] = false;
        jQuery("#separate_CHANNEL_" + self.weekDayID[number]).val(0);
        jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(number) - 1))).show();
      } else {
        self.numberOfActiveEntries = 0;
        number = self._addLeadingZero(number);
        jQuery("#entry" + number).fadeOut();
        jQuery("#separate_CHANNEL_" + self.weekDayID[number]).val(0);
        self.activeEntries[number] = false;
        jQuery("#weeklyProgramNotActive").show();
        jQuery("#btnAddNewEntry0").show();
      }
      if (self.isDoorLockDrive) {
        jQuery("#doorLockDriveModeElm_" + number).val(self.defaultDoorLockMode);
        self.DoorLockWPMode[self.devAddress][number] = self.defaultDoorLockMode;
        self.arDoorLockMetaData.push({"number": number, "value": self.defaultDoorLockMode});

        jQuery("#doorLockPermissionActionSelector" + self.chn + "_" + number).val("0");
        jQuery("[name='"+number+"_WP_LEVEL']").first().val("0");
        jQuery("[name='"+number+"_WP_DURATION_BASE']").first().val("7");
        jQuery("[name='"+number+"_WP_DURATION_FACTOR']").first().val("31");
        modeWP_DELETE = true;
        jQuery("#doorLockDriveModeElm_" + number).change();
        window.setTimeout(function() {modeWP_DELETE = false;},250);
      }
    };

    addEntry = function(elm, number) {
      self.numberOfActiveEntries++;
      var nextNumber = parseInt(number) + 1;
      jQuery("#weeklyProgramNotActive").hide();

      self.activeEntries[self._addLeadingZero(nextNumber)] = true;
      if(self.activeEntries["01"] == true) {
        jQuery("#btnAddNewEntry0").hide();
      }
      jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(number)))).hide();
      jQuery("#entry"+self._addLeadingZero(nextNumber)).show();

      jQuery("#separate_CHANNEL_" + self.weekDayID[self._addLeadingZero(nextNumber)]).val(127);
      jQuery("[name='weekDay"+self.chn+"_"+self._addLeadingZero(nextNumber)+"']").prop("checked", true);

      window.setTimeout(function() {self._initTargetChannels(number);},50);

      if ( (! self._isNextEntryInUse(nextNumber)) && (parseInt(nextNumber) < self.maxEntries)) {
        jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(nextNumber)))).show();
      } else {
        jQuery("#btnAddNewEntry" + (self._addLeadingZero(parseInt(nextNumber)))).hide();
      }
      jQuery("#btnDelEntry"+self._addLeadingZero(nextNumber)).get(0).scrollIntoView({behavior:'smooth', block:'end'});

      if ((self.chnType == self.UNIVERSAL_LIGHT_RECEIVER) && (self.ps[self._addLeadingZero(parseInt(nextNumber)) + "_WP_HUE_SATURATION_COLOR_TEMPERATURE_EFFECT_TYPE"] == 0)) {
        showHideDuration(1.0, parseInt(nextNumber));
        showFreeValue(1.0, parseInt(nextNumber) );
      }

      if (self.chnType == self.UNIVERSAL_LIGHT_RECEIVER) {
        self._getColorTempAndEffect(self._addLeadingZero(nextNumber));
      }

      if (((self._isDeviceType("HmIP-BSL")) && (self._getFwMajor() >= 2)) || (self.isWRC6230)) {
        self._setBSLPanel(self._addLeadingZero(nextNumber));
      }

      if (self.isWGS || self.isWGT) {
        self._setWGSPanel(self._addLeadingZero(nextNumber));
      }

      if (self.isDLP) {
        window.setTimeout(function() {
          jQuery("#dlpModeSelector_" + self._addLeadingZero(parseInt(nextNumber))).change();
        },50);
      }

      if (self.isDoorLockDrive) {
        self.DoorLockWPMode[self.devAddress][self._addLeadingZero(parseInt(nextNumber))] = self.userDoorLockMode;
        window.setTimeout(function() {
          jQuery("#doorLockDriveModeElm_" + self._addLeadingZero(parseInt(nextNumber))).change();
        },50);
      }

    };

    if (mode == "DEL") {
      classAddElm = "hidden";
    } else if (mode == "ADD_FIRST_ELEM") {
      classDelElm = "hidden";
    }

    var panel = "",
      delElm = "<td id='btnDelEntry"+number+"' class='"+classDelElm+"'><img src='/ise/img/cc_delete.png'  title='"+translateKey('lblDelSwitchPoint')+"' alt='Remove entry' style='width: 24px; height: 24px; cursor: pointer;' onclick='deleteEntry("+number+");'></td>",
      addElm = "<td id='btnAddNewEntry"+number+"' class='"+classAddElm+"'><img src='/ise/img/add.png' title='"+translateKey('lblAddSwitchPoint')+"' alt='Add entry' style='width: 24px; height: 24px; cursor: pointer;' onclick='addEntry(this,"+number+");'></td>";

    panel += "<tr>";
    panel += delElm;
    panel += addElm;
    panel += "</tr>";
    return panel;
  },

  _initTargetChannels: function(number) {
    var arTargetChannels = jQuery("[name='targetChannel" + this.chn + "_" + this._addLeadingZero(parseInt(number + 1)) + "']:visible"),
      elmTargetValue = jQuery("[name='" + this._addLeadingZero(parseInt(number + 1)) + "_WP_TARGET_CHANNELS']"),
      targetValue = 0,
      virtChnCounter = 0,
      maxVirtCounter = (this.isWGTC) ? 4 : 3;

    if (! self.ignoreVirtualChannels.includes(self.device.deviceType.id)) {
      jQuery.each(arTargetChannels, function (index, elm) {
        // At first unset all target channels
        jQuery(elm).prop('checked', false);
        if (((! self._isDeviceType("HmIP-BSL")) || ((self._isDeviceType("HmIP-BSL")) && (self._getFwMajor() < 2))) && (!this.isWRC6230)) {
          // SPHM-367 - activate only the first virtual channel
          if (!self.sessionIsExpert || virtChnCounter == 0) {
            jQuery(elm).prop('checked', true);
            targetValue += parseInt(jQuery(elm).val());
          }
          virtChnCounter++;
          virtChnCounter = (virtChnCounter >= maxVirtCounter) ? 0 : virtChnCounter;
        }
      });
      elmTargetValue.val(targetValue);
    } else {
      // This is for all devices without virtual channels
      if (self.isDoorLockDrive || self.isWGS || self.isWGT) {
        var arDoorLockTargetCh = jQuery("[name='targetChannel" + this.chn + "_" + this._addLeadingZero(parseInt(number) + 1) + "']");
        arTargetChannels.first().prop("checked", true).change(); //Set channel 1 active - this is the door lock channel
        arTargetChannels.not(":eq(0)").prop("checked", false).change(); //Set all other channels inactive - the user action channels aren't active
      } else {
        if (this._isDeviceType("HmIP-FLC") || this._isDeviceType("HmIP-FDC")) {
          var initVal = 0;
          jQuery.each(arTargetChannels, function(index, chn) {
            if (chn.attributes.data.value == "SWITCH_TRANSCEIVER") {
              jQuery(chn).prop("checked",true);
              initVal += parseInt(jQuery(chn).val());
            }
          });
          elmTargetValue.val(initVal);
        } else {
          arTargetChannels.prop("checked", true).change();
        }
      }
    }
  },

  _getDurationRamptimeHTML: function(mode, number) {
    var result = "",
      factorMin = "",
      factorMax = "",
      valBaseID,
      valFactorID;
    switch (mode) {
      case "duration":
        factorMin = this.psDescr.DURATION_FACTOR_MIN;
        factorMax = this.psDescr.DURATION_FACTOR_MAX;
        valBaseID = number +"_WP_DURATION_BASE",
          valFactorID = number +"_WP_DURATION_FACTOR";
        break;
      case "ramptime":
        factorMin = this.psDescr.RAMP_TIME_FACTOR_MIN;
        factorMax = this.psDescr.RAMP_TIME_FACTOR_MAX;
        valBaseID = number +"_WP_RAMP_TIME_BASE",
          valFactorID = number +"_WP_RAMP_TIME_FACTOR";
        break;
      default:
        console.log("HmIPWeeklyProgram - _getDurationRamptimeHTML: an error occured");
    }

    var valBase = (this.activeEntries[number] == true ) ? parseInt(this.ps[valBaseID]) : 0;
    var valFactor = (this.activeEntries[number] == true ) ? parseInt(this.ps[valFactorID]) : 0;

    var arOptions = ["BASE_100_MS","BASE_1_S","BASE_5_S","BASE_10_S","BASE_1_M","BASE_5_M","BASE_10_M","BASE_1_H"];

    this.prn++;
    result += "<input type='text' id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+valFactorID+"' value='"+valFactor+"' size='2' class='alignCenter' onblur='checkWPMinMaxValue(this,"+factorMin+","+factorMax+")'>";
    result += " x ";

    result += "<script type='text/javascript'>";
    result += "jQuery( '#separate_CHANNEL_"+this.chn+"_"+this.prn+"').on( 'keydown', function(event) {";
    result += "    if(event.which == 13)";
    result += "      checkWPMinMaxValue(this,"+factorMin+","+factorMax+")";
    result += "  });";
    result += "</script>";

    this.prn++;
    result += "<select id='separate_CHANNEL_"+this.chn+"_"+this.prn+"' name='"+valBaseID+"'>";
    jQuery.each(arOptions, function(index, value) {
      if (index != valBase) {
        result += "<option value='" + index + "'>" + translateKey(value) + "</options>";
      } else {
        result += "<option selected='selected' value='" + index + "'>" + translateKey(value) + "</options>";
      }
    });
    result += "</select>";

    return result;

  },

  _setWSMOutputBehaviour: function (number) {
    var literElm = jQuery("#valueLiters" + number),
      unitElem = jQuery("#unitLiters"+ number),
      outputBehaviourElm = jQuery("[name='" + number + "_WP_OUTPUT_BEHAVIOUR']").first(),
      levelElm = jQuery("[name='" + number + "_WP_LEVEL']").first(),
      helpIcon = jQuery("#iconHelp_" + number);

    if (parseInt(levelElm.val()) == 0) {
      outputBehaviourElm.val(0);
      helpIcon.hide();
    } else {helpIcon.show();}

    levelElm.on("change", function () {
      if (parseInt(levelElm.val()) == 0) {
        outputBehaviourElm.val(0);
        helpIcon.hide();
      } else {helpIcon.show();}
    });

    literElm.on("blur", function () {
      outputBehaviourElm.val(parseInt(literElm.val()) + parseInt(unitElem.val()));
    });

    unitElem.on("change", function () {
      outputBehaviourElm.val(parseInt(literElm.val()) + parseInt(unitElem.val()));
    });

  },

  _getFwMajor: function() {
    return parseInt(this.fwVersion.split(".")[0]);
  },

  _getMaxEntries: function() {
    //return 2; // Set the value for testing reasons to a low level - remove this after testing

    if (
      (this._isDeviceType("HmIP-MP3P"))
      || (this._isDeviceType("HmIPW-WRC6"))
      || (this._isDeviceType("HmIPW-WRC6-A"))
      || (this.isWRC6230)
      || (this.WATER_SWITCH)
      || ((this._isDeviceType("HmIP-BSL")) && (this._getFwMajor() == 2)) // BSL with Fw. 2.x.x
    ) {return 69;}

    switch (this.chnType) {
      case this.DIMMER:
      case this.UNIVERSAL_LIGHT_RECEIVER:
      case this.SWITCH:
      case this.BLIND:
      case this.SERVO:
        return 75;
      default: return -1;
    }
  },

  // Check if the parameter weekday is in use.
  // If this is not the case the entry shouldn`t be visible and all values of the entry are 0
  _setEntryVisibility: function(number) {
    var val = parseInt(this.ps[number +"_WP_WEEKDAY"]);
    this.activeEntries[number] = (val == 0) ? false : true ;

    if (this.isDLP && (val > 0)) {
      var iNumber = parseInt(number);
      var delay = (iNumber < 5) ? 250 : 2000; //set the mode of the first 5 entries after 250 ms
      window.setTimeout(function() {
        jQuery("#dlpModeSelector_" + self._addLeadingZero(iNumber)).change();
      },delay);

    }
  },

  _addLeadingZero: function(val) {
    if (typeof val == "string") {
      if (val[0] == "0") {return val;}
    }

    return (parseInt(val) < 10) ? "0"+val : val;
  },

  _getHelp: function(helpID) {
    switch (helpID) {
      case "DLD_Mode":
        return translateKey("DLD_Mode");
      case "DLD_LockMode":
        return translateKey("DLD_LockMode");
      case "DLD_UserMode":
        return translateKey("DLD_UserMode");
      case "DLD_TargetChannels":
        return translateKey("DLD_TargetChannels");
      case "SERVO_Duration":
        return translateKey("SERVO_Duration");
      case "ColorBehaviour":
        return translateKey("helpColorBehaviour");
      default:
        return translateKey("noHelpAvailable") + "<br/><br/>helpID: <b>" + helpID + "</b>";
    }
  },

  _extendFooterButtons: function() {
    if (this.isDoorLockDrive) {
      jQuery("#footerButtonTake, #footerButtonOK").click(function () {
        jQuery.each(self.arDoorLockMetaData, function(index,data) {
          homematic("Interface.setMetadata", {
            "objectId": self.device.id,
            "dataId": "WPDoorLockMode_" + data.number,
            "value": data.value
          });
        });

      });
    } else if ((this._isDeviceType("HmIP-BSL") && (this._getFwMajor() >= 2)) || (this.isWRC6230)) {

      jQuery("#footerButtonTake, #footerButtonOK").click(function () {
        // Store the selected mode of the BSL (Fw. >= 2.x.x)
        jQuery.each(arBSLMode, function(index,data) {
          homematic("Interface.setMetadata", {
            "objectId": self.device.id,
            "dataId": "bslMode" + data.number,
            "value": data.mode
          });
        });
      });
    } else if ((this._isDeviceType("HmIP-FLC")) || (this._isDeviceType("HmIP-FDC")) || (this.isDLP)) {
      jQuery("#footerButtonTake, #footerButtonOK").click(function () {
        window.setTimeout(function() {
          jQuery.each(self.metaSelectedMode, function (index, val) {
            if (val != undefined) {
            var x =  homematic("Interface.setMetadata", {
                "objectId": self.device.id,
                "dataId": "wpMode_" + self._addLeadingZero(index),
                "value": val
              },function(result) {});
            }
          });
        },100);
      });
    }
  }
};

