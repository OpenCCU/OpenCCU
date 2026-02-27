<!--<html>
<head>-->


<script type="text/javascript">
  setPath("<span onclick='WebUI.enter(CreateGroupPage);'>"+translateKey('menuGroupListPage')+"</span> &gt; "+ translateKey('groupDetails'));
</script>
<!--</head>
<body>-->
<form id="groupEditForm" style="display: none">
 <table id="parameter" class="tTable"  border="0" cellpadding="0" cellspacing="0">
  <thead>
  <tr>
      <td class="thCell CLASS04900" >${"$"}{groupParameterName}</td>
      <td class="thCell CLASS04900" colspan="2">${"$"}{groupValue}</td>
    </tr>
  </thead>
  <tbody>
  	<input type="hidden" id="group_id" value="${object.id}" />
  	<tr>
  		<td class="tBodyCell">${"$"}{groupGroupName}</td>
        <td class="tBodyCell" colspan="2">
        	<input type="text" onchange="checkGroupName();" onclick="storeGroupName();" id="group_name" data-bind="value: groupName" size="50"/>
        	<div id="attentionDeviceNameChange" class='hidden attention'>${"$"}{lblAttentionGroupNameChange}</div>
        </td>
    </tr>
  	<tr>
  		<td class="tBodyCell">${"$"}{groupGroupType}</td>
        <td class="tBodyCell" colspan="2">
	        <select id="grpSelector" size="1" data-bind="options: possibleGroupTypes, value: groupType, optionsText: 'label',  enable: isNew">
	        </select>
        </td>
    </tr>
    <tr data-bind="visible: !isNew()">
        <td class="tBodyCell">${"$"}{virtualDeviceSerialNumber}</td>
        <!-- <td id="virtualDeviceSerialNumber" class="tBodyCell" data-bind="text: virtualDeviceSerialNumber"></td> -->
        <td class="tBodyCell" data-bind="text: groupDeviceName"></td>
        <td class="tBodyCell" style="width: 0px">
            <input style="margin: 5px; display: block" type="button" name="btnVirtualDeviceStateAndOperating" value="btnVirtualDeviceStateAndOperating" class="StdButton CLASS04907" data-bind="click: operateVirtualDevice"/>
            <input style="margin: 5px; display: block" type="button" name="btnVirtualDeviceConfiguration" value="btnVirtualDeviceConfiguration" class="StdButton CLASS04907" data-bind="click: configureVirtualDevice"/>
        </td>
    </tr>

    <tr class="hidden">
      <td class="tBodyCell">${"$"}{lblAllowOnlyGroupOperation}</td>
      <td class="tBodyCell" colspan="2"><input id="allowOnlyGroupOperation"  data-bind="checked: isSingleOperationForbidden" type="checkbox" ></td>
    </tr>
	
  </tbody>
 </table>
 <table class="tTable"  border="0" cellpadding="0" cellspacing="0">
 <thead>
     <tr>
         <td class="thCell CLASS04900" colspan="5" style="font-size: 16px !important">${"$"}{groupAssignedDevices}</td>
     </tr>
 </thead>
  <thead>
      <tr data-bind="foreach: assignedDeviceHeaders">
          <td style="height: 40px" class="thCell CLASS04900 clickable" data-bind="click: function(data, event) {$parent.sortDeviceList($parent.assignedDevices, $parent.activeAssignedDeviceListHeader, data, event)}, text: title, css: headerClass"></td>
      </tr>
  </thead>
 <tbody data-bind="foreach: assignedDevices">
      <tr class="CLASS04901">
          <td class="tBodyCell"><div data-bind="text: name"></div><div data-bind="html: extDescr"></div></td>
          <td class="tBodyCell" data-bind="text: devType"></td>
          <td class="tBodyCell" style="background-color: white; width: 10px">
              <div style="position: relative;" data-bind="event: {mouseover: showDevicePicture, mouseout: hideDevicePicture}">
                  <img data-bind="attr:{src: imagePath, title: name, alt: name}">
              </div>
          </td>
          <td class="tBodyCell" data-bind="text: serialNumber"></td>

          <!-- Start action column -->
          <td class="tBodyCell CLASS04902" style="padding-left: 10px; padding-right: 10px; width: 0px">
              <input type="button" name="btnGroupRemove" value="btnGroupRemove" class="StdButton CLASS04907" data-bind="click: $root.removeDevice"/>
          </td>
          <!-- End Action Column -->
      </tr>
  </tbody>
 <tfoot data-bind="visible: assignedDevices().length < 1">
     <tr class="CLASS04901">
         <td class="tBodyCell" colspan="5" >${"$"}{groupNoMoreDevices}</td>
     </tr>
 </tfoot>
 </table>

 <table class="tTable"  border="0" cellpadding="0" cellspacing="0">
  <thead>
    <tr>
      <td class="thCell CLASS04900" colspan="5" style="font-size: 16px !important">${"$"}{groupAllDevices}</td>
    </tr>
  </thead>
  <thead>
    <tr data-bind="foreach: assignableDeviceHeaders">
        <td style="height: 40px" class="thCell CLASS04900 clickable" data-bind="click: function(data, event) {$parent.sortDeviceList($parent.assignableDevices, $parent.activeAssignableDeviceListHeader, data, event)}, text: title, css: headerClass"></td>
      <!--<th class="thCell CLASS04900" >${"$"}{groupSerialNumber}</th>
      <th class="thCell CLASS04900" >${"$"}{groupDeviceName}</th>
      <th class="thCell CLASS04900" >${"$"}{groupAction}</th>-->

    </tr>
  </thead>
  <tbody data-bind="foreach: assignableDevices">
    <tr class="CLASS04901">
        <!--td class="tBodyCell" data-bind="text: name"></td-->
        <td class="tBodyCell"><div data-bind="text: name"></div><div data-bind="html: extDescr"></div></td>
        <td class="tBodyCell" data-bind="text: devType"></td>
        <td class="tBodyCell" style="background-color: white; width: 10px">
            <div style="position: relative;" data-bind="event: {mouseover: showDevicePicture, mouseout: hideDevicePicture}">
                <img data-bind="attr:{src: imagePath, title: name, alt: name}">
            </div>
        </td>
        <td class="tBodyCell" data-bind="text: serialNumber"></td>

    	<!-- Start action column -->        
		<td class="tBodyCell CLASS04902"  style="padding-left: 10px; padding-right: 10px; width: 0px">
		    <input type="button" name="btnAdd" value="btnAdd" class="StdButton CLASS04907" data-bind="click: $root.addDevice"/>
		</td>
		<!-- End Action Column -->       
    </tr>
    <!---->

  </tbody>
  <tfoot data-bind="visible: assignableDevices().length < 1">
      <tr class="CLASS04901">
          <td class="tBodyCell" colspan="5" >${"$"}{groupNoMorePossibleDevices}</td>
      </tr>
  </tfoot>
 </table>

 <table class="tTable"  border="0" cellpadding="0" cellspacing="0">
     <thead>
     <tr>
         <td class="thCell CLASS04900" colspan="5" style="font-size: 16px !important">${"$"}{groupLinkedDevices}</td>
     </tr>
     </thead>
     <thead>
     <tr data-bind="foreach: leftoverDeviceHeaders">
         <td style="height: 40px" class="thCell CLASS04900 clickable" data-bind="click: function(data, event) {$parent.sortDeviceList($parent.leftoverDevices, $parent.activeLeftoverDeviceListHeader, data, event)}, text: title, css: headerClass"></td>

     </tr>
     </thead>
     <tbody data-bind="foreach: leftoverDevices">
     <tr class="CLASS04901">
         <!-- td class="tBodyCell" data-bind="text: name"></td -->
         <td class="tBodyCell"><div data-bind="text: name"></div><div data-bind="html: extDescr"></div></td>
         <td class="tBodyCell" data-bind="text: devType"></td>
         <td class="tBodyCell" style="background-color: white; width: 10px">
             <div style="position: relative;" data-bind="event: {mouseover: showDevicePicture, mouseout: hideDevicePicture}">
                 <img data-bind="attr:{src: imagePath, title: name, alt: name}">
             </div>
         </td>
         <td class="tBodyCell" data-bind="text: serialNumber"></td>
     </tr>
     <!---->

     </tbody>
     <tfoot data-bind="visible: leftoverDevices().length < 1">
     <tr class="CLASS04901">
         <td class="tBodyCell" colspan="5" >${"$"}{groupNoMoreLeftoverDevices}</td>
     </tr>
     </tfoot>
 </table>

