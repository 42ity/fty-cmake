# Macro to create a cmake package for a target.


# Macro etn_create_lib_pkgconfig
# Params:
#   TARGET_NAME
#   NAMESPACE 

macro(etn_create_lib_cmake_package)

  if(NOT (${ARGC} EQUAL 2))
    message( FATAL_ERROR "\n etn_create_lib_cmake_package: need at 2 arguments <TARGET> <NAMESPACE>. \n" )
  endif()

  if(NOT (TARGET ${ARGV0}))
    message( FATAL_ERROR "\n etn_create_lib_cmake_package: ${ARGV0} is not a target. \n" )
  endif()

  get_target_property(target_type ${ARGV0} TYPE)
  if (target_type STREQUAL "EXECUTABLE")
    message( FATAL_ERROR "\n etn_create_lib_cmake_package: ${ARGV0} is not a library target but an executable. \n" )
  endif ()

  ####  Create cmake package

  #if create cmake package
  if(CREATE_CMAKE_PKG)
    message("-- Generating cmake package file")

    set(MY_PROJECT_NAME ${ARGV0})
    set(MY_NAMESPACE ${ARGV1})

    #Create the cmake package in the namespace
    export(TARGETS ${MY_PROJECT_NAME} NAMESPACE ${MY_NAMESPACE}:: FILE ${MY_PROJECT_NAME}.cmake)
    set(CMAKE_EXPORT_PACKAGE_REGISTRY ON)
    export(PACKAGE ${MY_PROJECT_NAME})

    #install it
    install(EXPORT ${MY_PROJECT_NAME}
            FILE ${MY_PROJECT_NAME}.cmake
            NAMESPACE ${MY_NAMESPACE}::
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/cmake/${MY_NAMESPACE}
    )

    message("\t${MY_PROJECT_NAME} cmake package will be installed in ${CMAKE_INSTALL_DATAROOTDIR}/cmake/${MY_NAMESPACE}/${MY_PROJECT_NAME}.cmake" )

  endif()
endmacro()