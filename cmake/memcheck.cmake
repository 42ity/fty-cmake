#Add a target "memcheck" to run the test and run a valgrind test.

set(MEMORYCHECK_OPTIONS = "--error-exitcode=1 --leak-check=full")
add_custom_target(memcheck
  COMMAND ${CMAKE_CTEST_COMMAND} 
          --force-new-ctest-process --test-action memcheck
  COMMAND true > "${CMAKE_BINARY_DIR}/Testing/Temporary/MemoryCheckerFinal.log"
  COMMAND cat "${CMAKE_BINARY_DIR}/Testing/Temporary/MemoryChecker.*.log" >> "${CMAKE_BINARY_DIR}/Testing/Temporary/MemoryCheckerFinal.log"
  COMMAND cat "${CMAKE_BINARY_DIR}/Testing/Temporary/MemoryCheckerFinal.log"
  COMMAND test -s "${CMAKE_BINARY_DIR}/Testing/Temporary/MemoryCheckerFinal.log" && exit 33 || exit 0
)