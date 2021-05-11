
add_dependecy(mlm
    GIT          "https://github.com/42ity/malamute.git"
    VERSION      "1.0-FTY-master"
    LIB_OUTPUT   "lib/libmlm.so"
    DEPENDENCIES czmq
    AUTOCONF
)
