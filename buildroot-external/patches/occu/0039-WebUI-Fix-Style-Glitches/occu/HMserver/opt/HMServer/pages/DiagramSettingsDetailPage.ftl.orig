<html>
<head>


<script type="text/javascript">
	var notAssignedVisible;
	var diagramType = "";
	var devType = "";

	var jUnitElm = jQuery("#diagram_displayedUnit"),
	jConsolidationElm = jQuery("#diagram_defaultConsolidationFunction");

  GetDeviceName = function(address) {
	var dev = DeviceList.getDeviceByAddress(address);
	if (dev != undefined) {
		return dev.getName();
	} else {
		return address;
	}
  };

  GetChannelName = function(address) {
	var ch = DeviceList.getChannelByAddress(address);
	if (ch != undefined) {
		return ch.getName();
	} else {
		return address;
	}
  };

  ShowNotAssigned = function() {
	jQuery('#notAssignedDataSources').show();
	jQuery('#notAssignedDataSourcesMINUS').show();
	jQuery('#notAssignedDataSourcesPLUS').hide();
	notAssignedVisible = 1;
  };

  HideNotAssigned = function() {
	jQuery('#notAssignedDataSources').hide();
	jQuery('#notAssignedDataSourcesMINUS').hide();
	jQuery('#notAssignedDataSourcesPLUS').show();
	notAssignedVisible = 0;
  };

  adaptDefaultPeriodOptions = function() {
    var arOptions = [
      translateKey("diagramPeriodToday"),
      translateKey("diagramPeriodThisWeek"),
      translateKey("diagramPeriodThisMonth"),
      translateKey("diagramPeriodThisYear")
    ];

    jQuery("#diagram_defaultPeriod option").each(function(index) {
      jQuery(this).text(arOptions[index]);
    });
  };

  initDiagramType = function(type) {
    // type 1 = temperature, 2 = energy, 3 = user
    // TODO translate the unit values
    var arUnit = ["","\u00B0C", "Wh", ""];
    if (jUnitElm.val() == "") {
      jUnitElm.val(arUnit[type]);
    }
    if (type == 1 || type == 2) {
      // With bargraph diagrams the visible time period changes, e. g. there is no 'Last 24h' but a option 'Today'
      adaptDefaultPeriodOptions();

      // Select only the value 'Total' and hide the other options.
      jConsolidationElm.val(3).prop("selected", true).prop("disabled",true);
      jQuery("[name='nonTotal']").hide();
      jQuery("[name='total']").show();
    } else {
      // Hide the option 'Total'
      jQuery("[name='nonTotal']").show();
      jQuery("[name='total']").hide();
    }

  };

