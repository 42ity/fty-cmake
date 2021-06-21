
add_dependecy(fty_common_db
    GIT          "https://github.com/42ity/fty-common-db.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_common_db.so"
    DEPENDENCIES tntdb fty_common_logging fty_common czmq
)
