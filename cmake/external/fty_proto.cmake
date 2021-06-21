
add_dependecy(fty_proto
    GIT          "https://github.com/42ity/fty-proto.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_proto.so"
    DEPENDENCIES mlm fty_common_logging czmq
)
