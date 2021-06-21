
add_dependecy(fty-asset
    GIT          "https://github.com/42ity/fty-asset.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty-asset.so"
    DEPENDENCIES mlm fty_common_logging fty_common_mlm cxxtools fty_proto
)
