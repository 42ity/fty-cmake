
add_dependecy(tntdb
    GIT          "https://github.com/42ity/tntdb.git"
    VERSION      "ub-fix"
    LIB_OUTPUT   "lib/libtntdb.so"
    SRC_PREFIX   "tntdb"
    DEPENDENCIES cxxtools
    AUTOCONF
)
