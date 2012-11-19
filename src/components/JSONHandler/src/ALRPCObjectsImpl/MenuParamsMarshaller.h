#ifndef NSAPPLINKRPC_MENUPARAMSMARSHALLER_INCLUDE
#define NSAPPLINKRPC_MENUPARAMSMARSHALLER_INCLUDE

#include <string>
#include <json/json.h>

#include "../include/JSONHandler/ALRPCObjects/MenuParams.h"


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

  struct MenuParamsMarshaller
  {
    static bool checkIntegrity(MenuParams& e);
    static bool checkIntegrityConst(const MenuParams& e);
  
    static bool fromString(const std::string& s,MenuParams& e);
    static const std::string toString(const MenuParams& e);
  
    static bool fromJSON(const Json::Value& s,MenuParams& e);
    static Json::Value toJSON(const MenuParams& e);
  };
}

#endif
