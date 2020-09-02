set(ETN_POPULATED_PROPS
    INSTALL_DIR
    CMAKE_DIR
    CONFIG_DIR
    HEADERS_DIR
    CMAKE_EXPORT_FILE
    CMAKE_CONFIG_FILE
    CMAKE_VERSION_FILE
)

function(etn_configure_file target)
    set(targetProps
        NAME
        TYPE
        SOURCE_DIR
        BINARY_DIR
    )

    foreach(prop ${targetProps} ${ETN_POPULATED_PROPS})
        message("++++ ${prop}")
    endforeach()

    #read_target_properties(${target})
endfunction()

function(etn_get_custom_property var target name)
    get_target_property(type ${target} TYPE)
    if(type STREQUAL "INTERFACE_LIBRARY")
        get_target_property(var ${target} INTERFACE_${name})
    else()
        get_target_property(var ${target} TARGET_${name})
    endif()
endfunction()

function(etn_set_custom_property target name value)
    get_target_property(type ${target} TYPE)
    if(type STREQUAL "INTERFACE_LIBRARY")
        set_target_properties(${target} PROPERTIES INTERFACE_${name} "${value}")
    else()
        set_target_properties(${target} PROPERTIES TARGET_${name} "${value}")
    endif()
endfunction()

function(read_target_properties target)
    execute_process(
        COMMAND ${CMAKE_COMMAND} --help-property-list
        OUTPUT_VARIABLE propList
    )

    string(REPLACE ";" "\\\\;" propList "${propList}")
    string(REPLACE "\n" ";" propList "${propList}")
    list(FILTER propList EXCLUDE REGEX "^LOCATION$|^LOCATION_|_LOCATION$")
    list(REMOVE_DUPLICATES propList)

#    get_target_property(type ${target} TYPE)
#    if(type STREQUAL "INTERFACE_LIBRARY")
#    else()
#    endif()

    foreach(prop ${propList})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
        get_target_property(propval ${target} ${prop})
        if (propval)
            get_target_property(propval ${target} ${prop})
            message ("${tgt} ${prop} = ${propval}")
        endif()
    endforeach()
endfunction()
