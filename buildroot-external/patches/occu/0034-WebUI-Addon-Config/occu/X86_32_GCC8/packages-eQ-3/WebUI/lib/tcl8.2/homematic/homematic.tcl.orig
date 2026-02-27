
namespace eval ::HomeMatic {
	namespace export Addon Script Session Util GetSerialNumber
	
	if { ![info exists rega_script] } then {
		load tclrega.so
	}
	
	if { ![info exists xmlrpc] } then  {
		load tclrpc.so
	}
	
}

proc ::HomeMatic::GetSerialNumber { } {
  set content [::HomeMatic::Util::LoadFile "/etc/config/ids"]
  
  if { [regexp -line {SerialNumber=(.*)} $content dummy serial] } {
    return $serial
  } else {
    return INVALID
  }
}
namespace eval ::HomeMatic::Util {
  namespace export LoadFile SaveFile
}

proc ::HomeMatic::Util::LoadFile { filename } {
  set content {}

  catch {
    set fd [open $filename r]
    catch { set content [read $fd] }
    close $fd
  }
  
  return $content
}

proc ::HomeMatic::Util::SaveFile { filename content } {
  set result 0
  
  catch {
    set fd [open $filename w]
    catch { puts -nonewline $fd $content }
    close $fd
  }
  
  return $result
}




namespace eval ::HomeMatic::Session {
	namespace export LOGIN_URL RENEW_URL login logout renew
}

set ::HomeMatic::Session::LOGIN_URL "127.0.0.1/login.htm"
set ::HomeMatic::Session::RENEW_URL "127.0.0.1/pages/index.htm"

proc ::HomeMatic::Session::login { username password } {
	error "not implemented"
}

proc ::HomeMatic::Session::logout { sessionId } {
	error "not implemented"
}

proc ::HomeMatic::Session::renew { sessionId } {
	error "not implemented"
}

proc ::HomeMatic::Session::isValid { sessionId } {
}


namespace eval ::HomeMatic::Script {
	namespace export eval
}

proc ::HomeMatic::Script::eval { script } {
	error "not implemented"
}
namespace eval ::HomeMatic::Addon {
  global ::HomeMatic::Addon::_CONFIG_FILE_
  
  namespace export GetAll AddConfigPage
  
  set ::HomeMatic::Addon::_CONFIG_FILE_ "/etc/config/hm_addons.cfg"
}

proc ::HomeMatic::Addon::AddConfigPage { id url name description } {
  global ::HomeMatic::Addon::_CONFIG_FILE_
  set filename $::HomeMatic::Addon::_CONFIG_FILE_
  
  array set addon {}
  set addon(ID) $id
  set addon(CONFIG_URL) $url
  set addon(CONFIG_NAME) $name
  set addon(CONFIG_DESCRIPTION) $description
  
  array set addons [::HomeMatic::Util::LoadFile $filename]
  set addons($id) [array get addon]
  ::HomeMatic::Util::SaveFile $filename [array get addons]
}

proc ::HomeMatic::Addon::GetAll { } {
  global ::HomeMatic::Addon::_CONFIG_FILE_
  set filename $::HomeMatic::Addon::_CONFIG_FILE_

  return [::HomeMatic::Util::LoadFile $filename]
}




package provide HomeMatic 1.0

