local argparse = require("argparse")
local lunajson = require("lunajson")

local curseforge = require("tools.curseforge")
local modrinth = require("tools.modrinth")
local manifest = require("tools.manifest")
local raw_jar_download = require("tools.raw_jar_download")
local pack = require("tools.pack")

local parser = argparse("industrial-collapse-tools", "the modpack build tool")

local build_cmd = parser:command("build", "resolve mods and write modrinth.index.json")
build_cmd:option("-o --output", "output path for modrinth.index.json", "pack/modrinth.index.json")

parser:command("pack", "package modpack into .mrpack")
parser:command("list", "list mods in mods.jsonc")

local args = parser:parse()

local function strip_jsonc_comments(raw)
  local out = {}
  local i, n = 1, #raw
  local in_string = false

  while i <= n do
    local c = raw:sub(i, i)

    if in_string then
      out[#out + 1] = c
      if c == "\\" then
        -- copy the escaped character too, so \" doesn't end the string early
        i = i + 1
        if i <= n then out[#out + 1] = raw:sub(i, i) end
      elseif c == '"' then
        in_string = false
      end
      i = i + 1

    elseif c == '"' then
      in_string = true
      out[#out + 1] = c
      i = i + 1

    elseif c == "/" and raw:sub(i + 1, i + 1) == "/" then
      -- line comment: skip to end of line
      local nl = raw:find("\n", i)
      i = nl or (n + 1)

    elseif c == "/" and raw:sub(i + 1, i + 1) == "*" then
      -- block comment: skip to closing */
      local close = raw:find("*/", i + 2)
      i = close and (close + 2) or (n + 1)

    else
      out[#out + 1] = c
      i = i + 1
    end
  end

  return table.concat(out)
end

local function parse_jsonc(path)
  local f = assert(io.open(path, "r"), "could not open " .. path)
  local raw = f:read("*a")
  f:close()
  return lunajson.decode(strip_jsonc_comments(raw))
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
    elseif mod.source == "raw_jar_download" then
      result, err = raw_jar_download.resolve(mod)
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

elseif args.pack then
  local config = load_config()
  pack.pack(config)
end