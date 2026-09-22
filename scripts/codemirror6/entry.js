import {EditorState} from "@codemirror/state";
import {EditorView, keymap} from "@codemirror/view";
import {
  defaultKeymap,
  history,
  historyKeymap,
  indentLess,
  indentMore,
  indentWithTab
} from "@codemirror/commands";
import {bracketMatching, foldCode, foldGutter, foldKeymap, foldService, indentUnit, syntaxHighlighting, defaultHighlightStyle, HighlightStyle} from "@codemirror/language";
import {closeBrackets, closeBracketsKeymap, autocompletion, startCompletion, completeAnyWord} from "@codemirror/autocomplete";
import {search, searchKeymap, openSearchPanel} from "@codemirror/search";
import {lineNumbers, highlightActiveLineGutter} from "@codemirror/view";
import {StreamLanguage} from "@codemirror/language";
import {clike} from "@codemirror/legacy-modes/mode/clike";
import {tags} from "@lezer/highlight";

function wordSet(value) {
  const words = Array.isArray(value) ? value.join(" ") : value;
  const out = {};
  for (const word of words.split(/\s+/)) {
    if (word) {
      out[word] = true;
    }
  }
  return out;
}

const REGA_LANGUAGE = StreamLanguage.define(clike({
  name: "clike",
  keywords: wordSet("if while foreach return quit else elseif break continue Call Write WriteLine WriteURL WriteXML WriteHTML Debug Dump"),
  types: wordSet("var boolean integer real string time object idarray xml"),
  blockKeywords: wordSet("if while foreach else elseif"),
  defKeywords: wordSet("system dom root devices channels datapoints structure scheduler xmlrpc interfaces tcap web"),
  atoms: wordSet([
    "null true false currenttime localtime on off up down higher lower",
    "M_E M_LOG2E M_LOG10E M_LN2 M_LN10 M_PI M_PI_2 M_PI_4 M_1_PI M_2_PI",
    "M_2_SQRTPI M_SQRT2 M_SQRT1_2",
    "OT_NONE OT_OBJECT OT_ENUM OT_ROOT OT_DOM OT_DEVICE OT_DEVICES OT_MESSAGE OT_CHANNEL",
    "OT_CHANNELS OT_DP OT_DPS OT_TIMERDP OT_CALENDARDP OT_CALENDARDPS OT_MAPDP",
    "OT_VARDP OT_COMMDP OT_ALARMDP OT_IPDP OT_UPNPDP OT_KNXDP OT_OCEANDP OT_RFDP",
    "OT_IRDP OT_HSSDP OT_HISTORYDP OT_USER OT_USERS OT_SCHEDULER OT_USERPAGE",
    "OT_INTERFACE OT_INTERFACES OT_PROGRAM OT_SMTPSRV OT_POPCLIENT OT_RULE",
    "OT_RULES OT_CONDITION OT_SINGLECONDITION OT_DESTINATION OT_SINGLEDESTINATION",
    "OT_UIDATA OT_FAVORITE OT_XMLNODE OT_XMLNODES OT_ALL",
    "etUnknown etRooms etRoom etFunctions etFunction etFavorites etFavorite",
    "etStructure etLinks etScenes etCircuits etContacts etAlarms etAlarmMaps",
    "etUserPages etHistoryDPs etUPnP etEnocean etRF etIR etUsers etPrograms",
    "etPresenceSimulation etViewObjects etMessages etInterfaces etUIData",
    "etSystemVars etServices etRules etCalendarDPs etXmlNodes",
    "ID_DOM ID_ROOT ID_DEVICES ID_CHANNELS ID_DATAPOINTS ID_STRUCTURE ID_USERS",
    "ID_USERPAGES ID_INTERFACES ID_VALUE_EVENTING ID_EVENTING ID_GW_DEVICE",
    "ID_GW_CHANNEL ID_GW_DATAPOINT ID_PROGRAMS ID_HISTORYDPS ID_SMTPSERVER",
    "ID_POPCLIENT ID_PRESENCE_SIMULATION ID_GATEWAYCONFIG ID_RUNTIMECONFIG",
    "ID_WEBCONFIG ID_CHANNEL_STATE_VARIABLES ID_CHANNEL_COMMUNICATION",
    "ID_CHN_COM_DP_SMS ID_CHN_COM_DP_EMAIL ID_SYSTEM_VARIABLES ID_SERVICES",
    "ID_VIEW_OBJECTS ID_MESSAGES ID_UI_DATAS ID_RULES ID_CALENDARDPS",
    "ID_CONDITIONS ID_SCONDITIONS ID_DESTINATIONS ID_SDESTINATIONS",
    "ID_IP_DP_GW ID_GW_SYSALARM ID_GW_SYSSERVICE ID_INTERNALCHANNEL",
    "ID_ROOMS ID_FUNCTIONS ID_FAVORITES ID_LINKS ID_SCENES ID_CIRCUITS",
    "ID_CONTACTS ID_ALARM_MAPS ID_ALARMS ID_UPNP ID_UPNP_BEGIN ID_UPNP_DISCOVER",
    "ID_ENOCEAN ID_RF ID_SERVER_DP ID_PRESENT ID_ERROR",
    "pppNone pppServer pppClient",
    "ictUnknown ictBinaryTrigger ictBinarySensor ictBinaryActuator ictDimmingSensor",
    "ictDimmingActuator ictShutterSensor ictShutterActuator ictBitMask ictHeating",
    "ictTimeServer ictTimeClient ictMessage ictScalingSensor ictScalingActuator",
    "ictFloatSensor ictFloatActuator ictHSS ictDoorWindowContact ictSmokeDetector",
    "ictWaterDetector ictMotionDetector ictWeatherStation ictStateVariables",
    "ictCommunication ictBlindActuator ictHSSBinaryActuator ictHSSDimmingActuator",
    "ictInput ictMaintenance ictCentralMaintenance ictVirtualKey ictKey",
    "ictHSSListener ictHSSKeyMatic ictHSSWinMatic ictHSSBlind ictHSSDoorWindowContact",
    "ictHSSWindowRotarySensor",
    "ivtEmpty ivtNull ivtBinary ivtToggle ivtFloat ivtRelScaling ivtScaling",
    "ivtByte ivtWord ivtDWord ivtBitMask ivtDate ivtTime ivtDateTime ivtString",
    "ivtSceneNumber ivtInteger ivtObjectId ivtSystemId ivtCurrentValue ivtCurrentDateTime",
    "ivtCurrentDate ivtCurrentTime ivtSunrise ivtSunset ivtDelay ivtCalMonthly",
    "ivtCalYearly ivtCalOnce ivtCalDaily ivtCalWeekly ivtDeviceId ivtSpecialValue",
    "istGeneric istSwitch istBool istEnable istStep istUpDown istAlarm istOpenClose",
    "istStopStart istState istPresent istByteCounter istCharAscii istChar8859",
    "istWordCounter istDWordCounter istTemperature istVelocity istLux",
    "istDegree istValueS istValueU istSMS istEMail istStopStart istByteUCounter",
    "istIntUCounter istPercent istHumidity istAction istEnum",
    "OPERATION_NONE OPERATION_READ OPERATION_WRITE OPERATION_EVENT OPERATION_ALL",
    "ttOnce ttDaily ttWeekdays ttPeriodic ttCalWeekly ttCalMonthly ttCalYearly",
    "ttCalOnce ttCalDaily",
    "sotNone sotSunrise sotBeforeSunrise sotAfterSunrise sotSunset sotBeforeSunset",
    "sotAfterSunset",
    "mtNone mtLink mtScene mtCircuit",
    "ctNone ctSMTP ctSMTPvisaSOAP ctSMSviaSOAP ctMMSviaSOAP ctMSGviaSOAP",
    "atGeneric atEmergency atFire atBurglary atSystem atService",
    "asNone asOncoming asReceipted",
    "iulNone iulGuest iulUser iulMainuser iulAdmin iulOtherThanAdmin",
    "dwcAuto dwcPDA dwcHandy dwcPC",
    "iarNone iarRead iarWrite iarCreate iarChange iarExecute iarFullAccess",
    "OPERATOR_NONE OPERATOR_AND OPERATOR_OR OPERATOR_XOR",
    "iufNone iufVisible iufInternal iufReadyState iufOperated iufVirtualChn",
    "iufReadable iufWriteable iufEventable iufAll",
    "soAsc soDesc stAlpha stNatural"
  ]),
  multiLineStrings: true,
  indentStatements: false,
  indentSwitch: false,
  isOperatorChar: /[+\-*&%=<>!?|/#:@]/,
  modeProps: {closeBrackets: {pairs: "()[]{}\"\"", triples: "\""}},
  hooks: {
    "@": function(stream) {
      stream.eatWhile(/[0-9 :-]/);
      return "meta";
    },
    "\"": function(stream) {
      if (!stream.match("\"\"")) {
        return false;
      }
      let ch;
      while ((ch = stream.next()) != null) {
        if (ch === "\"" && stream.eat("\"")) {
          break;
        }
      }
      return "string";
    },
    "'": function(stream) {
      stream.eatWhile(/[\w\$_\xa1-\uffff]/);
      return "atom";
    },
    "=": function(stream) {
      if (stream.eat(">")) {
        return "operator";
      }
      return false;
    },
    token: function(_stream, state, style) {
      if ((style === "variable" || style === "type") && state.prevToken === ".") {
        return "variable-2";
      }
      return style;
    },
    "!": function(stream) {
      if (!stream.eat(" ")) {
        return false;
      }
      stream.skipToEnd();
      return "comment";
    }
  }
}));

const FULLSCREEN_CLASS = "cm6-fullscreen";
const REGA_HIGHLIGHT_STYLE = HighlightStyle.define([
  {tag: tags.keyword, color: "#708"},
  {tag: tags.atom, color: "#219"},
  {tag: tags.typeName, color: "#085"},
  {tag: tags.string, color: "#a11"},
  {tag: tags.comment, color: "#a50"}
]);

function foldReGaBraces(state, lineStart, lineEnd) {
  const doc = state.doc;
  const stack = [];
  let stringDelimiter = null;

  for (let pos = 0; pos < doc.length; ++pos) {
    const ch = doc.sliceString(pos, pos + 1);

    if (stringDelimiter) {
      if (stringDelimiter === "\"\"\"" && doc.sliceString(pos, pos + 3) === stringDelimiter) {
        stringDelimiter = null;
        pos += 2;
      } else if (stringDelimiter === "\"" && ch === "\\\\") {
        ++pos;
      } else if (stringDelimiter === "\"" && ch === stringDelimiter) {
        stringDelimiter = null;
      }
      continue;
    }

    if (ch === "!" && doc.sliceString(pos + 1, pos + 2) === " ") {
      const line = doc.lineAt(pos);
      pos = line.to;
      continue;
    }
    if (doc.sliceString(pos, pos + 3) === "\"\"\"") {
      stringDelimiter = "\"\"\"";
      pos += 2;
      continue;
    }
    if (ch === "\"") {
      stringDelimiter = ch;
      continue;
    }
    if (ch === "{") {
      stack.push(pos);
      continue;
    }
    if (ch !== "}" || stack.length === 0) {
      continue;
    }

    const open = stack.pop();
    if (open >= lineStart && open < lineEnd && doc.lineAt(open).number !== doc.lineAt(pos).number) {
      return {from: open + 1, to: pos};
    }
  }

  return null;
}

function keyName(name) {
  return name.replace(/-/g, "-");
}

function buildKeymap(extraKeys, getAdapter) {
  if (!extraKeys) {
    return [];
  }

  return Object.keys(extraKeys).map((key) => {
    const value = extraKeys[key];
    return {
      key: keyName(key),
      run(view) {
        if (typeof value === "string") {
          if (value === "autocomplete") {
            return startCompletion(view);
          }
          if (value === "findPersistent") {
            return openSearchPanel(view);
          }
          return false;
        }
        if (typeof value === "function") {
          value(getAdapter());
          return true;
        }
        return false;
      }
    };
  });
}

function docFromTextarea(textarea) {
  return textarea.value || textarea.textContent || "";
}

function asOffset(doc, pos) {
  return doc.line(pos.line + 1).from + pos.ch;
}

function asPos(doc, offset) {
  const line = doc.lineAt(offset);
  return {line: line.number - 1, ch: offset - line.from};
}

function fromTextArea(textarea, options = {}) {
  const host = document.createElement("div");
  host.className = "CodeMirror";
  textarea.style.display = "none";
  textarea.parentNode.insertBefore(host, textarea.nextSibling);

  const extensions = [
    history(),
    keymap.of([...defaultKeymap, ...historyKeymap, ...closeBracketsKeymap, ...searchKeymap, ...foldKeymap]),
    keymap.of([indentWithTab]),
    search({top: false}),
    bracketMatching(),
    closeBrackets(),
    autocompletion({override: [completeAnyWord]}),
    syntaxHighlighting(defaultHighlightStyle),
    syntaxHighlighting(REGA_HIGHLIGHT_STYLE),
    EditorView.lineWrapping,
    indentUnit.of(" ".repeat(options.indentUnit || 2)),
    EditorState.tabSize.of(options.tabSize || 2),
    EditorView.theme({
      "&.cm-editor": {height: "100%"},
      "&.cm-editor.cm-focused": {outline: "none"}
    })
  ];

  if (options.lineNumbers !== false) {
    extensions.push(lineNumbers(), highlightActiveLineGutter());
  }
  if (options.foldGutter) {
    extensions.push(foldGutter());
  }
  if (options.readOnly) {
    extensions.push(EditorState.readOnly.of(true), EditorView.editable.of(false));
  }
  if (options.mode === "text/x-rega") {
    extensions.push(REGA_LANGUAGE, foldService.of(foldReGaBraces));
  }

  let adapter = null;
  const extraKeymap = buildKeymap(options.extraKeys, () => adapter);
  if (extraKeymap.length > 0) {
    extensions.push(keymap.of(extraKeymap.map((entry) => ({
      key: entry.key,
      run(view) {
        return entry.run(view, adapter);
      }
    }))));
  }

  const state = EditorState.create({
    doc: docFromTextarea(textarea),
    extensions
  });
  const view = new EditorView({state, parent: host});

  adapter = {
    view,
    options: {
      indentWithTabs: !!options.indentWithTabs,
      tabSize: options.tabSize || 2
    },
    getValue() {
      return view.state.doc.toString();
    },
    setValue(value) {
      view.dispatch({
        changes: {from: 0, to: view.state.doc.length, insert: value}
      });
      textarea.value = value;
    },
    setSize(width, height) {
      if (width != null) {
        host.style.width = typeof width === "number" ? `${width}px` : `${width}`;
      }
      if (height != null) {
        host.style.height = typeof height === "number" ? `${height}px` : `${height}`;
      }
      view.requestMeasure();
    },
    getCursor() {
      return asPos(view.state.doc, view.state.selection.main.head);
    },
    somethingSelected() {
      return !view.state.selection.main.empty;
    },
    getSelection() {
      return view.state.sliceDoc(view.state.selection.main.from, view.state.selection.main.to);
    },
    getLine(lineNumber) {
      return view.state.doc.line(lineNumber + 1).text;
    },
    getRange(from, to) {
      return view.state.sliceDoc(asOffset(view.state.doc, from), asOffset(view.state.doc, to));
    },
    replaceRange(text, from, to) {
      view.dispatch({
        changes: {
          from: asOffset(view.state.doc, from),
          to: asOffset(view.state.doc, to),
          insert: text
        }
      });
      textarea.value = this.getValue();
    },
    execCommand(command) {
      if (command === "indentMore") {
        return indentMore(view);
      }
      if (command === "indentLess") {
        return indentLess(view);
      }
      if (command === "insertTab") {
        return indentWithTab(view);
      }
      if (command === "insertSoftTab") {
        const spaces = " ".repeat(this.options.tabSize);
        const pos = view.state.selection.main.head;
        view.dispatch({changes: {from: pos, to: pos, insert: spaces}});
        return true;
      }
      return false;
    },
    foldCode(pos) {
      const offset = asOffset(view.state.doc, pos);
      view.dispatch({
        selection: {anchor: offset}
      });
      return foldCode(view);
    },
    setOption(name, value) {
      if (name === "fullScreen") {
        host.classList.toggle(FULLSCREEN_CLASS, !!value);
      }
    },
    getOption(name) {
      if (name === "fullScreen") {
        return host.classList.contains(FULLSCREEN_CLASS);
      }
      return undefined;
    }
  };

  view.dispatch = ((originalDispatch) => (transaction) => {
    originalDispatch.call(view, transaction);
    textarea.value = view.state.doc.toString();
  })(view.dispatch);

  if (options.autofocus) {
    view.focus();
  }

  return adapter;
}

window.CCUCodeMirror6 = {
  fromTextArea
};
window.CodeMirror = window.CCUCodeMirror6;
