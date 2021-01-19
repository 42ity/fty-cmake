include(CMakePackageConfigHelpers)

##############################################################################################################

function(export_target target)
    set(exportCmakeFile   ${target}-targets.cmake)
    set(exportCmakeConfig ${target}-config.cmake)
    set(exportVersionFile ${CMAKE_CURRENT_BINARY_DIR}/${target}-config-version.cmake)

    export(TARGETS ${target} FILE ${exportCmakeFile})

    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${exportCmakeConfig}.in)
        set(exportCmakeConfigIn ${CMAKE_CURRENT_BINARY_DIR}/${target}-config.cmake.in)
        set(exportCmakeConfig ${CMAKE_CURRENT_BINARY_DIR}/${target}-config.cmake)
        file(WRITE ${exportCmakeConfigIn} "@PACKAGE_INIT@\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/${exportCmakeFile}\")")
    else()
        set(exportCmakeConfigIn ${CMAKE_CURRENT_SOURCE_DIR}/${exportCmakeConfig}.in)
        set(exportCmakeConfig ${CMAKE_CURRENT_BINARY_DIR}/${target}-config.cmake)
    endif()

    set(CMAKE_INSTALL_DIR ${CMAKE_INSTALL_DATAROOTDIR}/cmake/${target})

    configure_package_config_file(
        ${exportCmakeConfigIn}
        ${exportCmakeConfig}
        INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${target}/cmake
        PATH_VARS CMAKE_INSTALL_DIR CMAKE_INSTALL_BINDIR CMAKE_INSTALL_LIBDIR CMAKE_INSTALL_INCLUDEDIR
    )

    write_basic_package_version_file(
        ${exportVersionFile}
        VERSION ${PACKAGE_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    if (EXISTS "${FTY_CMAKE_CMAKE_DIR}/templates/")
        set(templates "${FTY_CMAKE_CMAKE_DIR}/templates")
    else()
        set(templates "${CMAKE_CURRENT_LIST_DIR}/cmake/templates")
    endif()

    etn_set_custom_property(${target} CMAKE_EXPORT_FILE  ${exportCmakeFile})
    etn_set_custom_property(${target} CMAKE_CONFIG_FILE  ${exportCmakeConfig})
    etn_set_custom_property(${target} CMAKE_VERSION_FILE ${exportVersionFile})

    get_target_property(type ${target} TYPE)
    if (NOT type STREQUAL "EXECUTABLE")
        if(type STREQUAL "INTERFACE_LIBRARY")
            set(LIB_TARGET "")
        else()
            set(LIB_TARGET "-l${target}")
        endif()
        configure_file(${templates}/package.pc.in ${CMAKE_CURRENT_BINARY_DIR}/${target}.pc @ONLY)
        etn_set_custom_property(${target} CMAKE_PKG_FILE     ${CMAKE_CURRENT_BINARY_DIR}/${target}.pc)
    endif()
endfunction()

##############################################################################################################
