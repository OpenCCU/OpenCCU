#!/bin/tclsh

set DPControls_GETSTATUS(TEMP.SETPOINT) [list TempControl_getStatus]

set DPControls_GETCONTROLS(TEMP.SETPOINT) [list TempControl_getControls]

set COMMANDS(temp_up_5)   [list TempControl_up_5]
set COMMANDS(temp_up_2)   [list TempControl_up_2]
set COMMANDS(temp_up_1)   [list TempControl_up_1]
set COMMANDS(temp_down_1) [list TempControl_down_1]
set COMMANDS(temp_down_2) [list TempControl_down_2]
set COMMANDS(temp_down_5) [list TempControl_down_5]

proc TempControl_getStatus {channelId dataPoint} {
	global cmd
	array set dp $dataPoint
	
	set    script "var dpId = \"$dp(ID)\";"
	append script {
		var dp = dom.GetObject(dpId);
		var level = dp.Value();
		Write(level.ToString(1));
	}
	set status [rega_exec $script]
	
	switch -exact -- $cmd {
		temp_up_5   { set correctionValue "(+5&nbsp;&deg;C)" }
		temp_up_2   { set correctionValue "(+2&nbsp;&deg;C)" }
		temp_up_1   { set correctionValue "(+1&nbsp;&deg;C)" }
		temp_down_1 { set correctionValue "(-1&nbsp;&deg;C)" }
		temp_down_2 { set correctionValue "(-2&nbsp;&deg;C)" }
		temp_down_5 { set correctionValue "(-5&nbsp;&deg;C)" }
		default     { set correctionValue "" }
	}
	
	set    result [status_separator]
	append result {<tr><td class="status">}
	append result {<div class="caption">Soll-Temperatur</div>}
	append result "<div class=\"center\">$status&nbsp;&deg;C $correctionValue</div>"
	append result {</td></tr>}
	
	if { "" != $correctionValue } {
	append result {<tr><td class="status">}
	append result {<div class="center">(&Auml;nderungen werden innerhalb von 3 Minuten wirksam)</div>}
	append result {</td></tr>}
	}

	return $result

}

proc TempControl_getControls {channelId dataPoint} {
	global sid favListId favId UI_URLBASE
	set result ""
	
	append result [button "+5&nbsp;&deg;" "$UI_URLBASE/fav.cgi?sid=$sid&uiStyle=[getUIStyle]&favListId=$favListId&favId=$favId&cmd=temp_up_5"]
	append result [button "+2&nbsp;&deg;" "$UI_URLBASE/fav.cgi?sid=$sid&uiStyle=[getUIStyle]&favListId=$favListId&favId=$favId&cmd=temp_up_2"]
	append result [button "+1&nbsp;&deg;" "$UI_URLBASE/fav.cgi?sid=$sid&uiStyle=[getUIStyle]&favListId=$favListId&favId=$favId&cmd=temp_up_1"]
	append result [button "-1&nbsp;&deg;" "$UI_URLBASE/fav.cgi?sid=$sid&uiStyle=[getUIStyle]&favListId=$favListId&favId=$favId&cmd=temp_down_1"]
	append result [button "-2&nbsp;&deg;" "$UI_URLBASE/fav.cgi?sid=$sid&uiStyle=[getUIStyle]&favListId=$favListId&favId=$favId&cmd=temp_down_2"]
	append result [button "-5&nbsp;&deg;" "$UI_URLBASE/fav.cgi?sid=$sid&uiStyle=[getUIStyle]&favListId=$favListId&favId=$favId&cmd=temp_down_5"]

	return $result
}

proc TempControl_change {channelId setPointOffset} {
	set    script "var channelId = \"$channelId\";"
	append script "var offset = $setPointOffset;"
	append script {
		var channel = dom.GetObject(channelId);
		var dpId = channel.DPByControl("TEMP.SETPOINT");
		var dp = dom.GetObject(dpId);
		var value = dp.Value() + offset;
		dp.State(value);
	}

	rega_exec $script
}

proc TempControl_up_5 { } {
	global fav
	TempControl_change $fav(ID) 5.0
}

proc TempControl_up_2 { } {
	global fav
	TempControl_change $fav(ID) 2.0
}

proc TempControl_up_1 { } {
	global fav
	TempControl_change $fav(ID) 1.0
}

proc TempControl_down_1 { } {
	global fav
	TempControl_change $fav(ID) -1.0
}

proc TempControl_down_2 { } {
	global fav
	TempControl_change $fav(ID) -2.0
}

proc TempControl_down_5 { } {
	global fav
	TempControl_change $fav(ID) -5.0
}
