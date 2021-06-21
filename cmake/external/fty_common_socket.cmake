
add_dependecy(fty_common_socket
    GIT          "https://github.com/42ity/fty-common-socket.git"
    VERSION      "master"
    LIB_OUTPUT   "lib/libfty_common_socket.so"
    DEPENDENCIES cxxtools fty_common_logging fty_common
)