(function () {
	setPath("<span onclick='WebUI.enter(DiagramDetailPage);'>"+translateKey('menuSettingsPage')+"</span> &gt; "+ translateKey('submenuCreateDiagram'));

	<#if object.id = 0 && object.name == "">
		jQuery('#diagram_name').val(translateKey('diagramDefaultName'));
	</#if>

	var devSN;

	var s = "";
	s += "<table cellspacing='8'>";
	s += "<tr>";
	s += "<td align='center' valign='middle'><div class='FooterButton' onclick='ReturnToListWithoutSave();'>"+ translateKey('footerBtnCancel') +"</div></td>";
	s += "<td align='center' valign='middle'><div class='FooterButton' onclick='SaveDiagram();'>"+ translateKey('footerBtnOk') +"</div></td>";
	s += "</tr>";
	s += "</table>";
	setFooter(s);
	translateButtons("btnRemove");
	translateButtons("btnAddDataSource");
	translatePage("#parameterTable");
	translatePage("#dataSourcesTable");
	jQuery("#DiagramDetailPage").show();

	<#assign i = 0>
	<#list object.dataSources as dataSource>
	  devSN = '${dataSource.id}';
	  devType = DeviceList.getDeviceByAddress(devSN.split(':')[0]);
		jQuery('#assignedGroupName${i}').text(GetDeviceName('${dataSource.getGroupId()}'));
		jQuery('#assignedName${i}').text(GetChannelName('${dataSource.getId()?substring(0,dataSource.getId()?index_of("_"))}'));
	<#assign i = i + 1>
	</#list>

	<#assign i = 0>
	<#list notAssignedDataSources as dataSource>
		jQuery('#notAssignedGroupName${i}').text(GetDeviceName('${dataSource.getGroupId()}'));
		jQuery('#notAssignedName${i}').text(GetChannelName('${dataSource.getId()?substring(0,dataSource.getId()?index_of("_"))}'));

    var chnType = jQuery('#notAssignedName${i}').text().split(" ")[0],
    chnAddress = '${dataSource.getId()}',
    channel = DeviceList.getChannelByAddress(chnAddress.split("_")[0]);

    if (channel.typeName == "HmIP-ESI") {
      var adrChnOne = channel.address.split(":")[0] + ":1",
      sensor = parseInt(homematic("Interface.getValue", {"interface": "HmIP-RF", "address": adrChnOne, "valueKey": "CHANNEL_OPERATION_MODE"}));

      if (isNaN(sensor)) {sensor = 0;}

      var valTypeElm = jQuery("#notAssignedValType${i}");

      if ("${dataSource.getKey()}" == "POWER") {
        if ((sensor < 3) && (channel.index > 2)) {
         // jQuery("#notAssignedGroupName${i}").parent().hide();
        }
        if (sensor == 1) {
            valTypeElm.html(translateKey("diagramValueTypeGAS_FLOW"));
        } else if (sensor == 2) {
          valTypeElm.html(translateKey("diagramValueTypePOWER"));
        } else if (sensor > 2) {
          valTypeElm.html(translateKey("diagramValueTypeIEC_POWER"));
        } else {valTypeElm.html(translateKey("diagramValueTypePOWER"));}
      }

      if ("${dataSource.getKey()}" == "ENERGY_COUNTER") {
        if ((sensor < 3) && (channel.index > 2)) {
         // jQuery("#notAssignedGroupName${i}").parent().hide();
        }
        if (sensor == 1) {
         valTypeElm.html(translateKey("diagramValueTypeGAS_VOLUME"));
        } else if (sensor == 2) {
         valTypeElm.html(translateKey("diagramValueTypeENERGY_COUNTER"));
        } else if (sensor > 2) {
         valTypeElm.html(translateKey("diagramValueTypeIEC_ENERGY_COUNTER"));
        } else {valTypeElm.html(translateKey("diagramValueTypeENERGY_COUNTER"));}
      }

      if (("${dataSource.getKey()}" == "GAS_FLOW") || ("${dataSource.getKey()}" == "GAS_VOLUME")) {
       // jQuery("#notAssignedGroupName${i}").parent().hide();
      }

    }

	<#assign i = i + 1>
	</#list>



	<#if notAssignedVisible = "1">
		ShowNotAssigned();
	<#else>
		HideNotAssigned();
	</#if>
	  initDiagramType(${object.type});
		initSelectColorDropDowns();
	})();

	function initSelectColorDropDowns() {
		jQuery('.dropdown').msDropDown();
	}
</script>

