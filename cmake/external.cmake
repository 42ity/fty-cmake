# This cmake loads the list of externals

# Standalone mode manages dependencies with externals
include(ProcessorCount)

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

