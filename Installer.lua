--[[
Creator: Ragog/SALexW
Installer ver: v1.0.0.0
]]--


local comp = require("component")
local serial = require("serialization")
local fsys = require("filesystem")
local shell = require("shell")
local term = require("term")
local gpu = component.gpu
local wwweb = nil
local webconnect = component.isAvailable("internet")
if webconnect then wwweb = require("internet") else io.stderr:write("No internet connection. Please install an\nInternet Card\n") os.exit(false) end
local type = false

local url = "https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main"

function dircreate()
 if not fsys.isDirectory("/arud") then
  local sccs, msg = fsys.makeDirectory("/arud")
  if sccs == nil then
   io.stderr:write("ERROR: Failed to create directory")
   os.exit(false)
  end
 end
end

function selecttype()
 print("Please select the device type for the program you are installing:")
 print("1 - Tablet, 2 - Computer/Server, Other - Cancel installation")
 local input = io.read()
 if (input == "1" or choose == "2") then
  if input == "1" then type = true else type = false end
 else
 io.stderr:write("Instalation canceled")
 os.exit(false)
 end
end

function download()
 print("Downloading files...")
 if type then
  
 else
    local file = 
 end
end

--[[
local args, opts = shell.parse(...)



function downloadNeededFiles()
  print("Downloading Files, Please Wait...")
  downloadFile(ReleaseVersionsFile)
  local file = io.open(ReleaseVersionsFile)
  ReleaseVersions = serialization.unserialize(file:read("*a"))
  file:close()
  downloadManifestedFiles(ReleaseVersions.launcher)
  if opts.d then ReleaseVersions.launcher.dev = true end
  file = io.open("/ags/installedVersions.ff", "w")
  file:write("{launcher="..serialization.serialize(ReleaseVersions.launcher)..",}")
  file:close()
end

function createSystemShortcut()
  local agsBinFile = [[
shell = require("shell")
filesystem = require("filesystem")

local args, opts = shell.parse(...)

if filesystem.exists("/ags/AuspexGateSystems.lua") then
  local options = "-"
  for k,v in pairs(opts) do options = options..tostring(k) end
  shell.execute("/ags/AuspexGateSystems.lua "..options)
else
  io.stderr:write("Auspex Gate Systems is Not Correctly Installed\n")
end
  ]]
  local file = io.open("/bin/ags.lua", "w")
  file:write(agsBinFile)
  file:close()
end

function downloadManifestedFiles(program)
  for i,v in ipairs(program.manifest) do downloadFile(v) end
end

function downloadFile(fileName)
  print("Downloading..."..fileName)
  local result = ""
  local response = internet.request(BranchURL..fileName)
  local isGood, err = pcall(function()
    local file, err = io.open(fileName, "w")
    if file == nil then error(err) end
    for chunk in response do
      file:write(chunk)
    end
    file:close()
  end)
  if not isGood then
    io.stderr:write("Unable to Download\n")
    io.stderr:write(err)
    forceExit(false)
  end
end

onlineCheck()
createInstallDirectory()
checkForExistingInstall()
downloadNeededFiles()
createSystemShortcut()
print("Launcher Changes:")
for i,v in ipairs(ReleaseVersions.launcher.note) do print("  "..v) end
print([[
Installation complete!
Please use the 'ags' system command to run the launcher.
]])
]]--