<style>
<#list [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] as x>
option.Colors${x}{
<#if 2= x>
color:#ffffff;
</#if>
<#if 2 != x>
color:#000000;
</#if>
background-color:#${colors[x]};
}
</#list>
</style>
</head>
<body>
<form>
<table id="parameterTable" class="tTable"  border="0" cellpadding="0" cellspacing="0">
  <thead>
  <tr>
      <td class="thCell CLASS04900" >${"$"}{thParameter}</td>
      <td class="thCell CLASS04900" >${"$"}{thValues}</td>
    </tr>
  </thead>
  <tbody>
  	<input type="hidden" id="diagram_id" value="${object.id}" />
  	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramName}</td>
        <td class="tBodyCell">
        	<input type="text" id="diagram_name" value="${object.name}" size="100" maxlength="200"/>
        </td>
    </tr>
  	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramDescription}</td>
        <td class="tBodyCell">
        	<input type="text" id="diagram_description" value="${object.description}" size="100" maxlength="200"/>
        </td>
    </tr>
    <tr class="hidden">
  		<td class="tBodyCell">${"$"}{thDiagramType}</td>
        <td class="tBodyCell">
        	<input type="text" id="diagram_type" value="${object.type}" size="100" maxlength="200"/>
        </td>
    </tr>
  	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramTemplate}</td>
        <td class="tBodyCell">
        	<select id="diagram_templateId" size="1">
		        <#list templates as template>
	        		<!--<option value="${template.id}" <#if object.templateId = template.getId()>selected</#if> >${template.getName()} - ${template.getDescription()}</option>-->
	        		<option value="${template.id}" <#if object.templateId = template.getId()>selected</#if> >${template.getDescription()}</option>
	        	</#list>
	        </select>
        </td>
    </tr>
  	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramDefaultPeriod}</td>
        <td class="tBodyCell">
	        <select id="diagram_defaultPeriod" size="1">
	          <!--<option value="0" <#if object.defaultPeriod = 0>selected</#if> > ${"$"}{diagramPeriodLastHour}</option>-->
	        	<option value="1" <#if object.defaultPeriod = 1>selected</#if> > ${"$"}{diagramPeriodLastDay}</option>
	        	<option value="2" <#if object.defaultPeriod = 2>selected</#if> > ${"$"}{diagramPeriodLastWeek}</option>
	        	<option value="3" <#if object.defaultPeriod = 3>selected</#if> > ${"$"}{diagramPeriodLastMonth}</option>
	        	<option value="4" <#if object.defaultPeriod = 4>selected</#if> > ${"$"}{diagramPeriodLastYear}</option>
	        </select>
        </td>
    </tr>
  	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramDefaultConsolidationFunction}</td>
        <td class="tBodyCell">
	        <select id="diagram_defaultConsolidationFunction" size="1">
	        	<option name="nonTotal" value="0" <#if object.defaultConsolidationFunction = 0>selected</#if> > ${"$"}{diagramConsolidationFunctionAverage}</option>
	        	<option name="nonTotal" value="1" <#if object.defaultConsolidationFunction = 1>selected</#if> > ${"$"}{diagramConsolidationFunctionMinimum}</option>
	        	<option name="nonTotal" value="2" <#if object.defaultConsolidationFunction = 2>selected</#if> > ${"$"}{diagramConsolidationFunctionMaximum}</option>
	        	<option name="total" value="3" <#if object.defaultConsolidationFunction = 3>selected</#if> > ${"$"}{diagramConsolidationFunctionTotal}</option>
	        </select>
        </td>
    </tr>
	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramDisplayedUnit}</td>
        <td class="tBodyCell">
        	<input type="text" id="diagram_displayedUnit" value="${object.displayedUnit}" size="50" maxlength="50"/>
        </td>
    </tr>
	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramYAxisScalingModeMin}</td>
        <td class="tBodyCell">
			<table>
				<tr>
					<td><input type="radio" name="selectYAxisScalingModeMin" ${object.usingCustomYAxisMin?string('', 'checked')} id="diagram_selectYAxisScalingModeMinAutomatic" value="false">${"$"}{diagramScalingModeAutomatic}</input></td>
				</tr>
				<tr>
					<td><input type="radio" name="selectYAxisScalingModeMin" ${object.usingCustomYAxisMin?string('checked', '')} id="diagram_selectYAxisScalingModeMinCustom" value="true">${"$"}{diagramScalingModeCustom}</input>
					<input type="text" id="diagram_YAxisScalingMinValue" value="${object.customYAxisMin}"></input></td>
				</tr>
			</table>
        </td>
    </tr>
	<tr>
  		<td class="tBodyCell">${"$"}{thDiagramYAxisScalingModeMax}</td>
        <td class="tBodyCell">
        	<table>
				<tr>
					<td><input type="radio" name="selectYAxisScalingModeMax" ${object.usingCustomYAxisMax?string('', 'checked')} id="diagram_selectYAxisScalingModeMaxAutomatic" value="false">${"$"}{diagramScalingModeAutomatic}</input></td>
				</tr>
				<tr>
					<td><input type="radio" name="selectYAxisScalingModeMax" ${object.usingCustomYAxisMax?string('checked', '')} id="diagram_selectYAxisScalingModeMaxCustom" value="true">${"$"}{diagramScalingModeCustom}</input>
					<input type="text" id="diagram_YAxisScalingMaxValue" value="${object.customYAxisMax}"></input></td>
				</tr>
			</table>
        </td>
    </tr>

  </tbody>
