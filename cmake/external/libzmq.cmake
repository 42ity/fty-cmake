
add_dependecy(libzmq
    GIT          "https://github.com/42ity/libzmq.git"
    VERSION      "4.2.0-FTY-master"
    LIB_OUTPUT   "lib/libzmq.so"
    DEPENDENCIES libsodium
    AUTOCONF
)
