/*******************************************************************************
 * tclrega.cpp
 * \brief Zugriff von tcl auf das ISE ReGa System
 ******************************************************************************/

/*############################################################################*/
/*# Header                                                                   #*/
/*############################################################################*/

#include <tcl.h>

#ifndef CONST84
#define CONST84
#endif

#include <algorithm>
#include <string>
#include <string.h>
#include <unistd.h>
#include <cstdio>
#include <iostream>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <xmlParser.h>
#include <fstream>

/*############################################################################*/
/*# Definitionen                                                             #*/
/*############################################################################*/

#define TCLREGA_VERSION "1.4"

/*############################################################################*/
/*# Variablen                                                                #*/
/*############################################################################*/

static Tcl_HashTable hashTable;
static Tcl_Encoding iso8859_encoding = NULL;

//static std::string DEFAULT_URL("http://127.0.0.1:8181/tclrega.exe");

static const char* USAGE =  "usage: rega command\n"
                        "\trega_script script\n"
                        "\trega_url url (url defaults to http://127.0.0.1:8183)\n"
                        "\trega_sid sid"
                        "\trega_post url payload";
                        
/* - - - wernerf/ - - - */
//static std::string REGA_URL_PREFIX("http://127.0.0.1:8181");
/* - - - wernerf - - - */
                        

struct sockaddr_in dest_addr;
static std::string uri;
static std::string sid;

// - - - niclaus - - -
static std::string portRega("8183");
static volatile bool portRegaRead;



/*############################################################################*/
/*# Interne Hilfsfunktionen                                                  #*/
/*############################################################################*/

std::string trim(const std::string& str)
{
    std::string::size_type first = str.find_first_not_of(' ');
    if (std::string::npos == first)
    {
        return str;
    }
    std::string::size_type last = str.find_last_not_of(' ');
    return str.substr(first, (last - first + 1));
}

std::string readPortFromFile(const char* filename) {
    std::ifstream ifs;
    ifs.open(filename, std::ifstream::in);
    char* buffer = new char[256];
    std::string base("01234567890");
    while(ifs.good()) {
        ifs.getline(buffer, 256);
        std::string port(buffer);
        port = trim(port);
        if(!port.empty() && (port.find_first_not_of(base) == std::string::npos)) {
            delete[] buffer;
            return port;
        }
    }
    delete[] buffer;
    return std::string("");
}

void initPorts() {
    if(!portRegaRead) {
        std::string port(readPortFromFile("/etc/rega_http.port"));
        if(!port.empty()) {
            portRega = port;
        }
        portRegaRead = true;
    }
}
// - - - niclaus - - -

