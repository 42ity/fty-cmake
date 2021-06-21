add_dependecy(nutclient
    GIT          "https://github.com/42ity/nut.git"
    VERSION      "release/IPM-2.3.0"
    LIB_OUTPUT   "lib/libnutclient.so"
    AUTOCONF
    EXTRA_ARGS   --with-augeas-lenses-dir=@INSTALL_PREFIX@/share/augeas/lenses
                 --with-dev
)
