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
    get_target_property(_includeDirs ${target} INCLUDE_DIRECTORIES)
    get_target_property(compileDefinitions ${target} COMPILE_DEFINITIONS)
    get_target_property(compileOptions ${target} COMPILE_OPTIONS)

    get_target_property(_includeDirs1 ${target} INTERFACE_INCLUDE_DIRECTORIES)
    message("=============== ${_includeDirs1}")

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

macro(etn_test_target target)
    if (BUILD_TESTING)
        include(CTest)
        enable_testing()

        if (NOT COMMAND catch_discover_tests)
            find_package(Catch2 REQUIRED)
            include(Catch)
            #include(catch_discover_tests)
        endif()

        get_target_property(type ${target} TYPE)
        if (type STREQUAL "INTERFACE_LIBRARY")
            get_target_property(sourceFiles ${target}-props SOURCES)
            get_target_property(linkLibs ${target} INTERFACE_LINK_LIBRARIES)
            get_target_property(compileDefinitions ${target}-props COMPILE_DEFINITIONS)
            get_target_property(compileOptions ${target}-props COMPILE_OPTIONS)
            get_target_property(_srcDir ${target}-props SOURCE_DIR)
            get_target_property(_inc ${target}-props INTERFACE_INCLUDE_DIR)
        else()
            get_target_property(sourceFiles ${target} SOURCES)
            get_target_property(linkLibs ${target} LINK_LIBRARIES)
            get_target_property(compileDefinitions ${target} COMPILE_DEFINITIONS)
            get_target_property(compileOptions ${target} COMPILE_OPTIONS)
            get_target_property(_srcDir ${target} SOURCE_DIR)
            get_target_property(_inc ${target} TARGET_INCLUDE_DIR)
        endif()

        if (_srcDir AND NOT _inc)
            set(inc ${_srcDir})
        endif()
        if (_inc AND _srcDir)
            set(inc ${_srcDir}/${_inc})
        endif()

        set(includeDirs)
        etn_get_custom_property(privLibs ${target} PRIVATE_INCLUDE)
        if (privLibs)
            foreach(inc ${privLibs})
                list(APPEND includeDirs ${inc})
            endforeach()
        endif()
        list(REMOVE_DUPLICATES includeDirs)

        cmake_parse_arguments(args "" "SUBDIR" "SOURCES;USES;PREPROCESSOR;FLAGS;CONFIGS;INCLUDE_DIRS" ${ARGN})

        # create unit test
        message(STATUS "Creating ${target}-test target")
        etn_target(exe ${target}-test PRIVATE
            CONFIGS
                ${args_CONFIGS}
            SOURCES
                ${args_SOURCES}
                ${sourceFiles}
            USES
                ${args_USES}
                Catch2::Catch2
            FLAGS
                ${args_FLAGS}
                ${compileOptions}
            PREPROCESSOR
                ${args_PREPROCESSOR}
                ${compileDefinitions}
            INCLUDE_DIRS
                ${args_INCLUDE_DIRS}
                ${includeDirs}
                ${inc}
        )

        if (linkLibs)
            target_link_libraries(${target}-test PRIVATE ${linkLibs})
        endif()

        catch_discover_tests(${target}-test)

        find_program(LCOV lcov)
        find_program(GCOVR gcovr)
        find_program(GENHTML genhtml)

        if (NOT LCOV)
            message("lcov was not found, please do `apt install lcov`")
        endif()

        if (NOT GCOVR)
            message("gcovr was not found, please do `apt install gcovr`")
        endif()

        if (NOT GENHTML)
            message("genhtml was not found")
        endif()

        if (LCOV AND GENHTML OR GCOVR)
            # create coverage
            message(STATUS "Creating ${target}-coverage target")
            etn_target(exe ${target}-coverage PRIVATE
                CONFIGS
                    ${args_CONFIGS}
                SOURCES
                    ${args_SOURCES}
                    ${sourceFiles}
                USES
                    ${args_USES}
                    Catch2::Catch2
                    gcov
                FLAGS
                    ${args_FLAGS}
                    ${compileOptions}
                PREPROCESSOR
                    ${args_PREPROCESSOR}
                    ${compileDefinitions}
                INCLUDE_DIRS
                    ${args_INCLUDE_DIRS}
                    ${includeDirs}
                    ${inc}
            )

            if (CMAKE_COMPILER_IS_GNUCC)
                target_compile_options(${target}-coverage PRIVATE -coverage -g -O0 -fno-inline -fno-inline-small-functions -fno-default-inline -fprofile-arcs -ftest-coverage)
            else()
                target_compile_options(${target}-coverage PRIVATE -coverage -g -O0 -fno-inline -fprofile-arcs -ftest-coverage)
            endif()
            target_link_options(${target}-coverage PRIVATE -coverage)
            if (linkLibs)
                target_link_libraries(${target}-coverage PRIVATE ${linkLibs})
            endif()

            set_target_properties(${target}-coverage PROPERTIES EXCLUDE_FROM_ALL TRUE)

            set(out ${CMAKE_BINARY_DIR}/capture/${target})
            set(base ${CMAKE_CURRENT_SOURCE_DIR})
            set(work ${CMAKE_CURRENT_BINARY_DIR})
            if (args_SUBDIR)
                set(base ${base}/${args_SUBDIR})
            endif()

            file(MAKE_DIRECTORY ${out})

            if (LCOV AND GENHTML)
                file(APPEND ${CMAKE_BINARY_DIR}/coverage-local.targets "
                    cmake --build ${CMAKE_BINARY_DIR} --target ${target}-coverage
                    ${LCOV} -d ${work}  -b ${base} --zerocounters
                    ${LCOV} -c -i -d ${work} -b ${base} -o ${out}/${target}.base
                    ${CMAKE_CURRENT_BINARY_DIR}/${target}-coverage
                    ${LCOV} -d ${work} -b ${base} --capture --rc lcov_branch_coverage=1 --output-file ${out}/${target}.capture
                    ${LCOV} -a ${out}/${target}.base -a ${out}/${target}.capture --output-file ${out}/${target}.total
                    ${LCOV} --remove ${out}/${target}.total --output-file ${out}/${target}.info '/usr/*'
                    ${GENHTML} --demangle-cpp --ignore-errors source -o ${out}/${target} ${out}/${target}.info
                ")
            endif()

            if (GCOVR)
                file(APPEND ${CMAKE_BINARY_DIR}/coverage.targets "
                    cmake --build ${CMAKE_BINARY_DIR} --target ${target}-coverage
                    cd ${CMAKE_CURRENT_BINARY_DIR}/
                    ${CMAKE_CURRENT_BINARY_DIR}/${target}-coverage
                    cd ~
                    ${GCOVR} -x -r ${base} --xml-pretty --print-summary --object-directory ${work} -o ${out}/${target}.xml -f ${_srcDir}
                ")
            endif()

            get_property(tars DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY COVERAGE_TARGETS)
            set_property(DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY COVERAGE_TARGETS ${tars})
        endif()

    endif()
endmacro()

