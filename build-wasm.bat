@echo off
setlocal enabledelayedexpansion
echo == build-wasm.bat: WebAssembly build helper ==

REM Try to source emsdk environment if installed in user profile
if exist "%USERPROFILE%\emsdk\emsdk_env.bat" (
  echo Sourcing emsdk_env.bat from %USERPROFILE%\emsdk
  call "%USERPROFILE%\emsdk\emsdk_env.bat"
) else (
  echo Warning: %USERPROFILE%\emsdk\emsdk_env.bat not found. Ensure emsdk is installed and emsdk_env.bat has been run.
)

REM If a CMakeLists.txt exists, use emcmake + cmake
if exist CMakeLists.txt (
  echo Found CMakeLists.txt, using emcmake + cmake...
  emcmake cmake -S . -B build
  cmake --build build --config Release
  goto :eof
)

REM Otherwise collect .cpp files and compile with em++
set "SOURCES="
for /r %%f in (*.cpp) do (
  set "SOURCES=!SOURCES! "%%~ff""
)
if "%SOURCES%"=="" (
  echo No .cpp files found. Place sources in the repository or provide a CMakeLists.txt.
  goto :eof
)
mkdir build 2>nul

echo Compiling with em++ ...
em++ -std=c++17 -O2 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -IHeaders %SOURCES% -o build/index.html -s EXPORTED_FUNCTIONS="['_main','_i']" -s EXTRA_EXPORTED_RUNTIME_METHODS="['ccall','cwrap']"

echo Done. Output: build/index.html
endlocal
