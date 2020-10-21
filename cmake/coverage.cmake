if (NOT TARGET coverage-local)
    add_custom_target(coverage-local
        COMMAND sh "${CMAKE_BINARY_DIR}/coverage-local.targets"
        COMMENT "Render coverage info/html"
    )
    file(WRITE ${CMAKE_BINARY_DIR}/coverage-local.targets "")
endif()

if (NOT TARGET coverage)
    add_custom_target(coverage
        COMMAND sh "${CMAKE_BINARY_DIR}/coverage.targets"
        COMMENT "Render coverage for cobertura"
    )
    file(WRITE ${CMAKE_BINARY_DIR}/coverage.targets "")
endif()

macro(etn_coverage target)
    cmake_parse_arguments(args "" "SUBDIR" "" ${ARGN})

    find_program(LCOV lcov)
    find_program(GCOVR gcovr)
    find_program(GENHTML genhtml)

    get_target_property(type ${target} TYPE)
    get_target_property(sourceFiles ${target} SOURCES)
    get_target_property(linkLibs ${target} LINK_LIBRARIES)
    get_target_property(includeDirs ${target} INCLUDE_DIRECTORIES)
    get_target_property(compileDefinitions ${target} COMPILE_DEFINITIONS)
    get_target_property(compileOptions ${target} COMPILE_OPTIONS)

    set(newTarget ${target}-coverage)
    if ("${type}" STREQUAL "EXECUTABLE")
        add_executable(${newTarget}
            ${sourceFiles}
        )
    endif()

    target_include_directories(${newTarget} PRIVATE
        ${includeDirs}
    )

    target_link_libraries(${newTarget} PRIVATE
        ${linkLibs}
    )

    if (compileOptions)
        target_compile_options(${newTarget} PRIVATE
            ${compileOptions}
        )
    endif()

    if (compileDefinitions)
        target_compile_definitions(${newTarget} PRIVATE
            ${compileDefinitions}
        )
    endif()

    target_compile_options(${newTarget} PRIVATE --coverage -g -O0 -fno-inline -fkeep-inline-functions)
    target_link_options(${newTarget} PRIVATE -coverage)
    target_link_libraries(${newTarget} PRIVATE gcov)

    set_target_properties(${newTarget} PROPERTIES CXX_STANDARD 17 EXCLUDE_FROM_ALL TRUE)

    add_dependencies(coverage-local ${newTarget})
    add_dependencies(coverage ${newTarget})

    set(out ${CMAKE_BINARY_DIR}/capture/${target})
    set(base ${CMAKE_CURRENT_SOURCE_DIR})
    set(work ${CMAKE_CURRENT_BINARY_DIR})
    if (args_SUBDIR)
        set(base ${CMAKE_CURRENT_SOURCE_DIR}/${args_SUBDIR})
        #set(work ${CMAKE_CURRENT_BINARY_DIR}/${args_SUBDIR})
    endif()

    file(MAKE_DIRECTORY ${out})

    file(APPEND ${CMAKE_BINARY_DIR}/coverage-local.targets "
        ${LCOV} -d ${work}  -b ${base} --zerocounters
        ${LCOV} -c -i -d ${work} -b ${base} -o ${out}/${target}.base
        ${CMAKE_CURRENT_BINARY_DIR}/${newTarget}
        ${LCOV} -no-external -d ${work} -b ${base} --capture --output-file ${out}/${target}.capture
        ${LCOV} -a ${out}/${target}.base -a ${out}/${target}.capture --output-file ${out}/${target}.total
        ${LCOV} --remove ${out}/${target}.total --output-file ${out}/${target}.info
        ${GENHTML} --demangle-cpp --ignore-errors source -o ${out}/${target} ${out}/${target}.info
    ")

    file(APPEND ${CMAKE_BINARY_DIR}/coverage.targets "
        ${CMAKE_CURRENT_BINARY_DIR}/${newTarget}
        ${GCOVR} -x -r ${base} --object-directory ${work} -o ${out}/${target}.xml
    ")

    get_property(tars DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY COVERAGE_TARGETS)
    set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY COVERAGE_TARGETS ${tars})
endmacro()
