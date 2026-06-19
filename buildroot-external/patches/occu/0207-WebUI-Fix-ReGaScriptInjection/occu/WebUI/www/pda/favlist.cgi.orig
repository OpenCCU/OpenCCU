#!/bin/tclsh

load tclrega.so

source extern/cgi.tcl
source extern/tmpl_parser.tcl

source eq3/ui.tcl
source eq3/rega.tcl
source eq3/session.tcl
source eq3/favorite.tcl

source eq3/util.tcl
source eq3/template.tcl

set TEMPLATE_FILE               templates/favlist.tmpl
set TEMPLATE_FILE_ERROR_SESSION templates/error_session.tmpl

cgi_eval {

	cgi_input
	
	set sid {}
	catch {import sid }
	set favListId {}
	catch { import favListId }
	set uiStyle {}
	catch { import uiStyle }
	
	if { {true} != [session_isValid $sid] } then {
		http_head
		puts [eval [template_parseFile $TEMPLATE_FILE_ERROR_SESSION]]
		exit
	}
	
	array set favList [Favorite_getList $favListId]
	
	http_head
	puts [eval [template_parseFile $TEMPLATE_FILE]]
}
