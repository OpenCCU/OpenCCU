jQuery.extend(true,langJSON, {
  "en" : {
    "dummy" : "",
    "dialogSettingsGeneralSettingsTitle" : "General settings",
    "btnSysConfGeneralSettings" : "General settings",
    "dialogSettingsSDCardSettings" : "microSD card",
    "dialogSettingsSDCardStatus" : "Status",
    "dialogSettingsStorageSettingsBtnInitaliseSDCard" : "Initialize",
    "dialogSettingsStorageSettingsBtnBackup" : "Save data",
    "dialogSettingsStorageHintSDCardP1" : "Initialize microSD card. Attention! The microSD card will be formatted during initialization.",
    "dialogSettingsStorageHintSDCardP2" : "Only data of directories that are used by included system components (e.g. diagrams) will be saved.",
    "dialogSettingsStorageStateInitialised" : "microSD card has been initialized.",
    "dialogSettingsStorageStateNotInitialised" : "microSD card is available but has not yet been initialized.",
    "dialogSettingsStorageStateNotPresent" : "microSD card is not available or could not be recognized.",
    "dialogSettingsInitialisingMessageTitle" : "microSD card is currently being initialized.",
    "lblSysConfStorage" : "Memory management",

    "dialogSettingsExternalStorageStateInitialised" : "external USB memory available.",
    "dialogSettingsExternalStorageStateNotPresent" : "No external USB memory found."
  }
});

window.setTimeout(function () {
  if (typeof WEBUI_VERSION != "undefined") {
    if (WEBUI_VERSION.split(".")[0] >= 3) {
      langJSON.en.dialogSettingsStorageStateInitialised = langJSON.en.dialogSettingsExternalStorageStateInitialised;
      langJSON.en.dialogSettingsStorageStateNotPresent = langJSON.en.dialogSettingsExternalStorageStateNotPresent;
      langJSON.en.dialogSettingsStorageStateNotInitialised = langJSON.en.dialogSettingsExternalStorageStateNotPresent;
    }
  }
}, 1500);


