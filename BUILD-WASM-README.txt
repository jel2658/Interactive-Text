build-wasm scripts — quick reference

What these scripts do

- Purpose: provide a single-step way to build a WebAssembly/HTML deliverable from the repository using Emscripten.
- Files added to repo root:
  - build-wasm.bat  (Windows)
  - build-wasm.sh   (macOS / Linux)

High-level behavior

1. Try to source the emsdk environment if found in the default user location (%USERPROFILE%/emsdk on Windows, $HOME/emsdk on POSIX).
2. If a `CMakeLists.txt` file exists in the repo root, the scripts use `emcmake` + `cmake` to configure and build into the `build` directory.
3. Otherwise the scripts search the repo for `*.cpp` files, and invoke `em++` with `-IHeaders` and produce `build/index.html`.
4. The scripts set sensible Emscripten flags for a typical app:
   - `-std=c++17 -O2 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1`
   - `-s EXPORTED_FUNCTIONS="['_main','_i']"` and `-s EXTRA_EXPORTED_RUNTIME_METHODS="['ccall','cwrap']"` (edit if you need to export additional symbols).

How to run

- Windows (after installing and activating emsdk):
  - Open a new Command Prompt where `emsdk_env.bat` has run (or let the script try to source `%USERPROFILE%\emsdk\emsdk_env.bat`).
  - From the repository root run: `build-wasm.bat`

- macOS / Linux:
  - Ensure you have run `source $HOME/emsdk/emsdk_env.sh` (or let the script try to source it).
  - Make the script executable if needed: `chmod +x build-wasm.sh`
  - Run: `./build-wasm.sh`

Output

- Primary output when not using CMake: `build/index.html` plus the companion `build/index.wasm` and JS glue files created by Emscripten.
- When using CMake the output location depends on the generated project, but the script builds into the `build` directory.

Prerequisites

- Emscripten SDK installed and activated. Follow https://emscripten.org/docs/getting_started/downloads.html
- Python present on PATH so `emsdk` commands work on Windows.
- `em++` / `emcmake` available on PATH (after sourcing `emsdk_env` or activating emsdk).
- If using the CMake flow: `cmake` available on PATH.

Customizing

- To add more exported functions, edit the `-s EXPORTED_FUNCTIONS` option in the scripts (add extra names like `'_myfunc'`).
- To change includes add `-I` flags to the `em++` command in the scripts.
- If you want to prefer a different emsdk installation path, edit the path the script checks (the default is `%USERPROFILE%\emsdk` and `$HOME/emsdk`).

Troubleshooting

- "Python not found" on Windows: install Python from python.org and enable "Add Python to PATH", and/or disable the Microsoft Store app execution alias for `python`.
- If the scripts warn they couldn't find `emsdk_env`, run the appropriate environment script manually and open a new shell before running the script.
- If `em++` is not found after running `emsdk_env`, confirm the script actually ran and that `emsdk` was activated (`emsdk activate latest`).
- If you need to debug the exact compile invocation, run the `em++` line printed by the script directly in a terminal after the environment is set up.

Notes

- The repository header `Headers/Output.h` already has guards so the code still compiles natively when Emscripten isn't present.
- These scripts are minimal helpers. For larger projects it's recommended to add a `CMakeLists.txt` and use the `emcmake` flow for cleaner multi-file builds and platform-specific options.

Contact

If you want, I can:
- add a simple `CMakeLists.txt` to the repo and prefer the CMake flow,
- adjust the exported functions list to match the actual functions your JS expects,
- or create a single wrapper script that builds WASM when `em++` is available and otherwise builds the native Visual Studio project. (Tell me which.)
