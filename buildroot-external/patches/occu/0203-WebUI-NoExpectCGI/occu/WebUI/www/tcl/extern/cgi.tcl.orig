##################################################
#
# cgi.tcl - routines for writing CGI scripts in Tcl
# Author: Don Libes <libes@nist.gov>, January '95
#
# These routines implement the code described in the paper
# "Writing CGI scripts in Tcl" which appeared in the Tcl '96 conference.
# Please read the paper before using this code.  The paper is:
# http://expect.nist.gov/doc/cgi.pdf
#
##################################################

##################################################
# http header support
##################################################

proc cgi_http_head {args} {
    global _cgi env errorInfo

    if {[info exists _cgi(http_head_done)]} return

    set _cgi(http_head_in_progress) 1

    if {0 == [llength $args]} {
	cgi_content_type
    } else {
	if {[catch {uplevel 1 [lindex $args 0]} errMsg]} {
	    set savedInfo $errorInfo
	    cgi_content_type
	}
    }
    cgi_puts ""

    unset _cgi(http_head_in_progress)
    set _cgi(http_head_done) 1

    if {[info exists savedInfo]} {
	error $errMsg $savedInfo
    }
}

# avoid generating http head if not in CGI environment
# to allow generation of pure HTML files
proc _cgi_http_head_implicit {} {
    global env

    if {[info exists env(REQUEST_METHOD)]} cgi_http_head
}

proc cgi_status {num str} {
    global _cgi

    if {[info exists _cgi(http_status_done)]} return
    set _cgi(http_status_done) 1
    puts "Status: $num $str"
}

# If these are called manually, they automatically generate the extra newline

proc cgi_content_type {args} {
    global _cgi

    if {0==[llength $args]} {
	set t "text/html; charset=iso-8859-1"
    } else {
	set t [lindex $args 0]
	if {[regexp ^multipart/ $t]} {
	    set _cgi(multipart) 1
	}
    }

    if {[info exists _cgi(http_head_in_progress)]} {
	cgi_puts "Content-type: $t"
    } else {
	cgi_http_head [list cgi_content_type $t]
    }
}

proc cgi_redirect {t} {
    global _cgi

    if {[info exists _cgi(http_head_in_progress)]} {
	cgi_status 302 Redirected
	cgi_puts "Uri: $t"
	cgi_puts "Location: $t"
    } else {
	cgi_http_head {
	    cgi_redirect $t
	}
    }
}

# deprecated, use cgi_redirect
proc cgi_location {t} {
    global _cgi

    if {[info exists _cgi(http_head_in_progress)]} {
	cgi_puts "Location: $t"
    } else {
	cgi_http_head "cgi_location $t"
    }
}

proc cgi_target {t} {
    global _cgi

    if {![info exists _cgi(http_head_in_progress)]} {
	error "cgi_target must be set from within cgi_http_head."
    }
    cgi_puts "Window-target: $t"
}

# Make client retrieve url in this many seconds ("client pull").
# With no 2nd arg, current url is retrieved.
proc cgi_refresh {seconds {url ""}} {
    global _cgi

    if {![info exists _cgi(http_head_in_progress)]} {
	error "cgi_refresh must be set from within cgi_http_head.  Try using cgi_http_equiv instead."
    }
    cgi_put "Refresh: $seconds"

    if {0!=[string compare $url ""]} {
	cgi_put "; $url"
    }
    cgi_puts ""
}

# Example: cgi_pragma no-cache
proc cgi_pragma {arg} {
    global _cgi

    if {![info exists _cgi(http_head_in_progress)]} {
	error "cgi_pragma must be set from within cgi_http_head."
    }
    cgi_puts "Pragma: $arg"
}

##################################################
# support for debugging or other crucial things we need immediately
##################################################

proc cgi_comment	{args}	{}	;# need this asap

proc cgi_html_comment	{args}	{
    regsub -all {>} $args {\&gt;} args
    cgi_put "<!--[_cgi_list_to_string $args] -->"
}

set _cgi(debug) -off
proc cgi_debug {args} {
    global _cgi

    set old $_cgi(debug)
    set arg [lindex $args 0]
    if {$arg == "-on"} {
	set _cgi(debug) -on
	set args [lrange $args 1 end]
    } elseif {$arg == "-off"} {
	set _cgi(debug) -off
	set args [lrange $args 1 end]
    } elseif {[regexp "^-t" $arg]} {
	set temp 1
	set _cgi(debug) -on
	set args [lrange $args 1 end]
    } elseif {[regexp "^-noprint$" $arg]} {
	set noprint 1
	set args [lrange $args 1 end]
    }

    set arg [lindex $args 0]
    if {$arg == "--"} {
	set args [lrange $args 1 end]
    }

    if {[llength $args]} {
	if {$_cgi(debug) == "-on"} {

	    _cgi_close_tag
	    # force http head and open html, head, body
	    catch {
		if {[info exists noprint]} {
		    uplevel 1 [lindex $args 0]
		} else {
		    cgi_html {
			cgi_head {
			    cgi_title "debugging before complete HTML head"
			}
			# force body open and leave open
			_cgi_body_start
			uplevel 1 [lindex $args 0]
			# bop back out to catch, so we don't close body
			error "ignore"
		    }
		}
	    }
	}
    }

    if {[info exists temp]} {
	set _cgi(debug) $old
    }
    return $old
}

proc cgi_uid_check {user} {
    global env

    # leave in so old scripts don't blow up
    if {[regexp "^-off$" $user]} return

    if {[info exists env(USER)]} {
	set whoami $env(USER)
    } elseif {0==[catch {exec whoami} whoami]} {
	# "who am i" on some Linux hosts returns "" so try whoami first
    } elseif {0==[catch {exec who am i} whoami]} {
	# skip over "host!"
	regexp "(.*!)?(\[^ \t]*)" $whoami dummy dummy whoami
    } elseif {0==[catch {package require registry}]} {
	set whoami [registry get HKEY_LOCAL_MACHINE\\Network\\Logon username]
    } else {
	set whoami $user  ;# give up and let go
    }
    if {$whoami != "$user"} {
	error "Warning: This CGI script expects to run with uid \"$user\".  However, this script is running as \"$whoami\"."
    }
}

# print out elements of an array
# like Tcl's parray, but formatted for browser
proc cgi_parray {a {pattern *}} {
    upvar 1 $a array
    if {![array exists array]} {
	error "\"$a\" isn't an array"
    }

    set maxl 0
    foreach name [lsort [array names array $pattern]] {
	if {[string length $name] > $maxl} {
	    set maxl [string length $name]
	}
    }
    cgi_preformatted {
	set maxl [expr {$maxl + [string length $a] + 2}]
	foreach name [lsort [array names array $pattern]] {
	    set nameString [format %s(%s) $a $name]
	    cgi_puts [cgi_quote_html [format "%-*s = %s" $maxl $nameString $array($name)]]
	}
    }
}

proc cgi_eval {cmd} {
    global env _cgi

    # put cmd somewhere that uplevel can find it
    set _cgi(body) $cmd

    uplevel 1 {
	global env _cgi errorInfo

	if {1==[catch $_cgi(body) errMsg]} {
	    # error occurred, handle it
	    set _cgi(errorInfo) $errorInfo

	    if {![info exists env(REQUEST_METHOD)]} {
		puts stderr $_cgi(errorInfo)
		return
	    }
	    # the following code is all to force browsers into a state
	    # such that diagnostics can be reliably shown

	    # close irrelevant things
	    _cgi_close_procs
	    # force http head and open html, head, body
	    cgi_html {
		cgi_body {
		    if {[info exists _cgi(client_error)]} {
			cgi_h6 "Client Error"
			cgi_p "$errMsg  Report this to your system administrator or browser vendor."
		    } else {
			cgi_put [cgi_anchor_name cgierror]
			cgi_h6 "An internal error was detected in the service\
				software:"

			# suppress formatting
			cgi_preformatted {
				cgi_puts ""
				cgi_puts "<u>Backtrace:</u>"
				cgi_puts [cgi_quote_html $_cgi(errorInfo)]
				cgi_puts ""
				cgi_puts "<u>CGI info:</u>"
				cgi_puts "_cgi(input): $_cgi(input)"
				cgi_puts "_cgi(queryencoding): $_cgi(queryencoding)"
				cgi_puts ""
				cgi_puts "<u>Environment info:</u>"
				catch {cgi_parray env}
			}
			# output in file/mail
			cgi_mail_start $_cgi(admin_email)
			cgi_mail_add "Subject: [cgi_name] CGI problem"
			cgi_mail_add
			cgi_mail_add "CGI environment:"
			cgi_mail_add "REQUEST_METHOD: $env(REQUEST_METHOD)"
			cgi_mail_add "SCRIPT_NAME: $env(SCRIPT_NAME)"
			# this next few things probably don't need
			# a catch but I'm not positive
			catch {cgi_mail_add "HTTP_USER_AGENT: $env(HTTP_USER_AGENT)"}
			catch {cgi_mail_add "HTTP_REFERER: $env(HTTP_REFERER)"}
			catch {cgi_mail_add "HTTP_HOST: $env(HTTP_HOST)"}
			catch {cgi_mail_add "REMOTE_HOST: $env(REMOTE_HOST)"}
			catch {cgi_mail_add "REMOTE_ADDR: $env(REMOTE_ADDR)"}
			cgi_mail_add "cgi.tcl version: 1.10.0"
			cgi_mail_add "input:"
			catch {cgi_mail_add $_cgi(input)}
			cgi_mail_add "cookie:"
			catch {cgi_mail_add $env(HTTP_COOKIE)}
			cgi_mail_add "errorInfo:"
			cgi_mail_add "$_cgi(errorInfo)"
			cgi_mail_end
		    }
		} ;# end cgi_body
	    } ;# end cgi_html
	} ;# end catch
    } ;# end uplevel
}

