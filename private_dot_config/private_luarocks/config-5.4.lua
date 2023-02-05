-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.local/lib/luarocks/5.4"}
}
lua_interpreter = "lua5.4";
variables = {
   LUA_DIR = "/usr";
   LUA_BINDIR = "/usr/bin";
}
