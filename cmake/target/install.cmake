##############################################################################################################

function(install_target target)
    install(
        TARGETS ${target}
        EXPORT  ${target}-targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    get_target_property(type ${target} TYPE)
    if ("${type}" STREQUAL "INTERFACE_LIBRARY")
        install_from_target(INTERFACE_HEADERS ${CMAKE_INSTALL_INCLUDEDIR} ${target})
        install_from_target(INTERFACE_CMAKE   ${CMAKE_INSTALL_DATADIR}/cmake/${target} ${target})
        install_from_target(INTERFACE_CONFIGS ${CMAKE_INSTALL_SYSCONFDIR}/${target} ${target})
        install_from_target(INTERFACE_DATA    ${CMAKE_INSTALL_DATADIR}/${target} ${target})
    else()
        install_from_target(PUBLIC_HEADERS ${CMAKE_INSTALL_INCLUDEDIR} ${target})
        install_from_target(PUBLIC_CMAKE   ${CMAKE_INSTALL_DATADIR}/cmake/${target} ${target})
        install_from_target(PUBLIC_CONFIGS ${CMAKE_INSTALL_SYSCONFDIR}/${target} ${target})
        install_from_target(PUBLIC_DATA    ${CMAKE_INSTALL_DATADIR}/${target} ${target})
        install_from_target(PUBLIC_SYSTEMD ${CMAKE_INSTALL_LIBDIR}/systemd/system/ ${target})
    endif()

    # install cmake configs
    get_target_property(exportFile ${target} INTERFACE_EXPORT_FILE)
    get_target_property(confFile   ${target} INTERFACE_CONF_FILE)
    get_target_property(verFile    ${target} INTERFACE_VERSION_FILE)

    if (NOT "${confFile}" STREQUAL "")
        install(FILES
            ${confFile}
            ${verFile}
            DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/${target}
        )
    endif()

    if (NOT "${exportFile}" STREQUAL "")
        install(
            EXPORT ${target}-targets
            DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/${target}
            FILE ${exportFile}
        )
    endif()

    # install pkg config
    get_target_property(pkgFile ${target} INTERFACE_PKG_FILE)
    if (NOT "${pkgFile}" STREQUAL "")
        install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${target}.pc
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig/
        )
    endif()
endfunction()

##############################################################################################################

function(install_from_target propname destination target)
    get_target_property(what ${target} ${propname})
    if(what)
        foreach(file ${what})
            get_filename_component(dir ${file} DIRECTORY)
            install(FILES ${file} DESTINATION ${destination}/${dir} COMPONENT ${component})
        endforeach()
    endif()
endfunction()

##############################################################################################################
