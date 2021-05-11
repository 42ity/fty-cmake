
add_dependecy(fty_common_messagebus
    GIT          "https://github.com/42ity/fty-common-messagebus.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_common_messagebus.so"
    DEPENDENCIES mlm czmq fty_common_logging
)
