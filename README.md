# fty-cmake
The goal of this project is to store common files used by the 42ity projects with the new cmake structure

## CMAKE
The cmake common settings will:

- include GNUInstallDirs variables 
- include CTest
- create a target memcheck which run the test with valgrind
- set differents warnings
- define macros (more information bellow on each macro)
- define the following options:
```
option(BUILD_TESTING "Build tests" OFF)
option(BUILD_DOC "Build documentation" OFF)
```

To use it you have to add the following into your CMakeLists.txt file:

```
# Use common cmake settings
find_package(fty-cmake)

```

### Dependency management
Dependency management is managed using the [ExternalProject_add](https://cmake.org/cmake/help/v3.13/module/ExternalProject.html) feature of `CMake`.

The [external](cmake/external) directory provides the cmake files to download and build dependencies.

To build the dependencies you need to use the cmake option "ENABLE_STANDALONE=ON"

### Target creation

Target has follow syntax:
```
etn_target([type] [target name] 
    SOURCES 
        [sources list] 
    USES 
        [private dependencies list] 
    USES_PUBLIC 
        [public dependencies]
    INCLUDE_DIRS 
        [include directories]
    PUBLIC 
        [public headers]
    PREPROCESSOR 
        [preprocessor definitions]
    FLAGS 
        [extra compilation flags]
    CMAKE 
        [extra cmake scripts]
    CONFIGS 
        [configs]
```

Where type could be:
 * `exe` - regular executable
 * `static` - static library
 * `shared` - shared library
 * `interface` - non binary library, just headers, configs etc

`USES` and `USES_PUBLIC` are dependencies of the project. Firstly system will try to find dependency in the system. 
If it will not found and ENABLE_STANDALONE is ON then will try to find it in `external` projects and will add it to compilation process.

Example of the project:
```
etn_target(exe ${PROJECT_NAME}
    SOURCES
        src/daemon.cpp
        src/include.hpp
    USES
        tntdb
)
```
