#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

# export CFLAGS_CONFIG="-O3 -g"
export CFLAGS_CONFIG="-O2"

export CFLAGS_WASI="--sysroot=${WASI_SYSROOT} -D_WASI_EMULATED_GETPID -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS"
export LDFLAGS_WASI="--sysroot=${WASI_SYSROOT} -lwasi-emulated-getpid -lwasi-emulated-signal -lwasi-emulated-process-clocks"

export CFLAGS_SQLITE='-DSQLITE_OMIT_LOAD_EXTENSION=1'
export LDFLAGS_SQLITE='-lsqlite3'

export CFLAGS_PHP='-D_POSIX_SOURCE=1 -D_GNU_SOURCE=1 -DHAVE_FORK=0 -DWASM_WASI -DWASM_WASMEDGE'

# We need to add LDFLAGS to CFLAGS because autoconf compiles(+links) to binary when checking stuff
export LDFLAGS="${LDFS} ${LDFLAGS_WASI} ${LDFLAGS_DEPENDENCIES} ${LDFLAGS_SQLITE} ${LDFLAGS}"
export CFLAGS="${CFS} ${CFLAGS_CONFIG} ${CFLAGS_WASI} ${CFLAGS_SQLITE} ${CFLAGS_DEPENDENCIES} ${CFLAGS_PHP} ${LDFLAGS} ${CFLAGS}"

cd "${WASMLABS_CHECKOUT_PATH}"

logStatus "Generating configure script... "
./buildconf --force || exit 1

export PHP_CONFIGURE='--with-wasmedge --without-libxml --disable-dom --without-iconv --without-openssl --disable-simplexml --disable-xml --disable-xmlreader --disable-xmlwriter --without-pear --disable-phar --disable-opcache --disable-zend-signals --without-pcre-jit --with-sqlite3 --enable-pdo --with-pdo-sqlite'

logStatus "Configuring build with '${PHP_CONFIGURE}'... "
./configure --host=wasm32-wasi host_alias=wasm32-musl-wasi --target=wasm32-wasi target_alias=wasm32-musl-wasi ${PHP_CONFIGURE} || exit 1

logStatus "Building php-cgi... "
make cgi cli || exit 1

logStatus "Preparing artifacts... "
mkdir -p ${WASMLABS_OUTPUT}/bin 2>/dev/null || exit 1

cp sapi/cgi/php-cgi ${WASMLABS_OUTPUT}/bin/ || exit 1
cp sapi/cli/php ${WASMLABS_OUTPUT}/bin/ || exit 1

logStatus "DONE. Artifacts in ${WASMLABS_OUTPUT}"
