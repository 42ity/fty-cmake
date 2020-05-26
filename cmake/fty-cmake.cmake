
# Options and default value
option(BUILD_TESTING "Build tests" OFF)
option(BUILD_DOC "Build documentation" OFF)
option(ENABLE_STANDALONE "Enable standalone mode" OFF)

set(FTY_CMAKE_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})

# CMAKE Linux Path
include(GNUInstallDirs) # Linux variables like CMAKE_INSTALL_LIBDIR

#CTest
include(CTest)

# Externals
include(${CMAKE_CURRENT_LIST_DIR}/external.cmake)

# Warnings
include(${CMAKE_CURRENT_LIST_DIR}/warnings.cmake)

## Valgrind
#include(${CMAKE_CURRENT_LIST_DIR}/memcheck.cmake)

# Raven cmake

include(${CMAKE_CURRENT_LIST_DIR}/target/target.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/export.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/version.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/uses.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/flags.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/target/install.cmake)

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
    install_target(${name})

    dump_target(${name})
endmacro()

##############################################################################################################
