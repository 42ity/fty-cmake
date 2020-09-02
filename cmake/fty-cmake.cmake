
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
include(${CMAKE_CURRENT_LIST_DIR}/target/properties.cmake)

##############################################################################################################

macro(disable_etn_target Type Name)
endmacro()

##############################################################################################################

macro(etn_target type name)
    cmake_parse_arguments(args
        "PRIVATE"
        "OUTPUT;PUBLIC_INCLUDE_DIR"
        "SOURCES;USES;USES_PRIVATE;INCLUDE_DIRS;PUBLIC;PUBLIC_HEADERS;PREPROCESSOR;FLAGS;CMAKE;CONFIGS;USES_PUBLIC;DATA;SYSTEMD"
        ${ARGN}
    )

    if (args_PUBLIC_HEADERS)
       set(args_PUBLIC ${args_PUBLIC_HEADERS})
    endif()

    if (args_USES_PRIVATE)
       set(args_USES ${args_USES_PRIVATE})
    endif()

    create_target(${name} ${type}
        OUTPUT  ${args_OUTPUT}
        SOURCES ${args_SOURCES}
        PUBLIC  ${args_PUBLIC}
        CMAKE   ${args_CMAKE}
        CONFIGS ${args_CONFIGS}
        DATA    ${args_DATA}
        SYSTEMD ${args_SYSTEMD}
        PUBLIC_INCLUDE_DIR ${args_PUBLIC_INCLUDE_DIR}
    )

    setup_includes(${name} args_INCLUDE_DIRS "${args_PUBLIC_INCLUDE_DIR}")
    setup_version(${name})
    parse_using(${name} args_USES args_USES_PUBLIC)
    set_cppflags(${name} args_FLAGS)
    preprocessor(${name} args_PREPROCESSOR)
    if (NOT args_PRIVATE)
        export_target(${name})
        install_target(${name})
    endif()

    dump_target(${name})
endmacro()

##############################################################################################################

macro(etn_test name)
    if (NOT COMMAND ParseAndAddCatchTests)
        find_package(Catch2 QUIET)
        if (Catch2)
            include(Catch)
        endif()
    endif()

    etn_target(exe ${name} ${ARGN})

    if (COMMAND ParseAndAddCatchTests)
        ParseAndAddCatchTests(${name})
    else()
        catch_discover_tests(${name})
    endif()
endmacro()

##############################################################################################################
