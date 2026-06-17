local M = {}

function M.pack(config)
  local name    = config.name:gsub("%s+", "-"):lower()
  local version = config.version
  local output  = "dist/" .. name .. "-" .. version .. ".mrpack"

  os.execute("mkdir -p dist")

  -- zip pack/ directory into .mrpack
  local cmd = "cd pack && zip -r ../" .. output .. " . && cd .."
  local ok = os.execute(cmd)

  if not ok then
      return nil, "failed to create .mrpack"
  end

  print("created " .. output)
  return output
end

return M