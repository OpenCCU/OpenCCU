
// This one should not be initialized for each lang, 
// as that is lateron used for indication of loaded Ressources
var EscapedLangDict = {};

function isNoProgramScript(cont) {
  if ((cont == "#prgrulecontent") || (jQuery("#scrinp").length > 0)) {
    return false;
  }
  return true;
}

function setTextContent(cont, callback) {
  var lang = getLang(),
    container = "#header, #menubar, #content, #footer",
    invisibleBeforeTranslationSelector = ".j_translate";
  container = (cont == undefined) ? container : cont;

  jQuery(container)
    .find("*")
    .addBack()
    .contents()
    .filter(function () {
      return this.nodeType === 3;
    })
    .filter(function () {
      if (this.nodeValue.match(/room[A-Z]/) || this.nodeValue.match(/func[A-Z]/)) {
        var result = this.nodeValue.match(/\${\w+}/g);
        if((result == null) && isNoProgramScript(container)) {
          // Remove leading and trailing space and add ${}
          this.nodeValue = "\${"+this.nodeValue.replace(/^\s+|\s+$/g, '')+"}";
        } else {
          // Remove leading and trailing space
          this.nodeValue = this.nodeValue.replace(/^\s+|\s+$/g, '');
        }
      }
      // Only match when contains 'simple string' anywhere in the text
      return this.nodeValue.indexOf('${') != -1;
    })
    .each(function (index, elem) {
      try {
        var jElem = jQuery(elem),
        jElemParent = jElem.parent(),
        value = jElemParent.html(),
        arrSearchStrings = value.match(/\${\w+}/g);

        jQuery.each(arrSearchStrings, function (index, val) {
          var transKey = val.substring(val.search(/\$\{/) + 2 , val.search(/\}/)).replace(/\<br\/\>|\<br\>/gi,""), // remove possible line breaks
          translatedVal = langJSON[lang][transKey];
          if (translatedVal != undefined) {
            value = value.replace(val, translatedVal);
          }
        });
        if (value != undefined) {
          jElemParent.html(unescape(value));
        }
      } catch(e) {}
    });

  if (callback) {
    callback();
  }

  jQuery(invisibleBeforeTranslationSelector).show();
}

function translatePage(container, callback) {
  setTextContent(container, callback);
}

/**
 * Translates a single key
 * @param {string} key The key to translate
 * @return {*} The translated key
 */
function translateKey(key, lang) {
  if(null == lang) lang = getLang();
  // This check is more performant then always processing all Keys.
  if(EscapedLangDict[lang] === undefined) {
    if (Object.keys(HMIdentifier[lang]).length === 0 ||
        Object.keys(langJSON[lang]).length === 0) {
      loadTextResource();
    } else {
      EscapedLangDict[lang] = {};
    }
    var text = langJSON[lang][key];
    if(text === undefined) text = key;
    return unescape(text);
  }
  
  // Check if we already have an escaped variant of the ressource
  if(EscapedLangDict[lang][key] !== undefined) {
    return EscapedLangDict[lang][key];
  }

  // Get ressource, escape and cach it
  var keyText = langJSON[lang][key];
  if(keyText === undefined) keyText = key;
  var result = unescape(keyText);
  EscapedLangDict[lang][key] = result;
  return result;
}

/**
 * Translates all buttons with the name key to the value of key
 * @param {string} key The key(s) (can be a comma separated list) to translate
 */
function translateButtons(key) {
  jQuery.each(key.replace(/ /g,"").split(","), function(index,val){
    jQuery('input[name='+val+']').val(translateKey(val));
  });
}

/**
 * Translates all elements within a container with a name attribute.
 * The value of the name attribute has to be the key for the translation table.
 * When a key is successful translated the innerHTML of the elem will be set to the translated text.
 * This is necessary because some html-pages are templates using TrimPath (e. g. devicelist_tree.jst).
 * It´s not possible to translate these pages with our usual translatePage() because TrimPath is unfortunately using the same
 * placeholder char ($) like setTextContent() which is being used by translatePage().
 * @param container {string} The container as jQuery selector, e. g. ".class" or "#id"
 */
function translateJSTemplate(container) {
  var origKey, translatedKey;
  var lang = getLang();
  jQuery.each(jQuery(container+" *[name]"), function(i, e) {
    origKey = e.getAttribute("name");
    translatedKey =  translateKey(origKey, lang);

    // Set the html of an element or the title of an image only if a valid translation is available.
    if (origKey != translatedKey) {
      //console.log("val: " + origKey +  " - translated: " + translatedKey);

      switch (this.tagName) {
        case "IMG":
          // An image gets the tooltip translated.
          e.setAttribute("title", translatedKey);
          break;
        default:
          // Replacing textContent with translation is faster
          // but elements with html tags <..> have to be stored
          // using innerHTML
          if(translatedKey.indexOf("<") >= 0) {
            e.innerHTML = translatedKey;
          } else {
            e.textContent = translatedKey;
          }
          break;
      }
    }
  });
}

/**
 * Translates an attribute of a given element.
 * This can e. g. be useful for translating tooltips
 * @param elemSelector {string} jQuery selector like ".class" of "#id"
 * @param attr {string} attribute to set, e. g. the title attribute
 * @param key {string} key of the string to translate
 */
function translateAttribute(elemSelector, attr, key) {
  jQuery(elemSelector).attr(attr, translateKey(key));
}

/**
 * Translates an ordinary string
 * @param stringToTranslate
 * @return {*}
 */
function translateString(stringToTranslate) {

  if (typeof stringToTranslate == "undefined") {
    conInfo("stringToTranslate = undefined");
    return;
  }

  var arrSearchStrings = stringToTranslate.match(/\${\S+}/g);
  if (arrSearchStrings == null) {
    return stringToTranslate;
  } else {
     jQuery.each(arrSearchStrings, function (index, val) {
      var transKey = val.substring(val.search(/\$\{/) + 2 , val.search(/\}/)),
        tmpString = stringToTranslate.replace(val, translateKey(transKey));
       stringToTranslate = tmpString;
    });
    return stringToTranslate;
  }
}

function translateFilter() {
  jQuery(".j_Filter_MODE_DEFAULT").html(translateKey("lblStandard"));
  jQuery(".j_Filter_MODE_AES").html(translateKey("lblSecured"));
  jQuery(".j_Filter_INTERFACE_BIDCOS_RF").html(translateKey("BidCosRF-Filter"));
  jQuery(".j_Filter_INTERFACE_BIDCOS_WIRED").html(translateKey("BidCosWired-Filter"));
  jQuery(".j_Filter_INTERFACE_HMIP_RF").html(translateKey("HmIPRF"));
  jQuery(".j_Filter_INTERFACE_VIRTUAL_DEVICES").html(translateKey("VirtualDevices"));
}

/**
 * Sets an image according to the selected language
 * The image will be searched within the path /ise/img/lang/*
 * @param elem {string} Selector of an image element, e. g. "#pic1"
 * @param nameOfPic {string} Name of the picture, e. g. "testPic.png"
 */
function translateAndSetImage(elem, nameOfPic) {
  jQuery(elem).attr("src", "/ise/img/lang/"+getLang()+"/"+nameOfPic);
}

function showHelp(topic, x, y) {
  var width = (! isNaN(x)) ? x : 450;
  var height = (! isNaN(y)) ? y : 260;
  if ((typeof showRamptimeOff != "undefined") && (showRamptimeOff == true)) {
    topic += "WithRampOff";
  }
  MessageBox.show(translateKey("HelpTitle"), translateKey(topic), "", width, height);
}

function translateAvailable() {
  alert("translateAvailable");
}
