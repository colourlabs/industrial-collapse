local mani = require("mani")

mani.project {
  name     = "industrial-collapse",
  version  = "0.1.0",
  license  = "MIT",
  homepage = "https://github.com/colourlabs/industrial-collapse",
  summary  = "tools for industrial collapse creation",
}

local TREE = ".mani/tree/share/lua/5.4"
local LUA_PATH = "LUA_PATH='" .. TREE .. "/?.lua;" .. TREE .. "/?/init.lua;;'"

local function load_build_config()
  local f = io.open("build_config.json", "r")
  if not f then
    mani:log("warning: build_config.json not found, copying from build_config.example.json")
    mani:log("error: curseforge mods will be built until CF_API_KEY is set")
    return {}
  end
  local raw = f:read("*a")
  f:close()

  local config = {}
  config.cf_api_key = raw:match('"cf_api_key"%s*:%s*"([^"]+)"')

  if not config.cf_api_key then
    mani:log("warning: cf_api_key not found in build_config.json, curseforge mods will be skipped")
  end

  return config
end

local cfg = load_build_config()
local ENV = LUA_PATH

if cfg.cf_api_key then
  ENV = "CF_API_KEY='" .. cfg.cf_api_key .. "' " .. ENV
end

mani.dependencies({
  "argparse^0.7.2-1",
  "lunajson^1.2.3-1",
  "luasocket^3.1.0-1",
})

mani.dev_dependencies({})

mani.task("run", function()
  mani:exec(ENV .. " lua tools/main.lua")
end)

mani.task("build", function()
  mani:log("building modpack...")
  mani:exec(ENV .. " lua tools/main.lua build")
end)

mani.task("list", function()
  mani:exec(ENV .. " lua tools/main.lua list")
end)

mani.task("pack", function()
  mani:log("packaging modpack...")
  mani:exec(ENV .. " lua tools/main.lua pack")
end)

mani.task("default", { "run" }, function() end)
