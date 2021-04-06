include(CMakePackageConfigHelpers)

##############################################################################################################

function(export_target target)
    # check if .cmake are actually needed (-dev pkg, exporting public includes and .so)
    if ( args_PUBLIC_INCLUDE_DIR OR args_PUBLIC_HEADERS )
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
    else()
        message ( "-- Disabling CMake files support (not requested / needed)" )
        etn_set_custom_property(${target} CMAKE_EXPORT_FILE  "")
        etn_set_custom_property(${target} CMAKE_CONFIG_FILE  "")
        etn_set_custom_property(${target} CMAKE_VERSION_FILE "")
    endif()

    # Pkg config
    get_target_property(type ${target} TYPE)
    if (type STREQUAL "INTERFACE_LIBRARY")
        if (TARGET ${tar}-props)
            get_target_property(dir ${target}-props BINARY_DIR)
            get_target_property(src ${target}-props SOURCE_DIR)
            get_target_property(_inc ${target}-props INTERFACE_INCLUDE_DIR)
        endif()
    else()
        get_target_property(dir ${target} BINARY_DIR)
        get_target_property(src ${target} SOURCE_DIR)
        get_target_property(_inc ${target} TARGET_INCLUDE_DIR)
        if (src AND NOT _inc)
            set(inc ${src})
        endif()
        if (_inc AND src)
            set(inc ${src}/${_inc})
        endif()
    endif()

    if(type STREQUAL "INTERFACE_LIBRARY")
        set(LIB_TARGET "")
    else()
        set(LIB_TARGET "-l${target}")
    endif()

    # Local build pkg file
    set(pgkname    ${CMAKE_CURRENT_BINARY_DIR}/lib${target}.pc)
    set(prefix     ${dir})
    set(libdir     ${dir})
    set(includedir ${inc})

    # Use existing pkgconfig file, if provided
    if (EXISTS ${src}/${target}.pc.in)
        configure_file(${src}/${target}.pc.in ${pgkname} @ONLY)
    else()
        # Otherwise, check if it's actually needed (-dev pkg, exporting public includes and .so)
        if ( args_PUBLIC_INCLUDE_DIR OR args_PUBLIC_HEADERS )
            configure_file(${templates}/package.pc.in ${pgkname} @ONLY)
        endif()
    endif()

    # Exported pkg file
    #set(pgkname    ${CMAKE_CURRENT_BINARY_DIR}/export/lib${target}.pc)
    set(prefix     ${CMAKE_INSTALL_PREFIX})
    set(libdir     ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
    set(includedir ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})

    if ( args_PUBLIC_INCLUDE_DIR OR args_PUBLIC_HEADERS )
        etn_set_custom_property(${target} CMAKE_PKG_FILE ${pgkname})
    else()
        message ( "-- Disabling pkgconfig support (not requested / needed)" )
        etn_set_custom_property(${target} CMAKE_PKG_FILE "")
    endif()
endfunction()

##############################################################################################################