# return true if cgi_eval caught an error
proc cgi_error_occurred {} {
    global _cgi

    return [info exists _cgi(errorInfo)]
}

##################################################
# CGI URL creation
##################################################

# declare location of root of CGI files
# this allows all CGI references to be relative in the source
# making it easy to move everything in the future
# If you have multiple roots, just don't call this.
proc cgi_root {args} {
    global _cgi

    if {[llength $args]} {
	set _cgi(root) [lindex $args 0]
    } else {
	set _cgi(root)
    }
}

# make a URL for a CGI script
proc cgi_cgi {args} {
    global _cgi

    set root $_cgi(root)
    if {0!=[string compare $root ""]} {
	if {![regexp "/$" $root]} {
		append root "/"
	}
    }
		
    set suffix [cgi_suffix]

    set arg [lindex $args 0]
    if {0==[string compare $arg "-suffix"]} {
	set suffix [lindex $args 1]
	set args [lrange $args 2 end]
    }

    if {[llength $args]==1} {
	return $root[lindex $args 0]$suffix
    } else {
	return $root[lindex $args 0]$suffix?[join [lrange $args 1 end] &]
    }
}

proc cgi_suffix {args} {
    global _cgi
    if {[llength $args] > 0} {
	set _cgi(suffix) [lindex $args 0]
    }
    if {![info exists _cgi(suffix)]} {
	return .cgi
    } else {
	return $_cgi(suffix)
    }
}

