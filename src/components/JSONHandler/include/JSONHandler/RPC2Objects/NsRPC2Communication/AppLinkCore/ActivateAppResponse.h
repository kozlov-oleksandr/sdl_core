#ifndef NSRPC2COMMUNICATION_APPLINKCORE_ACTIVATEAPPRESPONSE_INCLUDE
#define NSRPC2COMMUNICATION_APPLINKCORE_ACTIVATEAPPRESPONSE_INCLUDE

#include "JSONHandler/RPC2Response.h"


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

    class ActivateAppResponse : public ::NsRPC2Communication::RPC2Response
    {
    public:
    
      ActivateAppResponse(const ActivateAppResponse& c);
      ActivateAppResponse(void);
    
      ActivateAppResponse& operator =(const ActivateAppResponse&);
    
      virtual ~ActivateAppResponse(void);
    
      bool checkIntegrity(void);
    

    private:

      friend class ActivateAppResponseMarshaller;


    };
  }
}

#endif
