CC_ActivateFreeTemp = function(selectelem, pref)
{
  var pnr = selectelem.options[selectelem.selectedIndex].value; //1
  var upnr = pnr.split(".")[1];

  //2
  if (isNaN(upnr) == true) {
    var special_input_id = selectelem.id.split("_")[0]; //3 
    var selectedvalue = document.getElementById("separate_" + special_input_id + "_" + pnr + "_" + pref).value; //4 
    var parameter = document.getElementById("separate_" + special_input_id + "_" + pnr + "_" + pref).name; //5  
    var temperatur = document.getElementById("vis_temp_" + pnr + "_" + pref + "_" + special_input_id);
    var x_max = selectelem.length + 1;
    //6 
    if (pnr > x_max) {x_max = parseInt(pnr) + 1;}
    var y_max = 15;
    //7
    if (exists_temparr != "ok" || temp_tmp != x_max) 
    {
      //8
      temp2d = [];
      for (var i = 0; i < x_max; ++i) 
      temp2d[i] = [];
      exists_temparr = "ok";
      temp_tmp = x_max; //9
    }
    temp2d[pnr][pref] = 0;
    
    prefix[parameter + special_input_id] = pnr + "_" + pref + "_" + special_input_id; 
      
    if (selectedvalue == "99999997" )
    {   
      document.getElementById("NewProfileTemplate_receiver").style.visibility = "hidden";
      document.getElementById("receiver_profiles").options[selectelem.selectedIndex].style.color = WebUI.getColor("gray");
      if (CheckGroup()) document.getElementById("NewProfileTemplate_receivergroup").style.visibility = "hidden";
      temp2d[pnr][pref] = 1; //10
      temperatur.style.display = "inline";
    
    } else { 
      if (free_time != 1 && free_perc != 1 && free_temp != 1) {
      document.getElementById("NewProfileTemplate_receiver").style.visibility = "visible";
      if (CheckGroup()) document.getElementById("NewProfileTemplate_receivergroup").style.visibility = "visible";
      } else  document.getElementById("receiver_profiles").options[selectelem.selectedIndex].style.color = CC_TextColor(_textcolor);
      
      temp2d[pnr][pref] = 0; //11
      temperatur.style.display = "none";
    }
  
    free_temp = 0; //12 
    for (var loopx = 0; loopx < x_max; loopx++){
      for (var loopy = 0; loopy < y_max; loopy++){
        if (temp2d[loopx][loopy] == 1) {free_temp = 1; break;}
      }
    }
    
    for (loopy = 0; loopy <= y_max; loopy++) {
      if (temp2d[pnr][loopy] == 1)   {temp_textcolor = 1; break;}
      else temp_textcolor = 0;
    }
    
    if (time_textcolor == 0 && perc_textcolor == 0 && temp_textcolor == 0) _textcolor = 0;
    else _textcolor = 1;
    document.getElementById("receiver_profiles").options[selectelem.selectedIndex].style.color = CC_TextColor(_textcolor);
    
    if (free_time == 0 && free_perc == 0 && free_temp == 0) {
      document.getElementById("NewProfileTemplate_receiver").style.visibility = "visible";
      if (CheckGroup()) document.getElementById("NewProfileTemplate_receivergroup").style.visibility = "visible";
    }
  }
};

CC_check_Value = function(id)
{
  var unit_cf = document.getElementById('separate_CHANNEL_2_2').selectedIndex ;//1 
  var val = ($F(id)); //2 
  var input = $(id + "_temp"); //3 
  var min = 6;
  var max = 30;
  var ok = false;
  var valid = /^[1-3]?[0-9]\.?[0-9]*$/; 
  
  //4 
  if (unit_cf)
  {
    min = 42.8; //5 
    max = 86.0; //6 
    valid = /^[4-8]?[0-9]\.?[0-9]*$/; 
  }
  
  if (input.value.match(valid)) 
  ok = true;
  
  if (input.value < min || input.value > max || ok == false)
  {
    input.style.backgroundColor = WebUI.getColor("red");
    input.style.textAlign = "center";
    document.getElementById('separate_CHANNEL_2_2').disabled = true ; //7 
    document.getElementById('separate_CHANNEL_2_5_temp').disabled = true ; 
    document.getElementById('separate_CHANNEL_2_6_temp').disabled = true ; 
    document.getElementById('separate_CHANNEL_2_8_temp').disabled = true ; 
    input.disabled = false;
    input.value =  "min= " + min + " max= " + max ;
  }
  else
  {
    input.style.backgroundColor = WebUI.getColor("transparent");
    input.style.textAlign = "left";
    document.getElementById('separate_CHANNEL_2_2').disabled = false ; //8 
    document.getElementById('separate_CHANNEL_2_5_temp').disabled = false ; 
    document.getElementById('separate_CHANNEL_2_6_temp').disabled = false ; 
    document.getElementById('separate_CHANNEL_2_8_temp').disabled = false ; 
  }

  //9 
  if (unit_cf == 1)
  {
    $(id).value = (($F(input) - 32) * 5 / 9 ).toFixed(1);
  }
  else
  {  
    $(id).value = ($F(input));
  }
  
};