</table>
<table id="dataSourcesTable" class="tTable"  border="0" cellpadding="0" cellspacing="0">
  <thead>
    <tr>
      <td class="thCell CLASS04900" colspan="6">
		${"$"}{thDiagramAssignedDataSourceGroups}
		</td>
    </tr>
    <tr>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceGroupName}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceGroup}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSource}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceType}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceColor}</td>
      <td class="thCell CLASS04900" >${"$"}{thAction}</td>
    </tr>
  </thead>
  <tbody id="assignedDataSources">
	<#assign i = 0>
    <#list object.dataSources as dataSource>
    <tr class="CLASS04901">
  		<td class="tBodyCell CLASS04902" id="assignedGroupName${i}"></td>
  		<td class="tBodyCell CLASS04907">${dataSource.getGroupId()}</td>
  		<td class="tBodyCell CLASS04902" id="assignedName${i}"></td>
      <td class="tBodyCell CLASS04907" id="assignedValType${i}" name="valueType${dataSource.getKey()}">${"$"}{diagramValueType${dataSource.getKey()}}</td>

      <script>
        if ((devType.typeName == "HmIP-SCTH230") && ("${dataSource.getKey()}" == "CONCENTRATION") ) {
          jQuery(" [name='valueType${dataSource.getKey()}'] ").html( '${"$"}{diagramValueType${dataSource.getKey()}_CO2}' );
        }
        var chnType = jQuery('#assignedName${i}').text().split(" ")[0],
        chnAddress = '${dataSource.getId()}',
        channel = DeviceList.getChannelByAddress(chnAddress.split("_")[0]);

        if (channel.typeName == "HmIP-ESI") {
          var adrChnOne = channel.address.split(":")[0] + ":1",
          sensor = parseInt(homematic("Interface.getValue", {"interface": "HmIP-RF", "address": adrChnOne, "valueKey": "CHANNEL_OPERATION_MODE"}));

          if (isNaN(sensor)) {sensor = 0;}

          var valTypeElm = jQuery("#assignedValType${i}");

          if ("${dataSource.getKey()}" == "POWER") {
            if (sensor == 1) {
                valTypeElm.html(translateKey("diagramValueTypeGAS_FLOW"));
            } else if (sensor == 2) {
              valTypeElm.html(translateKey("diagramValueTypePOWER"));
            } else if (sensor > 2) {
              valTypeElm.html(translateKey("diagramValueTypeIEC_POWER"));
            } else {valTypeElm.html(translateKey("diagramValueTypePOWER"));}
          }

          if ("${dataSource.getKey()}" == "ENERGY_COUNTER") {
            if (sensor == 1) {
             valTypeElm.html(translateKey("diagramValueTypeGAS_VOLUME"));
            } else if (sensor == 2) {
             valTypeElm.html(translateKey("diagramValueTypeENERGY_COUNTER"));
            } else if (sensor > 2) {
             valTypeElm.html(translateKey("diagramValueTypeIEC_ENERGY_COUNTER"));
            } else {valTypeElm.html(translateKey("diagramValueTypeENERGY_COUNTER"));}
          }
        }

      </script>

        <td class="tBodyCell CLASS04907">
		<select id="assignedColor${i}" class="dropdown" size="1" style="width:175px;">
        	<#list [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] as x>
        		<option value="${x}" class="Colors${x}" data-image="/webui/css/extern/msdropdown/icons/${x}.png" <#if dataSource.getColor() = x>selected</#if> > ${"$"}{diagramColor${colors[x]}}</option>
        	</#list>
        </select></td>
		<!-- Start action column -->
		<td class="tBodyCell CLASS04907" >
		<input type="button" name="btnRemove" value="btnRemove" class="StdButton CLASS04907" onclick="DeleteDataSource(${i});" />
		</td>
		<!-- End Action Column -->
    </tr>
	<#assign i = i + 1>
    </#list>
	<tr>
      <td height="10" colspan="6">
	  </td>
    </tr>
  </tbody>
  <thead>
    <tr>
      <td class="thCell CLASS04900" colspan="6">
		<img id="notAssignedDataSourcesPLUS" align="left" width="16px" height="16px" title="${"$"}{btnDiagramShowNotAssigned}" alt="${"$"}{btnDiagramShowNotAssigned}" src="/ise/img/plus.png" onclick="ShowNotAssigned();"></img>
		<img id="notAssignedDataSourcesMINUS" align="left" width="16px" height="16px" style="display:none;" title="${"$"}{btnDiagramHideNotAssigned}" alt="${"$"}{btnDiagramHideNotAssigned}" src="/ise/img/minus.png" onclick="HideNotAssigned();"></img>
		${"$"}{thDiagramAllDataSourceGroups}
		</td>
    </tr>
	<#if object.dataSources?size &gt; 14>
	<tr>
      <td class="tBodyCell CLASS04900 CLASS21906" colspan="6">
		${"$"}{diagramTooManyDataSources}
		</td>
    </tr>
	</#if>
  </thead>
  <tbody id="notAssignedDataSources" style="display:none;">
    <tr>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceGroupName}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceGroup}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSource}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceType}</td>
      <td class="thCell CLASS04900" >${"$"}{thDiagramDataSourceColor}</td>
      <td class="thCell CLASS04900" >${"$"}{thAction}</td>
    </tr>
	<#assign i = 0>
    <#list notAssignedDataSources as dataSource>
    <tr class="CLASS04901">
  		<td class="tBodyCell CLASS04902" id="notAssignedGroupName${i}"></td>
  		<td class="tBodyCell CLASS04907">${dataSource.getGroupId()}</td>
  		<td class="tBodyCell CLASS04902" id="notAssignedName${i}"></td>
      <td class="tBodyCell CLASS04907" id="notAssignedValType${i}" name="valueType${dataSource.getKey()}">${"$"}{diagramValueType${dataSource.getKey()}}</td>

      <script>

        if ((devType.typeName == "HmIP-SCTH230") && ("${dataSource.getKey()}" == "CONCENTRATION") ) {
          jQuery(" [name='valueType${dataSource.getKey()}'] ").html( '${"$"}{diagramValueType${dataSource.getKey()}_CO2}' );
        }

      </script>

      <td class="tBodyCell CLASS04907">
      <select id="notAssignedColor${i}" class="dropdown" style="width:175px;" size="1">
        <#list [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] as x>
          <option value="${x}" class="Colors${x}" data-image="/webui/css/extern/msdropdown/icons/${x}.png" <#if dataSource.getColor() = x>selected</#if> > ${"$"}{diagramColor${colors[x]}}</option>
        </#list>
      </select></td>
		<!-- Start action column -->
		<td class="tBodyCell CLASS04907" >
		<#if object.dataSources?size &lt; 15>
			<input type="button" name="btnAddDataSource" value="btnAddDataSource" class="StdButton CLASS04907" onclick="AddDataSource('${dataSource.getGroupId()}', '${dataSource.getId()}', '${i}');" />
		</#if>
		</td>
		<!-- End Action Column -->
    </tr>
	<#assign i = i + 1>
    </#list>
  </tbody>
