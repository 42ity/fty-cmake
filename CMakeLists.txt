cmake_minimum_required(VERSION 3.13)
cmake_policy(VERSION 3.13)

##############################################################################################################
project(fty-cmake
    VERSION     1.0
    DESCRIPTION "Fty cmake support"
)
##############################################################################################################
include(cmake/fty-cmake.cmake)
##############################################################################################################

etn_target(interface ${PROJECT_NAME}
    CMAKE
        cmake/external.cmake
        cmake/fty-cmake.cmake
        cmake/memcheck.cmake
        cmake/warnings.cmake

        cmake/target/export.cmake
        cmake/target/flags.cmake
        cmake/target/resolve.cmake
        cmake/target/target.cmake
        cmake/target/uses.cmake
        cmake/target/version.cmake
        cmake/target/install.cmake
        cmake/templates/package.pc.in

        cmake/external/catch2/CMakeLists.txt.in
        cmake/external/catch2/catch2.cmake

        cmake/external/cxxtools/CMakeLists.txt.in
        cmake/external/cxxtools/cxxtools.cmake

        cmake/external/googletest/CMakeLists.txt.in
        cmake/external/googletest/googletest.cmake

        cmake/external/tntdb/CMakeLists.txt.in
        cmake/external/tntdb/tntdb.cmake
)
