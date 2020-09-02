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
        cmake/target/properties.cmake
        cmake/templates/package.pc.in

        cmake/external/*
)

etn_configure_file(${PROJECT_NAME})
