local M = {}

local function mkdir(path)
  os.execute("mkdir -p " .. path)
end

local function write_file(path, content)
  local f = assert(io.open(path, "w"), "could not open " .. path)
  f:write(content)
  f:close()
end

local function dirname(path)
  return path:match("^(.*)/[^/]*$") or "."
end

local function build_files(resolved_mods)
  local files = {}

  for _, mod in ipairs(resolved_mods) do
    if mod.hash then
      table.insert(files, {
        path      = "mods/" .. mod.filename,
        hashes    = {
          sha512 = mod.hash,
        },
        downloads = { mod.download },
        fileSize  = mod.size,
      })
    else
      io.stderr:write("warning: skipping " .. mod.slug .. " (no hash)\n")
    end
  end

  return files
end

local function build_manifest(resolved_mods, config)
  return {
    formatVersion = 1,
    game          = "minecraft",
    versionId     = config.version,
    name          = config.name,
    summary       = config.summary or "",
    dependencies  = {
      minecraft = config.mc_version,
      [config.loader] = config.loader_version or "latest",
    },
    files         = build_files(resolved_mods),
  }
end

-- pretty print json with 2 space indent
local function pretty(tbl)
  local function serialize(val, indent)
    local t = type(val)
    indent = indent or 0

    local pad = string.rep("  ", indent)
    local pad2 = string.rep("  ", indent + 1)

    if t == "number" or t == "boolean" then
      return tostring(val)
    elseif t == "string" then
      -- escape special characters
      return '"' .. val:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
    elseif t == "table" then
      -- check if array
      local is_array = #val > 0
      if is_array then
        local parts = {}
        for _, v in ipairs(val) do
          table.insert(parts, pad2 .. serialize(v, indent + 1))
        end
        return "[\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "]"
      else
        local parts = {}
        for k, v in pairs(val) do
          table.insert(parts, pad2 .. '"' .. k .. '": ' .. serialize(v, indent + 1))
        end
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. pad .. "}"
      end
    end
  end

  return serialize(tbl)
end

function M.write(resolved_mods, config, output_path)
  local manifest = build_manifest(resolved_mods, config)
  mkdir(dirname(output_path))

  local encoded = pretty(manifest)
  write_file(output_path, encoded)

  print("wrote " .. #manifest.files .. " mods to " .. output_path)
end

function M.build(resolved_mods, config)
  return build_manifest(resolved_mods, config)
end

return M
