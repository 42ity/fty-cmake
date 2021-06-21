
add_dependecy(fty_common
    GIT          "https://github.com/42ity/fty-common.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_common.so"
    DEPENDENCIES cxxtools fty_common_logging
)
