<script>
  var product = parseInt(getProduct());
	var enableInitaliseSDCardButton = ${SDCardEnableInitButton};
	var enableBackupSDCardButton = ${SDCardEnableBackupButton};
  var arCurrency = ["EUR", "TRY", "GBP", "CHF", "PLN"],
  curSelBoxElm = jQuery("#currency"),
  curPricePerKWhElm = jQuery("#curPricePerKWh"),
  gasPricePerKWhElm = jQuery("#gasPricePerKWh"),
  gasHeatingValueElm = jQuery("#gasHeatingValue"),
  gasConditionNumberElm = jQuery("#gasConditionNumber");

  var tdMicroSDElm = jQuery("#tdMicroSD"),
  tdUSBStorageElm = jQuery("#tdUSBStorage"),
	tdLEDSElm = jQuery("#tdLEDS");
	trFieldTest = jQuery("#fieldTest");

	var base_url = "/pages/jpages/system/StorageSettings/";
    dlgResult = 0;

  if (product >= 3) {
    tdUSBStorageElm.show();
		tdLEDSElm.show();
		trFieldTest.show();
  } else {
    tdMicroSDElm.show();
  }

	OnInitaliseSDCard = function() {
		MessageBox.show(
			translateKey('dialogSettingsInitialisingMessageTitle'), 
			'<br/><br/><img id="messageBoxSdCardGraph" src="/ise/img/anim_bargraph.gif"><br/>',
			'',
			'320',
			'90',
			'messageBoxSdCard', 
			'messageBoxSdCardGraph');
  
		var opt = {
			onComplete: function(t){
				jQuery("#messageBoxSdCard").remove();
				CreateCPPopup("/pages/jpages/system/StorageSettings/show");
			}
		}
		url = base_url + "initialize?sid=" + SessionId
		new Ajax.Request(url,opt);
	};

	OnEjectSDCard = function() {
		// alert ("Init Button pressed");
		var opt = {
			onComplete: function(t){
				CreateCPPopup("/pages/jpages/system/StorageSettings/show");        			
			}
		}
		
		url = base_url + "eject?sid=" + SessionId
		new Ajax.Request(url,opt);
	};

	/*
	OnBackupSDCard = function() {
    homematic('CCU.existsFile', {'file': '/media/sd-mmcblk0/measurement'}, function(result){
      if(result) {
        var url = base_url + "backup?sid=" + SessionId;
        window.open(url,'_blank')
      } else {
        alert("Es sind keine Diagrammdaten zum Sichern vorhanden.");
      }
    });
	};
	*/

	OnBackupSDCard = function() {
		var url = base_url + "backup?sid=" + SessionId;
		window.open(url,'_blank')
	};

	OnRestoreSDCard = function() {
		var url = base_url + "restore?sid=" + SessionId;
		jQuery('#uploadForm').attr("action", url);
		jQuery("#uploadForm").submit();
	};            
	
	enable_disable = function () {
		if(enableInitaliseSDCardButton == false) {
			jQuery('#initaliseSDCardButton').hide();
		} else {		
			jQuery('#initaliseSDCardButton').show();
		}

		if(enableBackupSDCardButton == false) {
			jQuery('[name="backupSDCardButton"]').hide();
		} else {
			jQuery('[name="backupSDCardButton"]').show();
		}
	};
        
	enable_disable();

	jQuery("#btnRestoreSDCard").prop('value', translateKey('dialogSettingsStorageSettingsBtnRecovery'));

  readPricePerKWh = function() {
    var url = "/pages/jpages/system/EnergyPriceController/readPricePerKWh?sid=" + SessionId;
    var opt = {
      onComplete: function(t) {
        var arResponse = t.responseText.split(","),
        currency = arResponse[0];
        priceCur = arResponse[1];
        priceGas = arResponse[2];
        gasHeatingValue = arResponse[3];
        gasConditionNumber = arResponse[4];

        if ((arResponse.length == 6) && (t.responseText != "noConfig")) {
          curSelBoxElm.val(currency.replace(/\"/g,""));
          curPricePerKWhElm.val(priceCur.replace(/\"/g,""));
          gasPricePerKWhElm.val(priceGas.replace(/\"/g,""));
          gasHeatingValueElm.val(gasHeatingValue.replace(/\"/g,""));
          gasConditionNumberElm.val(gasConditionNumber.replace(/\"/g,""));
        } else if (arResponse.length == 3 && t.responseText != "noConfig") {
            // This is for compatibility reasons - the first version of the config file
            // consists only of the values for the electricity bill.
            curSelBoxElm.val(arResponse[1]);
            curPricePerKWhElm.val(arResponse[0].toString());
        } else {
          conInfo("No energy price available!");
        }
      }
    }
    new Ajax.Request(url,opt);
  };

  simulateBtnPress = function(elmId) {
    var saveBtnElm = jQuery("#"+elmId);
    saveBtnElm.addClass("border2px");
    setTimeout(function() {
      saveBtnElm.removeClass("border2px");
    }, 1500);
  };

  savePricePerKWh = function(saveBtn) {
    simulateBtnPress(saveBtn.id);
    var url = "/pages/jpages/system/EnergyPriceController/savePricePerKWh?sid=" + SessionId;
    var currency = curSelBoxElm.val(),
    curPricePerKWh = curPricePerKWhElm.val().replace(",","."),
    gasPricePerKWh = gasPricePerKWhElm.val().replace(",","."),
    gasHeatingValue = gasHeatingValueElm.val().replace(",","."),
    gasConditionNumber = gasConditionNumberElm.val().replace(",",".");

    var pb ='{';
      pb += '"currency": ' + '"' + currency + '",';
      pb += '"curPricePerKWh": ' + '"' + curPricePerKWh + '",';
      pb += '"gasPricePerKWh": ' + '"' + gasPricePerKWh + '",';
      pb += '"gasHeatingValue": ' + '"' + gasHeatingValue + '",';
      pb += '"gasConditionNumber": ' + '"' + gasConditionNumber + '"';

    pb += '}'
    var opt = {
      postBody: pb,
      onComplete: function(t){
        conInfo("Response savePricePerKWh: " + t.responseText);
      }
    }
    new Ajax.Request(url,opt);
  };

	onInfoLedCheckChange = function() {
		var serviceVal = jQuery("#inputServiceLed").prop("checked");
		var alarmVal = jQuery("#inputAlarmLed").prop("checked");
		console.log("service checked:"+serviceVal);
		console.log("alarm checked:"+alarmVal);
		homematic("CCU.setInfoLedConfig", { serviceLedOn: serviceVal, alarmLedOn: alarmVal})

	}

  jQuery.each(arCurrency, function(index, val) {
    curSelBoxElm.append("<option value='"+val+"'>"+val+"</option>");
  });
  readPricePerKWh();
	translatePage('#messagebox');
	dlgPopup.readaptSize();

	//info led settings
  getMessagesLEDSettings = function() {
		return homematic("CCU.getInfoLedConfig", {});
	};

	var infoLedSettings = getMessagesLEDSettings();
	infoLedServiceElm = jQuery("#inputServiceLed");
	infoLedServiceElm.prop("checked", infoLedSettings.serviceLedOn);
	infoLedServiceElm.val(infoLedSettings.serviceLedOn);
	infoLedAlarmElm = jQuery("#inputAlarmLed");
	infoLedAlarmElm.prop("checked", infoLedSettings.alarmLedOn);
	infoLedAlarmElm.val(infoLedSettings.alarmLedOn);

</script>
<div class="popupTitle">${"$"}{dialogSettingsGeneralSettingsTitle}</div>
<div class="CLASS21114 j_translate">
	<table  class="popupTable" border=1 width="100%">

    <!-- Micro SD CARD -->
		<tr id="tdMicroSD" class="CLASS21115 hidden">
			<td class="CLASS21116">${"$"}{dialogSettingsSDCardSettings}</td>
			<td  align="center"  width="35%">
				<table>
					<tr>
						<td class="CLASS21112">${"$"}{dialogSettingsSDCardStatus}:</td>
						<td>${SDCardStatus}</td>
					</tr>
					<tr>
						<td align="center" class="CLASS21112" colspan="2" >
							<div class="popupControls CLASS21107">
								<table>
								<tr>
									<td align="right">
										<div id="initaliseSDCardButton" class="StdButton CLASS04907" onClick="OnInitaliseSDCard()">${"$"}{dialogSettingsStorageSettingsBtnInitaliseSDCard}</div>
									</td>
									<td align="right">
										<div name="backupSDCardButton" class="StdButton CLASS04907" onClick="OnBackupSDCard()">${"$"}{dialogSettingsStorageSettingsBtnBackup}</div>
									</td>
								</tr>
								</table>
							</div>
								<!--<div id="ejectSDCardButton" class="StdButton" onClick="OnEjectSDCard()">${"$"}{dialogSettingsStorageSettingsBtnEjectSDCard}</div> -->
						</td>
					</tr>
				</table>
			</td>
			<td class="CLASS21113" align="left">
				<p> ${"$"}{dialogSettingsStorageHintSDCardP1} </p>
				<p> ${"$"}{dialogSettingsStorageHintSDCardP2} </p>
			</td>
		</tr>
    <!-- END Micro SD CARD -->

    <!-- USB Storage -->
		<tr id="tdUSBStorage" class="CLASS21115 hidden">
			<td class="CLASS21116">${"$"}{dialogSettingsUSBStorageSettings}</td>
			<td  align="center"  width="35%">
				<table>
					<tr>
						<td class="CLASS21112">${"$"}{dialogSettingsSDCardStatus}:</td>
						<td>${SDCardStatus}</td>
					</tr>
					<tr>
						<td align="center" class="CLASS21112" colspan="2" >
							<div class="popupControls CLASS21107">
								<table>
								<tr>
										<td align="right">
										<div name="backupSDCardButton" class="StdButton CLASS04907" onClick="OnBackupSDCard()">${"$"}{dialogSettingsStorageSettingsBtnBackup}</div>
									</td>
								</tr>
								</table>
							</div>
							</td>
					</tr>
				</table>
			</td>
			<td class="CLASS21113" align="left">
				<p> ${"$"}{dialogSettingsStorageHintUSBStorageP1} </p>
			</td>
		</tr>
    <!-- END USB Storage -->

		<tr class="CLASS21115">
		  <td class="CLASS21116">
       ${"$"}{tdPowerCost}
		  </td>
		  <td align="center">

		    <table>
		      <tr>
		        <td>
              <table>
                <tr>
                  <td>
                    <b>${"$"}{lblCurrency}</b>
                  </td>
                  <td>
                    <select id="currency"/>
                  </td>
                </tr>
                <tr><td colspan="2"><hr></td></tr>
                <tr><td><b>${"$"}{lblGeneralSettingsCurrent}</b></td></tr>
                <tr>
                  <td>
                    ${"$"}{lblPowerCost}
                  </td>
                  <td>
                    <input id="curPricePerKWh" type="text" size="5" value="0.00" style="text-align:center"/>
                  </td>
                </tr>
                <tr><td colspan="2"><hr></td></tr>
                <tr><td><b>${"$"}{lblGeneralSettingsGas}</b></td></tr>
                <tr>
                  <td>
                    ${"$"}{lblPowerCost}
                  </td>
                  <td>
                    <input id="gasPricePerKWh" type="text" size="5" value="0.00" style="text-align:center"/>
                  </td>
                </tr>
                <tr>
                  <td>
                    ${"$"}{lblGeneralSettingsHeatingValue}
                  </td>
                  <td>
                    <input id="gasHeatingValue" type="text" size="5" value="0.00" style="text-align:center"/>
                  </td>
                </tr>
                <tr>
                  <td>
                    ${"$"}{lblGeneralSettingsConditionNumber}
                  </td>
                  <td>
                    <input id="gasConditionNumber" type="text" size="5" value="0.00" style="text-align:center"/>
                  </td>
                </tr>
              </table>
		        </td>
		      </tr>

		      <tr><td colspan="2"><hr></td></tr>
		      <tr>
		        <td colspan="2" align="center">
					    <div id="savePriceKWhBtn" class="StdButton CLASS04907" onClick="savePricePerKWh(this)">${"$"}{btnSave}</div>
		        </td>
		      </tr>

		    </table>

  	  </td>
  	  <td align="left">
      ${"$"}{helpPowerCost}
  	  </td>
		</tr>


    <!-- Service- / Alarm LED -->
		<tr id="tdLEDS" class="CLASS21115 hidden">
			<td class="CLASS21116">${"$"}{dialogSettingsStorageTitleLEDS}</td>
			<td  align="left"  width="35%">
				<table>
					<tr>
						<td class="CLASS21112"><label class="CLASS04904">${"$"}{dialogSettingsStorageSettingsLblServiceLed}</label></td>
						<td><input id="inputServiceLed" type="checkbox" onClick="onInfoLedCheckChange()" /></td>
					</tr>
					<tr>
						<td class="CLASS21112"><label class="CLASS04904">${"$"}{dialogSettingsStorageSettingsLblAlarmLed}</label></td>
						<td><input id="inputAlarmLed" type="checkbox" onClick="onInfoLedCheckChange()" /></td>
					</tr>
				</table>
			</td>
			<td class="CLASS21113" align="left">
				<p> ${"$"}{dialogSettingsStorageHintLEDS} </p>
			</td>
		</tr>

    <tr id="fieldTest" class="hidden">
      <td>${"$"}{lblBetaTest}</td>
      <td align="left" width="35%" class="CLASS21115">
        <table>
          <tr>
            <td class="CLASS21112"><label class="CLASS04904">${"$"}{showDeviceBetaFw}</label></td>
            <td><input id="inputShowBetaFw" type="checkbox" onClick="activateDeviceBetaFw()" /></td>
          </tr>
        </table>
      </td>
      <td class="CLASS21113" align="left">
        <p> ${"$"}{hintDeviceBetaFw} </p>
      </td>
    </tr>

    <tr id='setWebUIColor' class='hidden'>
      <td>WebUI Color Scheme</td>
      <td class='CLASS21115'>
        <div class="StdButton CLASS04907" onClick="setColorWebUI();"">Set Color </div>
      </td>
      <td class='CLASS21115'></td>
    </tr>

	</table>
</div>

<div class="popupControls">
	<table>
		<tr>
			<td class="CLASS21103">
				<div class="CLASS21108" onClick="PopupClose()">${"$"}{footerBtnPageBack}</div>
			</td>
		</tr>
	</table>
</div>

<script type='text/javascript'>
   var setWebUIColor = homematic("system.getTweak", {"key":"SET_COLOR_WEBUI"});
   if (setWebUIColor == true) {
     jQuery('#setWebUIColor').show();	
   }

   if (homematic("CCU.existsFile", {"file" : "/etc/config/fieldTestActive"})) {
      jQuery("#inputShowBetaFw").prop("checked",true);
   }

</script>
