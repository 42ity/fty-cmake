# Macro to create a pkgconfig for a target.

set_property(GLOBAL PROPERTY PKGCONFIG_TEMPLATE_PATH "${CMAKE_CURRENT_LIST_DIR}/package.pc.cmake.in")

# Macro etn_create_lib_pkgconfig
# Params:
#   TARGET_NAME
#   CFLAGS (optionnal)
#   LIBRARIES (optionnal)

macro( etn_create_lib_pkgconfig )

  if((${ARGC} GREATER 3))
    message( FATAL_ERROR "\n etn_create_lib_cmake_package: need at 3 arguments <TARGET> [<CFLAGS>] [<LIBRARIES>]. \n" )
  endif()

  if(NOT (TARGET ${ARGV0}))
    message( FATAL_ERROR "\n etn_create_lib_cmake_package: ${ARGV0} is not a target. \n" )
  endif()

  get_target_property(target_type ${ARGV0} TYPE)
  if (target_type STREQUAL "EXECUTABLE")
    message( FATAL_ERROR "\n etn_create_lib_cmake_package: ${ARGV0} is not a library target but an executable. \n" )
  endif ()

  #if create pkgconfig
  if(CREATE_PKGCONFIG)
    message("-- Generating pkgconfig file")

    set(MY_TARGET_NAME ${ARGV0})

    set(PKGCONFIG_CFLAGS_LIST "")
    if(${ARGC} GREATER 1)
      set(PKGCONFIG_CFLAGS_LIST ${ARGV1})
    endif()

    if(${ARGC} EQUAL 3)
      set(LIBRARY_LIST ${ARGV2})
    else()
      get_target_property(TARGET_INTERFACE_LINK_LIBRARIES ${PROJECT_NAME} INTERFACE_LINK_LIBRARIES)
      set(LIBRARY_LIST ${TARGET_INTERFACE_LINK_LIBRARIES})
    endif()

    set(PKGCONFIG_LIBRARY_LIST "")
    foreach(LIB IN LISTS LIBRARY_LIST)
      set(PKGCONFIG_LIBRARY_LIST "${PKGCONFIG_LIBRARY_LIST}-l${LIB} ")
    endforeach()

    message("\tpkgconfig Cflags: ${PKGCONFIG_CFLAGS_LIST}")
    message("\tpkgconfig Libs:   ${PKGCONFIG_LIBRARY_LIST}")

    get_property(PKGCONFIG_TEMPLATE GLOBAL PROPERTY PKGCONFIG_TEMPLATE_PATH)

    #configure pkgconfig file
    configure_file( ${PKGCONFIG_TEMPLATE}
                    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc @ONLY)

    message("\tpkgconfig file created: ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc")

    #install it
    #install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig )
  endif()
endmacro()