local http = require("socket.http")
local ltn12 = require("ltn12")
local lunajson = require("lunajson")
local socket = require("socket")

local BASE_URL = "https://api.modrinth.com/v2"

local M = {}

local function get(path)
  socket.sleep(0.3)
  local body = {}
  local _, code = http.request({
    url = BASE_URL .. path,
    sink = ltn12.sink.table(body),
    headers = {
      ["User-Agent"] = "industrial-collapse-modpack-tool/1.0"
    }
  })

  if code ~= 200 then
    return nil, "HTTP " .. tostring(code) .. " for " .. path
  end

  local ok, result = pcall(lunajson.decode, table.concat(body))
  if not ok then
    return nil, "failed to parse JSON response"
  end

  return result
end

local function encode_params(params)
  local parts = {}
  for k, v in pairs(params) do
    table.insert(parts, k .. "=" .. v)
  end
  return "?" .. table.concat(parts, "&")
end

function M.get_project(slug)
  local result, err = get("/project/" .. slug)
  if not result then
    return nil, err
  end
  return result
end

function M.get_versions(slug, mc_version, loader)
  local params = encode_params({
    game_versions = "%5B%22" .. mc_version .. "%22%5D", -- ["1.20.1"]
    loaders = "%5B%22" .. loader .. "%22%5D",           -- ["neoforge"]
  })

  local result, err = get("/project/" .. slug .. "/version" .. params)
  if not result then
    return nil, err
  end

  return result
end

-- resolve a mod entry from mods.jsonc into a manifest-ready table
function M.resolve(mod, mc_version, loader)
  if mod.source == "url" then
    return {
      slug = mod.slug,
      filename = mod.filename,
      download = mod.download,
      hash = nil,
    }
  end

  local versions, err = M.get_versions(mod.slug, mc_version, loader)
  if not versions then
    return nil, err
  end
  if #versions == 0 then
    return nil, "no versions found for " .. mod.slug
        .. " (mc=" .. mc_version .. " loader=" .. loader .. ")"
  end

  local version
  if mod.pin then
    for _, v in ipairs(versions) do
      if v.id == mod.pin then
        version = v
        break
      end
    end
    if not version then
      return nil, "pinned version " .. mod.pin .. " not found for " .. mod.slug
    end
  else
    version = versions[1] -- latest matching version
  end

  local file
  for _, f in ipairs(version.files) do
    if f.primary then
      file = f
      break
    end
  end
  file = file or version.files[1]

  if not file then
    return nil, "no files found for " .. mod.slug
  end

  local hash = file.hashes.sha512
  if not hash or #hash ~= 128 then
    return nil, "bad or missing sha512 hash for " .. mod.slug
        .. " (got " .. tostring(hash and #hash or 0) .. " chars)"
  end

  return {
    slug = mod.slug,
    filename = file.filename,
    download = file.url,
    hash = hash,
    size = file.size,
    version = version.id,
  }
end

return M
