#ifndef NSAPPLINKRPC_CHOICEMARSHALLER_INCLUDE
#define NSAPPLINKRPC_CHOICEMARSHALLER_INCLUDE

#include <string>
#include <json/json.h>

#include "../include/JSONHandler/ALRPCObjects/Choice.h"


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

  struct ChoiceMarshaller
  {
    static bool checkIntegrity(Choice& e);
    static bool checkIntegrityConst(const Choice& e);
  
    static bool fromString(const std::string& s,Choice& e);
    static const std::string toString(const Choice& e);
  
    static bool fromJSON(const Json::Value& s,Choice& e);
    static Json::Value toJSON(const Choice& e);
  };
}

#endif
