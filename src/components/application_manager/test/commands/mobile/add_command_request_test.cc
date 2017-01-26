/*
 * Copyright (c) 2016, Ford Motor Company
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following
 * disclaimer in the documentation and/or other materials provided with the
 * distribution.
 *
 * Neither the name of the Ford Motor Company nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdint.h>
#include <string>
#include <set>

#include "application_manager/commands/mobile/add_command_request.h"

#include "gtest/gtest.h"
#include "utils/shared_ptr.h"
#include "utils/helpers.h"
#include "utils/make_shared.h"
#include "smart_objects/smart_object.h"
#include "utils/custom_string.h"
#include "application_manager/commands/command_request_test.h"
#include "application_manager/smart_object_keys.h"
#include "application_manager/mock_application.h"
#include "application_manager/mock_application_manager.h"
#include "application_manager/mock_message_helper.h"
#include "application_manager/event_engine/event.h"
#include "application_manager/mock_hmi_interface.h"

namespace test {
namespace components {
namespace commands_test {
namespace mobile_commands_test {
namespace add_command_request {

namespace am = application_manager;

using am::commands::AddCommandRequest;
using am::commands::CommandImpl;
using am::ApplicationManager;
using am::commands::MessageSharedPtr;
using am::ApplicationSharedPtr;
using am::MockMessageHelper;
using am::MockHmiInterfaces;

using ::testing::_;
using ::testing::Mock;
using ::testing::Return;
using ::testing::ReturnRef;
using ::utils::SharedPtr;
using ::test::components::application_manager_test::MockApplication;

namespace custom_str = utils::custom_string;
namespace strings = ::application_manager::strings;
namespace hmi_response = ::application_manager::hmi_response;

namespace {
const int32_t kCommandId = 1;
const uint32_t kAppId = 1u;
const uint32_t kCmdId = 1u;
const uint32_t kConnectionKey = 2u;
const uint32_t kType = 34u;
const uint32_t kGrammarId = 12u;
const uint32_t kPosition = 10u;
const uint32_t kCmdIcon = 1u;
}  // namespace

class AddCommandRequestTest
    : public CommandRequestTest<CommandsTestMocks::kIsNice> {
 public:
  AddCommandRequestTest()
      : mock_message_helper_(*MockMessageHelper::message_helper_mock())
      , mock_app_(CreateMockApp()) {}

 protected:
  MessageSharedPtr CreateFullParamsVRSO() {
    MessageSharedPtr msg = CreateMessage(smart_objects::SmartType_Map);
    (*msg)[strings::params][strings::connection_key] = kConnectionKey;
    smart_objects::SmartObject msg_params =
        smart_objects::SmartObject(smart_objects::SmartType_Map);
    msg_params[strings::cmd_id] = kCmdId;
    msg_params[strings::vr_commands] =
        smart_objects::SmartObject(smart_objects::SmartType_Array);
    msg_params[strings::vr_commands][0] = "lamer";
    msg_params[strings::type] = kType;
    msg_params[strings::grammar_id] = kGrammarId;
    msg_params[strings::app_id] = kAppId;
    (*msg)[strings::msg_params] = msg_params;

    return msg;
  }

  MessageSharedPtr CreateFullParamsUISO() {
    MessageSharedPtr msg = CreateMessage(smart_objects::SmartType_Map);
    (*msg)[am::strings::params][am::strings::connection_key] = kConnectionKey;
    smart_objects::SmartObject menu_params =
        smart_objects::SmartObject(smart_objects::SmartType_Map);
    menu_params[am::strings::position] = kPosition;
    menu_params[am::strings::menu_name] = "LG";

    smart_objects::SmartObject msg_params =
        smart_objects::SmartObject(smart_objects::SmartType_Map);
    msg_params[am::strings::cmd_id] = kCmdId;
    msg_params[am::strings::menu_params] = menu_params;
    msg_params[am::strings::app_id] = kAppId;
    msg_params[am::strings::cmd_icon] = kCmdIcon;
    msg_params[am::strings::cmd_icon][am::strings::value] = "10";
    (*msg)[am::strings::msg_params] = msg_params;

    return msg;
  }

  MessageSharedPtr CreateFullParamsSO() {
    MessageSharedPtr msg = CreateFullParamsUISO();
    smart_objects::SmartObject& msg_params = (*msg)[am::strings::msg_params];
    msg_params[strings::vr_commands] =
        smart_objects::SmartObject(smart_objects::SmartType_Array);
    msg_params[strings::vr_commands][0] = "lamer";
    msg_params[strings::type] = kType;
    msg_params[strings::grammar_id] = kGrammarId;
    return msg;
  }

  MessageSharedPtr CreateParamsUISOWithOutCmdIcon() {
    MessageSharedPtr msg = CreateMessage(smart_objects::SmartType_Map);
    (*msg)[am::strings::params][am::strings::connection_key] = kConnectionKey;
    smart_objects::SmartObject menu_params =
        smart_objects::SmartObject(smart_objects::SmartType_Map);
    menu_params[am::strings::position] = kPosition;
    menu_params[am::strings::menu_name] = "LG";

    smart_objects::SmartObject msg_params =
        smart_objects::SmartObject(smart_objects::SmartType_Map);
    msg_params[am::strings::cmd_id] = kCmdId;
    msg_params[am::strings::menu_params] = menu_params;
    msg_params[am::strings::app_id] = kAppId;
    (*msg)[am::strings::msg_params] = msg_params;

    return msg;
  }

  void SetStateForHMIInterfaces(am::HmiInterfaces::InterfaceState ui_state,
                                am::HmiInterfaces::InterfaceState vr_state) {
    ON_CALL(hmi_interfaces_, GetInterfaceFromFunction(_))
        .WillByDefault(Return(am::HmiInterfaces::HMI_INTERFACE_UI));
    ON_CALL(hmi_interfaces_,
            GetInterfaceState(am::HmiInterfaces::HMI_INTERFACE_UI))
        .WillByDefault(Return(ui_state));
    ON_CALL(hmi_interfaces_,
            GetInterfaceState(am::HmiInterfaces::HMI_INTERFACE_VR))
        .WillByDefault(Return(vr_state));
  }

  void CommonExpectations(MessageSharedPtr msg) {
    ON_CALL(*mock_app_, FindSubMenu(_)).WillByDefault(Return(&(*msg)));

    smart_objects::SmartObject* ptr = NULL;
    ON_CALL(*mock_app_, FindCommand(kCmdId)).WillByDefault(Return(ptr));
    EXPECT_EQ(NULL, ptr);

    ON_CALL(mock_message_helper_, HMIToMobileResult(_))
        .WillByDefault(Return(mobile_apis::Result::SUCCESS));

    ON_CALL(mock_message_helper_, VerifyImage(_, _, _))
        .WillByDefault(Return(mobile_apis::Result::SUCCESS));

    EXPECT_CALL(*mock_app_,
                AddCommand(kCmdId, (*msg)[am::strings::msg_params]));
    EXPECT_CALL(*mock_app_, UpdateHash());
  }

  MessageSharedPtr PrepareResponseFromHMI(
      const hmi_apis::Common_Result::eType result_code, const char* info) {
    MessageSharedPtr msg = CreateMessage(smart_objects::SmartType_Map);
    (*msg)[am::strings::params][am::hmi_response::code] = result_code;
    (*msg)[strings::msg_params] =
        smart_objects::SmartObject(smart_objects::SmartType_Map);
    if (info) {
      (*msg)[am::strings::msg_params][am::strings::info] = info;
    }
    return msg;
  }

  void SetUp() OVERRIDE {
    ON_CALL(app_mngr_, application(kConnectionKey))
        .WillByDefault(Return(mock_app_));
    ON_CALL(*mock_app_, app_id()).WillByDefault(Return(kConnectionKey));
    ON_CALL(app_mngr_, hmi_interfaces())
        .WillByDefault(ReturnRef(hmi_interfaces_));
  }

  void TearDown() OVERRIDE {
    Mock::VerifyAndClearExpectations(&mock_message_helper_);
  }

  void ResultCommandExpectations(MessageSharedPtr msg,
                                 mobile_apis::Result::eType result_code,
                                 const std::string& info) {
    EXPECT_EQ((*msg)[am::strings::msg_params][am::strings::success].asBool(),
              true);
    EXPECT_EQ((*msg)[am::strings::msg_params][am::strings::result_code].asInt(),
              static_cast<int32_t>(result_code));
    if (!info.empty()) {
      EXPECT_EQ((*msg)[am::strings::msg_params][am::strings::info].asString(),
                info);
    }
  }

  sync_primitives::Lock lock_;
  NiceMock<MockHmiInterfaces> hmi_interfaces_;
  MockMessageHelper& mock_message_helper_;
  MockAppPtr mock_app_;
};

TEST_F(AddCommandRequestTest, OnTimeout_GENERIC_ERROR) {
  MessageSharedPtr msg = CreateMessage(smart_objects::SmartType_Map);
  (*msg)[strings::msg_params][strings::result_code] =
      am::mobile_api::Result::GENERIC_ERROR;
  (*msg)[strings::msg_params][strings::success] = false;
  (*msg)[strings::params][strings::connection_key] = kConnectionKey;

  utils::SharedPtr<AddCommandRequest> command =
      CreateCommand<AddCommandRequest>(msg);

  ON_CALL(*mock_app_, get_grammar_id()).WillByDefault(Return(kConnectionKey));
  ON_CALL(*mock_app_, RemoveCommand(_)).WillByDefault(Return());

  EXPECT_CALL(
      mock_message_helper_,
      CreateNegativeResponse(_, _, _, am::mobile_api::Result::GENERIC_ERROR))
      .WillOnce(Return(msg));

  MessageSharedPtr command_result;
  EXPECT_CALL(
      app_mngr_,
      ManageMobileCommand(_, am::commands::Command::CommandOrigin::ORIGIN_SDL))
      .WillOnce(DoAll(SaveArg<0>(&command_result), Return(true)));

  command->onTimeOut();
  EXPECT_EQ((*command_result)[strings::msg_params][strings::success].asBool(),
            false);
  EXPECT_EQ(
      (*command_result)[strings::msg_params][strings::result_code].asInt(),
      static_cast<int32_t>(am::mobile_api::Result::GENERIC_ERROR));
}

TEST_F(AddCommandRequestTest, OnEvent_VR_HmiSendSuccess_UNSUPPORTED_RESOURCE) {
  MessageSharedPtr add_command_msg = CreateFullParamsSO();

  utils::SharedPtr<AddCommandRequest> command =
      CreateCommand<AddCommandRequest>(add_command_msg);

  SetStateForHMIInterfaces(am::HmiInterfaces::STATE_AVAILABLE,
                           am::HmiInterfaces::STATE_NOT_AVAILABLE);

  MessageSharedPtr msg_vr =
      PrepareResponseFromHMI(hmi_apis::Common_Result::UNSUPPORTED_RESOURCE,
                             "VR is not supported by system");

  Event event_vr(hmi_apis::FunctionID::VR_AddCommand);
  event_vr.set_smart_object(*msg_vr);

  MessageSharedPtr msg_ui =
      PrepareResponseFromHMI(hmi_apis::Common_Result::SUCCESS, NULL);
  Event event_ui(hmi_apis::FunctionID::UI_AddCommand);
  event_ui.set_smart_object(*msg_ui);

  CommonExpectations(add_command_msg);

  am::CommandsMap commands_map;
  ON_CALL(*mock_app_, commands_map())
      .WillByDefault(
          Return(DataAccessor<am::CommandsMap>(commands_map, lock_)));

  command->Run();
  command->on_event(event_ui);

  MessageSharedPtr vr_command_result;
  EXPECT_CALL(
      app_mngr_,
      ManageMobileCommand(_, am::commands::Command::CommandOrigin::ORIGIN_SDL))
      .WillOnce(DoAll(SaveArg<0>(&vr_command_result), Return(true)));

  command->on_event(event_vr);

  ResultCommandExpectations(vr_command_result,
                            mobile_apis::Result::UNSUPPORTED_RESOURCE,
                            "VR is not supported by system");
}

TEST_F(AddCommandRequestTest,
       OnEvent_UI_HmiSendUnsupportedResource_UNSUPPORTED_RESOURCE) {
  MessageSharedPtr add_command_msg = CreateFullParamsSO();

  utils::SharedPtr<AddCommandRequest> command =
      CreateCommand<AddCommandRequest>(add_command_msg);

  SetStateForHMIInterfaces(am::HmiInterfaces::STATE_NOT_AVAILABLE,
                           am::HmiInterfaces::STATE_AVAILABLE);

  MessageSharedPtr msg_ui =
      PrepareResponseFromHMI(hmi_apis::Common_Result::UNSUPPORTED_RESOURCE,
                             "UI is not supported by system");
  Event event_ui(hmi_apis::FunctionID::UI_AddCommand);
  event_ui.set_smart_object(*msg_ui);

  MessageSharedPtr msg_vr =
      PrepareResponseFromHMI(hmi_apis::Common_Result::SUCCESS, NULL);
  Event event_vr(hmi_apis::FunctionID::VR_AddCommand);
  event_vr.set_smart_object(*msg_vr);

  CommonExpectations(add_command_msg);

  am::CommandsMap commands_map;
  ON_CALL(*mock_app_, commands_map())
      .WillByDefault(
          Return(DataAccessor<am::CommandsMap>(commands_map, lock_)));

  command->Run();
  command->on_event(event_vr);
  MessageSharedPtr ui_command_result;
  EXPECT_CALL(
      app_mngr_,
      ManageMobileCommand(_, am::commands::Command::CommandOrigin::ORIGIN_SDL))
      .WillOnce(DoAll(SaveArg<0>(&ui_command_result), Return(true)));

  command->on_event(event_ui);

  ResultCommandExpectations(ui_command_result,
                            mobile_apis::Result::UNSUPPORTED_RESOURCE,
                            "UI is not supported by system");
}

TEST_F(
    AddCommandRequestTest,
    OnEvent_UIHmiSendWarning_VRHmiSendAnySuccessfullCode_MobileResultWarning) {
  MessageSharedPtr add_command_msg = CreateFullParamsSO();
  utils::SharedPtr<AddCommandRequest> command =
      CreateCommand<AddCommandRequest>(add_command_msg);
  SetStateForHMIInterfaces(am::HmiInterfaces::STATE_AVAILABLE,
                           am::HmiInterfaces::STATE_AVAILABLE);

  MessageSharedPtr msg_ui =
      PrepareResponseFromHMI(hmi_apis::Common_Result::SUCCESS, NULL);
  Event event_ui(hmi_apis::FunctionID::UI_AddCommand);
  event_ui.set_smart_object(*msg_ui);

  MessageSharedPtr msg_vr =
      PrepareResponseFromHMI(hmi_apis::Common_Result::WARNINGS, NULL);
  Event event_vr(hmi_apis::FunctionID::VR_AddCommand);
  event_vr.set_smart_object(*msg_vr);

  CommonExpectations(add_command_msg);

  am::CommandsMap commands_map;
  ON_CALL(*mock_app_, commands_map())
      .WillByDefault(
          Return(DataAccessor<am::CommandsMap>(commands_map, lock_)));

  command->Run();
  command->on_event(event_vr);
  MessageSharedPtr ui_command_result;
  EXPECT_CALL(
      app_mngr_,
      ManageMobileCommand(_, am::commands::Command::CommandOrigin::ORIGIN_SDL))
      .WillOnce(DoAll(SaveArg<0>(&ui_command_result), Return(true)));

  command->on_event(event_ui);

  ResultCommandExpectations(
      ui_command_result, mobile_apis::Result::WARNINGS, "");
}

TEST_F(AddCommandRequestTest,
       OnEvent_UIHmiSendWarning_VRHmiSendUnsupported_MobileResultUnsupported) {
  MessageSharedPtr add_command_msg = CreateFullParamsSO();
  utils::SharedPtr<AddCommandRequest> command =
      CreateCommand<AddCommandRequest>(add_command_msg);
  SetStateForHMIInterfaces(am::HmiInterfaces::STATE_AVAILABLE,
                           am::HmiInterfaces::STATE_NOT_RESPONSE);

  MessageSharedPtr msg_ui =
      PrepareResponseFromHMI(hmi_apis::Common_Result::WARNINGS, NULL);
  Event event_ui(hmi_apis::FunctionID::UI_AddCommand);
  event_ui.set_smart_object(*msg_ui);

  MessageSharedPtr msg_vr = PrepareResponseFromHMI(
      hmi_apis::Common_Result::UNSUPPORTED_RESOURCE, NULL);
  Event event_vr(hmi_apis::FunctionID::VR_AddCommand);
  event_vr.set_smart_object(*msg_vr);

  CommonExpectations(add_command_msg);

  am::CommandsMap commands_map;
  ON_CALL(*mock_app_, commands_map())
      .WillByDefault(
          Return(DataAccessor<am::CommandsMap>(commands_map, lock_)));

  command->Run();
  command->on_event(event_vr);
  MessageSharedPtr ui_command_result;
  EXPECT_CALL(
      app_mngr_,
      ManageMobileCommand(_, am::commands::Command::CommandOrigin::ORIGIN_SDL))
      .WillOnce(DoAll(SaveArg<0>(&ui_command_result), Return(true)));

  command->on_event(event_ui);

  ResultCommandExpectations(
      ui_command_result, mobile_apis::Result::UNSUPPORTED_RESOURCE, "");
}

}  // namespace add_command_test
}  // namespace mobile_commands_test
}  // namespace commands_test
}  // namespace components
}  // namespace tests
