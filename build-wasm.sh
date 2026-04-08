#!/bin/sh
set -e
echo "== build-wasm.sh: WebAssembly build helper =="

# Source emsdk if installed in $HOME/emsdk
if [ -f "$HOME/emsdk/emsdk_env.sh" ]; then
  echo "Sourcing $HOME/emsdk/emsdk_env.sh"
  . "$HOME/emsdk/emsdk_env.sh"
else
  echo "Warning: $HOME/emsdk/emsdk_env.sh not found. Ensure emsdk is installed and emsdk_env.sh has been sourced."
fi

# If a CMakeLists.txt exists, use emcmake + cmake
if [ -f CMakeLists.txt ]; then
  echo "Found CMakeLists.txt, using emcmake + cmake..."
  emcmake cmake -S . -B build
  cmake --build build --config Release
  exit 0
fi

# Otherwise find .cpp files and compile with em++
SOURCES=$(find . -name '*.cpp' -print)
if [ -z "$SOURCES" ]; then
  echo "No .cpp files found. Place sources in the repository or provide a CMakeLists.txt."
  exit 1
fi

mkdir -p build

echo "Compiling with em++ ..."
em++ -std=c++17 -O2 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -IHeaders $SOURCES -o build/index.html -s EXPORTED_FUNCTIONS="['_main','_i']" -s EXTRA_EXPORTED_RUNTIME_METHODS="['ccall','cwrap']"

echo "Done. Output: build/index.html"
chmod +x build-wasm.sh