</table>

<script type="text/javascript">
  AddDataSource = function(dataSourceGroupId, dataSourceId, notAssignedIndex) {
	if(!IsDiagramTextValid())	{
		return;
	}

	if(!IsDiagramYAxisValid())	{
		return;
	}

	var colorId = "#notAssignedColor" + notAssignedIndex;

	var url = '/pages/jpages/diagram/settings/addDataSource?sid='+SessionId;
    var pb = "{";
	pb += '"notAssignedVisible" : "' + notAssignedVisible + '", ';
	pb += '"id" : "${object.id}", ';
	pb += '"dataSourceGroupId" : "' + dataSourceGroupId + '", ';
	pb += '"colorIndex" : "' + jQuery(colorId).val() + '", ';
	pb += '"dataSourceId" : "' + dataSourceId + '", ';
    pb += GetCurrentDiagram();
    pb += '}';
    var opt = {
        postBody: pb,
        onComplete: function(t){
			var response = JSON.parse(t.responseText);
			if(!response.isSuccessful)
			{
				if(response.errorCode == "42")
				{
					jQuery("#content").html(response.content);
				} else {
					alert(translateKey(response.content));
				}
			} else {
				jQuery("#content").html(response.content);
			}
        }
    }
	new Ajax.Request(url,opt);
  };

  DeleteDataSource = function(dataSourceIndex) {
	if(!IsDiagramTextValid())	{
		return;
	}

	if(!IsDiagramYAxisValid())	{
		return;
	}

    var url = '/pages/jpages/diagram/settings/removeDataSource?sid='+SessionId;
    var pb = "{";
	pb += '"notAssignedVisible" : "' + notAssignedVisible + '", ';
	pb += '"id" : "${object.id}", ';
	pb += '"dataSourceIndex" : "' + dataSourceIndex + '", ';
    pb += GetCurrentDiagram();
    pb += '}';
    var opt = {
        postBody: pb,
        onComplete: function(t){
	        var response = JSON.parse(t.responseText);
			if(!response.isSuccessful)
			{
				if(response.errorCode == "42")
				{
					jQuery("#content").html(response.content);
				} else {
					alert(translateKey(response.content));
				}
			} else {
				jQuery("#content").html(response.content);
			}
        }
    }
	new Ajax.Request(url,opt);
  };

  SaveDiagram = function() {
	<#if object.dataSources?size = 0>
	alert(translateKey('diagramErrorNoDataSources'));
	return;
	</#if>

	if(!IsDiagramTextValid())	{
		return;
	}

	if(!IsDiagramYAxisValid())	{
		return;
	}

	MessageBox.show(translateKey('diagramSaveMessageTitle'), '<br/><br/><img id="messageBoxDiagramGraph" src="/ise/img/anim_bargraph.gif"><br/>',
	'','320','90', 'messageBoxDiagram', 'messageBoxDiagramGraph');

  	var url = '/pages/jpages/diagram/settings/save?sid='+SessionId;
    var pb = "{";
	pb += '"id" : "${object.id}", ';
    pb += GetCurrentDiagram();
    pb += '}';
    var opt = {
      postBody: pb,
      onComplete: function(t){
        jQuery("#messageBoxDiagram").remove();
        var response = JSON.parse(t.responseText);
        if(!response.isSuccessful)
        {
          if(response.errorCode == "42")
          {
            jQuery("#content").html(response.content);
          } else {
            alert(translateKey('diagramErrorCouldNotSave'));
          }
        } else {
          ReturnToListWithoutSave();
        }
      }
    }
	new Ajax.Request(url,opt);
  };

  IsDiagramTextValid = function() {
	var name = jQuery("#diagram_name").val();
	var description = jQuery("#diagram_description").val();
	var unit = jQuery("#diagram_displayedUnit").val();
	var forbidden   = /['\"\\]/;
	var isForbiddenName = forbidden.test( name );
	var isForbiddenDescription = forbidden.test( description );
	var isForbiddenUnit = forbidden.test( unit );

	if (isForbiddenName || isForbiddenDescription || isForbiddenUnit) {
		alert(translateKey('alertDiagramCharsNotAllowed'));
		return false;
	}

	return true;
  };

  IsDiagramYAxisValid = function() {
	var minValue = parseFloat(jQuery("#diagram_YAxisScalingMinValue").val().replace(",", "."));
	var maxValue = parseFloat(jQuery("#diagram_YAxisScalingMaxValue").val().replace(",", "."));

	if (isNaN(minValue)) {
		minValue = 0.0;
	}

	if (isNaN(maxValue)) {
		maxValue = 0.0;
	}

	var usingYAxisMin = jQuery('input[name=selectYAxisScalingModeMin]:checked', '#parameterTable').val();
	var usingYAxisMax = jQuery('input[name=selectYAxisScalingModeMax]:checked', '#parameterTable').val();

	if(usingYAxisMin == "false" || usingYAxisMax == "false") {
		return true;
	}

	if(minValue > maxValue) {
		alert(translateKey('alertDiagramMinLowerThanMax'));
		return false;
	}

	return true;
  }

  GetCurrentDiagram = function() {
	var minValue = parseFloat(jQuery("#diagram_YAxisScalingMinValue").val().replace(",", "."));
	var maxValue = parseFloat(jQuery("#diagram_YAxisScalingMaxValue").val().replace(",", "."));

	if (isNaN(minValue)) {
		minValue = 0.0;
	}

	if (isNaN(maxValue)) {
		maxValue = 0.0;
	}

	var name = jQuery("#diagram_name").val().replace("'", "").replace("\"", "").replace("\\", "");
	conInfo("Diagram name: " + name);
	var description = jQuery("#diagram_description").val().replace("'", "").replace("\"", "").replace("\\", "");
	var unit = jQuery("#diagram_displayedUnit").val().replace("'", "").replace("\"", "").replace("\\", "");
	name = escape(name);
	description = escape(description);
	unit = escape(unit);

	diagram = '"diagram" : {';
	diagram += '"id" : ${object.id}, ';
	diagram += '"name" : "' + name + '", ';
	diagram += '"description" : "' + description + '", ';
	diagram += '"type" : "' + jQuery("#diagram_type").val() + '", ';
	diagram += '"templateId" : ' + jQuery("#diagram_templateId").val() + ', ';
	diagram += '"defaultPeriod" : ' + jQuery("#diagram_defaultPeriod").val() + ', ';
	diagram += '"defaultConsolidationFunction" : ' + jQuery("#diagram_defaultConsolidationFunction").val() + ', ';
	diagram += '"displayedUnit" : "' + unit + '", ';
	diagram += '"active" : ${object.active?string('true', 'false')}, ';
	diagram += '"operable" : ${object.operable?string('true', 'false')}, ';
	diagram += '"visible" : ${object.visible?string('true', 'false')}, ';
	diagram += '"usingCustomYAxisMin" : ' + jQuery('input[name=selectYAxisScalingModeMin]:checked', '#parameterTable').val() + ', ';
	diagram += '"usingCustomYAxisMax" : ' + jQuery('input[name=selectYAxisScalingModeMax]:checked', '#parameterTable').val() + ', ';
	diagram += '"customYAxisMin" : ' + minValue + ', ';
	diagram += '"customYAxisMax" : ' + maxValue + ', ';
	diagram += '"dataSources" : [';

	<#assign i = 0>
    <#list object.dataSources as dataSource>
	diagram += '{"id" : "${dataSource.id}", ';
	diagram += '"groupId" : "${dataSource.groupId}",';
	diagram += '"key" : "${dataSource.key}", ';
	diagram += '"type" : ${dataSource.type}, ';
	diagram += '"color" : ' + jQuery("#assignedColor${i}").val() + '}, ';
	<#assign i = i + 1>
    </#list>
	// remove last ", "
	<#if object.dataSources?size != 0>
	diagram = diagram.substring(0, diagram.length - 2);
	</#if>
	diagram += ']';
    diagram += '}';
	return diagram;
  };

  ReturnToListWithoutSave = function() {
    var url = '/pages/jpages/diagram/settings?sid='+SessionId;
    var pb = "{}";
    var opt =
    {
      postBody: pb,
      onComplete: function(t)
      {
		jQuery("#content").html(t.responseText);
      }
    }
    new Ajax.Request(url,opt);
  };
</script>
</form>
</body>
</html>