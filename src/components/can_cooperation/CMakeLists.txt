set(target CANCooperation)
set(library_name ${CMAKE_SHARED_LIBRARY_PREFIX}${target}${CMAKE_SHARED_LIBRARY_SUFFIX})
set(install_destination ${CMAKE_BINARY_DIR}/bin/plugins)
set(copy_destination ${CMAKE_BINARY_DIR}/src/appMain/plugins)

option(ENABLE_TEST_COV_COUNT "Enable compilation flags to count test coverage" OFF)

if (ENABLE_TEST_COV_COUNT)
  set(GCOV_FLAGS "-ftest-coverage -fprofile-arcs")
else()
  set(GCOV_FLAGS "")
endif()

set(CMAKE_CXX_FLAGS "-fPIC -std=gnu++0x -Wall -Werror ${GCOV_FLAGS}")

if (CMAKE_BUILD_TYPE)
  if (${CMAKE_BUILD_TYPE} STREQUAL "Release")
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG")
    set(CMAKE_CXX_FLAGS_DEBUG "")
  else ()
    set(CMAKE_CXX_FLAGS_RELEASE "")
    set(CMAKE_CXX_FLAGS_DEBUG "-g3 -ggdb3 -DDEBUG")
  endif()
endif()

include_directories (
  ./include/
  ../include/
  ../functional_module/include/
  ../application_manager/include
  ../connection_handler/include/
  ${JSONCPP_INCLUDE_DIRECTORY}
  ${LOG4CXX_INCLUDE_DIRECTORY}
  ${CMAKE_BINARY_DIR}/src/components/
)

set (SOURCES
    ./src/can_module.cc
    ./src/can_app_extension.cc
    ./src/can_tcp_connection.cc
    ./src/can_module_event.cc
    ./src/mobile_command_factory.cc
    ./src/request_controller.cc
    ./src/message_helper.cc
    ./src/command/base_command_request.cc
    ./src/command/base_command_notification.cc
    ./src/command/grant_access_request.cc
    ./src/command/cancel_access_request.cc
    ./src/command/start_scan_request.cc
    ./src/command/stop_scan_request.cc
    ./src/command/tune_radio_request.cc
    ./src/command/tune_down_request.cc
    ./src/command/tune_up_request.cc
    ./src/command/climate_control_on_request.cc
    ./src/command/get_seat_control_request.cc
    ./src/command/on_radio_details_notification.cc
    ./src/command/on_control_changed_notification.cc
    ./src/command/on_preset_changed_notification.cc
    ./src/validators/validator.cc
    ./src/validators/on_preset_changed_notification_validator.cc
    ./src/validators/radio_station_validator.cc
    ./src/validators/tune_radio_request_validator.cc
    ./src/validators/time_validator.cc
    ./src/validators/address_validator.cc
    ./src/validators/location_validator.cc
    ./src/validators/song_info_validator.cc
    ./src/validators/advertisement_validator.cc
    ./src/validators/event_details_validator.cc
    ./src/validators/web_activity_validator.cc
    ./src/validators/on_radio_details_notification_validator.cc
)

set (LIBRARIES
    jsoncpp
    FunctionalModule
    ApplicationManager
    Utils
)

add_library(${target} SHARED ${SOURCES})
target_link_libraries(${target} ${LIBRARIES} )

if(ENABLE_LOG)
  target_link_libraries("CANCooperation" log4cxx -L${LOG4CXX_LIBS_DIRECTORY})
endif()


install(TARGETS ${target}
  DESTINATION ${install_destination}
  PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
    GROUP_READ GROUP_EXECUTE
    WORLD_READ WORLD_EXECUTE
)

install(
  FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/can_config.json"
  DESTINATION ${install_destination}
)

if(BUILD_TESTS)
  add_subdirectory(test)
endif()