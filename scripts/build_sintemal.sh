api_level_string="android-25"
api_level="25"
working_dir=`pwd`
lib="lib"
mounted_aosp="/mnt/A46CF1566CF123A8/aosp"
arch_path="generic_x86_64"
debug_binaries=true

dexToOatLibs=(
    "libc.so"
    "libc++.so"
    "libnativebridge.so"
    "libnativehelper.so"
    "libnativeloader.so "
    "libart.so"
    "libart-compiler.so"
    "libvixl.so"
    "libbacktrace.so"
    "libbase.so"
    "liblog.so"
    "libcutils.so"
    "libsigchain.so"
    "libunwind.so"
    "libutils.so"
    "libdl.so"
    "libm.so"
    "liblzma.so"
    "liblz4.so"
)
exe() { echo "\$ $@" ; "$@" ; }
set -e # fail on errors in subcommands
set -u # treat missing variables as errors

echo ""
echo "Build ARTist succeeded!"
echo ""
cd ./app/src/main

echo "Removing old binaries and shared objects"
echo ""

# delete files if they exist but do not fail if they don't (first compilation)
rm ./assets/artist/${api_level_string}/dex2oat || true 
rm ./assets/artist/${api_level_string}/lib/*.so || true

echo "Creating folders if necessary: ./assets/artist/${api_level_string}/lib/"
mkdir -p ./assets/artist/${api_level_string}/lib/ || true

echo ""
echo "Debug binaries will get copied to ${working_dir}/debug/android-${api_level}/${lib}"
mkdir -p ${working_dir}/debug/android-${api_level}/${lib} || true
echo ""

echo "Copying new binaries and shared objects"
echo ""

echo "Copy dex2oat -> ./assets/artist/${api_level_string}/dex2oat"
exe cp ${mounted_aosp}/out/target/product/${arch_path}/symbols/system/bin/dex2oat ./assets/artist/${api_level_string}/dex2oat
exe cp ./assets/artist/${api_level_string}/dex2oat ${working_dir}/debug/android-${api_level}/dex2oat

## now loop through the above array
for lib in "${dexToOatLibs[@]}"
do
    echo "Copy ${lib} -> './assets/artist/${api_level_string}/lib/'"
    exe cp ${mounted_aosp}/out/target/product/${arch_path}/symbols/system/lib/${lib} ./assets/artist/${api_level_string}/lib/ || true
    exe cp ./assets/artist/${api_level_string}/lib/${lib} ${working_dir}/debug/android-${api_level}/${lib} || true
    if [ "${debug_binaries}" = true ]; then
        echo " > ${lib}: Keeping debug symbols"
    else
        echo " > ${lib}: Stripping debug symbols"
        exe ${ndk_binary_strip} ./assets/artist/${api_level_string}/lib/${lib} || true
    fi
done
echo ""
echo "Copying files DONE"