CC_conv_CF = function()
{
  //1 
  var unit_cf = document.getElementById('separate_CHANNEL_2_2').selectedIndex ;//2 
  
  var temp_5 = $F('separate_CHANNEL_2_5_temp'); //3 
  var temp_6 = $F('separate_CHANNEL_2_6_temp');
  var temp_8 = $F('separate_CHANNEL_2_8_temp');
  
  //4 
  if (unit_cf == 1)
  {
    document.getElementById('separate_CHANNEL_2_5').value = ((temp_5 - 32) * 5 / 9 ).toFixed(1);
    document.getElementById('separate_CHANNEL_2_6').value = ((temp_6 - 32) * 5 / 9 ).toFixed(1);
    document.getElementById('separate_CHANNEL_2_8').value = ((temp_8 - 32) * 5 / 9 ).toFixed(1);
  }
  else
  {  
    
    document.getElementById('separate_CHANNEL_2_5').value = temp_5 ;
    document.getElementById('separate_CHANNEL_2_6').value = temp_6 ;
    document.getElementById('separate_CHANNEL_2_8').value = temp_8 ;
  }
  
};

CC_save_Temp = function(prgName)
{
  var prg = (typeof prgName != "undefined" && prgName != null) ? prgName : "";
  var unit_cf = 0;

  if ($F("global_iface") == "BidCos-RF") {
    try {
      // C or F - the new heating control supports no F
      unit_cf = document.getElementById('separate_CHANNEL_2_2').selectedIndex;//2
    } catch (e) {
    }
  }

  for (loop = 0; loop <= (document.getElementsByName(prg+'temp_tmp').length -1); loop++)
  {
    if (unit_cf == 0)
      document.getElementsByName(prg + 'temp')[loop].value = parseFloat(document.getElementsByName(prg +'temp_tmp')[loop].value).toFixed(1);
    else
      document.getElementsByName(prg+'temp')[loop].value = parseFloat((document.getElementsByName(prg+'temp_tmp')[loop].value -32) * 5 / 9 ).toFixed(1);
  }
};

CC_setUnit = function()
{
  var unit_cf = document.getElementById('separate_CHANNEL_2_2').selectedIndex,
  unit = "",
  loop = 0;
  if (unit_cf) unit = "F";
  else unit = "C";
  
  //2
  var anzahl = document.getElementsByTagName('span').length - 1;
  for (loop = 0; loop <= anzahl; loop++)
  {
    var knoten = document.getElementsByTagName('span')[loop];
    var einheit = document.createTextNode(unit);
    if (knoten.hasChildNodes()) 
    {
      if (knoten.firstChild.data == "C" || knoten.firstChild.data == "F" )
      {
        knoten.replaceChild(einheit, knoten.firstChild);
      }
    }
  }


  var temp_5 = $F('separate_CHANNEL_2_5_temp');
  var temp_6 = $F('separate_CHANNEL_2_6_temp');
  var temp_8 = $F('separate_CHANNEL_2_8_temp');

  //3 
  if (unit_cf == 1 && $F('separate_CHANNEL_2_5_temp') < 40) 
  {
      
    document.getElementById('separate_CHANNEL_2_5_temp').value = (temp_5 / 5 * 9 + 32).toFixed(1) ;  
    document.getElementById('separate_CHANNEL_2_6_temp').value = (temp_6 / 5 * 9 + 32).toFixed(1) ;  
    document.getElementById('separate_CHANNEL_2_8_temp').value = (temp_8 / 5 * 9 + 32).toFixed(1) ;  

  }
  
  //4 
  if (unit_cf == 0 && $F('separate_CHANNEL_2_5_temp') > 40)
  {
    document.getElementById('separate_CHANNEL_2_5_temp').value = ((temp_5 - 32 ) * 5 / 9).toFixed(1) ;  
    document.getElementById('separate_CHANNEL_2_6_temp').value = ((temp_6 - 32 ) * 5 / 9).toFixed(1) ;  
    document.getElementById('separate_CHANNEL_2_8_temp').value = ((temp_8 - 32 ) * 5 / 9).toFixed(1) ;  
  
    //5 
    for (loop = 0; loop <= (document.getElementsByName('temp_tmp').length -1); loop++)
    {
      document.getElementsByName('temp_tmp')[loop].value = document.getElementsByName('temp')[loop].value;
    }
  }

  //6   
  if (unit_cf == 1)
  {
    for (loop = 0; loop <= (document.getElementsByName('temp_tmp').length -1); loop++)
    {
      document.getElementsByName('temp_tmp')[loop].value = (document.getElementsByName('temp')[loop].value / 5 * 9 + 32).toFixed(1);
    }
  }
  CC_conv_CF();
};


