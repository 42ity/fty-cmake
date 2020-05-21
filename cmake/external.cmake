# This cmake loads the list of externals

# Standalone mode manages dependencies with externals
option(ENABLE_STANDALONE "Enable standalone mode" FALSE)

macro(SUBDIRLIST result dir)
  file(GLOB children ${dir}/*)
  set(dirlist "")
  foreach(child ${children})
    if(IS_DIRECTORY ${child})
      list(APPEND dirlist ${child})
    endif()
  endforeach()
  set(${result} ${dirlist})
endmacro()

if (ENABLE_STANDALONE)
  subdirlist(EXT_MODULE_PATHS ${CMAKE_CURRENT_LIST_DIR}/external)
  set(CMAKE_MODULE_PATH ${EXT_MODULE_PATHS} ${CMAKE_CURRENT_LIST_DIR}/external)
endif()
