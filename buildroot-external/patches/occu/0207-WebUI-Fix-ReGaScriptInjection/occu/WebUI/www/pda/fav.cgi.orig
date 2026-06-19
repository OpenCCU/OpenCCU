#!/bin/tclsh

load tclrega.so

source extern/cgi.tcl
source extern/tmpl_parser.tcl

source eq3/ui.tcl
source eq3/rega.tcl
source eq3/session.tcl
source eq3/favorite.tcl
source eq3/program.tcl
source eq3/sysvar.tcl
source eq3/channel.tcl
source eq3/dpcontrols.tcl

source eq3/util.tcl
source eq3/template.tcl

set TEMPLATE_FILE               templates/fav.tmpl
set TEMPLATE_FILE_ERROR_SESSION templates/error_session.tmpl

array set COMMANDS {}
set COMMANDS(exec) [list executePorgram]

proc getProgramStatus { progId } { 
	array set status [Program_getStatus $progId]

	set    result [status_separator]
	append result {<tr><td class="status">}
	if { {true} == $status(IS_ACTIVE) } then {
		append result {<div class="caption">Aktiv</div>}
	} else {
		append result {<div class="caption">Inaktiv</div>}
	}
	append result {</tr>}
	append result {<tr><td class="status_separator">&nbsp;</td></tr>}
	append result {<tr><td class="status">}
	append result {<div class="caption">Letzte Ausführung</div>}
	append result "<div class=\"center\">$status(LAST_EXEC_TIME)</div>"
	append result {</td></tr>}
	
	return $result
}


proc executePorgram { } { 
	global fav
	
	Program_execute $fav(ID)
}

proc getProgramControls { progId } {
	global sid favListId favId UI_URLBASE
	
	append result [button "Starten"  "$UI_URLBASE/fav.cgi?sid=$sid&favListId=$favListId&favId=$favId&cmd=exec"]
	
	return $result
}

proc getSysVarStatus { varId } {
	set    result [status_separator]
	append result {<tr><td class="status">}
	append result "<div class=\"center\">[SysVar_getValue $varId]</div>"
	append result {</td></tr>}
	
	return $result
}

proc getChannelStatus { channelId } {
	set result {}
	
	foreach dataPoint [Channel_getDataPoints $channelId] {
		append result [DPControls_getStatus $channelId $dataPoint]
	}
	
	return $result
}

proc getChannelTopControls { channelId } {
	set result {}
	
	foreach dataPoint [Channel_getDataPoints $channelId] {
		append result [DPControls_getTopControls $channelId $dataPoint]
	}
	
	return $result
}

proc getChannelControls { channelId } {
	set result {}
	
	foreach dataPoint [Channel_getDataPoints $channelId] {
		append result [DPControls_getControls $channelId $dataPoint]
	}
	
	return $result
}

proc getStatus { } {
	global fav
	
	switch -exact $fav(TYPE) {
		PROGRAM { return [getProgramStatus $fav(ID)] }
		SYSVAR  { return [getSysVarStatus $fav(ID)] }
		CHANNEL { return [getChannelStatus $fav(ID)] }
	}
	
	return ""
}

proc getTopControls { } {
	global fav
	
	if {$fav(CAN_USE)} {
		switch -exact $fav(TYPE) {
			PROGRAM { return {} }
			SYSVAR  { return {} }
			CHANNEL { return [getChannelTopControls $fav(ID)] }
		}
	}
	
	return ""
}

proc getControls { } {
	global fav
	
	if {$fav(CAN_USE)} {
		switch -exact $fav(TYPE) {
			PROGRAM { return [getProgramControls $fav(ID)] }
			SYSVAR  { return {} }
			CHANNEL { return [getChannelControls $fav(ID)] }
		}
	}
	
	return ""
}


cgi_eval {

	cgi_input
	
	set sid {}
	catch {import sid }
	set favListId {}
	catch { import favListId }
	set favId {}
	catch { import favId }
	set cmd {}
	catch { import cmd }
	set uiStyle {}
	catch { import uiStyle }
	
	if { {true} != [session_isValid $sid] } then {
		http_head
		puts [eval [template_parseFile $TEMPLATE_FILE_ERROR_SESSION]]
		exit
	}
	
	array set fav [Favorite_get $favListId $favId]
	
	if { [info exists COMMANDS($cmd)] } then {
		$COMMANDS($cmd)
	}
	
	
	http_head
	puts [eval [template_parseFile $TEMPLATE_FILE]]
}
