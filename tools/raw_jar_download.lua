local http = require("socket.http")
local ltn12 = require("ltn12")
local sha512lib = require("tools.lib.sha512")

local M = {}

local function download_and_hash(url)
  local body = {}
  local _, code = http.request({
    url     = url,
    sink    = ltn12.sink.table(body),
    headers = {
      ["User-Agent"] = "industrial-collapse-modpack-tool/1.0",
    },
  })

  if code ~= 200 then
    return nil, "failed to download " .. url .. " (HTTP " .. tostring(code) .. ")"
  end

  local data = table.concat(body)
  return sha512lib.sha512(data), #data
end

function M.resolve(mod)
  if not mod.url then
    return nil, "no url set for " .. mod.slug
  end

  local filename = mod.filename or mod.url:match("([^/]+)$")

  io.write(" hashing " .. filename .. "... ")
  local hash, size = download_and_hash(mod.url)
  if not hash then
    return nil, "failed to hash " .. mod.slug
  end
  print("ok")

  return {
    slug     = mod.slug,
    filename = filename,
    download = mod.url,
    hash     = hash,
    hashtype = "sha512",
    size     = size,
    version  = mod.version or "pinned",
  }
end

return M