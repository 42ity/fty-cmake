# CMake that contains clang related functions

function(install_clang_files)

  # Copy .clang-format to top project directory
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_LIST_DIR}/../clang/.clang-format
    ${CMAKE_SOURCE_DIR}/.clang-format
    )

  # Copy .clang-tidy to top project directory
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_LIST_DIR}/../clang/.clang-tidy
    ${CMAKE_SOURCE_DIR}/.clang-tidy
    )

endfunction()
