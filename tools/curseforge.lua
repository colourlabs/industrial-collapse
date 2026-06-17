local http = require("socket.http")
local ltn12 = require("ltn12")
local lunajson = require("lunajson")

local BASE_URL = "https://api.curseforge.com/v1"
local API_KEY  = os.getenv("CF_API_KEY")

local M = {}

local function get(path)
  if not API_KEY then
    return nil, "CF_API_KEY environment variable not set"
  end

  local body = {}
  local _, code = http.request({
    url = BASE_URL .. path,
    sink = ltn12.sink.table(body),
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

-- get mod info by project id
function M.get_project(project_id)
  local result, err = get("/mods/" .. project_id)
  if not result then
    return nil, err
  end
  return result.data
end

-- get files for a project filtered by mc version and loader
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

-- curseforge uses integers for loader types
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

-- resolve a curseforge mod into a manifest-ready table
function M.resolve(mod, mc_version, loader)
  local versions, err = M.get_versions(mod.project_id, mc_version, loader)
  if not versions or #versions == 0 then
    return nil, (err or "no versions found for ") .. mod.slug
  end

  -- curseforge returns newest first
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

  local download = "https://mediafilez.forgecdn.net/files/"
      .. math.floor(file.id / 1000) .. "/"
      .. (file.id % 1000) .. "/"
      .. file.fileName

  return {
    slug = mod.slug,
    filename = file.fileName,
    download = download,
    hash = file.hashes and file.hashes[1] and file.hashes[1].value,
    size = file.fileLength,
    version = tostring(file.id),
  }
end

return M
