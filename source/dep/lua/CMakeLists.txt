# Lua 5.4.9, vendored 2026-09-15. See README-comfycraft.md beside this file for
# what was removed from the upstream tree and why.
#
# Deliberately NOT a glob. Five upstream .c files are absent on purpose -- the
# os, io and package libraries, and the two standalone mains -- and a glob would
# silently pick them back up the day somebody unpacks a fresh tarball over this
# directory. Listing them is how the sandbox survives an upgrade.
set(lua_sources
  src/lapi.c      src/lauxlib.c  src/lbaselib.c src/lcode.c
  src/lcorolib.c  src/lctype.c   src/ldebug.c   src/ldo.c
  src/ldump.c     src/lfunc.c    src/lgc.c      src/llex.c
  src/lmathlib.c  src/lmem.c     src/lobject.c  src/lopcodes.c
  src/lparser.c   src/lstate.c   src/lstring.c  src/lstrlib.c
  src/ltable.c    src/ltablib.c  src/ltm.c      src/lundump.c
  src/lutf8lib.c  src/lvm.c      src/lzio.c
)

add_library(lua STATIC ${lua_sources})

# Compiled as C++ so that a Lua error longjmps as a C++ exception instead of
# setjmp/longjmp. The core is C++ and objects with destructors sit on the stack
# between the VM and our bindings; a longjmp straight through them would leak
# every one. luaconf.h switches on __cplusplus by itself.
set_source_files_properties(${lua_sources} PROPERTIES LANGUAGE CXX)
set_target_properties(lua PROPERTIES LINKER_LANGUAGE CXX)

if(MSVC)
  # Upstream C, not ours to tidy. Silence the two it trips on rather than
  # patching vendored files, which would have to be redone on every upgrade.
  target_compile_options(lua PRIVATE /wd4334 /wd4310 /wd4324)
endif()

target_include_directories(lua
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

set_target_properties(lua PROPERTIES FOLDER "3rd Party")
