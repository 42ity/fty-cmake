
add_dependecy(fty_shm
    GIT          "https://github.com/42ity/fty-shm.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_shm.so"
    DEPENDENCIES fty_proto fty_common_logging 
)
