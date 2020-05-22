##############################################################################################################

function(set_cppflags name flags)
    get_target_property(type ${name} TYPE)
    if (NOT "${type}" STREQUAL "INTERFACE_LIBRARY")
        target_compile_options(${name} PRIVATE ${WARNINGS_STR})
    endif()

    if (${flags})
        target_compile_options(${name} PRIVATE ${${flags}})
    endif()
endfunction()

##############################################################################################################

function(preprocessor name options)
    if (${options})
        target_compile_definitions(${name} PUBLIC ${${options}})
    endif()
endfunction()

##############################################################################################################
