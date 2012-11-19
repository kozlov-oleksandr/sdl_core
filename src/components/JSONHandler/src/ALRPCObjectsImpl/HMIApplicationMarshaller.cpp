#include "../include/JSONHandler/ALRPCObjects/HMIApplication.h"


#include "HMIApplicationMarshaller.h"


/*
  interface	Ford Sync RAPI
  version	1.2
  date		2011-05-17
  generated at	Mon Nov 19 10:37:06 2012
  source stamp	Mon Nov 19 10:35:56 2012
  author	robok0der
*/

using namespace NsAppLinkRPC;


bool HMIApplicationMarshaller::checkIntegrity(HMIApplication& s)
{
  return checkIntegrityConst(s);
}


bool HMIApplicationMarshaller::fromString(const std::string& s,HMIApplication& e)
{
  try
  {
    Json::Reader reader;
    Json::Value json;
    if(!reader.parse(s,json,false))  return false;
    if(!fromJSON(json,e))  return false;
  }
  catch(...)
  {
    return false;
  }
  return true;
}


const std::string HMIApplicationMarshaller::toString(const HMIApplication& e)
{
  Json::FastWriter writer;
  return checkIntegrityConst(e) ? writer.write(toJSON(e)) : "";
}


bool HMIApplicationMarshaller::checkIntegrityConst(const HMIApplication& s)
{
  if(s.appName.length()>100)  return false;
  if(s.ngnMediaScreenAppName && s.ngnMediaScreenAppName->length()>100)  return false;
  return true;
}

Json::Value HMIApplicationMarshaller::toJSON(const HMIApplication& e)
{
  Json::Value json(Json::objectValue);
  if(!checkIntegrityConst(e))
    return Json::Value(Json::nullValue);

  json["appName"]=Json::Value(e.appName);

  if(e.icon)
    json["icon"]=Json::Value(*e.icon);

  if(e.ngnMediaScreenAppName)
    json["ngnMediaScreenAppName"]=Json::Value(*e.ngnMediaScreenAppName);


  return json;
}


bool HMIApplicationMarshaller::fromJSON(const Json::Value& json,HMIApplication& c)
{
  if(c.icon)  delete c.icon;
  c.icon=0;

  if(c.ngnMediaScreenAppName)  delete c.ngnMediaScreenAppName;
  c.ngnMediaScreenAppName=0;

  try
  {
    if(!json.isObject())  return false;

    if(!json.isMember("appName"))  return false;
    {
      const Json::Value& j=json["appName"];
      if(!j.isString())  return false;
      c.appName=j.asString();
    }
    if(json.isMember("icon"))
    {
      const Json::Value& j=json["icon"];
      if(!j.isString())  return false;
      c.icon=new std::string(j.asString());
    }
    if(json.isMember("ngnMediaScreenAppName"))
    {
      const Json::Value& j=json["ngnMediaScreenAppName"];
      if(!j.isString())  return false;
      c.ngnMediaScreenAppName=new std::string(j.asString());
    }

  }
  catch(...)
  {
    return false;
  }
  return checkIntegrity(c);
}

