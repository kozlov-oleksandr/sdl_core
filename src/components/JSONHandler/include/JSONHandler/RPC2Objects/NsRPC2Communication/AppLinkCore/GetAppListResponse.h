#ifndef NSRPC2COMMUNICATION_APPLINKCORE_GETAPPLISTRESPONSE_INCLUDE
#define NSRPC2COMMUNICATION_APPLINKCORE_GETAPPLISTRESPONSE_INCLUDE

#include <vector>
#include "JSONHandler/RPC2Response.h"

#include "../include/JSONHandler/ALRPCObjects/HMIApplication.h"

/*
  interface	NsRPC2Communication::AppLinkCore
  version	1.2
  generated at	Mon Nov 19 10:37:39 2012
  source stamp	Mon Nov 19 10:17:20 2012
  author	robok0der
*/

namespace NsRPC2Communication
{
  namespace AppLinkCore
  {

    class GetAppListResponse : public ::NsRPC2Communication::RPC2Response
    {
    public:
    
      GetAppListResponse(const GetAppListResponse& c);
      GetAppListResponse(void);
    
      GetAppListResponse& operator =(const GetAppListResponse&);
    
      virtual ~GetAppListResponse(void);
    
      bool checkIntegrity(void);
    
// getters
      const std::vector< NsAppLinkRPC::HMIApplication>& get_appList(void);


// setters
      bool set_appList(const std::vector< NsAppLinkRPC::HMIApplication>& appList);


    private:

      friend class GetAppListResponseMarshaller;

      std::vector< NsAppLinkRPC::HMIApplication> appList;

    };
  }
}

#endif
