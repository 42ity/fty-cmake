
add_dependecy(fty_common_db
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_common_db.so"
    DEPENDENCIES tntdb fty_common_logging fty_common czmq
)