extern "C" {

/*############################################################################*/
/*# Prototypen                                                               #*/
/*############################################################################*/

static int Tclrega_Cmd (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[]);
static int Tclrega_Script (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[]);
static int Tclrega_URL (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[]);
static int Tclrega_SID (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[]);
static int ParseURL(const std::string& url);

/* - - - wernerf - - - */
static int Tclrega_post(ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[]);
static int TclError(Tcl_Interp *interp, const char *msg);
/* - - - wernerf - - - */

/*############################################################################*/
/*# Funktionen                                                               #*/
/*############################################################################*/

static void Tclrega_Exit (ClientData);

int Tclrega_Init (Tcl_Interp* interp) {
	Tcl_InitHashTable(&hashTable, TCL_STRING_KEYS);
	Tcl_CreateCommand(interp, "rega_script", Tclrega_Script, (ClientData) NULL, NULL);
	Tcl_CreateCommand(interp, "rega", Tclrega_Cmd, (ClientData) NULL, NULL);
	Tcl_CreateCommand(interp, "rega_url", Tclrega_URL, (ClientData) NULL, NULL);
	Tcl_CreateCommand(interp, "rega_sid", Tclrega_SID, (ClientData) NULL, NULL);
	Tcl_PkgProvide(interp, "rega", TCLREGA_VERSION);
  /* - - - wernerf - - - */
	Tcl_CreateCommand(interp, "rega_post", Tclrega_post, (ClientData) NULL, NULL);
  /* - - - wernerf - - - */
	Tcl_SetVar(interp, "rega_version", TCLREGA_VERSION, TCL_GLOBAL_ONLY);

	// get iso8859-1 encoding to convert all stuff to latin1
	// because rega can only handle iso-8859-1
	iso8859_encoding = Tcl_GetEncoding(interp, "iso8859-1");

	// create an exit handler to clean up afterwards
	Tcl_CreateExitHandler( Tclrega_Exit, 0 );

    initPorts();
    const std::string DEFAULT_URL = ("http://127.0.0.1:"+portRega+"/tclrega.exe");
    ParseURL(DEFAULT_URL);
	return TCL_OK;
}

static void Tclrega_Exit (ClientData)
{
	Tcl_DeleteExitHandler( Tclrega_Exit, 0 );
	if(iso8859_encoding != NULL)
	{
	  Tcl_FreeEncoding(iso8859_encoding);
	  iso8859_encoding = NULL;
	}
}

static int ParseURL(const std::string& url)
{
	std::string::size_type left, right;
    std::string host;
    unsigned int port=80;
	left=0;
	right=url.find("://", left);
	if(right != std::string::npos){
//		protocol=url.substr(left, right-left);
		left=right+3;
	}
	right=url.find_first_of(":", left);
	host=url.substr(left, right-left);
	if(right != std::string::npos){
        right++;
		left=right;
		if(url[left]!='/'){
			right=url.find('/', left);
			port=atoi(url.substr(left, right-left).c_str());
        }
	}
	if(right != std::string::npos){
		left=right;
		uri=url.substr(left);
	}else{
        uri="/tclrega.exe";
    }
    dest_addr.sin_family=AF_INET;
    dest_addr.sin_port=htons(port);
    dest_addr.sin_addr.s_addr=inet_addr(host.c_str());
    memset(&(dest_addr.sin_zero), 0, 8);
	return TCL_OK;
}

static int SendRequest(Tcl_Interp * interp, const std::string& request, std::string* response)
{
    static char buffer[1024];
    sprintf(buffer, "%u", static_cast<uint32_t>(request.size()));
    std::string http_request="POST "+uri+sid+" HTTP/1.0\x0d\x0a""Content-Length: "+buffer+"\x0d\x0a\x0d\x0a"+request;//+"\x0d\x0a";
    int fd=socket(PF_INET, SOCK_STREAM, 0);
    if(fd<0){
        Tcl_AppendResult(interp, "Error creating socket", NULL);
        return fd;
    }
    if(connect(fd, (struct sockaddr*)&dest_addr, sizeof(struct sockaddr))<0){
        Tcl_AppendResult(interp, "Error connecting to peer", NULL);
        close(fd);
        return -1;
    }
    unsigned int index=0;
    while(index<http_request.size()){
        int count=send(fd, http_request.c_str()+index, http_request.size()-index, 0);
        if(count<0){
            Tcl_AppendResult(interp, "Error on send", NULL);
            close(fd);
            return -1;
        }
        index+=count;
    }
    std::string http_response_head;
    std::string http_response_body;
    int count;
    int content_length=-1;
    while((count=recv(fd, buffer, sizeof(buffer), 0))){
        if(content_length<0){
            http_response_head.append(buffer, count);
            std::string::size_type pos=http_response_head.find("\x0d\x0a\x0d\x0a");
            if(pos!=std::string::npos){
                http_response_body=http_response_head.substr(pos+4);
                http_response_head.erase(pos);
                std::transform(http_response_head.begin(), http_response_head.end(), http_response_head.begin(), ::tolower);
                pos=http_response_head.find("content-length:");
                if(pos==std::string::npos){
                    Tcl_AppendResult(interp, "Content-Length Field not found", NULL);
                    close(fd);
                    return -1;
                }
                content_length=atoi(http_response_head.c_str()+pos+15);
            }
        }else{
            http_response_body.append(buffer, count);
        }
        if(content_length<=(int)http_response_body.size())break;
    }
    close(fd);
    if(content_length<0 || content_length>(int)http_response_body.size()){
        Tcl_AppendResult(interp, "Content size mismatch \nheader:\n", http_response_head.c_str(), "\nbody:\n", http_response_body.c_str(), NULL);
        return -1;
    }
    *response=http_response_body.substr(0, content_length);
    return 0;
}

static int Tclrega_Cmd (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[])
{
	if(argc < 2) {
		Tcl_AppendResult(interp, USAGE, NULL);
		return TCL_ERROR;
	}
    std::string content;
    std::string response;
    static char buffer[32];
    for(int i=1;i<argc;i++){
        sprintf(buffer, "var __tcl_result_%d=", i);
        content+=buffer;
        if(iso8859_encoding != NULL) {
          Tcl_DString dst;
          content += Tcl_UtfToExternalDString(iso8859_encoding, argv[i], -1, &dst);
          Tcl_DStringFree(&dst);
        } else {
          content+=argv[i];
        }
        if(content[content.size()-1]!=';')content+=";";
    }
    if(SendRequest(interp, content, &response)<0){
		return TCL_ERROR;
    }
//    XMLNode node=XMLNode::parseString(response.c_str(), "xml");
//    if(node.isEmpty()){
//        Tcl_AppendResult(interp, "Error parsing response ", response.c_str(), NULL);
//		return TCL_ERROR;
//    }
    
    for(int i=1;i<argc;i++){
        sprintf(buffer, "<__tcl_result_%d>", i);
        std::string::size_type left=response.find(buffer);
        if(left==std::string::npos){
            Tcl_AppendResult(interp, "Error parsing response from ", content.c_str(), " : ", response.c_str(), " missing tag ", buffer, NULL);
		    return TCL_ERROR;
        }
        left+=strlen(buffer);
        sprintf(buffer, "</__tcl_result_%d>", i);
        std::string::size_type right=response.find(buffer, left);
        if(right==std::string::npos){
            Tcl_AppendResult(interp, "Error parsing response from ", content.c_str(), " : ", response.c_str(), " missing tag ", buffer, NULL);
		    return TCL_ERROR;
        }
        const char *tcl_result = NULL;
        Tcl_DString dst;
        if(iso8859_encoding != NULL) {
          tcl_result = Tcl_ExternalToUtfDString(iso8859_encoding, response.substr(left, right-left).c_str(), -1, &dst);
        } else {
          tcl_result = response.substr(left, right-left).c_str();
        }
        if(argc==2){
            Tcl_AppendResult(interp, tcl_result, NULL);
        }else{
            Tcl_AppendElement(interp, tcl_result);
        }
        if(iso8859_encoding != NULL)
          Tcl_DStringFree(&dst);
    }
    return TCL_OK;
}

static int Tclrega_Script (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[])
{
	if(argc < 2) {
		Tcl_AppendResult(interp, USAGE, NULL);
		return TCL_ERROR;
	}
    std::string content;
    std::string response;
    for(int i=1;i<argc;i++){
        if(iso8859_encoding != NULL) {
          Tcl_DString dst;
          content += Tcl_UtfToExternalDString(iso8859_encoding, argv[i], -1, &dst);
          Tcl_DStringFree(&dst);
        } else {
          content+=argv[i];
        }
        content+="\0d\0a";
    }
    if(SendRequest(interp, content, &response)<0){
		return TCL_ERROR;
    }
    std::string::size_type xml_start=response.find("<xml><exec>");
    if(xml_start==std::string::npos){
        Tcl_AppendResult(interp, "Error parsing response ", response.c_str(), NULL);
		return TCL_ERROR;
    }
    Tcl_AppendElement(interp, const_cast<char*>("STDOUT"));
    if(iso8859_encoding != NULL) {
      Tcl_DString dst;
      const char* cstr;
      cstr = Tcl_ExternalToUtfDString(iso8859_encoding, response.substr(0, xml_start).c_str(), -1, &dst);
      Tcl_AppendElement(interp, cstr);
      Tcl_DStringFree(&dst);
    } else {
      Tcl_AppendElement(interp, const_cast<char*>(response.substr(0, xml_start).c_str()));
    }
    
    XMLNode node=XMLNode::parseString(response.substr(xml_start).c_str(), "xml");
    if(node.isEmpty()){
        Tcl_AppendResult(interp, "Error parsing response ", response.c_str(), NULL);
		return TCL_ERROR;
    }
    int i=1;
    XMLNode var_node=node.getChildNode(i);
    while(!var_node.isEmpty()){
        i++;
        if(iso8859_encoding != NULL) {
          Tcl_DString dst;
          const char* cstr;
          cstr = Tcl_ExternalToUtfDString(iso8859_encoding, var_node.getName(), -1, &dst);
          Tcl_AppendElement(interp, cstr);
          Tcl_DStringFree(&dst);
          cstr = Tcl_ExternalToUtfDString(iso8859_encoding, var_node.getText(), -1, &dst);
          Tcl_AppendElement(interp, cstr);
          Tcl_DStringFree(&dst);
        } else {
          Tcl_AppendElement(interp, const_cast<char*>(var_node.getName()));
          Tcl_AppendElement(interp, const_cast<char*>(var_node.getText()));
        }
        var_node=node.getChildNode(i);
    }
    return TCL_OK;
}


/* - - - wernerf - - -*/

/*******************************************************************************
 * \fn static int Tclrega_post(ClientData, Tcl_Interp *interp, int argc, 
 *       const char* argv[]
 * \brief Führt einen HTTP Post aus.
 *
 * Sendet eine HTTP Anfrage an eine URL auf dem ISE ReGa Webserver mittels
 * der HTTP-Methode "POST".
 *
 * \param ClientData ?
 * \param interp     ?
 * \param arc        Anzahl der Parameter in argv
 * \param argv       Parameter
 *                   argv[1] : URL auf dem ISE ReGa Server
 *                   argv[>1]: Daten, die im Payload der Anfrage gesendet 
 *                             werden. 
 *
 * \return TCL_OK   : Die Anfrage wurde erfolgreich ausgeführt
 * \return TCL_ERROR: Es sind Fehler aufgetreten
 ******************************************************************************/
static int Tclrega_post (ClientData, Tcl_Interp * interp, int argc, 
  CONST84 char* argv[])
{
  static char ERROR_MSG[] = "Error while sending the request.";
  std::string url;
  std::string content;
  std::string response;
    
  if (2 >= argc) { return TclError(interp, USAGE); }
  
  initPorts();
  const std::string REGA_URL_PREFIX("http://127.0.0.1:"+portRega);
  url  = REGA_URL_PREFIX;
  if(iso8859_encoding != NULL) {
    Tcl_DString dst;
    url += Tcl_UtfToExternalDString(iso8859_encoding, argv[1], -1, &dst);
    Tcl_DStringFree(&dst);
  } else {
    url += argv[1];
  }
  for(int i = 2; i < argc; i++)
  {
    if(iso8859_encoding != NULL) {
      Tcl_DString dst;
      content += Tcl_UtfToExternalDString(iso8859_encoding, argv[i], -1, &dst);
      Tcl_DStringFree(&dst);
    } else {
      content += argv[i];
    }
    content += "\r\n";
  }
  
  ParseURL(url);
  if (0 > SendRequest(interp, content, &response)) 
  { 
    return TclError(interp, ERROR_MSG); 
  }
  if(iso8859_encoding != NULL) {
    Tcl_DString dst;
    const char *cstr;
    cstr = Tcl_ExternalToUtfDString(iso8859_encoding, response.c_str(), -1, &dst);
    Tcl_AppendResult(interp, cstr, NULL);
    Tcl_DStringFree(&dst);
  } else {
    Tcl_AppendResult(interp, response.c_str(), NULL);
  }
  
  initPorts();
  const std::string DEFAULT_URL = "http://127.0.0.1:"+portRega+ "/tclrega.exe";
  ParseURL(DEFAULT_URL);
  
  return TCL_OK;
}

/*******************************************************************************
 * \fn static int TclError(Tcp_Interp *interp, char *msg)
 * \brief Setzt eine tcl-Fehlerausgabe und gibt TCL_ERROR zurück.
 *
 * \param interp ?
 * \param msg    Fehlermeldung
 *
 * \return TCL_ERROR
 ******************************************************************************/
static int TclError(Tcl_Interp *interp, const char* msg)
{
  Tcl_AppendResult(interp, msg, NULL);
  return TCL_ERROR;
}

/* - - - wernerf - - -*/


static int Tclrega_URL (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[])
{
	if(argc < 2) {
		Tcl_AppendResult(interp, USAGE, NULL);
		return TCL_ERROR;
	}
    ParseURL(argv[1]);
	return TCL_OK;
}

static int Tclrega_SID (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[])
{
	if(argc > 2) {
		Tcl_AppendResult(interp, USAGE, NULL);
		return TCL_ERROR;
	}
    if(argc==2){
        if(strlen(argv[1])){
            sid="?sid=";
            sid+=argv[1];
        }else{
            sid="";
        }
    }
    if(sid.length()>=5){
        Tcl_AppendResult(interp, const_cast<char*>(sid.substr(5).c_str()), NULL);
    }else{
        Tcl_AppendResult(interp, const_cast<char*>(""), NULL);
    }
	return TCL_OK;
}

}/* extern "C" */
