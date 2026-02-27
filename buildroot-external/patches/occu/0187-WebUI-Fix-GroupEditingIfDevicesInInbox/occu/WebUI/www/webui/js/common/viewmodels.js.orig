virtualDevicePrefix = "INT";

//Class to represent a device
function GroupDevice(id, serialNumber, type)
{
  conInfo(id + " " + serialNumber + " " + type);
  var self = this;
  self.id = id;
  self.arSerialNumber = serialNumber.split(":");
  self.realSerialNumber = self.arSerialNumber[0];
  self.Channel = self.arSerialNumber[1];
  conInfo(self.realSerialNumber);
  self.serialNumber = serialNumber;
  self.device = DeviceList.getDeviceByAddress(self.realSerialNumber);
  conInfo(self.device);
  self.type = type;
  self.devType = translateKey(type);
  self.name = "";
  self.extDescr = "";
  if(typeof self.device == "undefined")
  {
    self.name = type +" "+ self.serialNumber;    
  }
  else
  {
    var chn = DeviceList.getChannelByAddress(serialNumber);
    if (typeof chn != "undefined") {
      self.name = chn.getName();
      self.extDescr = (typeof chn.nameExtention != "undefined") ? chn.nameExtention : "";
    } else {
      self.name = self.device.getName();
    }
  }
  
  self.getConfigPending = function()
  {
  var interfaceId = "BidCos-RF";
  if(!self.type.startsWith("HM-"))
  {
    interfaceId = "HmIP-RF";
  }
  
  var deviceParamSet = homematic('Interface.getParamset', {"interface": interfaceId, "address" : self.realSerialNumber+":0", "paramsetKey" : "VALUES"});
    // conInfo(deviceParamSet);
    // handle null/undefined like no config pending
  if(deviceParamSet != typeof 'undefined' && deviceParamSet != null && (deviceParamSet.CONFIG_PENDING === '1' || deviceParamSet.CONFIG_PENDING === true))
    {
      return true;
    }
    else
    {
      return false;
    }
  };
  
  self.imagePath = ko.computed(function() {
    if(this.type == "unknown")
    {
      return "/config/img/devices/50/unknown_device_thumb.png";
    }
    else
    {
      //return DEV_getImagePath(this.type, 50);
      if (typeof self.device != "undefined") {
        return DEV_getImagePath(self.device.deviceType.id, 50);
      }
    }
        
    }, this);
  
  self.showDevicePicture = function(groupdevice, mouseoverevent)
  {
    //picDivShow(jg_250, self.type, 250, -1, mouseoverevent.currentTarget);
    if (typeof self.device != "undefined") {
      picDivShow(jg_250, self.device.deviceType.id, 250, self.Channel, mouseoverevent.currentTarget);
    }
  };
  
  self.hideDevicePicture = function()
  {
    picDivHide(jg_250);
  };
}

function Header(title, propertyName)
{
  var self = this;
  self.title = title;
  self.sortPropertyName = propertyName;
  self.colspan = 1;
  self.asc = true;
  self.isActive = ko.observable(false);
  self.headerClass = ko.computed(function(){
    return self.isActive() ? "DeviceListHead_Active" : "DeviceListHead";
  });
}

function padLeft(nr, n, str){
  return Array(n-String(nr).length+1).join(str||'0')+nr;
}

function createVirtualDeviceSerialNumber (id) {
    return virtualDevicePrefix+padLeft(id,7);
}

function retryGetDeviceAndDeviceName(group, tries) {
  function getGroupDeviceFromRega () {
    group.device = DeviceList.getDeviceByAddress(group.virtualDeviceSerialNumber);
    if(typeof group.device === "undefined")
    {
      if(tries > 0) {
        retryGetDeviceAndDeviceName(group, tries - 1);
      } else {
        group.virtualDeviceName("");
        group.groupDeviceName("");
      }
    }
    else
    {
      group.virtualDeviceName(group.device.getName());
      group.groupDeviceName(group.device.getName());
    }
  }  
  
  window.setTimeout(getGroupDeviceFromRega, 1000);
}

function VirtualGroup(id, name, groupTypeLabel, virtualDeviceType)
{
  var selfGroup = this;
  selfGroup.id = id;
  selfGroup.name = name;
  var temp = createVirtualDeviceSerialNumber(selfGroup.id);
  selfGroup.virtualDeviceSerialNumber = temp;
  selfGroup.device = DeviceList.getDeviceByAddress(temp);
  selfGroup.groupTypeLabel = groupTypeLabel;
  selfGroup.virtualDeviceName = ko.observable(""); // Todo check if this is still in use somewhere
  selfGroup.groupDeviceName = ko.observable("");
  if(typeof selfGroup.device === "undefined")
  {
    retryGetDeviceAndDeviceName(selfGroup, 3);
  }
  else
  {
    selfGroup.virtualDeviceName(selfGroup.device.getName());
    selfGroup.groupDeviceName(selfGroup.device.getName());
  }

  selfGroup.configureVirtualDevice = function()
  {
  ShowWaitAnim();
    DeviceListPage.showConfiguration(false, 'DEVICE', selfGroup.device.id);
    HideWaitAnim();
    /*
    jQuery.get( "/config/ic_deviceparameters.cgi?sid="+SessionId+"&iface=VirtualDevices&address="+selfGroup.virtualDeviceSerialNumber+"&redirect_url=GO_BACK",
    function( data ) {
      WebUI.previousPage        = WebUI.currentPage;
      WebUI.previousPageOptions = WebUI.currentPageOptions;
      WebUI.currentPage = DeviceListPage;
      HideWaitAnim();
      jQuery("#content").html(data);
    });
    */
  };

  selfGroup.operateVirtualDevice = function()
  {
    var virtualDevice = new GroupDevice(selfGroup.virtualDeviceSerialNumber,selfGroup.virtualDeviceSerialNumber);
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

        /*regularExpression = new RegExp("WebUI.goBack\\(\\)");
        newContent = newContent.replace(regularExpression, "WebUI.enter"+"(CreateGroupPage)");*/


        jQuery("#content").html(newContent);
      }
    };
    new Ajax.Request(url,opt);
  };
}