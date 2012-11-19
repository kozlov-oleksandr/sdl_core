#ifndef NSAPPLINKRPC_TBTSTATE_INCLUDE
#define NSAPPLINKRPC_TBTSTATE_INCLUDE


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

///  Enumeration that describes possible states of turn-by-turn module.

  class TBTState
  {
  public:
    enum TBTStateInternal
    {
      INVALID_ENUM=-1,
      ROUTE_UPDATE_REQUEST=0,
      ROUTE_ACCEPTED=1,
      ROUTE_REFUSED=2,
      ROUTE_CANCELLED=3
    };
  
    TBTState() : mInternal(INVALID_ENUM)				{}
    TBTState(TBTStateInternal e) : mInternal(e)		{}
  
    TBTStateInternal get(void) const	{ return mInternal; }
    void set(TBTStateInternal e)		{ mInternal=e; }
  
  private:
    TBTStateInternal mInternal;
    friend class TBTStateMarshaller;
  };
  
}

#endif
