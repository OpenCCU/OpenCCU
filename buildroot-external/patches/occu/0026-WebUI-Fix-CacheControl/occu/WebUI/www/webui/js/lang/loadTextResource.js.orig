langJSON = {};
HMIdentifier = {};

jQuery.each(getAvailableLang(), function(index, language) {
  if (getLang() != language) {
    langJSON[language] = {};
    HMIdentifier[language] = {};
  }
});

/**
 * This function returns the default language
 * @return {String} Default language
 */
function getDefaultLang() {
  return "en";
}

/**
 * This function returns the available languages
 * @return {Array} Available languages
 */
function getAvailableLang() {
  return ["de", "en"];
}

/**
 * This function checks if a given language is supported.
 * Useful with e. g. URL-Parameter
 * @param lang {String} Language like "de" or "en"
 * @return {Boolean} True / False
 */
function isLanguageSupported(lang) {
  var langSupported = false;
  if (lang == undefined) return false;
  jQuery.each(getAvailableLang(), function(index, val) {
    if (lang == val) {
      langSupported = true;
      return false; // leave the each-loop
    }
  });
  return langSupported;
};

/**
 * This function determines the language used by the browser
 * The original browser string will be stripped to e. g. "de" or "en"
 * If the browser language is not supported the default language will be returned
 * @return {String} Either the browser language or the default language
 */
function getBrowserLang() {
  var lang = navigator.language || navigator.userLanguage;
  lang = lang.split("-")[0];
  if (jQuery.inArray(lang, getAvailableLang()) != -1) {
    return lang;
  } else {
    return getDefaultLang();
  }
};

/**
 * This function returns the chosen language from the user account.
 * For temporary testing it´s possible to set a language by url parameter, e. g. "lang=de"
 * If the given language is not supported the parameter has no effect.
 *
 * @return {String} The detected language - e. g. "en"
 */
function getLang() {

    var lang,
      defaultLang = getDefaultLang(),
      urlLang = jQuery.url().param('lang'),
      arrLang = getAvailableLang();

    // Add 'auto' as first element to the array
    arrLang.unshift("auto");

    // If a url-parameter is given ....
    if (urlLang != undefined) {
      lang = (isLanguageSupported(urlLang)) ? urlLang : undefined;
    }

    if (lang != undefined) {
      return lang;
    }

    // When only one language is supported uncomment the next line and return the relevant language shorthand symbol.
    // return "de";

    var langID = jQuery("#header").attr("lang");

    if (langID == undefined) {
      //Use the browser settings!
      return getBrowserLang();
    } else {
      if (langID == "0") {
      // The user has chosen "Auto" which will use the browser settings
      return getBrowserLang();
      } else {
        return (parseInt(langID) < arrLang.length) ? arrLang[parseInt(langID)] : getBrowserLang();
      }
    }
    return defaultLang;
}

function loadTextResource() {

  var arResource = [
    "translate.lang.js",
    "translate.lang.extension.js",
    "translate.lang.deviceDescription.js",
    "translate.lang.group.js",
    "translate.lang.system.js",
    "translate.lang.channelDescription.js",
    "translate.lang.help.js",
    "translate.lang.option.js",
    "translate.lang.label.js",
    "translate.lang.stringtable.js",
    "translate.lang.diagram.js",
    "translate.lang.notTranslated.js"
  ];
  var url = "/webui/js/lang/" + getLang() + "/";

  jQuery.each(arResource, function(index, res){
    var request = jQuery.ajax({
      url: url + res,
      type:  "GET",
      async: false,
      contentType: "application/x-www-form-urlencoded;charset=ISO-8859-1",
      dataType: "script",
      cache: false
    });

    request.done(function(result) {
    });

    request.fail(function( jqXHR, textStatus ) {
    });

  });
};

loadTextResource();