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
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/Tablet.lua /arud/AUD.lua -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/MWAS.ff /arud/MWAS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/MWDS.ff /arud/MWDS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/MWGS.ff /arud/MWGS.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/MWG.ff /arud/MWG.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/UNG.ff /arud/UNG.ff -fQ")
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/GI.ff /arud/GI.ff -fQ")
 else
 shell.execute("wget https://raw.githubusercontent.com/SAlexW/AunisUniversalDialer/main/PC.lua /arud/AUD.lua -fQ") 
 end
local autorunFile = [[
local shell = require("shell")

do
shell.setWorkingDirectory("/arud/")
shell.execute("AUD.lua")
end
]]
local file = io.open("/autorun.lua", "w")
file:write(autorunFile)
file:close()
print("Download completed. Please, restart your PC/Tablet. Programm will run automatically")
end
