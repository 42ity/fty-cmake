
add_dependecy(fty_asset_activator
    GIT          "https://github.com/42ity/fty-asset-activator.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_asset_activator.so"
    DEPENDENCIES fty-cmake mlm fty_common_logging fty_proto fty_common_mlm
)
