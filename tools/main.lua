local argparse = require("argparse")
local lunajson = require("lunajson")

local curseforge = require("tools.curseforge")
local modrinth = require("tools.modrinth")
local manifest = require("tools.manifest")

local parser = argparse("industrial-collapse-tools", "the modpack build tool")

local build_cmd = parser:command("build", "resolve mods and write modrinth.index.json")
build_cmd:option("-o --output", "output path for modrinth.index.json", "pack/modrinth.index.json")

parser:command("list", "list mods in mods.jsonc")

local args = parser:parse()

local function parse_jsonc(path)
  local f = assert(io.open(path, "r"), "could not open " .. path)
  local raw = f:read("*a")
  f:close()
  raw = raw:gsub("//[^\n]*", "")
  raw = raw:gsub("/%*.-%*/", "")
  return lunajson.decode(raw)
end

local function load_config() return parse_jsonc("pack.jsonc") end
local function load_mods()   return parse_jsonc("mods.jsonc") end

if args.build then
  local config = load_config()
  local mods = load_mods()

  print("resolving " .. #mods .. " mods...")
  local resolved = {}
  for _, mod in ipairs(mods) do
    io.write("  -> " .. mod.slug .. "... ")

    local result, err
    if mod.source == "curseforge" then
      result, err = curseforge.resolve(mod, config.mc_version, config.loader)
    elseif mod.source == "modrinth" then
      result, err = modrinth.resolve(mod, config.mc_version, config.loader)
    end

    if result then
      print("ok")
      table.insert(resolved, result)
    else
      print("FAILED")
    end
  end

  manifest.write(resolved, config, args.output)
  print("done!")

elseif args.list then
  local mods = load_mods()
  print(#mods .. " mods:")
  for _, mod in ipairs(mods) do
      local pin = mod.pin and " (pinned: " .. mod.pin .. ")" or ""
      print("  " .. mod.slug .. " [" .. mod.source .. "]" .. pin)
  end
end