##############################################################################################################

function(set_cppflags name flags extraFlags)
    get_target_property(type ${name} TYPE)
    if (NOT "${type}" STREQUAL "INTERFACE_LIBRARY")
        separate_arguments(args NATIVE_COMMAND ${WARNINGS_STR})
        target_compile_options(${name} PRIVATE ${args})
        set_target_properties(${name} PROPERTIES CXX_STANDARD 17)
    endif()

    if (${flags})
        target_compile_options(${name} PRIVATE ${${flags}})
    endif()
    if (${extraFlags})
        target_compile_options(${name} PRIVATE ${${extraFlags}})
    endif()
endfunction()

##############################################################################################################

function(preprocessor name options)
    if (${options})
        target_compile_definitions(${name} PUBLIC ${${options}})
    endif()
endfunction()

##############################################################################################################
