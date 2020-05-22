
# Options and default value
option(BUILD_TESTING "Build tests" OFF)
option(BUILD_DOC "Build documentation" OFF)
option(CREATE_PKGCONFIG "Create package config file" OFF)
option(CREATE_CMAKE_PKG "Create cmake packages" OFF)
option(ENABLE_STANDALONE "Enable standalone mode" ON)

set(FTY_PROJECT_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})

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

include(${CMAKE_CURRENT_LIST_DIR}/target/target.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/export.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/version.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/uses.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/flags.cmake)

##############################################################################################################

macro(disable_etn_target Type Name)
endmacro()

##############################################################################################################

macro(etn_target type name)
    cmake_parse_arguments(args
        ""
        "OUTPUT"
        "SOURCES;USES;INCLUDE_DIRS;PUBLIC;PREPROCESSOR;FLAGS;CMAKE;CONFIGS;USES_PUBLIC"
        ${ARGN}
    )

    create_target(${name} ${type} OUTPUT ${args_OUTPUT} SOURCES ${args_SOURCES} PUBLIC ${args_PUBLIC} CMAKE ${args_CMAKE} CONFIGS ${args_CONFIGS})
    setup_includes(${name} args_INCLUDE_DIRS)
    setup_version(${name})
    parse_using(${name} args_USES args_USES_PUBLIC)
    set_cppflags(${name} args_FLAGS)
    preprocessor(${name} args_PREPROCESSOR)
    export_target(${name})

    dump_target(${name})
endmacro()

##############################################################################################################

#if(${CMAKE_BUILD_TYPE} MATCHES "Debug")
#  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 -DDEBUG")
#  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O0")
#  # For pretty print of file name in traces
#  set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D__FILENAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"'" )
#else()
#  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
#endif()