CC_TextColor = function(c)
{
  if (!c) { return WebUI.getColor("windowText"); }
  else    { return WebUI.getColor("gray"); }
};

CC_TimeTable_on_off = function()
{
  //1  
  var id_mode = document.getElementById('separate_CHANNEL_2_3');
  var time_area = document.getElementById('Timeouts_Area');
  var selectedElement = id_mode.selectedIndex; //2 
  
  //if (selectedElement == 1 || selectedElement == 3) time_area.style.display = "block"; 
  if (selectedElement == 1)  {time_area.style.display = "block"; time_area.scrollIntoView();}
  else time_area.style.display = "none"; 
};

setPointVisibility = function(elem, prn) {
  var curMode = jQuery("#separate_" +elem+ "_" +prn+ "_1 :selected").val();
  if (curMode == 1 || curMode == 3 || curMode == 4) {
    jQuery("#setpoint_" + elem).show();
  } else {jQuery("#setpoint_" + elem).hide();}
};

setMinMaxTempOption = function(optionElemId, tmpElemId) {
  var optionElem = jQuery('#' + optionElemId),
     origVal = parseFloat(jQuery('#' + tmpElemId).val());

  jQuery('#'+optionElemId +' > option').each(function(index, val) {
    var htmlVal = parseFloat(jQuery(this).html()).toFixed(1);
    if (htmlVal == origVal) {
      optionElem.val(index).attr('selected', true);
    }
    if (htmlVal < 5.0) {
      jQuery(this).html(translateKey("optionTemperatureMinimum"));
    }

    if (htmlVal > 30.0) {
      jQuery(this).html(translateKey("optionTemperatureMaximum"));
    }
  });
};

setMinMaxTemp = function(optionElemId, tmpElemId) {
  var selectedVal = jQuery("#"+optionElemId + " option:selected").html();
  // OFF selected
  if (isNaN(parseFloat(selectedVal)) && selectedVal == jQuery("#"+optionElemId + " option:first").html()) {
   selectedVal = 4.5;
  }
  // ON selected
  if (isNaN(parseFloat(selectedVal)) && selectedVal == jQuery("#"+optionElemId + " option:last").html()) {
   selectedVal = 30.5;
  }
  jQuery("#" + tmpElemId).val(parseFloat(selectedVal));
};


isEcoLTComfort = function(elmName) {
  // elmName should be e. g. TEMPERATURE_COMFORT
  var arName = elmName.split("_"),
  elmType = arName[1], // e.g.COMFORT
  isComfort = (elmType == "COMFORT") ? true : false,
  comfElm = jQuery("input[name='"+arName[0]+"_COMFORT']"),
  comfValIsValid = (comfElm.attr("valvalid") == "true") ? true : false,
  ecoElm = jQuery("input[name='"+arName[0]+"_LOWERING']"),
  ecoValIsValid = (ecoElm.attr("valvalid") == "true") ? true : false,
  comfVal = parseInt(jQuery(comfElm[0]).val()),
  ecoVal = parseInt(jQuery(ecoElm[0]).val()),
  comfOldElm = jQuery("#comfortOld"),
  ecoOldElm = jQuery("#ecoOld"),
  errorRow = jQuery("#errorRow"),
  errorComfElm = jQuery("#errorComfort"),
  errorEcoElm = jQuery("#errorEco"),
  errorMsg = translateKey("errorComfortLTEco"),
  fadeOutTime = 3500;

  //console.log("comfValIsValid: " + comfValIsValid + " - ecoValIsValid: " + ecoValIsValid);

  switch (elmType) {
    case "COMFORT":
      if (comfValIsValid) {
        if (comfVal < ecoVal) {
          jQuery(comfElm[0]).val(parseFloat(jQuery(comfOldElm).val()).toFixed(2));
          errorRow.show();
          errorComfElm.html(errorMsg).show();
          errorComfElm.fadeOut(fadeOutTime);
        }
      } else {
        jQuery(comfElm[0]).val(parseFloat(jQuery(comfOldElm).val()).toFixed(2));
      }
      break;
    case "LOWERING":
      if (ecoValIsValid) {
        if (ecoValIsValid && (ecoVal > comfVal)) {
          jQuery(ecoElm[0]).val(parseFloat(jQuery(ecoOldElm).val()).toFixed(2));
          errorRow.show();
          errorEcoElm.html(errorMsg).show();
          errorEcoElm.fadeOut(fadeOutTime);
        }
      } else {
        jQuery(ecoElm[0]).val(parseFloat(jQuery(ecoOldElm).val()).toFixed(2));
      }
      break;
  }
  comfVal = parseFloat(jQuery(comfElm).val()).toFixed(2);
  ecoVal = parseFloat(jQuery(ecoElm).val()).toFixed(2);
  jQuery(comfElm).val(comfVal);
  jQuery(ecoElm).val(ecoVal);

  jQuery(comfOldElm).val(jQuery(comfElm[0]).val());
  jQuery(ecoOldElm).val(jQuery(ecoElm[0]).val());

};