<script type="text/javascript">
       
      // Belongs to SPHM-1040 
      window.setTimeout(function() {
        var grpSelectorElm = jQuery("#grpSelector");
        // Execute this only when creating a new group
        if (! grpSelectorElm.prop("disabled")) {
          grpSelectorElm.prop("selectedIndex",1).change();
        }
      },100);


     this.groupNameHasChanged = false;
    // TWIST-589
    // Replaces the char " by '
    function checkGroupName() {
      var groupNameElem = jQuery("#group_name");
      groupNameElem.val(groupNameElem.val().replace(/"/g, "'"));
      this.groupNameHasChanged = true;
    }

    function storeGroupName() {
      if (viewModel.origGroupName == "") {
        viewModel.origGroupName = viewModel.groupName() + " " + viewModel.virtualDeviceSerialNumber();
      }
    }

    var sessionTimeoutErrorCode = "42";
    //Class to represent a GroupType
    function GroupType(id, label)
    {
        var self = this;
        this.id = id;
        this.label = label;
    }

    //The Viewmodel
    function GroupViewModel()
    {
        var self = this;
        self.changeVirtualDeviceName = true;
        self.origGroupName = "";
        self.groupId = ${object.id};
        self.isNew = ko.observable(${isNewGroup?c});
        /*self.executeDeviceRefresh = true;
        self.regaId = "2082"*/
        self.executeDeviceRefresh = ${executeDeviceRefresh?c};
        self.regaId = "${addedRegaId}";

        self.virtualDeviceSerialNumber = ko.observable("");
        self.groupDeviceName = ko.observable("");

        if(self.isNew())
        {
            self.groupName = ko.observable(translateKey('newGroupInputField'));
        }
        else
        {
            self.groupName = ko.observable("${object.name}");
            var temp = createVirtualDeviceSerialNumber(${object.id});
            self.virtualDeviceSerialNumber(temp);

            <#if object.groupDeviceName??>
              self.groupDeviceName("${object.groupDeviceName}");
            <#else>
               self.groupDeviceName("");
            </#if>
        }
        self.device = DeviceList.getDeviceByAddress(self.virtualDeviceSerialNumber());
        self.isSingleOperationForbidden = ${isSingleOperationForbidden}
        self.isSaving = ko.observable(false);

        self.possibleGroupTypes = [];
        <#list possibleGroupTypes as deviceType>self.possibleGroupTypes.push(new GroupType("${deviceType.getId()}", translateKey('${deviceType.getLabel()}')));</#list>



        ko.utils.arrayForEach(self.possibleGroupTypes, function(item) {
            if(item.id == "${groupType.getId()}") {
                self.groupType = ko.observable(item);
            }
        });

        self.groupType.subscribe(function(item)
        {
            var url = '/pages/jpages/group/suitableGroupMembers?sid='+SessionId;

            var data = new Object();

            data.groupTypeId = item.id;

            var pb = JSON.stringify(data);

            var opt =
            {
                postBody: pb,
                onComplete: function(t)
                {
                    var parsed = JSON.parse(t.responseText);
                    viewModel.assignableDevices.removeAll();
                    viewModel.assignedDevices.removeAll();
                    viewModel.leftoverDevices.removeAll();
                    ko.utils.arrayForEach(parsed.assignableGroupMembers, function(item) {
                        viewModel.assignableDevices.push(new GroupDevice(item.id, item.serialNumber, item.type));
                    });
                    ko.utils.arrayForEach(parsed.leftoverGroupMembers, function(item) {
                        viewModel.leftoverDevices.push(new GroupDevice(item.id, item.serialNumber, item.type));
                    });
                    translateButtons("btnAdd");
                }
            };

            new Ajax.Request(url,opt);
        });

        self.assignableDevices = ko.observableArray();
        <#list assignableDevices as groupMember>self.assignableDevices.push(new GroupDevice("${groupMember.getId()}", "${groupMember.getLabel()}", "${groupMember.getGroupMemberType().getId()}"));</#list>

        self.assignedDevices = ko.observableArray();
        <#list object.getGroupMembers() as groupMember>self.assignedDevices.push(new GroupDevice("${groupMember.getId()}", "${groupMember.getLabel()}", "${groupMember.getGroupMemberType().getId()}"));</#list>

        self.leftoverDevices = ko.observableArray();
        <#list leftoverDevices as groupMember>self.leftoverDevices.push(new GroupDevice("${groupMember.getId()}", "${groupMember.getLabel()}", "${groupMember.getGroupMemberType().getId()}"));</#list>

        self.devicesInConfigPending = ko.observableArray();

        self.addDevice = function(device)
        {
            self.assignableDevices.remove(device);
            self.assignedDevices.push(device);
            translateButtons("btnGroupRemove");
        };

        self.removeDevice = function(device)
        {
            self.assignedDevices.remove(device);
            self.assignableDevices.push(device);
            translateButtons("btnAdd");
        };

        self.configureVirtualDevice = function()
        {
            ShowWaitAnim();

            DeviceListPage.showConfiguration(false, 'DEVICE', selfGroup.device.id);
            HideWaitAnim();

            /*
            jQuery.get( "/config/ic_deviceparameters.cgi?sid="+SessionId+"&iface=VirtualDevices&address="+self.virtualDeviceSerialNumber()+"&redirect_url=GO_BACK",
                    function( data ) {
                    WebUI.previousPage        = WebUI.currentPage;
                    WebUI.previousPageOptions = WebUI.currentPageOptions;
                    WebUI.currentPage = DeviceListPage;
                    HideWaitAnim();
                    jQuery("#content").html(data);
            });
            */
        };

        self.operateVirtualDevice = function()
        {
            var virtualDevice = new GroupDevice(self.virtualDeviceSerialNumber(),self.virtualDeviceSerialNumber(), "VirtualDevice");
            var url = '/pages/tabs/control/devices.htm?sid='+SessionId;
            var pb = "{}";
            var opt =
            {
                postBody: pb,
                onComplete: function(t)
                {
                    WebUI.previousPage        = WebUI.currentPage;
                    WebUI.previousPageOptions = WebUI.currentPageOptions;
                    WebUI.currentPage = ControlDevicesPage;
                    var regularExpression = new RegExp("loadChannels\\W\\s[0-9]+\\s\\W");
                    var newContent = t.responseText.replace(regularExpression, "loadChannels("+virtualDevice.device.id+")");
                    jQuery("#content").html(newContent);
                }
            };
            new Ajax.Request(url,opt);
        };

        self.assignableDeviceHeaders = [];
        self.assignableDeviceHeaders.push(new Header(translateKey('groupDeviceName'), 'name'));
        self.assignableDeviceHeaders.push(new Header(translateKey('thTypeDescriptorWOLineBreak'), 'type'));
        self.assignableDeviceHeaders.push(new Header(translateKey('thPicture'), 'thPicture'));

        self.assignableDeviceHeaders.push(new Header(translateKey('groupSerialNumber'), 'serialNumber'));
        self.assignableDeviceHeaders.push(new Header(translateKey('groupAction'), 'deviceAction'));

        self.assignedDeviceHeaders = [];
        self.assignedDeviceHeaders.push(new Header(translateKey('groupDeviceName'), 'name'));
        self.assignedDeviceHeaders.push(new Header(translateKey('thTypeDescriptorWOLineBreak'), 'type'));
        self.assignedDeviceHeaders.push(new Header(translateKey('thPicture'), 'thPicture'));
        self.assignedDeviceHeaders.push(new Header(translateKey('groupSerialNumber'), 'serialNumber'));
        self.assignedDeviceHeaders.push(new Header(translateKey('groupAction'), 'deviceAction'));

        self.leftoverDeviceHeaders = [];
        self.leftoverDeviceHeaders.push(new Header(translateKey('groupDeviceName'), 'name'));
        self.leftoverDeviceHeaders.push(new Header(translateKey('thTypeDescriptorWOLineBreak'), 'type'));
        self.leftoverDeviceHeaders.push(new Header(translateKey('thPicture'), 'thPicture'));
        self.leftoverDeviceHeaders.push(new Header(translateKey('groupSerialNumber'), 'serialNumber'));

        self.activeAssignableDeviceListHeader = self.assignableDeviceHeaders[0];
        self.activeAssignedDeviceListHeader = self.assignedDeviceHeaders[0];
        self.activeLeftoverDeviceListHeader = self.leftoverDeviceHeaders[0];

        self.sortDeviceList = function(deviceList, lastHeader, header, event){

            if(lastHeader === header) {
                header.asc = !header.asc;
            } else {
                lastHeader.isActive(false);
                if(lastHeader === self.activeAssignableDeviceListHeader)
                {
                    self.activeAssignableDeviceListHeader = header;
                }
                else if(lastHeader === self.activeAssignedDeviceListHeader)
                {
                    self.activeAssignedDeviceListHeader = header;
                }
                else if(lastHeader === self.activeLeftoverDeviceListHeader)
                {
                    self.activeLeftoverDeviceListHeader = header;
                }
            }
            header.isActive(true);
            var prop = header.sortPropertyName;
            var ascSort = function(a,b){ return a[prop] < b[prop] ? -1 : a[prop] > b[prop] ? 1 : a[prop] == b[prop] ? 0 : 0; };
            var descSort = function(a,b){ return ascSort(b,a); };
            var sortFunc = header.asc ? ascSort : descSort;
            deviceList.sort(sortFunc);
        };
    }

    var viewModel = new GroupViewModel();

    // Activates knockout.js
    // This Page needs a new ViewModel
    ko.applyBindings(viewModel, document.getElementById('groupEditForm'));

    ReturnToListWithoutSave = function()
    {
        var tempPreviousPage = WebUI.previousPage;
        var tempPreviousPageOptions = WebUI.previousPageOptions;
        WebUI.previousPage        = WebUI.currentPage;
        WebUI.previousPageOptions = WebUI.currentPageOptions;
        WebUI.currentPage = tempPreviousPage;
        WebUI.currentPageOptions = tempPreviousPageOptions;
        WebUI.goBack();
    };

    ReturnToListAfterSave = function(devicesInPendingState)
    {
        var data = new Object();

        data.devicesToConfigure = [];

        ko.utils.arrayForEach(devicesInPendingState, function(item) {
            var device = new Object();
            device.id = item.id;
            device.serialNumber = item.serialNumber;
            device.type = translateKey(item.type);
            data.devicesToConfigure.push(device);
        });

        var url = '/pages/jpages/group/list?sid='+SessionId,
        pb = JSON.stringify(data);
        var opt =
        {
            postBody: pb,
            onComplete: function(t)
            {
                jQuery("#content").html(t.responseText);
            }
        };
        new Ajax.Request(url,opt);
    };

    adaptChannelNames = function(id, groupName) {
      var device = DeviceList.getDevice(id),
      channelOffset = 1;
      if (device) {
        if (device.typeName == "HmIP-HEATING") {
          channelOffset = 0;
        }
        jQuery.each(device.channels, function(index, channel) {
          homematic("Channel.setName", {id: channel.id, name: groupName+":"+parseInt(index + channelOffset)}, function(result) {
            if (parseInt(index + 1) == device.channels.length) {
              DeviceList.beginUpdateDevice(id, function() {
                conInfo("Device list actualized");
              });
            }
          });
        });
      }
    };

    refreshDeviceFromHomematic = function(serialNumberParam, groupName) {
        var changeVirtualDevice = viewModel.changeVirtualDeviceName;
        homematic("Device.getReGaIDByAddress",{address:serialNumberParam}, function(result) {
            if(changeVirtualDevice) {
              // Set Name of the device
              homematic("Device.setName", {id: result, name: groupName}, function() {
                  homematic("Device.listAllDetail", null, function(deviceList) {
                      jQuery.each(deviceList, function (index, data) {
                          if (data !== null)
                          {
                              var serialNumber = data["address"];
                              if(serialNumber == serialNumberParam)
                              {
                                DeviceList.beginUpdateDevice(data["id"], function() {
                                  //change the channelnames of the new created device
                                   adaptChannelNames(data["id"], groupName) ;
                                });
                              }
                          }
                      });
                      window.setTimeout(function() {
                        WebUI.enter(CreateGroupPage);
                        homematic("system.saveObjectModel", {}, function () {
                          conInfo("ObjectModel saved");
                        });
                      }, 2500);

                  });
              });
            }
        });
    };

    SaveGroup = function() {
      var showMessage = false,
      channelOffset = 1;

      if ( !viewModel.isNew() && (viewModel.origGroupName != "") && (viewModel.origGroupName != viewModel.groupDeviceName())) {
        showMessage = true;
      }

      if (viewModel.device && !viewModel.isNew()) {
        if (viewModel.device.typeName == "HmIP-HEATING") {
          channelOffset = 0;
        }
        jQuery.each(viewModel.device.channels, function(index,channel) {
          if (((viewModel.origGroupName != "")) && viewModel.origGroupName + ":" + parseInt(index + channelOffset) != channel.name) {
            showMessage = true;
          }
        });
      }
      if (showMessage) {
        new YesNoDialog(translateKey("dialogRenameVirtualGroupDeviceTitle"), translateKey("dialogVirtualGroupDeviceContent"), function(result) {
          viewModel.changeVirtualDeviceName = false;
          if (result == YesNoDialog.RESULT_YES)
          {
            viewModel.changeVirtualDeviceName = true;
          }
          _SaveGroup();

        });
      } else { _SaveGroup();}
    };

    _SaveGroup = function()
    {

        var self = this;
        viewModel.isSaving(true);
        var url = '/pages/jpages/group/save?sid='+SessionId;

        var data = new Object();

        data.groupId = viewModel.groupId;
        data.groupName = escape(viewModel.groupName());
        data.groupTypeId = viewModel.groupType().id;
        data.forbidSingleOperation = viewModel.isSingleOperationForbidden;
        data.assignedDevicesIds = [];
        data.isNewGroup = viewModel.isNew();
        data.groupDeviceName = jQuery("#group_name").val() + " " + viewModel.virtualDeviceSerialNumber();

        ko.utils.arrayForEach(viewModel.assignedDevices(), function(item) {
            data.assignedDevicesIds.push(item.id);
            homematic("Interface.setMetadata", {"objectId":item.device.id, "dataId": "inHeatingGroup", "value" : "true"});
        });

        ko.utils.arrayForEach(viewModel.assignableDevices(), function(item) {
            homematic("Interface.setMetadata", {"objectId":item.device.id, "dataId": "inHeatingGroup", "value" : "false"});
        });

        pb = JSON.stringify(data);

        var opt =
        {
            postBody: pb,
            onComplete: function(t)
            {
                var response = JSON.parse(t.responseText);
                if(response.isSuccessful)
                {
                    if(viewModel.executeDeviceRefresh && viewModel.regaId != "")
                    {
                        //iseDevices.setOperateGroupOnly(jQuery("#allowOnlyGroupOperation").prop("checked"));
                        iseDevices.setReadyConfig(viewModel.regaId);
                    }

                    ko.utils.arrayForEach(viewModel.assignedDevices(), function(item) {
                       if(item.device != undefined) {
                        //SetOperateGroupOnly(item, jQuery("#allowOnlyGroupOperation").prop("checked"));
                       }
                        if(item.getConfigPending())
                        {
                            viewModel.devicesInConfigPending.push(item);
                        }
                    });

                    /* This is not necessary when saving a group
                    ko.utils.arrayForEach(viewModel.assignableDevices(), function(item) {
                        if(item.device != undefined) {
                          //SetOperateGroupOnly(item, false)
                        }

                        if(item.getConfigPending())
                        {
                          //viewModel.devicesInConfigPending.push(item);
                        }
                    });
                    */

                    if(viewModel.isNew()) {
                        var virtualSerialNumber = createVirtualDeviceSerialNumber(response.content);
                        refreshDeviceFromHomematic(virtualSerialNumber, viewModel.groupName() + " " + virtualSerialNumber);
                    }

                    if ((! viewModel.isNew()) && (self.groupNameHasChanged)){
                        var virtualSerialNumber = viewModel.virtualDeviceSerialNumber();
                        var newGroupName = (viewModel.changeVirtualDeviceName) ? jQuery("#group_name").val() + " " + virtualSerialNumber : viewModel.groupDeviceName();
                        refreshDeviceFromHomematic(virtualSerialNumber, newGroupName);
                      }

                    viewModel.isSaving(false);
                    ReturnToListAfterSave(viewModel.devicesInConfigPending());
                }
                else
                {
                    viewModel.isSaving(false);
                    if(response.errorCode == sessionTimeoutErrorCode)
                    {
                        jQuery("#content").html(response.content);
                    }
                }
            }
        };

        new Ajax.Request(url,opt);
    };

    SetOperateGroupOnly = function(item, mode) {
      homematic("Device.setOperateGroupOnly", {id:item.device.id, mode: mode}, function(result) {
        if (DeviceList.devices[item.device.id]) {
          DeviceList.devices[item.device.id].isOperateGroupOnly = mode;
        }
      });
    };

  var s = "";
  s += "<table cellspacing='8'>";
  s += "<tr>";
  s += "<td align='center' valign='middle'><div class='FooterButton' onclick='ReturnToListWithoutSave();'>"+ translateKey('footerBtnCancel') +"</div></td>";
  s += "<td align='center' valign='middle'><div class='FooterButton' onclick='SaveGroup();'>"+ translateKey('footerBtnOk') +"</div></td>";
  s += "</tr>";
  s += "</table>";
  setFooter(s);
  translateButtons("btnGroupRemove");
  translateButtons("btnAdd");
  translateButtons("btnVirtualDeviceStateAndOperating");
  translateButtons("btnVirtualDeviceConfiguration");
  translatePage();
  jQuery( "#groupEditForm" ).submit(function( event ) {
    event.preventDefault();
  });
  jQuery("#groupEditForm").show();

</script>
 <div class="DialogLayer" style="z-index: 200; position: absolute; top: 0px; left: 0px; display: none" data-bind="visible: isSaving">
     <div class="UIFrame" style="width: 324px; height:86px; top: 260px; left: 480px;">
         <div class="UIFrameTitle" style="top: 2px; left: 2px; width: 320px; height: 20px; line-height: 20px;">
             ${"$"}{groupWillBeSavedHeader}
         </div>
         <div class="UIFrameContent" style="top: 24px; left: 2px; width: 320px; height: 60px;">
             <div class="UIText" style="top: 10px; left:10px; width:310px">
                 <img src="/ise/img/ajaxload_white.gif" style="float:left;margin-right:10px" />${"$"}{groupWillBeSavedContent}
             </div>
         </div>
     </div>
 </div>
</form>



<!--</body>
</html>-->