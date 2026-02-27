jQuery.extend(true,langJSON, {
  "de" : {
    "dummy" : "",
    "dialogSettingsGeneralSettingsTitle" : "Allgemeine Einstellungen",
    "btnSysConfGeneralSettings" : "Allgemeine<br/>Einstellungen",
    "dialogSettingsSDCardSettings" : "microSD-Karte",
    "dialogSettingsSDCardStatus" : "Status",
    "dialogSettingsStorageSettingsBtnInitaliseSDCard" : "Initialisieren",
    "dialogSettingsStorageSettingsBtnBackup" : "Daten sichern",
    "dialogSettingsStorageHintSDCardP1" : "MicroSD-Karte initialisieren. Achtung! Bei der Initialisierung wird die microSD-Karte formatiert.",
    "dialogSettingsStorageHintSDCardP2" : "Die Sicherung der Daten umfasst nur die Verzeichnisse, die von mitgelieferten Systemkomponenten wie den Diagrammen verwendet werden.",
    "dialogSettingsStorageStateInitialised" : "microSD Karte ist initialisiert.",
    "dialogSettingsStorageStateNotInitialised" : "microSD Karte ist vorhanden aber nicht initalisiert.",
    "dialogSettingsStorageStateNotPresent" : "microSD Karte ist nicht vorhanden bzw. wurde nicht erkannt.",
    "dialogSettingsInitialisingMessageTitle" : "Die microSD Karte wird zurzeit initialisiert",
    "lblSysConfStorage" : "Speicherverwaltung",

    "dialogSettingsExternalStorageStateInitialised" : "externer Speicher vorhanden.",
    "dialogSettingsExternalStorageStateNotPresent" : "Es wurde kein externer Speicher gefunden."
  }
});

  window.setTimeout(function () {
    if (typeof WEBUI_VERSION != "undefined") {
      if (WEBUI_VERSION.split(".")[0] >= 3) {
        langJSON.de.dialogSettingsStorageStateInitialised = langJSON.de.dialogSettingsExternalStorageStateInitialised;
        langJSON.de.dialogSettingsStorageStateNotPresent = langJSON.de.dialogSettingsExternalStorageStateNotPresent;
        langJSON.de.dialogSettingsStorageStateNotInitialised = langJSON.de.dialogSettingsExternalStorageStateNotPresent;
      }
    }
  }, 1500);



