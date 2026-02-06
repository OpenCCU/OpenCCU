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

  // Ensure we only trigger language resource loading once.
  if (window.__langTextResourcesDeferred) {
    return window.__langTextResourcesDeferred.promise();
  }

  window.__langTextResourcesDeferred = jQuery.Deferred();

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

  /*
   * Avoid synchronous XHR on the main thread.
   *
   * If we are still in the document parsing phase, we can preserve the original
   * deterministic execution order by writing <script> tags into the parser stream.
   * However, document.write() must NEVER be used after the document has finished
   * loading, as it can implicitly call document.open() and wipe the DOM.
   */
  if ((document.readyState === "loading") && (typeof document.write === "function")) {
    jQuery.each(arResource, function(index, res) {
      document.write('<script type="text/javascript" charset="ISO-8859-1" src="' +
                     url + res + '"><\/script>');
    });

    window.__langTextResourcesDeferred.resolve();
    return window.__langTextResourcesDeferred.promise();
  }

  // Fallback: load sequentially via dynamic script injection (asynchronous).
  var head = document.head || document.getElementsByTagName("head")[0] || document.documentElement;
  var idx = 0;

  var loadNext = function() {
    if (idx >= arResource.length) {
      window.__langTextResourcesDeferred.resolve();
      return;
    }

    var s = document.createElement("script");
    s.type = "text/javascript";
    s.charset = "ISO-8859-1";
    s.src = url + arResource[idx++];

    s.onload = function() { loadNext(); };
    s.onerror = function() { loadNext(); };

    head.appendChild(s);
  };

  loadNext();
  return window.__langTextResourcesDeferred.promise();
};

loadTextResource();
