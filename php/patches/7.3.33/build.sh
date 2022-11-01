if [[ ! -v WASI_SDK_ROOT ]]
then
    echo "Please set WASI_SDK_ROOT and run again"
    exit 1
fi
export WASI_SDK_ROOT=$(readlink -f $WASI_SDK_ROOT)

if [[ ! -v WASMLABS_BUILD_OUTPUT ]]
then
    echo "Please set WASMLABS_BUILD_OUTPUT and run again. Artifacts will go to \$WASMLABS_BUILD_OUTPUT/{include/lib/share}"
    exit 1
fi
export WASMLABS_BUILD_OUTPUT=$(readlink -f $WASMLABS_BUILD_OUTPUT)

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATCH_PATH=$THIS_SCRIPT_DIR/patch.v2.diff
if [[ ! -f $PATCH_PATH ]]
then
    echo "Cannot find the patch file in $PATCH_PATH"
    exit 1
fi

pushd $WASMLABS_BUILD_OUTPUT
function onExit {
    popd
}
trap onExit EXIT

mkdir build 2>/dev/null
cd build

#REPO-build-TAG
git clone --depth=1 -b php-7.3.32 https://github.com/php/php-src.git php-src-build-php-7.3.33 && cd php-src-build-php-7.3.33
git apply $PATCH_PATH
./wasmlabs-build.sh
