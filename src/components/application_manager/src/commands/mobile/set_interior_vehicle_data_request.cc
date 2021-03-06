/*

 Copyright (c) 2013, Ford Motor Company
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following
 disclaimer in the documentation and/or other materials provided with the
 distribution.

 Neither the name of the Ford Motor Company nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#include <string.h>
#include "application_manager/commands/mobile/set_interior_vehicle_data_request.h"
#include "application_manager/application_manager_impl.h"
#include "application_manager/application_impl.h"
#include "application_manager/message_helper.h"
#include "interfaces/MOBILE_API.h"
#include "interfaces/HMI_API.h"

namespace application_manager {

namespace commands {


SetInteriorVehicleDataRequest::SetInteriorVehicleDataRequest(
    const MessageSharedPtr& message)
 : CommandRequestImpl(message)
{
  subscribe_on_event(hmi_apis::FunctionID::UI_OnResetTimeout);
}

SetInteriorVehicleDataRequest::~SetInteriorVehicleDataRequest()
{
}

bool SetInteriorVehicleDataRequest::Init()
{
  /* Timeout in milliseconds.
     If omitted a standard value of 10000 milliseconds is used.*/
  if ((*message_)[strings::msg_params].keyExists(strings::timeout)) {
    default_timeout_ =
        (*message_)[strings::msg_params][strings::timeout].asUInt();
  } else {
    const int32_t def_value = 30000;
    default_timeout_ = def_value;
  }

  return true;
}

void SetInteriorVehicleDataRequest::Run()
{
  LOG4CXX_AUTO_TRACE(logger_);

  ApplicationSharedPtr app = application_manager::ApplicationManagerImpl::instance()
      ->application((*message_)[strings::params][strings::connection_key].asUInt());

  if (!app) {
    LOG4CXX_ERROR(logger_, "Application is not registered");
    SendResponse(false, mobile_apis::Result::APPLICATION_NOT_REGISTERED);
    return;
  }
  //////////////////

  //Checks needed?//

  /*

  */
  //////////////////

  //Construct msg_params to be sent to HMI

  smart_objects::SmartObject msg_params = smart_objects::SmartObject(
      smart_objects::SmartType_Map);

  msg_params = (*message_)[strings::msg_params];
  msg_params[strings::app_id] = app->app_id();

  SendHMIRequest(hmi_apis::FunctionID::RC_SetInteriorVehicleData, &msg_params, true);
}

void SetInteriorVehicleDataRequest::on_event(const event_engine::Event& event) {
  LOG4CXX_AUTO_TRACE(logger_);
  const smart_objects::SmartObject& message = event.smart_object();

  switch (event.id()) {
    case hmi_apis::FunctionID::UI_OnResetTimeout: {
      LOG4CXX_INFO(logger_, "Received UI_OnResetTimeout event");
      ApplicationManagerImpl::instance()->updateRequestTimeout(connection_key(),
          correlation_id(),
          default_timeout());
      break;
    }
    case hmi_apis::FunctionID::RC_SetInteriorVehicleData: {
      LOG4CXX_INFO(logger_, "Received RC_SetInteriorVehicleData event");

      mobile_apis::Result::eType result_code =
          static_cast<mobile_apis::Result::eType>
          (message[strings::params][hmi_response::code].asInt());
      HMICapabilities& hmi_capabilities =
          ApplicationManagerImpl::instance()->hmi_capabilities();
      bool result = false;
      if (mobile_apis::Result::SUCCESS == result_code) {
        result = true;
      } else if ((mobile_apis::Result::UNSUPPORTED_RESOURCE == result_code) &&
          hmi_capabilities.is_ui_cooperating()) {
        result = true;
      }
      SendResponse(result, result_code, NULL, &(message[strings::msg_params]));
      break;
    }
    default: {
      LOG4CXX_ERROR(logger_,"Received unknown event" << event.id());
      break;
    }
  }
}

}  // namespace commands
}  // namespace application_manager