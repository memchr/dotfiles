-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.local/lib/luarocks/5.1"}
}
lua_interpreter = "luajit";
variables = {
   LUA_DIR = "/usr";
   LUA_INCDIR = "/usr/include/luajit-2.1";
   LUA_BINDIR = "/usr/bin";
}
