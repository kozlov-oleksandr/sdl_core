if (ENABLE_GCOV)
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

set(GCOV gcov)

include_directories (
  ./include/
  ../include/
  ../application_manager/include
  ../connection_handler/include/
  ../utils/include
  ../config_profile/include
  ${JSONCPP_INCLUDE_DIRECTORY}
  ${LOG4CXX_INCLUDE_DIRECTORY}
  ${CMAKE_BINARY_DIR}/src/components/
)

set (SOURCES
    ./src/generic_module.cc
    ./src/plugin_manager.cc
    ./src/settings.cc
)

add_library("FunctionalModule" ${SOURCES})

if(ENABLE_LOG)
  target_link_libraries("FunctionalModule" log4cxx -L${LOG4CXX_LIBS_DIRECTORY} ${GCOV})
endif()

if(BUILD_TESTS)
  add_subdirectory(test)
endif()
