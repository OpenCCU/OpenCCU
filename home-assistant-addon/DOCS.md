# Home Assistant App: OpenCCU

This app provides all features of a standard, e.g. Raspberry Pi or
even virtual (e.g. OVA) based OpenCCU system to be used as a HomeMatic or
homematicIP IoT central which is fully compatible to a CCU3 device.

## Installation

Follow these steps to install the app within your Home Assistant system:

1. Navigate in your Home Assistant frontend to **Settings** -> **Apps** -> **Install app**.
2. Click on the vertical "⋮" dots on the top-right corner and select **Repositories**.
3. Enter the URL <https://github.com/OpenCCU/OpenCCU> as a new app repository and click **Add** and **Close**.
4. Find the "OpenCCU" app in the "OpenCCU Apps" section of the app list and select it.
5. Click on the `INSTALL` button.
6. Add the app to the sidebar by clicking on `Show in sidebar`.
7. Start the app by clicking on `START`.
8. Click on the `OpenCCU` sidebar link to switch into the OpenCCU WebUI.

More detailed documentation on the installation and how to communicate with your HomeMatic/homematicIP devices
can be found in the official [OpenCCU documentation](https://github.com/OpenCCU/OpenCCU/wiki/en.Installation-HomeAssistant).

## How to use

After installation you can configure the app to add a "OpenCCU" link
to the sidebar of your Home Assistant user interface. After having done so, this link can
be used to access the standard OpenCCU WebUI to configure/setup your
HomeMatic/homematicIP devices in the usual CCU like way.

## HomeMatic/homematicIP device integration

After the OpenCCU app has been correctly installed and your OpenCCU WebUI shows existing HomeMatic/homematicIP devices, you still have to install and setup the "Homematic(IP) Local for OpenCCU" integration. Only this step will bring up/integrate your HomeMatic/homematicIP devices - which the OpenCCU app shows - in the Home Assistant user interface, thus making them usable within the context of Home Assistant.

For this to happen, please follow the official OpenCCU documentation on the [Home Assistant integration](https://github.com/OpenCCU/OpenCCU/wiki/en.HomeAssistant-Integration).
