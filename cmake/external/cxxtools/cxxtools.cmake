# cxxtools.cmake
# Import cxxtools

configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt.in
  cxxtools-download/CMakeLists.txt
  )

# Do not build gtest with all our warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-useless-cast -Wno-pedantic -Wno-sign-conversion" )


# Download and unpack cxxtools at configure time
execute_process(COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cxxtools-download
  )
if(result)
  message(FATAL_ERROR "CMake step for cxxtools failed: ${result}")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build .
  RESULT_VARIABLE result
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/cxxtools-download
  )
if(result)
  message(FATAL_ERROR "Build step for cxxtools failed: ${result}")
endif()

# Add cxxtools directly to our build.
if (NOT TARGET cxxtools)
  include_directories(${CMAKE_CURRENT_BINARY_DIR}/cxxtools-destdir/include)
  link_directories(${CMAKE_CURRENT_BINARY_DIR}/cxxtools-destdir/lib)
endif()
