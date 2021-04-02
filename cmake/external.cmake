# This cmake loads the list of externals

# Standalone mode manages dependencies with externals
include(ProcessorCount)

function(getAllTargets var)
    set(targets)
    getAllTargetsRecursive(targets ${CMAKE_SOURCE_DIR})
    set(${var} ${targets} PARENT_SCOPE)
endfunction()

macro(getAllTargetsRecursive targets dir)
    get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirectories})
        getAllTargetsRecursive(${targets} ${subdir})
    endforeach()

    get_property(currentTargets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
    list(APPEND ${targets} ${currentTargets})
endmacro()


function(add_dependecy name)
    cmake_parse_arguments(args
        ""
        "VERSION"
        "LIB_OUTPUT;HEADER_OUTPUT;DEPENDENCIES"
        ${ARGN}
    )

    foreach(dep ${args_DEPENDENCIES})
        resolve(${dep})
    endforeach()

    ProcessorCount(NBJOBS)
    if(NBJOBS EQUAL 0)
        set(NBJOBS 1)
    endif()

    set(VERSION        ${args_VERSION})
    set(INSTALL_PREFIX ${CMAKE_BINARY_DIR}/deps-runtime)
    set(SRC_DIR        ${CMAKE_BINARY_DIR}/deps-src/${name})
    set(BUILD_DIR      ${CMAKE_BINARY_DIR}/deps-build/${name})
    set(DOWNLOAD_DIR   ${CMAKE_BINARY_DIR}/deps-download/${name})

    getAllTargets(allTargets)
    set(EXTERN_CMAKE_FLAGS)
    set(_PKG_PATH)
    set(_EXTERN_LDFLAGS)
    set(_EXTERN_CXXFLAGS)
    foreach(tar ${allTargets})
        unset(dir)
        unset(_inc)
        unset(src)
        if(NOT (tar MATCHES "-props$" OR tar MATCHES "_build$"))
            get_target_property(type ${tar} TYPE)
            if ("${type}" STREQUAL "INTERFACE_LIBRARY")
                if (TARGET ${tar}-props)
                    get_target_property(dir ${tar}-props BINARY_DIR)
                    get_target_property(src ${tar}-props SOURCE_DIR)
                    get_target_property(_inc ${tar}-props INTERFACE_INCLUDE_DIR)
                endif()
            else()
                get_target_property(dir ${tar} BINARY_DIR)
                get_target_property(src ${tar} SOURCE_DIR)
                get_target_property(_inc ${tar} TARGET_INCLUDE_DIR)
                if (src AND NOT _inc)
                    set(inc ${src})
                endif()
                if (_inc AND src)
                    set(inc ${src}/${_inc})
                endif()
            endif()

            if (dir)
                set(EXTERN_CMAKE_FLAGS "${EXTERN_CMAKE_FLAGS} -D${tar}_DIR=${dir}")
                list(APPEND _EXTERN_LDFLAGS -L${dir})
                list(APPEND _PKG_PATH ${dir})
            endif()
            if (inc)
                list(APPEND _EXTERN_CXXFLAGS -I${inc})
            endif()
        endif()
    endforeach()

    list(REMOVE_DUPLICATES _EXTERN_LDFLAGS)
    string(REPLACE ";" " " EXTERN_LDFLAGS "${_EXTERN_LDFLAGS}")

    list(REMOVE_DUPLICATES _EXTERN_CXXFLAGS)
    string(REPLACE ";" " " EXTERN_CXXFLAGS "${_EXTERN_CXXFLAGS}")

    list(REMOVE_DUPLICATES _PKG_PATH)
    string(REPLACE ";" ":" PKG_PATH "${_PKG_PATH}")

    configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in
        ${DOWNLOAD_DIR}/CMakeLists.txt
    )

    set(output)
    set(liboutput)
    set(headoutput)
    foreach(out ${args_LIB_OUTPUT})
        list(APPEND liboutput ${INSTALL_PREFIX}/${out})
        list(APPEND output ${INSTALL_PREFIX}/${out})
    endforeach()

    foreach(out ${args_HEADER_OUTPUT})
        list(APPEND headoutput ${INSTALL_PREFIX}/${out})
        list(APPEND output ${INSTALL_PREFIX}/${out})
    endforeach()

    add_custom_command(
        OUTPUT  ${output}
        COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
        COMMAND ${CMAKE_COMMAND} --build .
        WORKING_DIRECTORY ${DOWNLOAD_DIR}
    )

    string(REPLACE "::" "-" sName ${name})

    add_custom_target(
        ${sName}_build
        DEPENDS ${args_DEPENDENCIES} ${output}
        WORKING_DIRECTORY ${DOWNLOAD_DIR}
    )

    # Add cxxtools directly to our build.
    if (NOT TARGET ${name})
        add_library(${sName} INTERFACE)
        if (NOT ${sName} STREQUAL ${name})
            add_library(${name} ALIAS ${sName})
        endif()
        add_dependencies(${sName} ${sName}_build)
        target_include_directories(${sName}
            INTERFACE
                ${INSTALL_PREFIX}/include
        )
        if (args_LIB_OUTPUT)
            target_link_libraries(${sName} INTERFACE ${output})
        endif()
    endif()
endfunction()

