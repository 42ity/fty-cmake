add_dependecy(czmq
    GIT          "https://github.com/42ity/czmq.git"
    VERSION      "v3.0.2-FTY-master"
    LIB_OUTPUT   "lib/libczmq.so"
    DEPENDENCIES libzmq
    AUTOCONF
)
