export KERL_BUILD_DOCS="yes"
export KERL_INSTALL_MANPAGES="yes"
export KERL_INSTALL_HTMLDOCS="yes"
export KERL_CONFIGURE_OPTIONS="--disable-debug \
  --without-javac \
  --with-ssl=$(brew --prefix openssl@3) \
  --with-wx"
