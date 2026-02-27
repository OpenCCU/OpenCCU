#include <tcl.h>

#ifndef CONST84
#define CONST84
#endif


#include <string>
#include <cstring>
#include <cstdio>
#include <cstdlib>

#ifndef DLLEXPORT
  #ifdef WIN32
    #define DLLEXPORT __declspec(dllexport)
  #else
    #define DLLEXPORT
  #endif
#endif

#include <iostream>
#include <XmlRpc.h>

using namespace XmlRpc;

#define TCLRPC_VERSION "1.4"

static const char* USAGE = "usage: xmlrpc url methodName ?arg1 ?arg2 ...??";

// Error handler
static class TclrpcErrorHandler : public XmlRpcErrorHandler {
public:

  void error(const char* msg) {
      if(!message.empty())message+="\n";
      message += msg;
  }
  std::string get_message() {
      return message;
  }
  void clear_message() {
      message.clear();
  }
private:
    std::string message;
} g_tclrpcErrorHandler;

static XmlRpcClient* xmlRpcClient = NULL;
static Tcl_Encoding iso8859_encoding = NULL;

extern "C" {

static int Tclrpc_Cmd (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[]);
static void Tclrpc_Exit (ClientData);

int DLLEXPORT Tclrpc_Init (Tcl_Interp* interp) {
	Tcl_CreateCommand(interp, "xmlrpc", Tclrpc_Cmd, (ClientData) NULL, NULL);
	Tcl_PkgProvide(interp, "xmlrpc", TCLRPC_VERSION);
	Tcl_SetVar(interp, "xmlrpc_version", TCLRPC_VERSION, TCL_GLOBAL_ONLY);
	Tcl_CreateExitHandler( Tclrpc_Exit, 0 );
    XmlRpc::XmlRpcErrorHandler::setErrorHandler( &g_tclrpcErrorHandler );

	// get iso8859-1 encoding to convert all stuff to latin1
	// because rega can only handle iso-8859-1
	iso8859_encoding = Tcl_GetEncoding(interp, "iso8859-1");

	return TCL_OK;
}

static void Tclrpc_Exit (ClientData)
{
	Tcl_DeleteExitHandler( Tclrpc_Exit, 0 );
	if(iso8859_encoding != NULL)
	{
	  Tcl_FreeEncoding(iso8859_encoding);
	  iso8859_encoding = NULL;
	}

	if( xmlRpcClient )delete xmlRpcClient;
}

static int StringToXmlRpcValue(Tcl_Interp * interp, XmlRpcValue& v, CONST char* arg)
{
    int listc;
    CONST84 char** listv;
    int retval=Tcl_SplitList(interp, arg, &listc, &listv);
    if(retval != TCL_OK)return retval;

    if(listc == 2){
        const char* type=listv[0];
        CONST84 char* value=listv[1];
        retval=TCL_ERROR;
        if(strstr(type, "string")==type){//string
            v=value;
            retval=TCL_OK;
        }else if(strstr(type, "int")==type || strstr(type, "i4")==type){//int
            int i;
            retval=Tcl_GetInt(interp, value, &i);
            if(retval==TCL_OK)v=i;
        }else if(strstr(type, "dateTime")==type){//time
        }else if(strstr(type, "double")==type){//double
            double d;
            retval=Tcl_GetDouble(interp, value, &d);
            if(retval==TCL_OK)v=d;
        }else if(strstr(type, "bool")==type){//bool
            int b;
            retval=Tcl_GetBoolean(interp, value, &b);
            if(retval==TCL_OK)(bool&)v=(b!=0);
        }else if(strstr(type, "binary")==type){//binary
			XmlRpcValue::BinaryData& binary_data=v;
            const char* s=value;
            char buf[3];
            buf[2]=0;
            while(s[0] && s[1]){
                memcpy(buf, s, 2);
                int byte=strtol(buf, NULL, 16);
                s+=2;
                binary_data.push_back(byte);                
            }
            retval=TCL_OK;
        }else if(strstr(type, "array")==type){//array
            int arrc;
            CONST84 char** arrv=NULL;
            retval=Tcl_SplitList(interp, value, &arrc, &arrv);
            if(retval==TCL_OK){
                for(int i=0;i<arrc;i++){
                    retval=StringToXmlRpcValue(interp, v[i], arrv[i]);
                    if(retval!=TCL_OK)break;
                }
            }
            if(arrv)Tcl_Free((char*)arrv);
        }else if(strstr(type, "struct")==type){//struct
            int structc;
            CONST84 char** structv=NULL;
            retval=Tcl_SplitList(interp, value, &structc, &structv);
            if(retval==TCL_OK){
                v.assertStruct();
                for(int i=0;i<structc;i++){
                    CONST84 char** entryv=NULL;
                    int entryc;
                    retval=Tcl_SplitList(interp, structv[i], &entryc, &entryv);
                    if(retval!=TCL_OK){
                        retval=TCL_ERROR;
                        break;
                    }
                    if(entryc != 2){
                        retval=TCL_ERROR;
                        Tcl_AddErrorInfo(interp, "Every struct member needs two fields (key and value)\n");
                        char buffer[32];
                        snprintf(buffer, sizeof(buffer)-1, "Field count is %d\n", entryc);
                        Tcl_AddErrorInfo(interp, buffer);
                        if(entryv)Tcl_Free((char*)entryv);
                        break;
                    }
                    XmlRpcValue xmlRpcStructVal;
                    retval=StringToXmlRpcValue(interp, xmlRpcStructVal, entryv[1]);
                    if(retval!=TCL_OK){
                        retval=TCL_ERROR;
                        if(entryv)Tcl_Free((char*)entryv);
                        break;
                    }
                    try{
                        v[(const char*)entryv[0]]=xmlRpcStructVal;
                    }catch(...){
                        retval=TCL_ERROR;
                        if(entryv)Tcl_Free((char*)entryv);
                        break;
                    }
                    if(entryv)Tcl_Free((char*)entryv);
                }
            }
            if(structv)Tcl_Free((char*)structv);
        }else{
            v=arg;
            retval=TCL_OK;
        }
    }else{
        v=arg;
        retval=TCL_OK;
    }
    Tcl_Free((char*)listv);
    return retval;
}

static int StringFromXmlRpcValue(Tcl_Interp * interp, XmlRpcValue& v, std::string& sval)
{
    int retval=TCL_ERROR;
    switch (v.getType()) {
      default:           break;
      case XmlRpcValue::TypeBoolean:
        {
            sval=(bool)v?"1":"0"; 
            retval=TCL_OK;
            break;
        }
      case XmlRpcValue::TypeInt:      
        {
            char buffer[32];
            snprintf(buffer, sizeof(buffer)-1, "%d", (int)v);
            sval=buffer;
            retval=TCL_OK;
            break;
        }
      case XmlRpcValue::TypeDouble:   
        {
            char buffer[32];
            snprintf(buffer, sizeof(buffer)-1, "%f", (double)v);
            buffer[sizeof(buffer)-1] = 0;
            sval=buffer;
            retval=TCL_OK;
            break;
        }
      case XmlRpcValue::TypeString:
        {
            sval=(std::string)v; 
            retval=TCL_OK;
            break;
        }
      case XmlRpcValue::TypeDateTime:
        {
          char buffer[20];
          struct tm t = v;
          snprintf(buffer, sizeof(buffer)-1, "%4d%02d%02dT%02d:%02d:%02d", 
            t.tm_year,t.tm_mon,t.tm_mday,t.tm_hour,t.tm_min,t.tm_sec);
          buffer[sizeof(buffer)-1] = 0;
          sval=buffer;
          retval=TCL_OK;
          break;
        }
      case XmlRpcValue::TypeBase64:
        {
          Tcl_AddErrorInfo(interp, "Returning binary data is not supported at the moment\n");
          break;
        }
      case XmlRpcValue::TypeArray:
        {
          int s = v.size();
          char** valp=new char*[s];
          memset(valp, 0, s * sizeof(char*));
          retval=TCL_OK;
          for (int i=0; i<s; ++i)
          {
            std::string curval;
            retval=StringFromXmlRpcValue(interp, v[i], curval);
            if(retval!=TCL_OK)break;
            valp[i]=new char[curval.length()+1];
            strcpy(valp[i], curval.c_str());
          }
          if(retval==TCL_OK){
              char* tcl_str=Tcl_Merge(s, valp);
              if(!tcl_str){
                  retval=TCL_ERROR;
              }else{
                  sval=tcl_str;
                  Tcl_Free(tcl_str);
              }
          }
          for (int i=0; i<s; ++i)
          {
              if(valp[i])delete[] valp[i];
          }
          delete[] valp;
          break;
        }
      case XmlRpcValue::TypeStruct:
        {
          //generate a list consisting of name/value pairs
          XmlRpcValue::ValueStruct& strct=(XmlRpcValue::ValueStruct&)v;
          int s = strct.size()*2;
          char** valp=new char*[s];
          memset(valp, 0, s * sizeof(char*));
          retval=TCL_OK;
          int i=0;
          for(XmlRpcValue::ValueStruct::iterator it=strct.begin();it!=strct.end();it++)
          {
            const std::string& name=it->first;
//            printf("%s=%s\n", name.c_str(), it->second.toText().c_str());
            std::string curval;
            
            retval=StringFromXmlRpcValue(interp, it->second, curval);
//            printf("%s=%s\n", name.c_str(), curval.c_str());
            if(retval!=TCL_OK)break;
            valp[i]=new char[name.length()+1];
            strcpy(valp[i], name.c_str());
            i++;
            valp[i]=new char[curval.length()+1];
            strcpy(valp[i], curval.c_str());
            i++;
          }
          if(retval==TCL_OK){
              char* tcl_str=Tcl_Merge(s, valp);
              if(!tcl_str){
                  retval=TCL_ERROR;
              }else{
                  sval=tcl_str;
                  Tcl_Free(tcl_str);
              }
          }
          for (i=0; i<s; ++i)
          {
              if(valp[i])delete[] valp[i];
          }
          delete[] valp;
          break;
        }
      
    }
    return retval;
    
}

/*
static int ParseURL(const std::string& url, std::string& protocol, std::string& host, int& port, std::string& uri)
{
	port=80;
	uri="/RPC2";
	std::string::size_type left, right;
	left=0;
	right=url.find("://", left);
	if(right != std::string::npos){
		protocol=url.substr(left, right-left);
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
	}
	return TCL_OK;
}
*/

static int Tclrpc_Cmd (ClientData, Tcl_Interp * interp, int argc, CONST84 char* argv[])
{
	if(argc < 3) {
		Tcl_AppendResult(interp, USAGE, NULL);
		return TCL_ERROR;
	}
        XmlRpcValue params;
        int retval=TCL_OK;
        int index=0;
        for(int i=3;i<argc;i++){
            if(iso8859_encoding != NULL) {
              Tcl_DString dst;
              const char *cstr = Tcl_UtfToExternalDString(iso8859_encoding, argv[i], -1, &dst);
              retval=StringToXmlRpcValue(interp, params[index], cstr);
              Tcl_DStringFree(&dst);
            } else {
              retval=StringToXmlRpcValue(interp, params[index], argv[i]);
            }
            if(retval!=TCL_OK){
		    Tcl_AppendResult(interp, "Error parsing argument ", argv[i], NULL);
		return TCL_ERROR;
            }
            index++;
        }
        if(retval==TCL_OK){
            g_tclrpcErrorHandler.clear_message();
            std::string url=argv[1];
			XmlRpcClient* newXmlRpcClient = new XmlRpcClient( url );
			if( (xmlRpcClient == NULL) || (xmlRpcClient->getURL() != newXmlRpcClient->getURL()) )
			{
				if(xmlRpcClient)delete xmlRpcClient;
				xmlRpcClient = newXmlRpcClient;
			}else{
				delete newXmlRpcClient;
			}
            XmlRpcValue response;
            if(!xmlRpcClient->execute(argv[2]/*method name*/, params, response)){
                Tcl_AppendResult(interp, "Transport error on xmlrpc call ", argv[2], " to ", url.c_str(), ": ", g_tclrpcErrorHandler.get_message().c_str(), NULL);
				retval = TCL_ERROR;
            }else if(xmlRpcClient->isFault()){
                char buffer[32];
                snprintf(buffer, sizeof(buffer)-1, "faultCode=%d\n", (int)response["faultCode"]);
        		Tcl_AppendResult(interp, "Fault received on xmlrpc call ", argv[2], "(", params.toText().c_str(), ")\n", buffer, "faultString=", const_cast<char*>(((std::string)response["faultString"]).c_str()), NULL);
		//retval=TCL_ERROR;
		/*
		* C.Niclaus: Reverted change from svn revsision 56882 made to fix something in speedy pick, but broke return code evaluation in
		* tcl script 'dispatch.tcl'. Since this code was forked in twist project, this should be reverted now, to evaluate new return code
		* (i.e. -10 TransmissionPending from Legacy API
		*/
		retval=(int)response["faultCode"];
		if(TCL_OK==retval) {
			retval=TCL_ERROR;
		}
            }else{
                std::string tcl_result;
                retval=StringFromXmlRpcValue(interp, response, tcl_result);
                if(iso8859_encoding != NULL) {
                  Tcl_DString dst;
                  char* cstr;
                  cstr = Tcl_ExternalToUtfDString(iso8859_encoding, tcl_result.c_str(), -1, &dst);
                  Tcl_SetResult(interp, cstr, TCL_VOLATILE);
                  Tcl_DStringFree(&dst);
                } else {
                  Tcl_SetResult(interp, const_cast<char*>(tcl_result.c_str()), TCL_VOLATILE);
                }
            }
        }
	return retval;
}

}/* extern "C" */
