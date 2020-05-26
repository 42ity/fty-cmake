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
        file(WRITE ${exportCmakeConfigIn} "@PACKAGE_INIT@")
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

message("${FTY_CMAKE_CMAKE_DIR}/templates/")
    if (EXISTS "${FTY_CMAKE_CMAKE_DIR}/templates/")
        set(templates "${FTY_CMAKE_CMAKE_DIR}/templates")
    else()
        set(templates "${CMAKE_CURRENT_LIST_DIR}/cmake/templates")
    endif()


    configure_file(${templates}/package.pc.in ${CMAKE_CURRENT_BINARY_DIR}/${target}.pc @ONLY)

    set_target_properties(${target} PROPERTIES
        INTERFACE_CONF_FILE    ${exportCmakeConfig}
        INTERFACE_VERSION_FILE ${exportVersionFile}
        INTERFACE_PKG_FILE     ${CMAKE_CURRENT_BINARY_DIR}/${target}.pc
    )

endfunction()

##############################################################################################################
