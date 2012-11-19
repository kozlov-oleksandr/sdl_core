#ifndef NSAPPLINKRPC_UNREGISTERAPPINTERFACE_RESPONSEMARSHALLER_INCLUDE
#define NSAPPLINKRPC_UNREGISTERAPPINTERFACE_RESPONSEMARSHALLER_INCLUDE

#include <string>
#include <json/json.h>

#include "../include/JSONHandler/ALRPCObjects/UnregisterAppInterface_response.h"


/*
  interface	Ford Sync RAPI
  version	1.2
  date		2011-05-17
  generated at	Mon Nov 19 10:37:06 2012
  source stamp	Mon Nov 19 10:35:56 2012
  author	robok0der
*/

namespace NsAppLinkRPC
{

  struct UnregisterAppInterface_responseMarshaller
  {
    static bool checkIntegrity(UnregisterAppInterface_response& e);
    static bool checkIntegrityConst(const UnregisterAppInterface_response& e);
  
    static bool fromString(const std::string& s,UnregisterAppInterface_response& e);
    static const std::string toString(const UnregisterAppInterface_response& e);
  
    static bool fromJSON(const Json::Value& s,UnregisterAppInterface_response& e);
    static Json::Value toJSON(const UnregisterAppInterface_response& e);
  };
}

#endif