proc cgi_cgi_set {variable value} {
    regsub -all {%}  $value "%25" value
    regsub -all {&}  $value "%26" value
    regsub -all {\+} $value "%2b" value
    regsub -all { }  $value "+"   value
    regsub -all {=}  $value "%3d" value
    regsub -all {#}  $value "%23" value
    regsub -all {/}  $value "%2f" value   ;# Added...
    return $variable=$value
}

##################################################
# URL dictionary support
##################################################

proc cgi_link {args} {
    global _cgi_link

    set tag [lindex $args 0]
    switch -- [llength $args] {
	1 {
	    set label $_cgi_link($tag,label)
	} 2 {
	    set label [lindex $args end]
	} default {
	    set _cgi_link($tag,label) [set label [lindex $args 1]]
	    set _cgi_link($tag,url) [lrange $args 2 end]
	}
    }

    return [eval cgi_url [list $label] $_cgi_link($tag,url)]
}

# same as above but for images
# note: uses different namespace
proc cgi_imglink {args} {
    global _cgi_imglink

    set tag [lindex $args 0]
    if {[llength $args] >= 2} {
	set _cgi_imglink($tag) [eval cgi_img [lrange $args 1 end]]
    }
    return $_cgi_imglink($tag)
}

proc cgi_link_label {tag} {
    global _cgi_link
    return $_cgi_link($tag,label)
}

proc cgi_link_url {tag} {
    global _cgi_link
    return $_cgi_link($tag,url)
}

##################################################
# hyperlink support
##################################################

# construct a hyperlink labeled "display"
# last arg is the link destination
# any other args are passed through into <a> display
proc cgi_url {display args} {
    global _cgi

    set buf "<a href=\"[lindex $args 0]\""
    foreach a [lrange $args 1 end] {
	if {[regexp $_cgi(attr,regexp) $a dummy attr str]} {
	    append buf " $attr=\"$str\""
	} else {
	    append buf " $a"
	}
    }
    return "$buf>$display</a>"
}

proc cgi_iframe {args} {
    global _cgi

    set buf "<iframe src=\"[lindex $args 0]\""
    foreach a [lrange $args 1 end] {
        append buf " $a"
    }
    return "$buf />"
}

# generate an image reference (<img ...>)
# first arg is image url
# other args are passed through into <img> tag
proc cgi_img {args} {
    global _cgi

    set buf "<img src=\"[lindex $args 0]\""
    foreach a [lrange $args 1 end] {
	if {[regexp "^(alt|lowsrc|usemap)=(.*)" $a dummy attr str]} {
	    append buf " $attr=[cgi_dquote_html $str]"
	} elseif {[regexp $_cgi(attr,regexp) $a dummy attr str]} {
	    append buf " $attr=\"$str\""
	} else {
	    append buf " $a"
	}
    }
    return "$buf />"
}

# names an anchor so that it can be linked to
proc cgi_anchor_name {name} {
    return "<a name=\"$name\"/>"
}

proc cgi_base {args} {
    global _cgi

    cgi_put "<base"
    foreach a $args {
	if {[regexp "^href=(.*)" $a dummy str]} {
	    cgi_put " href=[cgi_dquote_html $str]"
	} elseif {[regexp $_cgi(attr,regexp) $a dummy attr str]} {
	    cgi_put " $attr=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_puts " />"
}

##################################################
# quoting support
##################################################

if {[info tclversion] >= 8.2} {
    proc cgi_unquote_input buf {
	# rewrite "+" back to space
	# protect \ from quoting another \ and throwing off other things
	# replace line delimiters with newlines
	set buf [string map -nocase [list + { } "\\" "\\\\" %0d%0a \n] $buf]

	# prepare to process all %-escapes
	regsub -all -nocase {%([a-f0-9][a-f0-9])} $buf {\\u00\1} buf

	# process \u unicode mapped chars
	encoding convertfrom $::_cgi(queryencoding) \
		 [subst -novar -nocommand $buf]
    }
} elseif {[info tclversion] >= 8.1} {
    proc cgi_unquote_input buf {
	# rewrite "+" back to space
	regsub -all {\+} $buf { } buf
	# protect \ from quoting another \ and throwing off other things
	regsub -all {\\} $buf {\\\\} buf

	# replace line delimiters with newlines
	regsub -all -nocase "%0d%0a" $buf "\n" buf

	# prepare to process all %-escapes
	regsub -all -nocase {%([a-f0-9][a-f0-9])} $buf {\\u00\1} buf
	# process \u unicode mapped chars
	return [subst -novar -nocommand $buf]
    }
} else {
    proc cgi_unquote_input {buf} {
	# rewrite "+" back to space
	regsub -all {\+} $buf { } buf
	# protect \ from quoting another \ and throwing off other things first
	# protect $ from doing variable expansion
	# protect [ from doing evaluation
	# protect " from terminating string
	regsub -all {([\\["$])} $buf {\\\1} buf
	
	# replace line delimiters with newlines
	regsub -all -nocase "%0d%0a" $buf "\n" buf
	# Mosaic sends just %0A.  This is handled in the next command.

	# prepare to process all %-escapes 
	regsub -all -nocase {%([a-f0-9][a-f0-9])} $buf {[format %c 0x\1]} buf
	# process %-escapes and undo all protection
	eval return \"$buf\"
    }
}

# return string but with html-special characters escaped,
# necessary if you want to send unknown text to an html-formatted page.
proc cgi_quote_html {s} {
    regsub -all {&}	$s {\&amp;}	s	;# must be first!
    regsub -all {"}	$s {\&quot;}	s
    regsub -all {<}	$s {\&lt;}	s
    regsub -all {>}	$s {\&gt;}	s
    regsub -all {ä}	$s {\&auml;}	s
    regsub -all {Ä}	$s {\&Auml;}	s
    regsub -all {ö}	$s {\&ouml;}	s
    regsub -all {Ö}	$s {\&Ouml;}	s
    regsub -all {ü}	$s {\&uuml;}	s
    regsub -all {Ü}	$s {\&Uuml;}	s
    regsub -all {ß}	$s {\&szlig;}	s
    return $s
}

proc cgi_dquote_html {s} {
    return \"[cgi_quote_html $s]\"
}

# return string quoted appropriately to appear in a url
proc cgi_quote_url {in} {
    regsub -all {%}  $in "%25" in
    regsub -all {\+} $in "%2b" in
    regsub -all { }  $in "%20" in
    regsub -all {"}  $in "%22" in
    regsub -all {\?} $in "%3f" in
    return $in
}

##################################################
# short or single paragraph support
##################################################

proc cgi_br {args} {
    cgi_put "<br"
    if {[llength $args]} {
	cgi_put "[_cgi_list_to_string $args]"
    }
    cgi_put " />"
}

# generate cgi_h1 and others
for {set _cgi(tmp) 1} {$_cgi(tmp)<8} {incr _cgi(tmp)} {
    proc cgi_h$_cgi(tmp) {{args}} "eval cgi_h $_cgi(tmp) \$args"
}
proc cgi_h {num args} {
    cgi_put "<h$num"
    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
	set args [lrange $args end end]
    }
    cgi_put ">[lindex $args 0]</h$num>"
}

proc cgi_p {args} {
    cgi_put "<p"
    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
	set args [lrange $args end end]
    }
    cgi_put ">[lindex $args 0]</p>"
}

proc cgi_address      {s} {cgi_put <address>$s</address>}
proc cgi_blockquote   {s} {cgi_puts <blockquote>$s</blockquote>}

##################################################
# long or multiple paragraph support
##################################################

# Shorthand for <div align=center>.  We used to use <center> tags but that
# is now officially unsupported.
proc cgi_center	{cmd}	{
    uplevel 1 "cgi_division align=center [list $cmd]"
}

proc cgi_division {args} {
    cgi_put "<div"
    _cgi_close_proc_push "cgi_put </div>"

    if {[llength $args]} {
	cgi_put "[_cgi_lrange $args 0 [expr {[llength $args]-2}]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

proc cgi_preformatted {args} {
    cgi_put "<pre"
    _cgi_close_proc_push "cgi_put </pre>"

    if {[llength $args]} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

##################################################
# list support
##################################################

proc cgi_li {args} {
    cgi_put <li
    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">[lindex $args end]</li>"
}

proc cgi_number_list {args} {
    cgi_put "<ol"
    _cgi_close_proc_push "cgi_put </ol>"

    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]

    _cgi_close_proc
}

proc cgi_bullet_list {args} {
    cgi_put "<ul"
    _cgi_close_proc_push "cgi_put </ul>"

    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]

    _cgi_close_proc
}

# Following two are normally used from within definition lists
# but are actually paragraph types on their own.
proc cgi_term            {s} {cgi_put <dt>$s</dt>}
proc cgi_term_definition {s} {cgi_put <dd>$s</dd>}

proc cgi_definition_list {cmd} {
    cgi_put "<dl>"
    _cgi_close_proc_push "cgi_put </dl>"

    uplevel 1 $cmd
    _cgi_close_proc
}

proc cgi_menu_list {cmd} {
    cgi_put "<menu>"
    _cgi_close_proc_push "cgi_put </menu>"

    uplevel 1 $cmd
    _cgi_close_proc
}
proc cgi_directory_list {cmd} {
    cgi_put "<dir>"
    _cgi_close_proc_push "cgi_put </dir>"

    uplevel 1 $cmd
    _cgi_close_proc
}

##################################################
# text support
##################################################

proc cgi_put	    {s} {cgi_puts -nonewline $s}

# some common special characters
proc cgi_lt	     {}  {return "&lt;"}
proc cgi_gt	     {}  {return "&gt;"}
proc cgi_amp	     {}  {return "&amp;"}
proc cgi_quote	     {}  {return "&quot;"}
proc cgi_enspace     {}  {return "&ensp;"}
proc cgi_emspace     {}  {return "&emsp;"}
proc cgi_nbspace     {}  {return "&#160;"} ;# nonbreaking space
proc cgi_tm	     {}  {return "&#174;"} ;# registered trademark
proc cgi_copyright   {}  {return "&#169;"}
proc cgi_isochar     {n} {return "&#$n;"}
proc cgi_breakable   {}  {return "<wbr />"}

proc cgi_unbreakable_string {s} {return "<nobr>$s</nobr>"}
proc cgi_unbreakable {cmd} {
    cgi_put "<nobr>"
    _cgi_close_proc_push "cgi_put </nobr>"
    uplevel 1 $cmd
    _cgi_close_proc
}

proc cgi_nl          {args} {
    set buf "<br"
    if {[llength $args]} {
	append buf "[_cgi_list_to_string $args]"
    }
    return "$buf />"
}

proc cgi_bold	    {s} {return "<b>$s</b>"}
proc cgi_italic     {s} {return "<i>$s</i>"}
proc cgi_underline  {s} {return "<u>$s</u>"}
proc cgi_strikeout  {s} {return "<s>$s</s>"}
proc cgi_subscript  {s} {return "<sub>$s</sub>"}
proc cgi_superscript {s} {return "<sup>$s</sup>"}
proc cgi_typewriter {s} {return "<tt>$s</tt>"}
proc cgi_blink	    {s} {return "<blink>$s</blink>"}
proc cgi_emphasis   {s} {return "<em>$s</em>"}
proc cgi_strong	    {s} {return "<strong>$s</strong>"}
proc cgi_cite	    {s} {return "<cite>$s</cite>"}
proc cgi_sample     {s} {return "<samp>$s</samp>"}
proc cgi_keyboard   {s} {return "<kbd>$s</kbd>"}
proc cgi_variable   {s} {return "<var>$s</var>"}
proc cgi_definition {s} {return "<dfn>$s</dfn>"}
proc cgi_big	    {s} {return "<big>$s</big>"}
proc cgi_small	    {s} {return "<small>$s</small>"}

proc cgi_basefont   {size} {cgi_put "<basefont size=$size />"}

proc cgi_font {args} {
    global _cgi

    set buf "<font"
    foreach a [lrange $args 0 [expr [llength $args]-2]] {
	if {[regexp $_cgi(attr,regexp) $a dummy attr str]} {
	    append buf " $attr=\"$str\""
	} else {
	    append buf " $a"
	}
    }
    return "$buf>[lindex $args end]</font>"
}

# take a cgi func and have it return what would normally print
# This command is reentrant (that's why it's so complex).
proc cgi_buffer {cmd} {
    global _cgi

    if {0==[info exists _cgi(returnIndex)]} {
	set _cgi(returnIndex) 0
    }

    rename cgi_puts cgi_puts$_cgi(returnIndex)
    incr _cgi(returnIndex)
    set _cgi(return[set _cgi(returnIndex)]) ""

    proc cgi_puts args {
	global _cgi
	upvar #0 _cgi(return[set _cgi(returnIndex)]) buffer

	append buffer [lindex $args end]
	if {[llength $args] == 1} {
	    append buffer $_cgi(buffer_nl)
	}
    }

    # must restore things before allowing the eval to fail
    # so catch here and rethrow later
    if {[catch {uplevel 1 $cmd} errMsg]} {
	global errorInfo
	set savedInfo $errorInfo
    }

    # not necessary to put remainder of code in close_proc_push since it's
    # all buffered anyway and hasn't yet put browser into a funky state.

    set buffer $_cgi(return[set _cgi(returnIndex)])

    incr _cgi(returnIndex) -1
    rename cgi_puts ""
    rename cgi_puts$_cgi(returnIndex) cgi_puts

    if {[info exists savedInfo]} {
	error $errMsg $savedInfo
    }
    return $buffer
}

set _cgi(buffer_nl) "\n"
proc cgi_buffer_nl {nl} {
    global _cgi

    set old $_cgi(buffer_nl)
    set _cgi(buffer_nl) $nl
    return $old
}

##################################################
# html and tags that can appear in html top-level
##################################################

proc cgi_html {args} {
    set html [lindex $args end]
    set argc [llength $args]
    if {$argc > 1} {
	eval _cgi_html_start [lrange $args 0 [expr {$argc-2}]]
    } else {
	_cgi_html_start
    }
    uplevel 1 $html
    _cgi_html_end
}

proc _cgi_html_start {args} {
    global _cgi
    
    if {[info exists _cgi(html_in_progress)]} return
    _cgi_http_head_implicit

    set _cgi(html_in_progress) 1
    cgi_doctype

    append buf "<html"
    foreach a $args {
	if {[regexp $_cgi(attr,regexp) $a dummy attr str]} {
	    append buf " $attr=\"$str\""
	} else {
	    append buf " $a"
	}
    }
    cgi_puts "$buf>"
}

proc _cgi_html_end {} {
    global _cgi
    unset _cgi(html_in_progress)
    set _cgi(html_done) 1
    cgi_puts "</html>"
}

# force closure of all tags and exit without going through normal returns.
# Very useful if you want to call exit from a deeply stacked CGI script
# and still have the HTML be correct.
proc cgi_exit {} {
    _cgi_close_procs
    cgi_html {cgi_body {}}
    exit
}

##################################################
# head support
##################################################

proc cgi_head {{head {}}} {
    global _cgi

    if {[info exists _cgi(head_done)]} {
	return
    }

    # allow us to be recalled so that we can display errors
    if {0 == [info exists _cgi(head_in_progress)]} {
	_cgi_http_head_implicit
	set _cgi(head_in_progress) 1
	cgi_puts "<head>"
    }

    # prevent cgi_html (during error handling) from generating html tags
    set _cgi(html_in_progress) 1
    # don't actually generate html tags since there's nothing to clean
    # them up

    if {0 == [string length $head]} {
	if {[catch {cgi_title}]} {
	    set head "cgi_title untitled"
	}
    }
    uplevel 1 $head
    if {![info exists _cgi(head_suppress_tag)]} {
	cgi_puts "</head>"
    } else {
	unset _cgi(head_suppress_tag)
    }

    set _cgi(head_done) 1

    # debugging can unset this in the uplevel above
    catch {unset _cgi(head_in_progress)}
}

# with one arg: set, print, and return title
# with no args: return title
proc cgi_title {args} {
    global _cgi

    set title [lindex $args 0]

    if {[llength $args]} {
	_cgi_http_head_implicit

	# we could just generate <head></head> tags, but head-level commands
	# might follow so just suppress the head tags entirely
	if {![info exists _cgi(head_in_progress)]} {
	    set _cgi(head_in_progress) 1
	    set _cgi(head_suppress_tag) 1
	}

	set _cgi(title) $title
	cgi_puts "<title>$title</title>"
    }
    return $_cgi(title)
}

# This tag can only be called from with cgi_head.
# example: cgi_http_equiv Refresh 1
# There's really no reason to call this since it can be done directly
# from cgi_http_head.
proc cgi_http_equiv {type contents} {
    _cgi_http_head_implicit
    cgi_puts "<meta http-equiv=\"$type\" content=[cgi_dquote_html $contents]/>"
}

# Do whatever you want with meta tags.
# Example: <meta name="author" content="Don Libes">
proc cgi_meta {args} {
    cgi_put "<meta"
    foreach a $args {
	if {[regexp "^(name|content|http-equiv)=(.*)" $a dummy attr str]} {
	    cgi_put " $attr=[cgi_dquote_html $str]"
	} else {
	    cgi_put " $a"
	}
    }
    cgi_puts " />"
}

proc cgi_relationship {rel href args} {
    cgi_puts "<link rel=$rel href=\"$href\""
    foreach a $args {
	if {[regexp "^title=(.*)" $a dummy str]} {
	    cgi_put " title=[cgi_dquote_html $str]"
	} elseif {[regexp "^type=(.*)" $a dummy str]} {
	    cgi_put " type=[cgi_dquote_html $str]"
	} else {
	    cgi_put " $a"
	}
    }
    cgi_puts "/>"
}

proc cgi_name {args} {
    global _cgi

    if {[llength $args]} {
	set _cgi(name) [lindex $args 0]
    }
    return $_cgi(name)
}

##################################################
# body and other top-level support
##################################################

proc cgi_body {args} {
    global errorInfo errorCode _cgi

    # allow user to "return" from the body without missing _cgi_body_end
    if {1==[catch {
	eval _cgi_body_start [lrange $args 0 [expr [llength $args]-2]]
	uplevel 1 [lindex $args end]
    } errMsg]} {
	set savedInfo $errorInfo
	set savedCode $errorCode
	error $errMsg $savedInfo $savedCode
    }
    _cgi_body_end
}

proc _cgi_body_start {args} {
    global _cgi
    if {[info exists _cgi(body_in_progress)]} return

    cgi_head

    set _cgi(body_in_progress) 1

    cgi_put "<body"
    foreach a "$args $_cgi(body_args)" {
	if {[regexp "^(background|bgcolor|text|link|vlink|alink|onLoad|onUnload)=(.*)" $a dummy attr str]} {
	    cgi_put " $attr=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_puts ">"

    cgi_debug {
	global env
	catch {cgi_puts "Input: <pre>$_cgi(input)</pre>"}
	catch {cgi_puts "Cookie: <pre>$env(HTTP_COOKIE)</pre>"}
    }

    if {![info exists _cgi(errorInfo)]} {
	uplevel 2 app_body_start
    }
}

proc _cgi_body_end {} {
    global _cgi
    if {![info exists _cgi(errorInfo)]} {
	uplevel 2 app_body_end
    }
    unset _cgi(body_in_progress)
    cgi_puts "</body>"

    if {[info exists _cgi(multipart)]} {
	unset _cgi(http_head_done)
	catch {unset _cgi(http_status_done)}
	unset _cgi(head_done)
	catch {unset _cgi(head_suppress_tag)}
    }
}

proc cgi_body_args {args} {
    global _cgi

    set _cgi(body_args) $args
}

proc cgi_script {args} {
    cgi_puts "<script[_cgi_lrange $args 0 [expr [llength $args]-2]]>"
    _cgi_close_proc_push "cgi_puts </script>"

    uplevel 1 [lindex $args end]

    _cgi_close_proc
}

proc cgi_javascript {args} {
    cgi_puts "<script[_cgi_lrange $args 0 [expr [llength $args]-2]]>"
#    cgi_puts "<!--- Hide script from browsers that don't understand JavaScript"
#    _cgi_close_proc_push {cgi_puts "// End hiding -->\n</script>"}
    _cgi_close_proc_push {cgi_puts "\n</script>"}

    uplevel 1 [lindex $args end]

    _cgi_close_proc
}

proc cgi_noscript {args} {
    cgi_puts "<noscript[_cgi_lrange $args 0 [expr [llength $args]-2]]>"
    _cgi_close_proc_push {cgi_puts "</noscript>"}

    uplevel 1 [lindex $args end]

    _cgi_close_proc
}

proc cgi_applet {args} {
    cgi_puts "<applet[_cgi_lrange $args 0 [expr [llength $args]-2]]>"
    _cgi_close_proc_push "cgi_puts </applet>"

    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

proc cgi_param {nameval} {
    regexp "(\[^=]*)(=?)(.*)" $nameval dummy name q value

    if {$q != "="} {
	set value ""
    }
    cgi_puts "<param name=\"$name\" value=[cgi_dquote_html $value]/>"
}

# record any proc's that must be called prior to displaying an error
proc _cgi_close_proc_push {p} {
    global _cgi
    if {![info exists _cgi(close_proc)]} {
	set _cgi(close_proc) ""
    }
    set _cgi(close_proc) "$p; $_cgi(close_proc)"
}

proc _cgi_close_proc_pop {} {
    global _cgi
    regexp "^(\[^;]*);(.*)" $_cgi(close_proc) dummy lastproc _cgi(close_proc)
    return $lastproc
}

# generic proc to close whatever is on the top of the stack
proc _cgi_close_proc {} {
    eval [_cgi_close_proc_pop]
}

proc _cgi_close_procs {} {
    global _cgi

    _cgi_close_tag
    if {[info exists _cgi(close_proc)]} {
	uplevel #0 $_cgi(close_proc)
    }
}

proc _cgi_close_tag {} {
    global _cgi

    if {[info exists _cgi(tag_in_progress)]} {
	cgi_put ">"
	unset _cgi(tag_in_progress)
    }
}

##################################################
# hr support
##################################################

proc cgi_hr {args} {
    set buf "<hr"
    foreach a $args {
	if {[regexp "^width=(.*)" $a dummy str]} {
	    append buf " width=\"$str\""
	} else {
	    append buf " $a"
	}
    }
    cgi_put "$buf />"
}

##################################################
# form & isindex
##################################################

proc cgi_form {action args} {
    global _cgi

    _cgi_form_multiple_check
    set _cgi(form_in_progress) 1

    _cgi_close_proc_push _cgi_form_end
    cgi_put "<form action="
    if {[regexp {^[a-z]*:} $action]} {
	cgi_put "\"$action\""
    } else {
	cgi_put "\"[cgi_cgi $action]\""
    }
    set method "method=post"
    foreach a [lrange $args 0 [expr [llength $args]-2]] {
	if {[regexp "^method=" $a]} {
	    set method $a
	} elseif {[regexp "^(target|onReset|onSubmit)=(.*)" $a dummy attr str]} {
	    cgi_put " $attr=\"$str\""
	} elseif {[regexp "^enctype=(.*)" $a dummy str]} {
	    cgi_put " enctype=\"$str\""
	    set _cgi(form,enctype) $str
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put " $method>"
    uplevel 1 [lindex $args end]
    catch {unset _cgi(form,enctype)}
    _cgi_close_proc
}

proc _cgi_form_end {} {
    global _cgi
    unset _cgi(form_in_progress)
    cgi_put "</form>"
}

proc _cgi_form_multiple_check {} {
    global _cgi
    if {[info exists _cgi(form_in_progress)]} {
	error "Cannot create form (or isindex) with form already in progress."
    }
}

proc cgi_isindex {args} {
    _cgi_form_multiple_check

    cgi_put "<isindex"
    foreach a $args {
	if {[regexp "^href=(.*)" $a dummy str]} {
	    cgi_put " href=\"$str\""
	} elseif {[regexp "^prompt=(.*)" $a dummy str]} {
	    cgi_put " prompt=[cgi_dquote_html $str]"
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

##################################################
# argument handling
##################################################

proc cgi_input {{fakeinput {}} {fakecookie {}}} {
    global env _cgi _cgi_uservar _cgi_cookie _cgi_cookie_shadowed

    set _cgi(uservars) {}
    set _cgi(uservars,autolist) {}

    if {[info exists env(CONTENT_TYPE)] && [regexp ^multipart/form-data $env(CONTENT_TYPE)]} {
	if {![info exists env(REQUEST_METHOD)]} {
	    # running by hand
	    set fid [open $fakeinput]
	} else {
	    set fid stdin
	}
	if {([info tclversion] >= 8.1) || [catch exp_version] || [info exists _cgi(no_binary_upload)]} {
	    _cgi_input_multipart $fid
	} else {
	    _cgi_input_multipart_binary $fid
	}
    } else {
	if {![info exists env(REQUEST_METHOD)]} {
	    set input $fakeinput
	    set env(HTTP_COOKIE) $fakecookie
	} elseif { $env(REQUEST_METHOD) == "GET" } {
	    set input ""
	    catch {set input $env(QUERY_STRING)} ;# doesn't have to be set
	} elseif { $env(REQUEST_METHOD) == "HEAD" } {
	    set input ""
	} elseif {![info exists env(CONTENT_LENGTH)]} {
	    set _cgi(client_error) 1
	    error "Your browser failed to generate the content-length during a POST method."
	} else {
	    set length $env(CONTENT_LENGTH)
	    if {0!=[string compare $length "-1"]} {
		set input [read stdin $env(CONTENT_LENGTH)]		
	    } else {
		set _cgi(client_error) 1
		error "Your browser generated a content-length of -1 during a POST method."
	    }
	    if {[info tclversion] >= 8.1} {
                # guess query encoding from Content-Type header
                if {[info exists env(CONTENT_TYPE)] \
                    && [regexp -nocase -- {charset=([^[:space:]]+)} $env(CONTENT_TYPE) m cs]} {
                    if {[regexp -nocase -- {iso-?8859-([[:digit:]]+)} $cs m d]} {
                        set _cgi(queryencoding) "iso8859-$d"
                    } elseif {[regexp -nocase -- {windows-([[:digit:]]+)} $cs m d]} {
                        set _cgi(queryencoding) "cp$d"
                    } elseif {0==[string compare -nocase $cs "utf-8"]} {
                        set _cgi(queryencoding) "utf-8"
                    } elseif {0==[string compare -nocase $cs "utf-16"]} {
                        set _cgi(queryencoding) "unicode"
                    }
                    if { [lsearch -exact [encoding names] $_cgi(queryencoding)] == -1} {
                        set _cgi(queryencoding) [encoding system]
                    }
                } else {
                    set _cgi(queryencoding) [encoding system]
                }
            }
	}
	# save input for possible diagnostics later
	set _cgi(input) $input

	set pairs [split $input &]
	foreach pair $pairs {
	    if {0 == [regexp "^(\[^=]*)=(.*)$" $pair dummy varname val]} {
		# if no match, unquote and leave it at that
		# this is typical of <isindex>-style queries
		set varname anonymous
		set val $pair
	    }

	    set varname [cgi_unquote_input $varname]
	    set val [cgi_unquote_input $val]
	    _cgi_set_uservar $varname $val
	}
    }

    # O'Reilly's web server incorrectly uses COOKIE
    catch {set env(HTTP_COOKIE) $env(COOKIE)}
    if {![info exists env(HTTP_COOKIE)]} return
    foreach pair [split $env(HTTP_COOKIE) ";"] {
	# pairs are actually split by "; ", sigh
	set pair [string trimleft $pair " "]
	# spec is not clear but seems to allow = unencoded
	# only sensible interpretation is to assume no = in var names
	# appears MS IE can omit "=val"
	set val ""
	regexp (\[^=]*)=?(.*) $pair dummy varname val

	set varname [cgi_unquote_input $varname]
	set val [cgi_unquote_input $val]

	if {[info exists _cgi_cookie($varname)]} {
	    lappend _cgi_cookie_shadowed($varname) $val
	} else {
	    set _cgi_cookie($varname) $val
	}
    }
}

proc _cgi_input_multipart {fin} {
    global env _cgi _cgi_uservar _cgi_userfile

    cgi_debug -noprint {
	# save file for debugging purposes
	set dbg_filename [file join $_cgi(tmpdir) CGIdbg.[pid]]
	# explicitly flush all writes to fout, because sometimes the writer
	# can hang and we won't get to the termination code
	set dbg_fout [open $dbg_filename w]
	set _cgi(input) $dbg_filename
	catch {fconfigure $dbg_fout -translation binary}
    }

    # figure out boundary
    if {0==[regexp boundary=(.*) $env(CONTENT_TYPE) dummy boundary]} {
	set _cgi(client_error) 1
	error "Your browser failed to generate a \"boundary=\" line in a multipart response (CONTENT_TYPE: $env(CONTENT_TYPE)).  Please upgrade (or fix) your browser."
    }

    # make boundary into a legal regsub pattern by protecting #
    # legal boundary characters include ()+.? (among others)
    regsub -all "\\(" $boundary "\\(" boundary
    regsub -all "\\)" $boundary "\\)" boundary
    regsub -all "\\+" $boundary "\\+" boundary
    regsub -all "\\." $boundary "\\." boundary
    regsub -all "\\?" $boundary "\\?" boundary

    set boundary --$boundary

    # don't corrupt or modify uploads yet allow Tcl 7.4 to work
    catch {fconfigure $fin -translation binary}

    # get first boundary line
    gets $fin buf
    if {[info exists dbg_fout]} {puts $dbg_fout $buf; flush $dbg_fout}

    set _cgi(file,filecount) 0

    while {1} {
	# process Content-Disposition:
	if {-1 == [gets $fin buf]} break
	if {[info exists dbg_fout]} {puts $dbg_fout $buf; flush $dbg_fout}
	catch {unset filename}
	regexp {name="([^"]*)"} $buf dummy varname
	if {0==[info exists varname]} {
	    # lynx violates spec and doesn't use quotes, so try again but
	    # assume space is delimiter
	    regexp {name=([^ ]*)} $buf dummy varname
	    if {0==[info exists varname]} {
		set _cgi(client_error) 1
		error "In response to a request for a multipart form, your browser generated a part header without a name field.  Please upgrade (or fix) your browser."
	    }
	}	    
	# Lame-o encoding (on Netscape at least) doesn't escape field
	# delimiters (like quotes)!!  Since all we've ever seen is filename=
	# at end of line, assuming nothing follows.  Sigh.
	regexp {filename="(.*)"} $buf dummy filename

	# Skip remaining headers until blank line.
	# Content-Type: can appear here.
	set conttype ""
	while {1} {
	    if {-1 == [gets $fin buf]} break
	    if {[info exists dbg_fout]} {puts $dbg_fout $buf; flush $dbg_fout}
	    if {0==[string compare $buf "\r"]} break
	    regexp -nocase "^Content-Type:\[ \t]+(.*)\r" $buf x conttype
	}

	if {[info exists filename]} {
	    if {$_cgi(file,filecount) > $_cgi(file,filelimit)} {
		error "Too many files submitted.  Max files allowed: $_cgi(file,filelimit)"
	    }

	    # read the part into a file
	    set foutname [file join $_cgi(tmpdir) CGI[pid].[incr _cgi(file,filecount)]]
	    set fout [open $foutname w]
	    # "catch" permits this to work with Tcl 7.4
	    catch {fconfigure $fout -translation binary}
	    _cgi_set_uservar $varname [list $foutname $filename $conttype]
	    set _cgi_userfile($varname) [list $foutname $filename $conttype]

	    #
	    # Look for a boundary line preceded by \r\n.
	    #
	    # To do this, we buffer line terminators that might
	    # be the start of the special \r\n$boundary sequence.
	    # The buffer is called "leftover" and is just inserted
	    # into the front of the next output (assuming it's
	    # not a boundary line).

	    set leftover ""
	    while {1} {
		if {-1 == [gets $fin buf]} break
		if {[info exists dbg_fout]} {puts $dbg_fout $buf; flush $dbg_fout}

		if {0 == [string compare "\r\n" $leftover]} {
		    if {[regexp ^[set boundary](--)?\r?$ $buf dummy dashdash]} {
			if {$dashdash == "--"} {set eof 1}
			break
		    }
		}
		if {[regexp (.*)\r$ $buf x data]} {
		    puts -nonewline $fout $leftover$data
		    set leftover "\r\n"
		} else {
		    puts -nonewline $fout $leftover$buf
		    set leftover "\n"
		}
 		if {[file size $foutname] > $_cgi(file,charlimit)} {
		    error "File size exceeded.  Max file size allowed: $_cgi(file,charlimit)"
		}
	    }

	    close $fout
	    unset fout
	} else {
	    # read the part into a variable
	    set val ""
	    while {1} {
		if {-1 == [gets $fin buf]} break
		if {[info exists dbg_fout]} {puts $dbg_fout $buf; flush $dbg_fout}
		if {[regexp ^[set boundary](--)?\r?$ $buf dummy dashdash]} {
		    if {$dashdash == "--"} {set eof 1}
		    break
		}
		if {0!=[string compare $val ""]} {
		    append val \n
		}
		regexp (.*)\r$ $buf dummy buf
		append val $buf
	    }
	    _cgi_set_uservar $varname $val
	}
        if {[info exists eof]} break
    }
    if {[info exists dbg_fout]} {close $dbg_fout}
}

proc _cgi_input_multipart_binary {fin} {
    global env _cgi _cgi_uservar _cgi_userfile

    log_user 0
    set timeout -1

    cgi_debug -noprint {
	# save file for debugging purposes
	set dbg_filename [file join $_cgi(tmpdir) CGIdbg.[pid]]
	set _cgi(input) $dbg_filename
	spawn -open [open $dbg_filename w]
	set dbg_sid $spawn_id
    }
    spawn -open $fin
    set fin_sid $spawn_id
    remove_nulls 0

    if {0} {
	# dump input to screen
	cgi_debug {
	    puts "<xmp>"
	    expect {
		-i $fin_sid
		-re ^\r {puts -nonewline "CR"; exp_continue}
		-re ^\n {puts "NL"; exp_continue}
		-re . {puts -nonewline $expect_out(buffer); exp_continue}
	    }
	    puts "</xmp>"
	    exit
	}
    }

    # figure out boundary
    if {0==[regexp boundary=(.*) $env(CONTENT_TYPE) dummy boundary]} {
	set _cgi(client_error) 1
	error "Your browser failed to generate a \"boundary=\" definition in a multipart response (CONTENT_TYPE: $env(CONTENT_TYPE)).  Please upgrade (or fix) your browser."
    }

    # make boundary into a legal regsub pattern by protecting #
    # legal boundary characters include ()+.? (among others)
    regsub -all "\\(" $boundary "\\(" boundary
    regsub -all "\\)" $boundary "\\)" boundary
    regsub -all "\\+" $boundary "\\+" boundary
    regsub -all "\\." $boundary "\\." boundary
    regsub -all "\\?" $boundary "\\?" boundary

    set boundary --$boundary
    set linepat "(\[^\r]*)\r\n"

    # get first boundary line
    expect {
	-i $fin_sid
	-re $linepat {
	    set buf $expect_out(1,string)
	    if {[info exists dbg_sid]} {send -i $dbg_sid -- $buf\n}
	}
	eof {
	    set _cgi(client_error) 1
	    error "Your browser failed to provide an initial boundary ($boundary) in a multipart response.  Please upgrade (or fix) your browser."
	}
    }

    set _cgi(file,filecount) 0

    while {1} {
	# process Content-Disposition:
	expect {
	    -i $fin_sid
	    -re $linepat {
		set buf $expect_out(1,string)
		if {[info exists dbg_sid]} {send -i $dbg_sid -- $buf\n}
	    }
	    eof break
	}
	catch {unset filename}
	regexp {name="([^"]*)"} $buf dummy varname
	if {0==[info exists varname]} {
	    set _cgi(client_error) 1
	    error "In response to a request for a multipart form, your browser generated a part header without a name field.  Please upgrade (or fix) your browser."
	}	    

	# Lame-o encoding (on Netscape at least) doesn't escape field
	# delimiters (like quotes)!!  Since all we've ever seen is filename=
	# at end of line, assuming nothing follows.  Sigh.
	regexp {filename="(.*)"} $buf dummy filename

	# Skip remaining headers until blank line.
	# Content-Type: can appear here.
	set conttype ""
	expect {
	    -i $fin_sid
	    -re $linepat {
		set buf $expect_out(1,string)
		if {[info exists dbg_sid]} {send -i $dbg_sid -- $buf\n}
		if {0!=[string compare $buf ""]} exp_continue
		regexp -nocase "^Content-Type:\[ \t]+(.*)\r" $buf x conttype
	    }
	    eof break
	}

	if {[info exists filename]} {
	    if {$_cgi(file,filecount) > $_cgi(file,filelimit)} {
		error "Too many files submitted.  Max files allowed: $_cgi(file,filelimit)"
	    }

	    # read the part into a file
	    set foutname [file join $_cgi(tmpdir) CGI[pid].[incr _cgi(file,filecount)]]
	    spawn -open [open $foutname w]
	    set fout_sid $spawn_id

	    _cgi_set_uservar $varname [list $foutname $filename $conttype]
	    set _cgi_userfile($varname) [list $foutname $filename $conttype]

	    # This is tricky stuff - be very careful changing anything here!
	    # In theory, all we have to is record everything up to
	    # \r\n$boundary\r\n.  Unfortunately, we can't simply wait on
	    # such a pattern because the input can overflow any possible
	    # buffer we might choose.  We can't simply catch buffer_full
	    # because the boundary might straddle a buffer.  I doubt that
	    # doing my own buffering would be any faster than taking the
	    # approach I've done here.
	    #
	    # The code below basically implements a simple scanner that
	    # keeps track of whether it's seen crlfs or pieces of them.
	    # The idea is that we look for crlf pairs, separated by
	    # things that aren't crlfs (or pieces of them).  As we encounter
	    # things that aren't crlfs (or pieces of them), or when we decide
	    # they can't be, we mark them for output and resume scanning for
	    # new pairs.
	    #
	    # The scanner runs tolerably fast because the [...]+ pattern picks
	    # up most things.  The \r and \n are ^-anchored so the pattern
	    # match is pretty fast and these don't happen that often so the
	    # huge \n action is executed rarely (once per line on text files).
	    # The null pattern is, of course, only used when everything
	    # else fails.

	    # crlf	== "\r\n" if we've seen one, else == ""
	    # cr	== "\r" if we JUST saw one, else == ""
	    #           Yes, strange, but so much more efficient
	    #		that I'm willing to sacrifice readability, sigh.
	    # buf	accumulated data between crlf pairs

	    set buf ""
	    set cr ""
	    set crlf ""

	    expect {
		-i $fin_sid
		-re "^\r" {
		    if {$cr == "\r"} {
			append buf "\r"
		    }
		    set cr \r
		    exp_continue
		} -re "^\n" {
		    if {$cr == "\r"} {
			if {$crlf == "\r\n"} {
			    # do boundary test
			    if {[regexp ^[set boundary](--)?$ $buf dummy dashdash]} {
				if {$dashdash == "--"} {
				    set eof 1
				}
			    } else {
				# boundary test failed
				if {[info exists dbg_sid]} {send -i $dbg_sid -- \r\n$buf}
				send -i $fout_sid \r\n$buf ; set buf ""
				set cr ""
				exp_continue
			    }
			} else {
			    set crlf "\r\n"
			    set cr ""
			    if {[info exists dbg_sid]} {send -i $dbg_sid -- $buf}
			    send -i $fout_sid -- $buf ; set buf ""
			    exp_continue
			}
		    } else {
			if {[info exists dbg_sid]} {send -i $dbg_sid -- $crlf$buf\n}
			send -i $fout_sid -- $crlf$buf\n ; set buf ""
			set crlf ""
			exp_continue
		    }
		} -re "\[^\r\n]+" {
		    if {$cr == "\r"} {
			set buf $crlf$buf\r$expect_out(buffer)
			set crlf ""
			set cr ""
		    } else {
			append buf $expect_out(buffer)
		    }
		    exp_continue
		} null {
		    if {[info exists dbg_sid]} {
			send -i $dbg_sid -- $crlf$buf$cr
			send -i $dbg_sid -null
		    }
		    send -i $fout_sid -- $crlf$buf$cr ; set buf ""
		    send -i $fout_sid -null
		    set cr ""
		    set crlf ""
		    exp_continue
		} eof {
		    set _cgi(client_error) 1
		    error "Your browser failed to provide an ending boundary ($boundary) in a multipart response.  Please upgrade (or fix) your browser."
		}
	    }
	    exp_close -i $fout_sid    ;# implicitly closes fout
	    exp_wait -i $fout_sid
	    unset fout_sid
	} else {
	    # read the part into a variable
	    set val ""
	    expect {
		-i $fin_sid
		-re $linepat {
		    set buf $expect_out(1,string)
		    if {[info exists dbg_sid]} {send -i $dbg_sid -- $buf\n}
		    if {[regexp ^[set boundary](--)?$ $buf dummy dashdash]} {
			if {$dashdash == "--"} {set eof 1}
		    } else {
			regexp (.*)\r$ $buf dummy buf
			if {0!=[string compare $val ""]} {
			    append val \n
			}
			append val $buf
			exp_continue
		    }
		}
	    }
	    _cgi_set_uservar $varname $val
	}	    
        if {[info exists eof]} break
    }
    if {[info exists fout]} {
	exp_close -i $dbg_sid
	exp_wait -i $dbg_sid
    }

    # no need to close fin, fin_sid, or dbg_sid
}

# internal routine for defining user variables
proc _cgi_set_uservar {varname val} {
    global _cgi _cgi_uservar

    set exists [info exists _cgi_uservar($varname)]
    set isList $exists
    # anything we've seen before and is being set yet again necessarily
    # has to be (or become a list)

    if {!$exists} {
	lappend _cgi(uservars) $varname
    }

    if {[regexp List$ $varname]} {
	set isList 1
    } elseif {$exists} {
	# vars that we've seen before but aren't marked as lists
	# need to be "listified" so we can do appends later
	if {-1 == [lsearch $_cgi(uservars,autolist) $varname]} {
	    # remember that we've listified it
	    lappend _cgi(uservars,autolist) $varname
	    set _cgi_uservar($varname) [list $_cgi_uservar($varname)]
	}
    }
    if {$isList} {
	lappend _cgi_uservar($varname) $val
    } else {
	set _cgi_uservar($varname) $val
    }
}

# export named variable
proc cgi_export {nameval} {
    regexp "(\[^=]*)(=?)(.*)" $nameval dummy name q value

    if {$q != "="} {
	set value [uplevel 1 set [list $name]]
    }

    cgi_put "<input type=hidden name=\"$name\" value=[cgi_dquote_html $value]/>"
}

proc cgi_export_cookie {name args} {
    upvar 1 $name x
    eval cgi_cookie_set [list $name=$x] $args
}

# return list of variables available for import
# Explicit list is used to keep items in order originally found in form.
proc cgi_import_list {} {
    global _cgi

    return $_cgi(uservars)
}

# import named variable
proc cgi_import {name} {
    global _cgi_uservar
    upvar 1 $name var

    set var $_cgi_uservar($name)
}

proc cgi_import_as {name tclvar} {
    global _cgi_uservar
    upvar 1 $tclvar var

    set var $_cgi_uservar($name)
}

# like cgi_import but if not available, try cookie
proc cgi_import_cookie {name} {
    global _cgi_uservar
    upvar 1 $name var

    if {0==[catch {set var $_cgi_uservar($name)}]} return
    set var [cgi_cookie_get $name]
}

# like cgi_import but if not available, try cookie
proc cgi_import_cookie_as {name tclvar} {
    global _cgi_uservar
    upvar 1 $tclvar var

    if {0==[catch {set var $_cgi_uservar($name)}]} return
    set var [cgi_cookie_get $name]
}

proc cgi_import_file {type name} {
    global _cgi_userfile
    upvar 1 $name var

    set var $_cgi_userfile($name)
    switch -- $type {
	"-server" {
	    lindex $var 0
	} "-client" {
	    lindex $var 1
	} "-type" {
	    lindex $var 2
	}
    }
}

# deprecated, use cgi_import_file
proc cgi_import_filename {type name} {
    global _cgi_userfile
    upvar 1 $name var

    set var $_cgi_userfile($name)
    if {$type == "-server" || $type == "-local"} {
	# -local is deprecated
	lindex $var 0
    } else {
	lindex $var 1
    }
}

# set the urlencoding
proc cgi_urlencoding {{encoding ""}} {
    global _cgi 
    
    set result [expr {[info exists _cgi(queryencoding)]
                      ? $_cgi(queryencoding)
                      : ""}]

    # check if the encoding is available 
    if {[info tclversion] >= 8.1
        && [lsearch -exact [encoding names] $encoding] != -1 } {	
        set _cgi(queryencoding) $encoding
    }

    return $result
}

##################################################
# button support
##################################################

# not sure about arg handling, do we need to support "name="?
proc cgi_button {value args} {
    cgi_put "<input type=button value=[cgi_dquote_html $value]"
    foreach a $args {
	if {[regexp "^onClick=(.*)" $a dummy str]} {
	    cgi_put " onClick=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

# Derive a button from a link predefined by cgi_link
proc cgi_button_link {args} {
    global _cgi_link

    set tag [lindex $args 0]
    if {[llength $args] == 2} {
	set label [lindex $args end]
    } else {
	set label $_cgi_link($tag,label)
    }
    
    cgi_button $label onClick=$_cgi_link($tag,url)
}

proc cgi_submit_button {{nameval {=Submit Query}} args} {
    regexp "(\[^=]*)=(.*)" $nameval dummy name value
    cgi_put "<input type=submit"
    if {0!=[string compare "" $name]} {
	cgi_put " name=\"$name\""
    }
    cgi_put " value=[cgi_dquote_html $value]"
    foreach a $args {
	if {[regexp "^onClick=(.*)" $a dummy str]} {
	    cgi_put " onClick=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}


proc cgi_reset_button {{value Reset} args} {
    cgi_put "<input type=reset value=[cgi_dquote_html $value]"

    foreach a $args {
	if {[regexp "^onClick=(.*)" $a dummy str]} {
	    cgi_put " onClick=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

proc cgi_radio_button {nameval args} {
    regexp "(\[^=]*)=(.*)" $nameval dummy name value

    cgi_put "<input type=radio name=\"$name\" value=[cgi_dquote_html $value]"

    foreach a $args {
	if {[regexp "^checked_if_equal=(.*)" $a dummy default]} {
	    if {0==[string compare $default $value]} {
		cgi_put " checked"
	    }
	} elseif {[regexp "^checked=(.*)" $a dummy checked]} {
	    # test explicitly to avoid forcing user eval
	    if {$checked} {
		cgi_put " checked"
	    }
	} elseif {[regexp "^onClick=(.*)" $a dummy str]} {
	    cgi_put " onClick=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

proc cgi_image_button {nameval args} {
    regexp "(\[^=]*)=(.*)" $nameval dummy name value
    cgi_put "<input type=image"
    if {0!=[string compare "" $name]} {
	cgi_put " name=\"$name\""
    }
    cgi_put " src=\"$value\""
    foreach a $args {
	if {[regexp "^onClick=(.*)" $a dummy str]} {
	    cgi_put " onClick=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

# map/area implement client-side image maps
proc cgi_map {name cmd} {
    cgi_put "<map name=\"$name\">"
    _cgi_close_proc_push "cgi_put </map>"

    uplevel 1 $cmd
    _cgi_close_proc
}

proc cgi_area {args} {
    cgi_put "<area"
    foreach a $args {
	if {[regexp "^(coords|shape|href|target|onMouseOut|alt)=(.*)" $a dummy attr str]} {
	    cgi_put " $attr=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

##################################################
# checkbox support
##################################################

proc cgi_checkbox {nameval args} {
    regexp "(\[^=]*)(=?)(.*)" $nameval dummy name q value
    cgi_put "<input type=checkbox name=\"$name\""

    if {0!=[string compare "" $value]} {
	cgi_put " value=[cgi_dquote_html $value]"
    }

    foreach a $args {
	if {[regexp "^checked_if_equal=(.*)" $a dummy default]} {
	    if {0==[string compare $default $value]} {
		cgi_put " checked"
	    }
	} elseif {[regexp "^checked=(.*)" $a dummy checked]} {
	    # test explicitly to avoid forcing user eval
	    if {$checked} {
		cgi_put " checked"
	    }
	} elseif {[regexp "^onClick=(.*)" $a dummy str]} {
	    cgi_put " onClick=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

##################################################
# textentry support
##################################################

proc cgi_text {nameval args} {
    regexp "(\[^=]*)(=?)(.*)" $nameval dummy name q value

    cgi_put "<input name=\"$name\""

    if {$q != "="} {
	set value [uplevel 1 set [list $name]]
    }
    cgi_put " value=[cgi_dquote_html $value]"

    foreach a $args {
	if {[regexp "^on(Select|Focus|Blur|Change)=(.*)" $a dummy event str]} {
	    cgi_put " on$event=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put "/>"
}

##################################################
# textarea support
##################################################

proc cgi_textarea {nameval args} {
    regexp "(\[^=]*)(=?)(.*)" $nameval dummy name q value

    cgi_put "<textarea name=\"$name\""
    foreach a $args {
	if {[regexp "^on(Select|Focus|Blur|Change)=(.*)" $a dummy event str]} {
	    cgi_put " on$event=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_put ">"

    if {$q != "="} {
	set value [uplevel 1 set [list $name]]
    }
    cgi_put "[cgi_quote_html $value]</textarea>"
}

##################################################
# file upload support
##################################################

# for this to work, pass enctype=multipart/form-data to cgi_form
proc cgi_file_button {name args} {
    global _cgi
    if {[info exists _cgi(formtype)] && ("multipart/form-data" != $_cgi(form,enctype))} {
	error "cgi_file_button requires that cgi_form have the argument enctype=multipart/form-data"
    }
	cgi_put "<script>"
    cgi_put "function update(e) {fileName.textContent = file.files\[0\].name;}"
    cgi_put "const file = document.querySelector('#file'), fileName = document.querySelector('.file-name');"
    cgi_put "file.addEventListener('change', update);"
	cgi_put "</script>"
    cgi_put "<label class='file-label' for='file'><div class='file-button'>\${lblChooseFile}&hellip;</div></label><p class='file-name'>\${lblNoFileSelected}</p><input type=file id='file' name=\"$name\"[_cgi_list_to_string $args]/>"
}

# establish a per-file limit for uploads

proc cgi_file_limit {files chars} {
    global _cgi

    set _cgi(file,filelimit) $files
    set _cgi(file,charlimit) $chars
}

##################################################
# select support
##################################################

proc cgi_select {name args} {
    cgi_put "<select name=\"$name\""
    _cgi_close_proc_push "cgi_put </select>"
    foreach a [lrange $args 0 [expr [llength $args]-2]] {
	if {[regexp "^on(Focus|Blur|Change)=(.*)" $a dummy event str]} {
	    cgi_put " on$event=\"$str\""
	} else {
	    if {0==[string compare multiple $a]} {
		;# sanity check
		if {![regexp "List$" $name]} {
		    cgi_puts ">" ;# prevent error from being absorbed
		    error "When selecting multiple options, select variable \
			    must end in \"List\" to allow the value to be \
			    recognized as a list when it is processed later."
		}
	    }
	    cgi_put " $a"
	}
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

proc cgi_option {o args} {
    cgi_put "<option"
    set value $o
    set selected 0
    foreach a $args {
	if {[regexp "^selected_if_equal=(.*)" $a dummy selected_if_equal]} {
	} elseif {[regexp "^value=(.*)" $a dummy value]} {
	    cgi_put " value=[cgi_dquote_html $value]"
	} else {
	    cgi_put " $a"
	}
    }
    if {[info exists selected_if_equal]} {
	if {0 == [string compare $selected_if_equal $value]} {
	    cgi_put " selected"
	}
    }
    cgi_puts ">[cgi_quote_html $o]</option>"
}

##################################################
# plug-in support
##################################################

proc cgi_embed {src wh args} {
    regexp (.*)x(.*) $wh dummy width height
    cgi_put "<embed src=[cgi_dquote_html $src] width=\"$width\" height=\"$height\""
    foreach a $args {
	if {[regexp "^palette=(.*)" $a dummy str]} {
	    cgi_put " palette=\"$str\""
	} elseif {[regexp -- "-quote" $a]} {
	    set quote 1
	} else {
	    if {[info exists quote]} {
		regexp "(\[^=]*)=(.*)" $a dummy var val
		cgi_put " var=[cgi_dquote_html $var]"
	    } else {
		cgi_put " $a"
	    }
	}
    }
    cgi_put "/>"
}

##################################################
# mail support
##################################################

# mail to/from the service itself
proc cgi_mail_addr {args} {
    global _cgi

    if {[llength $args]} {
	set _cgi(email) [lindex $args 0]
    }
    return $_cgi(email)
}

proc cgi_mail_start {to} {
    global _cgi

    set _cgi(mailfile) [file join $_cgi(tmpdir) cgimail.[pid]]
    set _cgi(mailfid) [open $_cgi(mailfile) w+]
    set _cgi(mailto) $to

    # mail is actually sent by "nobody".  To force bounce messages
    # back to us, override the default return-path.
    cgi_mail_add "Return-Path: <$_cgi(email)>"
    cgi_mail_add "From: [cgi_name] <$_cgi(email)>"
    cgi_mail_add "To: $to"
}

# add another line to outgoing mail
# if no arg, add a blank line
proc cgi_mail_add {{arg {}}} {
    global _cgi

    puts $_cgi(mailfid) $arg
}	

# end the outgoing mail and send it
proc cgi_mail_end {} {
    global _cgi

    flush $_cgi(mailfid)

    if {[file executable /usr/lib/sendmail]} {
	exec /usr/lib/sendmail -t -odb < $_cgi(mailfile)
	# Explanation:
	# -t   means: pick up recipient from body
	# -odb means: deliver in background
	# note: bogus local address cause sendmail to fail immediately
    } elseif {[file executable /usr/sbin/sendmail]} {
	exec /usr/sbin/sendmail -t -odb < $_cgi(mailfile)
	# sendmail is in /usr/sbin on some BSD4.4-derived systems.
    } else {
	# fallback for sites without sendmail

	if {0==[info exists _cgi(mail_relay)]} {
	    regexp "@(.*)" $_cgi(mailto) dummy _cgi(mail_relay)
	}

	set s [socket $_cgi(mail_relay) 25]
	gets $s answer
	if {[lindex $answer 0] != 220} {error $answer} 

	puts $s "HELO [info host]";flush $s
	gets $s answer
	if {[lindex $answer 0] != 250} {error $answer}  

	puts $s "MAIL FROM:<$_cgi(email)>";flush $s
	gets $s answer
	if {[lindex $answer 0] != 250} {error $answer}  

	puts $s "RCPT TO:<$_cgi(mailto)>";flush $s
	gets $s answer
	if {[lindex $answer 0] != 250} {error $answer}  

	puts $s DATA;flush $s
	gets $s answer
	if {[lindex $answer 0] != 354} {error $answer}  

	seek $_cgi(mailfid) 0 start
	puts $s [read $_cgi(mailfid)];flush $s
	puts $s .;flush $s
	gets $s answer
	if {[lindex $answer 0] != 250} {error $answer}  

	close $s
    }
    close $_cgi(mailfid)
    file delete -force $_cgi(mailfile)
}

proc cgi_mail_relay {host} {
    global _cgi

    set _cgi(mail_relay) $host
}

##################################################
# cookie support
##################################################

# calls to cookie_set look like this:
#   cgi_cookie_set user=don domain=nist.gov expires=never
#   cgi_cookie_set user=don domain=nist.gov expires=now
#   cgi_cookie_set user=don domain=nist.gov expires=...actual date...

proc cgi_cookie_set {nameval args} {
    global _cgi

    if {![info exists _cgi(http_head_in_progress)]} {
	error "Cookies must be set from within cgi_http_head."
    }
    cgi_puts -nonewline "Set-Cookie: [cgi_cookie_encode $nameval];"

    foreach a $args {
	if {[regexp "^expires=(.*)" $a dummy expiration]} {
	    if {0==[string compare $expiration "never"]} {
		set expiration "Friday, 11-Jan-2038 23:59:59 GMT"
	    } elseif {0==[string compare $expiration "now"]} {
		set expiration "Friday, 31-Dec-1990 23:59:59 GMT"
	    }
	    cgi_puts -nonewline " expires=$expiration;"
	} elseif {[regexp "^(domain|path)=(.*)" $a dummy attr str]} {
	    cgi_puts -nonewline " $attr=[cgi_cookie_encode $str];"
	} elseif {[regexp "^secure$" $a]} {
	    cgi_puts -nonewline " secure;"
	}
    }
    cgi_puts ""
}

# return list of cookies available for import
proc cgi_cookie_list {} {
    global _cgi_cookie

    array names _cgi_cookie
}

proc cgi_cookie_get {args} {
    global _cgi_cookie

    set all 0

    set flag [lindex $args 0]
    if {$flag == "-all"} {
	set args [lrange $args 1 end]
	set all 1
    }
    set name [lindex $args 0]

    if {$all} {
	global _cgi_cookie_shadowed

	if {[info exists _cgi_cookie_shadowed($name)]} {
	    return [concat $_cgi_cookie($name) $_cgi_cookie_shadowed($name)]
	} else {
	    return [concat $_cgi_cookie($name)]
	}
    }
    return $_cgi_cookie($name)
}

proc cgi_cookie_encode {in} {
    regsub -all " " $in "+" in
    regsub -all "%" $in "%25" in   ;# must preceed other subs that produce %
    regsub -all ";" $in "%3B" in
    regsub -all "," $in "%2C" in
    regsub -all "\n" $in "%0D%0A" in
    return $in
}

##################################################
# table support
##################################################

proc cgi_table {args} {
    cgi_put "<table"
    _cgi_close_proc_push "cgi_put </table>"

    if {[llength $args]} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

proc cgi_caption {args} {
    cgi_put "<caption"
    _cgi_close_proc_push "cgi_put </caption>"

    if {[llength $args]} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

proc cgi_table_row {args} {
    cgi_put "<tr"
    _cgi_close_proc_push "cgi_put </tr>"
    if {[llength $args]} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

# like table_row but without eval
proc cgi_tr {args} {
    cgi_put <tr
    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    foreach i [lindex $args end] {
	cgi_td $i
    }
    cgi_put </tr>
}

proc cgi_table_head {args} {
    cgi_put "<th"
    _cgi_close_proc_push "cgi_put </th>"

    if {[llength $args]} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

# like table_head but without eval
proc cgi_th {args} {
    cgi_put "<th"

    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">[lindex $args end]</th>"
}

proc cgi_table_data {args} {
    cgi_put "<td"
    _cgi_close_proc_push "cgi_put </td>"

    if {[llength $args]} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

# like table_data but without eval
proc cgi_td {args} {
    cgi_put "<td"

    if {[llength $args] > 1} {
	cgi_put "[_cgi_lrange $args 0 [expr [llength $args]-2]]"
    }
    cgi_put ">[lindex $args end]</td>"
}

##################################################
# stylesheets - not yet documented
##################################################

proc cgi_stylesheet {href} {
    puts "<link rel=stylesheet href=\"$href\" type=\"text/css\"/>"
}

proc cgi_span {args} {
    set buf "<span"
    foreach a [lrange $args 0 [expr [llength $args]-2]] {
	if {[regexp "style=(.*)" $a dummy str]} {
	    append buf " style=\"$str\""
	} elseif {[regexp "class=(.*)" $a dummy str]} {
	    append buf " class=\"$str\""
	} else {
	    append buf " $a"
	}
    }
    return "$buf>[lindex $args end]</span>"
}

##################################################
# frames
##################################################

proc cgi_frameset {args} {
    cgi_head ;# force it out, just in case none

    cgi_put "<frameset"
    _cgi_close_proc_push "cgi_puts </frameset>"

    foreach a [lrange $args 0 [expr [llength $args]-2]] {
	if {[regexp "^(rows|cols|onUnload|onLoad|onBlur)=(.*)" $a dummy attr str]} {
	    cgi_put " $attr=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_puts ">"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

proc cgi_frame {namesrc args} {
    cgi_put "<frame"

    regexp "(\[^=]*)(=?)(.*)" $namesrc dummy name q src

    if {$name != ""} {
	cgi_put " name=\"$name\""
    }

    if {$src != ""} {
	cgi_put " src=\"$src\""
    }

    foreach a $args {
	if {[regexp "^(marginwidth|marginheight|scrolling|onFocus)=(.*)" $a dummy attr str]} {
	    cgi_put " $attr=\"$str\""
	} else {
	    cgi_put " $a"
	}
    }
    cgi_puts "/>"
}

proc cgi_noframes {args} {
    cgi_puts "<noframes>"
    _cgi_close_proc_push "cgi_puts </noframes>"
    uplevel 1 [lindex $args end]
    _cgi_close_proc
}

##################################################
# admin support
##################################################

# mail address of the administrator
proc cgi_admin_mail_addr {args} {
    global _cgi

    if {[llength $args]} {
	set _cgi(admin_email) [lindex $args 0]
    }
    return $_cgi(admin_email)
}

##################################################
# if possible, make each cmd available without cgi_ prefix
##################################################

if {[info tclversion] >= 7.5} {
    foreach _cgi(old) [info procs cgi_*] {
	regexp "^cgi_(.*)" $_cgi(old) _cgi(dummy) _cgi(new)
	if {[llength [info commands $_cgi(new)]]} continue
	interp alias {} $_cgi(new) {} $_cgi(old)
    }
} else {
    foreach _cgi(old) [info procs cgi_*] {
	regexp "^cgi_(.*)" $_cgi(old) _cgi(dummy) _cgi(new)
	if {[llength [info commands $_cgi(new)]]} continue
	proc $_cgi(new) {args} "uplevel 1 $_cgi(old) \$args"
    }
}

##################################################
# internal utilities
##################################################

# undo Tcl's quoting due to list protection
# This leaves a space at the beginning if the string is non-null
# but this is always desirable in the HTML context in which it is called
# and the resulting HTML looks more readable.
# (It makes the Tcl callers a little less readable - however, there aren't
# more than a handful and they're all right here, so we'll live with it.)
proc _cgi_list_to_string {list} {
    set string ""
    foreach l $list {
	append string " $l"
    }
    # remove first space if possible
    # regexp "^ ?(.*)" $string dummy string
    return $string
}

# do lrange but return as string
# needed for stuff like: cgi_puts "[_cgi_lrange $args ...]
# Like _cgi_list_to_string, also returns string with initial blank if non-null
proc _cgi_lrange {list i1 i2} {
    _cgi_list_to_string [lrange $list $i1 $i2]
}

##################################################
# user-defined procedures
##################################################

# User-defined procedure called immediately after <body>
# Good mechanism for controlling things such as if all of your pages
# start with the same graphic or other boilerplate.
proc app_body_start {} {}

# User-defined procedure called just before </body>
# Good place to generate signature lines, last-updated-by, etc.
proc app_body_end {} {}

proc cgi_puts {args} {
    eval puts $args
}

# User-defined procedure to generate DOCTYPE declaration
proc cgi_doctype {} {
    # AG, eQ-3, 29.01.2013
    puts "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"  \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
}

##################################################
# do some initialization
##################################################

# cgi_init initializes to a known state.

proc cgi_init {} {
    global _cgi
    unset _cgi

    # set explicitly for speed
    set _cgi(debug) -off
    set _cgi(buffer_nl) "\n"

    cgi_name ""
    cgi_root ""
    cgi_body_args ""
    cgi_file_limit 10 100000000

    if {[info tclversion] >= 8.1} {
	# set initial urlencoding
	if { [lsearch -exact [encoding names] "utf-8"] != -1} {
	    cgi_urlencoding "utf-8"
	} else {
	    cgi_urlencoding [encoding system]
	}
    }

    # email addr of person responsible for this service
    cgi_admin_mail_addr "root"	;# you should override this!

    # most services won't have an actual email addr
    cgi_mail_addr "CGI script - do not reply"
}
cgi_init

# deduce tmp directory
switch $tcl_platform(platform) {
    unix {
	set _cgi(tmpdir) /usr/local/tmp
    } macintosh {
	set _cgi(tmpdir) [pwd]
    } default {
	set _cgi(tmpdir) [pwd]
	catch {set _cgi(tmpdir) $env(TMP)}
	catch {set _cgi(tmpdir) $env(TEMP)}
    }
}

# regexp for matching attr=val
set _cgi(attr,regexp) "^(\[^=]*)=(\[^\"].*)"

package provide cgi 1.10.0
