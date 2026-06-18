local http = require("socket.http")
local ltn12 = require("ltn12")
local lunajson = require("lunajson")
local sha512lib = require("tools.lib.sha512")

local BASE_URL = "https://api.curseforge.com/v1"
local API_KEY = os.getenv("CF_API_KEY")

local M = {}

local function get(path)
  if not API_KEY then
    return nil, "CF_API_KEY environment variable not set"
  end

  local body = {}
  local _, code = http.request({
    url     = BASE_URL .. path,
    sink    = ltn12.sink.table(body),
    headers = {
      ["User-Agent"] = "industrial-collapse-modpack-tool/1.0",
      ["x-api-key"] = API_KEY,
      ["Accept"] = "application/json",
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

local function download_and_hash(url)
  local body = {}
  local _, code = http.request({
    url     = url,
    sink    = ltn12.sink.table(body),
    headers = {
      ["User-Agent"] = "industrial-collapse-modpack-tool/1.0",
    }
  })

  if code ~= 200 then
    return nil, "failed to download " .. url
  end

  local data = table.concat(body)
  return sha512lib.sha512(data), #data
end

function M.get_project(project_id)
  local result, err = get("/mods/" .. project_id)
  if not result then
    return nil, err
  end
  return result.data
end

function M.get_versions(project_id, mc_version, loader)
  local result, err = get(
    "/mods/" .. project_id .. "/files"
    .. "?gameVersion=" .. mc_version
    .. "&modLoaderType=" .. M.loader_type(loader)
  )
  if not result then
    return nil, err
  end
  return result.data
end

function M.loader_type(loader)
  local types = {
    forge = 1,
    cauldron = 2,
    liteloader = 3,
    fabric = 4,
    quilt = 5,
    neoforge = 6,
  }
  return types[loader] or 1
end

function M.resolve(mod, mc_version, loader)
  local versions, err = M.get_versions(mod.project_id, mc_version, loader)
  if not versions or #versions == 0 then
    return nil, (err or "no versions found for ") .. mod.slug
  end

  local file
  if mod.pin then
    for _, f in ipairs(versions) do
      if tostring(f.id) == tostring(mod.pin) then
        file = f
        break
      end
    end
    if not file then
      return nil, "pinned file " .. mod.pin .. " not found for " .. mod.slug
    end
  else
    file = versions[1]
  end

  -- prefer the API-provided download URL, fall back to constructing it
  local download = file.downloadUrl
  if not download then
    download = "https://mediafilez.forgecdn.net/files/"
        .. math.floor(file.id / 1000) .. "/"
        .. string.format("%03d", file.id % 1000) .. "/"
        .. file.fileName
  end

  io.write(" hashing " .. file.fileName .. "... ")
  local hash, size = download_and_hash(download)
  if not hash then
    return nil, "failed to hash " .. mod.slug
  end
  print("ok")

  return {
    slug     = mod.slug,
    filename = file.fileName,
    download = download,
    hash     = hash,
    hashtype = "sha512",
    size     = size,
    version  = tostring(file.id),
  }
end

return M
