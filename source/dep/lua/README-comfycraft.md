# Lua 5.4.9, vendored

Upstream `lua-5.4.9.tar.gz`, fetched from `https://www.lua.org/ftp/` on
2026-09-15. 373,429 bytes, matching the size lua.org's own directory listing
gives, `sha256 2335b6c582a52654f94612bf10d2f4672805d05329aa6568b1d8cd9e5c6fb8e6`.
lua.org publishes no checksum file, so that hash is recorded HERE to pin what we
took: an upgrade that does not match a freshly computed hash of a fresh download
is a reason to stop and look, not to proceed.

MIT licensed. `README` beside this file is upstream's own and carries the notice.

## What was removed, and why it was removed rather than disabled

Five upstream `.c` files are not here:

| File | What it is | Why it is gone |
|---|---|---|
| `loslib.c` | the `os` library | `os.execute` is a shell. `os.remove` and `os.rename` are the filesystem |
| `liolib.c` | the `io` library | reads and writes any file the server process can |
| `loadlib.c` | `require` and `package` | loads C shared libraries, which is arbitrary native code |
| `lua.c` | the standalone `lua` interpreter's `main` | nothing here runs a `main` |
| `luac.c` | the `luac` compiler's `main` | same |

**They are deleted rather than left out of the library list**, and that is the
whole point. A sandbox built by not calling `luaopen_os` is one forgotten line
away from being no sandbox at all, and the forgetting happens during an upgrade
when somebody unpacks a new tarball over this directory. A symbol that is not in
the binary cannot be reached by a mistake.

`linit.c` is gone too, for the same reason in the other direction: it is
upstream's "open all the standard libraries" convenience, and opening exactly
what we want is a decision that belongs in our code where it can be read.
`ldblib.c`, the Lua-visible `debug` table, is gone because `debug.sethook` would
let a script remove the instruction cap that stops it hanging the world. The C
side of the debug API lives in `ldebug.c`, which stays, so `lua_sethook` and
`luaL_traceback` still work for us.

`lualib.h` still DECLARES `luaopen_os`, `luaopen_io` and `luaopen_package`. That
is upstream's header left untouched so the next upgrade is a clean file copy;
a declaration with no definition is unreachable and a link error if anyone tries.

`CMakeLists.txt` lists the sources by name rather than globbing, so a fresh
tarball unpacked over this directory does not quietly restore any of the above.

## Compiled as C++

`set_source_files_properties(... LANGUAGE CXX)`. Lua's error handling is
`setjmp`/`longjmp` in C and C++ exceptions when built as C++ (`luaconf.h` picks
by `__cplusplus`). The core is C++ and our binding functions have objects with
destructors on the stack between the VM and the call, so a `longjmp` through
them would skip every destructor. Exceptions unwind properly.

## Upgrading

1. Download the new tarball from lua.org, record its size and sha256 above.
2. Copy `src/*.c` and `src/*.h` over `src/`.
3. **Delete the five files in the table again**, plus `linit.c` and `ldblib.c`.
4. Add any genuinely new `.c` to `CMakeLists.txt` by hand.
5. Re-read `src/LuaScene.cpp`'s sandbox list against the new `lbaselib.c`: a new
   global in the base library is a new thing to decide about.
