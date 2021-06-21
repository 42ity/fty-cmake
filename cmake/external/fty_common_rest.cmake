
add_dependecy(fty_common_rest
    GIT          "https://github.com/42ity/fty-common-rest.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_common_rest.so"
    DEPENDENCIES tntnet fty_common_logging cxxtools czmq fty_common fty_common_db
)
