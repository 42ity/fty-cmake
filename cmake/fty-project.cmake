
# Options and default value
option(BUILD_TESTING "Build tests" OFF)
option(BUILD_DOC "Build documentation" OFF)
option(CREATE_PKGCONFIG "Create package config file" OFF)
option(CREATE_CMAKE_PKG "Create cmake packages" OFF)

# CMAKE Linux Path
include(GNUInstallDirs) # Linux variables like CMAKE_INSTALL_LIBDIR

#CTest
include(CTest)

# Externals
include(${CMAKE_CURRENT_LIST_DIR}/external.cmake)

# Warnings
include(${CMAKE_CURRENT_LIST_DIR}/warnings.cmake)

# Valgrind
include(${CMAKE_CURRENT_LIST_DIR}/memcheck.cmake)

# Cmake package
include(${CMAKE_CURRENT_LIST_DIR}/cmakepackage.cmake)

# Pkgconfig
include(${CMAKE_CURRENT_LIST_DIR}/pkgconfig.cmake)

# Clang
include(${CMAKE_CURRENT_LIST_DIR}/clang.cmake)
install_clang_files()

if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -DDEBUG")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0")
  # For pretty print of file name in traces
  set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__FILENAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"'" )
else()
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
endif()
