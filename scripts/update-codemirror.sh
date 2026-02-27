#!/bin/bash
set -e

# unzip featuring an enhanced version of tar's --strip-components=1
# Usage: unzip-strip ARCHIVE [DESTDIR] [EXTRA_cp_OPTIONS]
# Derive DESTDIR to current dir and archive filename or toplevel dir
unzip-strip() (
    set -eu
    local archive=$1
    local destdir=${2:-}
    shift; shift || :
    local tmpdir
    tmpdir=$(mktemp -d)
    trap 'rm -rf -- "$tmpdir"' EXIT
    unzip -qd "$tmpdir" -- "$archive"
    shopt -s dotglob
    local files=("$tmpdir"/*) name i=1
    if (( ${#files[@]} == 1 )) && [[ -d "${files[0]}" ]]; then
        name=$(basename "${files[0]}")
        files=("$tmpdir"/"$name"/LICENSE "$tmpdir"/"$name"/README.md "$tmpdir"/"$name"/addon "$tmpdir"/"$name"/lib "$tmpdir"/"$name"/mode "$tmpdir"/"$name"/theme)
    fi
    while [[ -f "$destdir" ]]; do destdir=${destdir}-$((i++)); done
    mkdir -p "$destdir"
    cp -ar "$@" -t "$destdir" -- "${files[@]}"
)

# get latest codemirror archive
wget -O /tmp/codemirror.zip "https://codemirror.net/codemirror.zip"

# remove old stuff
rm -rf buildroot-external/overlay/WebUI-openccu/www/webui/js/extern/codemirror/*

# unzip with top-level dir skipping
unzip-strip /tmp/codemirror.zip buildroot-external/overlay/WebUI-openccu/www/webui/js/extern/codemirror/

# run inline patch to embed x-rega language definition in clike.js
patch -p1 -d buildroot-external/overlay/WebUI-openccu/www/webui/js/extern/codemirror <<'EOF'
--- codemirror/mode/clike/clike.js.orig	2022-01-18 10:36:39.293844757 +0100
+++ codemirror/mode/clike/clike.js	2022-01-18 10:35:32.751543181 +0100
@@ -932,4 +933,127 @@
     }
   });
 
+  def("text/x-rega", {
+    name: "clike",
+    keywords: words(
+      /* statements */
+      "if while foreach return quit else elseif break continue " +
+
+      /* calls */
+      "Call Write WriteLine WriteURL WriteXML WriteHTML Debug Dump"
+    ),
+    types: words(
+      "var boolean integer real string time object idarray xml"
+    ),
+    multiLineStrings: true,
+    blockKeywords: words("if while foreach else elseif"),
+    defKeywords: words(
+      "system dom root devices channels datapoints structure scheduler xmlrpc interfaces tcap web"
+    ),
+    atoms: words(
+      "null true false currenttime localtime on off up down higher lower " +
+      "M_E M_LOG2E M_LOG10E M_LN2 M_LN10 M_PI M_PI_2 M_PI_4 M_1_PI M_2_PI " +
+      "M_2_SQRTPI M_SQRT2 M_SQRT1_2 " +
+      "OT_NONE OT_OBJECT OT_ENUM OT_ROOT OT_DOM OT_DEVICE OT_DEVICES OT_MESSAGE OT_CHANNEL " +
+      "OT_CHANNELS OT_DP OT_DPS OT_TIMERDP OT_CALENDARDP OT_CALENDARDPS OT_MAPDP " +
+      "OT_VARDP OT_COMMDP OT_ALARMDP OT_IPDP OT_UPNPDP OT_KNXDP OT_OCEANDP OT_RFDP " +
+      "OT_IRDP OT_HSSDP OT_HISTORYDP OT_USER OT_USERS OT_SCHEDULER OT_USERPAGE " +
+      "OT_INTERFACE OT_INTERFACES OT_PROGRAM OT_SMTPSRV OT_POPCLIENT OT_RULE " +
+      "OT_RULES OT_CONDITION OT_SINGLECONDITION OT_DESTINATION OT_SINGLEDESTINATION " +
+      "OT_UIDATA OT_FAVORITE OT_XMLNODE OT_XMLNODES OT_ALL " +
+      "etUnknown etRooms etRoom etFunctions etFunction etFavorites etFavorite " +
+      "etStructure etLinks etScenes etCircuits etContacts etAlarms etAlarmMaps " +
+      "etUserPages etHistoryDPs etUPnP etEnocean etRF etIR etUsers etPrograms " +
+      "etPresenceSimulation etViewObjects etMessages etInterfaces etUIData " +
+      "etSystemVars etServices etRules etCalendarDPs etXmlNodes " +
+      "ID_DOM ID_ROOT ID_DEVICES ID_CHANNELS ID_DATAPOINTS ID_STRUCTURE ID_USERS " +
+      "ID_USERPAGES ID_INTERFACES ID_VALUE_EVENTING ID_EVENTING ID_GW_DEVICE " +
+      "ID_GW_CHANNEL ID_GW_DATAPOINT ID_PROGRAMS ID_HISTORYDPS ID_SMTPSERVER " +
+      "ID_POPCLIENT ID_PRESENCE_SIMULATION ID_GATEWAYCONFIG ID_RUNTIMECONFIG " +
+      "ID_WEBCONFIG ID_CHANNEL_STATE_VARIABLES ID_CHANNEL_COMMUNICATION " +
+      "ID_CHN_COM_DP_SMS ID_CHN_COM_DP_EMAIL ID_SYSTEM_VARIABLES ID_SERVICES " +
+      "ID_VIEW_OBJECTS ID_MESSAGES ID_UI_DATAS ID_RULES ID_CALENDARDPS " +
+      "ID_CONDITIONS ID_SCONDITIONS ID_DESTINATIONS ID_SDESTINATIONS " +
+      "ID_IP_DP_GW ID_GW_SYSALARM ID_GW_SYSSERVICE ID_INTERNALCHANNEL " +
+      "ID_ROOMS ID_FUNCTIONS ID_FAVORITES ID_LINKS ID_SCENES ID_CIRCUITS " +
+      "ID_CONTACTS ID_ALARM_MAPS ID_ALARMS ID_UPNP ID_UPNP_BEGIN ID_UPNP_DISCOVER " +
+      "ID_ENOCEAN ID_RF ID_SERVER_DP ID_PRESENT ID_ERROR " +
+      "pppNone pppServer pppClient " +
+      "ictUnknown ictBinaryTrigger ictBinarySensor ictBinaryActuator ictDimmingSensor " +
+      "ictDimmingActuator ictShutterSensor ictShutterActuator ictBitMask ictHeating " +
+      "ictTimeServer ictTimeClient ictMessage ictScalingSensor ictScalingActuator " +
+      "ictFloatSensor ictFloatActuator ictHSS ictDoorWindowContact ictSmokeDetector " +
+      "ictWaterDetector ictMotionDetector ictWeatherStation ictStateVariables " +
+      "ictCommunication ictBlindActuator ictHSSBinaryActuator ictHSSDimmingActuator " +
+      "ictInput ictMaintenance ictCentralMaintenance ictVirtualKey ictKey " +
+      "ictHSSListener ictHSSKeyMatic ictHSSWinMatic ictHSSBlind ictHSSDoorWindowContact " +
+      "ictHSSWindowRotarySensor " +
+      "ivtEmpty ivtNull ivtBinary ivtToggle ivtFloat ivtRelScaling ivtScaling " +
+      "ivtByte ivtWord ivtDWord ivtBitMask ivtDate ivtTime ivtDateTime ivtString " +
+      "ivtSceneNumber ivtInteger ivtObjectId ivtSystemId ivtCurrentValue ivtCurrentDateTime " +
+      "ivtCurrentDate ivtCurrentTime ivtSunrise ivtSunset ivtDelay ivtCalMonthly " +
+      "ivtCalYearly ivtCalOnce ivtCalDaily ivtCalWeekly ivtDeviceId ivtSpecialValue " +
+      "istGeneric istSwitch istBool istEnable istStep istUpDown istAlarm istOpenClose " +
+      "istStopStart istState istPresent istByteCounter istCharAscii istChar8859 " +
+      "istWordCounter istDWordCounter istTemperature istVelocity istLux " +
+      "istDegree istValueS istValueU istSMS istEMail istStopStart istByteUCounter " +
+      "istIntUCounter istPercent istHumidity istAction istEnum " +
+      "OPERATION_NONE OPERATION_READ OPERATION_WRITE OPERATION_EVENT OPERATION_ALL " +
+      "ttOnce ttDaily ttWeekdays ttPeriodic ttCalWeekly ttCalMonthly ttCalYearly " +
+      "ttCalOnce ttCalDaily " +
+      "sotNone sotSunrise sotBeforeSunrise sotAfterSunrise sotSunset sotBeforeSunset " +
+      "sotAfterSunset " +
+      "mtNone mtLink mtScene mtCircuit " +
+      "ctNone ctSMTP ctSMTPvisaSOAP ctSMSviaSOAP ctMMSviaSOAP ctMSGviaSOAP " +
+      "atGeneric atEmergency atFire atBurglary atSystem atService " +
+      "asNone asOncoming asReceipted " +
+      "iulNone iulGuest iulUser iulMainuser iulAdmin iulOtherThanAdmin " +
+      "dwcAuto dwcPDA dwcHandy dwcPC " +
+      "iarNone iarRead iarWrite iarCreate iarChange iarExecute iarFullAccess " +
+      "OPERATOR_NONE OPERATOR_AND OPERATOR_OR OPERATOR_XOR " +
+      "iufNone iufVisible iufInternal iufReadyState iufOperated iufVirtualChn " +
+      "iufReadable iufWriteable iufEventable iufAll" +
+      "soAsc soDesc stAlpha stNatural"
+    ),
+    indentStatements: false,
+    indentSwitch: false,
+    isOperatorChar: /[+\-*&%=<>!?|\/#:@]/,
+    hooks: {
+      "@": function(stream) {
+        stream.eatWhile(/[0-9 :-]/);
+        return "meta";
+      },
+      '"': function(stream, state) {
+        if (!stream.match('""')) return false;
+        state.tokenize = tokenTripleString;
+        return state.tokenize(stream, state);
+      },
+      "'": function(stream) {
+        stream.eatWhile(/[\w\$_\xa1-\uffff]/);
+        return "atom";
+      },
+      "=": function(stream, state) {
+        var cx = state.context
+        if (cx.type == "}" && cx.align && stream.eat(">")) {
+          state.context = new Context(cx.indented, cx.column, cx.type, cx.info, null, cx.prev)
+          return "operator"
+        } else {
+          return false
+        }
+      },
+      token: function(_stream, state, style) {
+        if ((style == "variable" || style == "type") &&
+            state.prevToken == ".") {
+          return "variable-2";
+        }
+      },
+      "!": function(stream, state) {
+        if (!stream.eat(" ")) return false
+        stream.skipToEnd();
+        return "comment"
+      }
+    },
+    modeProps: {closeBrackets: {pairs: '()[]{}""', triples: '"'}}
+  });
+
 });
EOF
