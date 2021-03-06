﻿/* Copyright (c) 2014, Ford Motor Company
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

#include <vector>

#include "gtest/gtest.h"
#include "mock_policy_listener.h"
#include "mock_pt_ext_representation.h"
#include "mock_cache_manager.h"
#include "mock_update_status_manager.h"
#include "policy/policy_manager_impl.h"

#ifdef SDL_REMOTE_CONTROL
#  include "mock_access_remote.h"
#endif  // SDL_REMOTE_CONTROL

using ::testing::_;
using ::testing::Return;
using ::testing::ReturnRef;
using ::testing::DoAll;
using ::testing::SetArgReferee;
using ::testing::NiceMock;
using ::testing::AtLeast;

namespace policy_table = rpc::policy_table_interface_base;

namespace policy {

class PolicyManagerImplTest : public ::testing::Test {
 protected:
  PolicyManagerImpl* manager;
  MockCacheManagerInterface* cache_manager;
  MockUpdateStatusManager update_manager;
  MockPolicyListener* listener;
#ifdef SDL_REMOTE_CONTROL
  MockAccessRemote* access_remote;
#endif  // SDL_REMOTE_CONTROL

  void SetUp() {
    manager = new PolicyManagerImpl();

    cache_manager = new MockCacheManagerInterface();
    manager->set_cache_manager(cache_manager);

#ifdef SDL_REMOTE_CONTROL
    access_remote = new MockAccessRemote();
    manager->access_remote_ = access_remote;
#endif  // SDL_REMOTE_CONTROL

    listener = new MockPolicyListener();
    manager->set_listener(listener);
  }

  void TearDown() {
    delete manager;
    delete listener;
  }

  ::testing::AssertionResult IsValid(const policy_table::Table& table) {
    if (table.is_valid()) {
      return ::testing::AssertionSuccess();
    } else {
      ::rpc::ValidationReport report(" - table");
      table.ReportErrors(&report);
      return ::testing::AssertionFailure() << ::rpc::PrettyFormat(report);
    }
  }

#ifdef SDL_REMOTE_CONTROL
 public:
  bool CheckPTURemoteCtrlChange(
      const utils::SharedPtr<policy_table::Table> pt_update,
      const utils::SharedPtr<policy_table::Table> snapshot) {
    return manager->CheckPTURemoteCtrlChange(pt_update, snapshot);
  }
#endif  // SDL_REMOTE_CONTROL
};

TEST_F(PolicyManagerImplTest, RefreshRetrySequence_SetSecondsBetweenRetries_ExpectRetryTimeoutSequenceWithSameSeconds) {

  //arrange
  std::vector<int> seconds;
  seconds.push_back(50);
  seconds.push_back(100);
  seconds.push_back(200);

  //assert
  EXPECT_CALL(*cache_manager, TimeoutResponse()).WillOnce(Return(60));
  EXPECT_CALL(*cache_manager, SecondsBetweenRetries(_)).WillOnce(
      DoAll(SetArgReferee<0>(seconds), Return(true)));

  //act
  manager->RefreshRetrySequence();

  //assert
  EXPECT_EQ(50, manager->NextRetryTimeout());
  EXPECT_EQ(100, manager->NextRetryTimeout());
  EXPECT_EQ(200, manager->NextRetryTimeout());
  EXPECT_EQ(0, manager->NextRetryTimeout());
}

TEST_F(PolicyManagerImplTest, DISABLED_GetUpdateUrl) {

  EXPECT_CALL(*cache_manager, GetServiceUrls("7",_));
  EXPECT_CALL(*cache_manager, GetServiceUrls("4",_));

  EndpointUrls ep_7;

  manager->GetServiceUrls("7", ep_7);
  EXPECT_EQ("http://policies.telematics.ford.com/api/policies", ep_7[0].url[0] );

  EndpointUrls ep_4;
  manager->GetServiceUrls("4", ep_4);
  EXPECT_EQ("http://policies.ford.com/api/policies", ep_4[0].url[0]);

}


TEST_F(PolicyManagerImplTest, ResetPT) {
  EXPECT_CALL(*cache_manager, ResetPT("filename")).WillOnce(Return(true))
      .WillOnce(Return(false));
  EXPECT_CALL(*cache_manager, ResetCalculatedPermissions()).Times(2);
  EXPECT_CALL(*cache_manager, TimeoutResponse());
  EXPECT_CALL(*cache_manager, SecondsBetweenRetries(_));

  EXPECT_TRUE(manager->ResetPT("filename"));
  EXPECT_FALSE(manager->ResetPT("filename"));
}

TEST_F(PolicyManagerImplTest, CheckPermissions_SetHmiLevelFullForAlert_ExpectAllowedPermissions) {

  //arrange
  ::policy::CheckPermissionResult expected;
  expected.hmi_level_permitted = ::policy::kRpcAllowed;
  expected.list_of_allowed_params.push_back("speed");
  expected.list_of_allowed_params.push_back("gps");

  policy_table::Strings groups;
  groups.push_back("Group-1");

  //assert
  EXPECT_CALL(*cache_manager, IsApplicationRepresented("12345678")).
      WillOnce(Return(true));
#ifdef SDL_REMOTE_CONTROL
  Subject who = { "dev1", "12345678" };
  EXPECT_CALL(*access_remote, GetGroups(who)).WillOnce(ReturnRef(groups));
#else  // SDL_REMOTE_CONTROL
  EXPECT_CALL(*cache_manager, GetGroups("12345678")).
      WillOnce(ReturnRef(groups));
#endif  // SDL_REMOTE_CONTROL

  EXPECT_CALL(*cache_manager, CheckPermissions(_, "FULL", "Alert", _)).
      WillOnce(SetArgReferee<3>(expected));

  //act
  ::policy::RPCParams input_params;
  ::policy::CheckPermissionResult output;
  manager->CheckPermissions("dev1", "12345678", "FULL", "Alert", input_params, output);

  //assert
  EXPECT_EQ(::policy::kRpcAllowed, output.hmi_level_permitted);

  ASSERT_TRUE(!output.list_of_allowed_params.empty());
  ASSERT_EQ(2u, output.list_of_allowed_params.size());
  EXPECT_EQ("speed", output.list_of_allowed_params[0]);
  EXPECT_EQ("gps", output.list_of_allowed_params[1]);
}

TEST_F(PolicyManagerImplTest, LoadPT_SetPT_PTIsLoaded) {

  //arrange
  Json::Value table(Json::objectValue);
  table["policy_table"] = Json::Value(Json::objectValue);

  Json::Value& policy_table = table["policy_table"];
  policy_table["module_config"] = Json::Value(Json::objectValue);
  policy_table["functional_groupings"] = Json::Value(Json::objectValue);
  policy_table["consumer_friendly_messages"] = Json::Value(Json::objectValue);
  policy_table["app_policies"] = Json::Value(Json::objectValue);

  Json::Value& module_config = policy_table["module_config"];
  module_config["preloaded_pt"] = Json::Value(true);
  module_config["exchange_after_x_ignition_cycles"] = Json::Value(10);
  module_config["exchange_after_x_kilometers"] = Json::Value(100);
  module_config["exchange_after_x_days"] = Json::Value(5);
  module_config["timeout_after_x_seconds"] = Json::Value(500);
  module_config["seconds_between_retries"] = Json::Value(Json::arrayValue);
  module_config["seconds_between_retries"][0] = Json::Value(10);
  module_config["seconds_between_retries"][1] = Json::Value(20);
  module_config["seconds_between_retries"][2] = Json::Value(30);
  module_config["endpoints"] = Json::Value(Json::objectValue);
  module_config["endpoints"]["0x00"] = Json::Value(Json::objectValue);
  module_config["endpoints"]["0x00"]["default"] = Json::Value(Json::arrayValue);
  module_config["endpoints"]["0x00"]["default"][0] = Json::Value(
      "http://ford.com/cloud/default");
  module_config["notifications_per_minute_by_priority"] = Json::Value(
      Json::objectValue);
  module_config["notifications_per_minute_by_priority"]["emergency"] =
      Json::Value(1);
  module_config["notifications_per_minute_by_priority"]["navigation"] =
      Json::Value(2);
  module_config["notifications_per_minute_by_priority"]["VOICECOMM"] =
      Json::Value(3);
  module_config["notifications_per_minute_by_priority"]["communication"] =
      Json::Value(4);
  module_config["notifications_per_minute_by_priority"]["normal"] = Json::Value(
      5);
  module_config["notifications_per_minute_by_priority"]["none"] = Json::Value(
      6);
  module_config["vehicle_make"] = Json::Value("MakeT");
  module_config["vehicle_model"] = Json::Value("ModelT");
  module_config["vehicle_year"] = Json::Value("2014");

  Json::Value& functional_groupings = policy_table["functional_groupings"];
  functional_groupings["default"] = Json::Value(Json::objectValue);
  Json::Value& default_group = functional_groupings["default"];
  default_group["rpcs"] = Json::Value(Json::objectValue);
  default_group["rpcs"]["Update"] = Json::Value(Json::objectValue);
  default_group["rpcs"]["Update"]["hmi_levels"] = Json::Value(Json::arrayValue);
  default_group["rpcs"]["Update"]["hmi_levels"][0] = Json::Value("FULL");
  default_group["rpcs"]["Update"]["parameters"] = Json::Value(Json::arrayValue);
  default_group["rpcs"]["Update"]["parameters"][0] = Json::Value("speed");

  Json::Value& consumer_friendly_messages =
      policy_table["consumer_friendly_messages"];
  consumer_friendly_messages["version"] = Json::Value("1.2");

  Json::Value& app_policies = policy_table["app_policies"];
  app_policies["default"] = Json::Value(Json::objectValue);
  app_policies["default"]["memory_kb"] = Json::Value(50);
  app_policies["default"]["heart_beat_timeout_ms"] = Json::Value(100);
  app_policies["default"]["groups"] = Json::Value(Json::arrayValue);
  app_policies["default"]["groups"][0] = Json::Value("default");
  app_policies["default"]["priority"] = Json::Value("EMERGENCY");
  app_policies["default"]["default_hmi"] = Json::Value("FULL");
  app_policies["default"]["keep_context"] = Json::Value(true);
  app_policies["default"]["steal_focus"] = Json::Value(true);
  app_policies["default"]["certificate"] = Json::Value("sign");
  app_policies["default"]["moduleType"] = Json::Value(Json::arrayValue);
  app_policies["default"]["moduleType"][0] = Json::Value("RADIO");
  app_policies["1234"] = Json::Value(Json::objectValue);
  app_policies["1234"]["memory_kb"] = Json::Value(50);
  app_policies["1234"]["heart_beat_timeout_ms"] = Json::Value(100);
  app_policies["1234"]["groups"] = Json::Value(Json::arrayValue);
  app_policies["1234"]["groups"][0] = Json::Value("default");
  app_policies["1234"]["priority"] = Json::Value("EMERGENCY");
  app_policies["1234"]["default_hmi"] = Json::Value("FULL");
  app_policies["1234"]["keep_context"] = Json::Value(true);
  app_policies["1234"]["steal_focus"] = Json::Value(true);
  app_policies["1234"]["certificate"] = Json::Value("sign");

  policy_table::Table update(&table);
  update.SetPolicyTableType(rpc::policy_table_interface_base::PT_UPDATE);

  //assert
  ASSERT_TRUE(IsValid(update));


  //act
  std::string json = table.toStyledString();
  ::policy::BinaryMessage msg(json.begin(), json.end());

  utils::SharedPtr<policy_table::Table> snapshot = new policy_table::Table(
      update.policy_table);

  //assert
  std::map<std::string, StringArray> hmi_types;
  hmi_types["1234"] = StringArray();
  EXPECT_CALL(*cache_manager, GetHMIAppTypeAfterUpdate(_)).
      WillOnce(SetArgReferee<0>(hmi_types));
  EXPECT_CALL(*listener, OnUpdateHMIAppType(hmi_types));
  EXPECT_CALL(*cache_manager, GenerateSnapshot()).WillOnce(Return(snapshot));
  EXPECT_CALL(*cache_manager, ApplyUpdate(_)).WillOnce(Return(true));
  EXPECT_CALL(*listener, GetAppName("1234")).WillOnce(Return(""));
  EXPECT_CALL(*listener, OnUpdateStatusChanged(_));
  EXPECT_CALL(*cache_manager, SaveUpdateRequired(false));
  EXPECT_CALL(*cache_manager, TimeoutResponse());
  EXPECT_CALL(*cache_manager, SecondsBetweenRetries(_));
#ifdef SDL_REMOTE_CONTROL
  EXPECT_CALL(*access_remote, Init());
#endif  // SDL_REMOTE_CONTROL

  EXPECT_TRUE(manager->LoadPT("file_pt_update.json", msg));
}

TEST_F(PolicyManagerImplTest, RequestPTUpdate_SetPT_GeneratedSnapshotAndPTUpdate) {

  //arrange
  ::utils::SharedPtr< ::policy_table::Table > p_table =
      new ::policy_table::Table();

  //assert
  EXPECT_CALL(*listener, OnSnapshotCreated(_, _, _));
  EXPECT_CALL(*cache_manager, GenerateSnapshot()).WillOnce(Return(p_table));

  //act
  manager->RequestPTUpdate();
}

TEST_F(PolicyManagerImplTest, DISABLED_AddApplication) {
  // TODO(AOleynik): Implementation of method should be changed to avoid
  // using of snapshot
  //manager->AddApplication("12345678");
}

TEST_F(PolicyManagerImplTest, DISABLED_GetPolicyTableStatus) {
  // TODO(AOleynik): Test is not finished, to be continued
  //manager->GetPolicyTableStatus();
}

#ifdef SDL_REMOTE_CONTROL
TEST_F(PolicyManagerImplTest, SetPrimaryDevice) {
  EXPECT_CALL(*access_remote, SetPrimaryDevice("dev1"));

  manager->SetPrimaryDevice("dev1");
}

TEST_F(PolicyManagerImplTest, ResetAccessBySubject) {
  Subject sub = {"dev1", "12345"};

  EXPECT_CALL(*access_remote, Reset(sub));

  manager->ResetAccess("dev1", "12345");
}

TEST_F(PolicyManagerImplTest, ResetAccessByObject) {
  SeatLocation zone = {0, 0, 0};
  Object obj = {policy_table::MT_RADIO, zone};

  EXPECT_CALL(*access_remote, Reset(obj));

  manager->ResetAccess(zone, "RADIO");
}

TEST_F(PolicyManagerImplTest, SetRemoteControl_Enable) {
  EXPECT_CALL(*access_remote, Enable());

  manager->SetRemoteControl(true);
}

TEST_F(PolicyManagerImplTest, SetRemoteControl_Disable) {
  EXPECT_CALL(*access_remote, Disable());

  manager->SetRemoteControl(false);
}

TEST_F(PolicyManagerImplTest, SetAccess_Allow) {
  Subject who = {"dev1", "12345"};
  SeatLocation zone = {0, 0, 0};
  Object what = {policy_table::MT_CLIMATE, zone};

  EXPECT_CALL(*access_remote, Allow(who, what));

  manager->SetAccess("dev1", "12345", zone, "CLIMATE", true);
}

TEST_F(PolicyManagerImplTest, SetAccess_Deny) {
  Subject who = {"dev1", "12345"};
  SeatLocation zone = {0, 0, 0};
  Object what = {policy_table::MT_RADIO, zone};

  EXPECT_CALL(*access_remote, Deny(who, what));

  manager->SetAccess("dev1", "12345", zone, "RADIO", false);
}

TEST_F(PolicyManagerImplTest, CheckAccess_PrimaryDevice) {
  Subject who {"dev1", "12345"};
  SeatLocation zone = {0, 0, 0};

  EXPECT_CALL(*access_remote,
              CheckModuleType("12345", policy_table::MT_CLIMATE)).
      WillOnce(Return(true));
  EXPECT_CALL(*access_remote, IsPrimaryDevice("dev1")).WillOnce(Return(true));

  EXPECT_EQ(TypeAccess::kAllowed,
            manager->CheckAccess("dev1", "12345", zone, "CLIMATE", "AnyRpc",
                                 RemoteControlParams()));
}

TEST_F(PolicyManagerImplTest, CheckAccess_DisabledRremoteControl) {
  EXPECT_CALL(*access_remote,
              CheckModuleType("12345", policy_table::MT_RADIO)).
      WillOnce(Return(true));
  EXPECT_CALL(*access_remote, IsPrimaryDevice("dev1")).WillOnce(Return(false));
  EXPECT_CALL(*access_remote, IsEnabled()).WillOnce(Return(false));

  SeatLocation zone {0,0,0};
  EXPECT_EQ(TypeAccess::kDisallowed,
            manager->CheckAccess("dev1", "12345", zone, "RADIO", "",
                                 RemoteControlParams()));
}

TEST_F(PolicyManagerImplTest, CheckAccess_Result) {
  Subject who = {"dev1", "12345"};
  SeatLocation zone = {0, 0, 0};
  Object what = {policy_table::MT_RADIO, zone};

  EXPECT_CALL(*access_remote,
              CheckModuleType("12345", policy_table::MT_RADIO)).
      WillOnce(Return(true));
  EXPECT_CALL(*access_remote, IsPrimaryDevice("dev1")).WillOnce(Return(false));
  EXPECT_CALL(*access_remote, IsEnabled()).WillOnce(Return(true));
  EXPECT_CALL(*access_remote, CheckParameters(_,_,_)).WillOnce(Return(kManual));
  EXPECT_CALL(*access_remote, Check(who, what)).
      WillOnce(Return(TypeAccess::kAllowed));

  EXPECT_EQ(TypeAccess::kAllowed,
            manager->CheckAccess("dev1", "12345", zone, "RADIO", "",
                                 RemoteControlParams()));
}

TEST_F(PolicyManagerImplTest, TwoDifferentDevice) {
  Subject who1 = {"dev1", "12345"};
  Subject who2 = {"dev2", "123456"};
  SeatLocation zone = {0, 0, 0};
  Object what = {policy_table::MT_RADIO, zone};

  EXPECT_CALL(*access_remote,
              CheckModuleType("12345", policy_table::MT_RADIO)).
      WillOnce(Return(true));
  EXPECT_CALL(*access_remote, IsPrimaryDevice("dev1")).WillOnce(Return(true));

  EXPECT_CALL(*access_remote,
              CheckModuleType("123456", policy_table::MT_RADIO)).
      WillOnce(Return(true));
  EXPECT_CALL(*access_remote, IsPrimaryDevice("dev2")).WillOnce(Return(false));
  EXPECT_CALL(*access_remote, IsEnabled()).WillOnce(Return(true));
  EXPECT_CALL(*access_remote, CheckParameters(_,_,_)).WillOnce(Return(kManual));
  EXPECT_CALL(*access_remote, Check(who2, what)).
        WillOnce(Return(TypeAccess::kDisallowed));

  EXPECT_EQ(TypeAccess::kAllowed,
            manager->CheckAccess("dev1", "12345", zone, "RADIO", "",
                                 RemoteControlParams()));
  EXPECT_EQ(TypeAccess::kDisallowed,
              manager->CheckAccess("dev2", "123456", zone, "RADIO", "",
                                   RemoteControlParams()));
}

TEST_F(PolicyManagerImplTest, CheckPTURemoteCtrlChange) {
  utils::SharedPtr<policy_table::Table> update = new policy_table::Table();
  utils::SharedPtr<policy_table::Table> snapshot = new policy_table::Table();
  rpc::Optional<rpc::Boolean>& new_consent = update->policy_table.module_config
      .country_consent_passengersRC;
  rpc::Optional<rpc::Boolean>& old_consent = snapshot->policy_table
      .module_config.country_consent_passengersRC;

  EXPECT_CALL(*listener, OnRemoteAllowedChanged(true)).Times(4);

  // Both are not initialized
  EXPECT_FALSE(CheckPTURemoteCtrlChange(update, snapshot));

  *old_consent = true;
  *new_consent = true;
  EXPECT_FALSE(CheckPTURemoteCtrlChange(update, snapshot));

  *old_consent = false;
  *new_consent = false;
  EXPECT_FALSE(CheckPTURemoteCtrlChange(update, snapshot));

  *old_consent = true;
  *new_consent = false;
  EXPECT_TRUE(CheckPTURemoteCtrlChange(update, snapshot));

  *old_consent = false;
  *new_consent = true;
  EXPECT_TRUE(CheckPTURemoteCtrlChange(update, snapshot));

  snapshot = new policy_table::Table();

  // snapshot is not initialized, update is true
  *new_consent = true;
  EXPECT_FALSE(CheckPTURemoteCtrlChange(update, snapshot));

  // snapshot is not initialized, update is false
  *new_consent = false;
  EXPECT_TRUE(CheckPTURemoteCtrlChange(update, snapshot));

  update = new policy_table::Table();

  // snapshot is true, update is not initialized
  *(snapshot->policy_table.module_config
      .country_consent_passengersRC) = true;
  EXPECT_FALSE(CheckPTURemoteCtrlChange(update, snapshot));

  // snapshot is false, update is not initialized
  *(snapshot->policy_table.module_config
      .country_consent_passengersRC) = false;
  EXPECT_TRUE(CheckPTURemoteCtrlChange(update, snapshot));
}
#endif  // SDL_REMOTE_CONTROL

} // namespace policy
