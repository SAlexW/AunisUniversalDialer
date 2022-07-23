--libraries--
local com = require("component")
local pc = require("computer")
local gpu = com.gpu
local event = require("event")
local term = require("term")
local serial = require("serialization")
local math = require("math")
local string = require("string")
local table = require("table")
--libraries--
 
--global variables--
local iocheck
local iomessage
local gateadd = com.stargate.address
local sym = "▩"
irisCode = nil
local startcheck = true
local tunidle = false
local tunmessagebool = true
local tunmessstate = ""
local gadd = {}
local disen = false
local ser = {}
local rep = true
local tun = com.isAvailable("tunnel")
local tunnel
if (tun) then tunnel = com.tunnel tunnel.setWakeMessage("link", true) end
local modem
if (com.isAvailable("modem") == false or com.modem.isWireless() == false) then pc.beep(500, 1) pc.beep(400, 1) pc.beep(500, 1) pc.beep(400, 1) rep = false  os.exit(false) else modem = com.modem modem.setWakeMessage("link") end 
--global variables--

--message read--
function keyadd(_,_,ch,code,_)
local posx, posy = term.getCursor()
 if (code == 28) then --enter
 iocheck = false
 goto ioend
 elseif (code == 14) then --backspace
 if iomessage ~= "" then iomessage = iomessage:sub(1, #iomessage-1) end
 gpu.fill(posx, posy, 80-posx, 1, " ")
 gpu.set(posx, posy, iomessage)
 elseif (#iomessage<iolength and ch<128) then
 iomessage = string.format("%s%s", iomessage, string.char(ch))
 gpu.fill(posx, posy, 80-posx, 1, " ")
 gpu.set(posx, posy, iomessage)
 else
 pc.beep(40,0.1)
 end
 ::ioend::
end

function messread(length)
iolength = length
iocheck = true
iomessage = ""
event.listen("key_down", keyadd)
while (iocheck) do os.sleep(0) end
event.ignore("key_down", keyadd)
end
 
--set Iris code--
function codeset(mode)
term.clear()
local code = io.open("code.ff", "r")
 if (code == nil or code:seek("end") == 0 or mode) then
 code = io.open("code.ff", "w")
 ::gdosetloop::
 term.write("Please, set GDO code. English, numbers and special characters (punctuation, algebraic, space, etc) only. Max: 30. \nYou can change it in future by pressing \"V\" key on keyboard\n")
 term.setCursor(1, 3)
 messread(30)
 term.setCursor(1, 4)
  if iomessage == nil or iomessage == "" then
  term.write("GDO code cannot be empty.Try again")
  os.sleep(1)
  term.clear()
  goto gdosetloop
  else
  code:write(string.format("irisCode = \"%s\"", iomessage))
  code:close()
  term.write("Changes accepted.\n")
  end
 else
 code:seek("set")
 code:close()
 end
term.clear()
dofile("code.ff")
end

codeset(false) 

function keylisten(_, _, _, key, _)
local i = 3
 if key == 47.0 then 
 ::inputloop::
 print("Please enter the current GDO code.")
 local _, get = pcall(io.read)
  if get == irisCode then
  codeset(true)
  else
  i=i-1
  term.clear()
   if i >0 then
   print(string.format("Wrong code. You have %u attempts left.", i))
   os.sleep(2)
   term.clear()
   goto inputloop
   else
   print("AN UNAUTHORIZED ACCESS TO THE SYSTEM IS DETECTED.\nTERMINAL IS LOCKED.")
   os.sleep(600)
   term.clear()
   end
  end
 end
end
--set Iris code-- 

--decode messages--
function decode(mess)
local mass = {}
for str in mess:gmatch("[^"..sym.."]+") do
tbl.insert(mass, str) end
return mass
end
--decode messages--

--repeat gdo message to opened wormhole--
function gdorepeat (mode, mess)
modem.broadcast(101, mode, mess)
os.sleep(0.1)
modem.broadcast(101, mode, mess)
os.sleep(0.1)
modem.broadcast(101, mode, mess)
end
--repeat gdo message to opened wormhole--

--toggle iris for incoming wormhole--
function incomeIris()
if com.stargate.getIrisState() == "OPENED" then com.stargate.toggleIris() end
end
--toggle iris for incoming wormhole--
 
--send modem message--
function send(add, chan, mass)
modem.send(add, chan, table.concat(mass, sym))
os.sleep(0.1)
modem.send(add, chan, table.concat(mass, sym))
os.sleep(0.1)
modem.send(add, chan, table.concat(mass, sym))
end
--send modem message--
 
--send tunnel message--
function tunenergymessage()
local gate = com.stargate
local state, _ = gate.getGateStatus()
local ener = gate.getEnergyStored()
local enmax = gate.getMaxEnergyStored()
tunnel.send(table.concat({"ener", ener, enmax}, sym))
 if(ener/enmax < 1 and state == "idle") then
 event.timer(10, tunenergymessage)
 end
end
 
function tunmessage()
 local gate = com.stargate
 local state, _ = gate.getGateStatus()
 local ener = gate.getEnergyStored()
 local enmax = gate.getMaxEnergyStored()
 local add = tostring(serial.serialize(gate.stargateAddress))
 if (tunmessagebool and (tunmessstate ~= state or gateadd ~= gate.address)) then
 tunmessstate = state
 tunmessagebool = false
 gateadd = gate.address
 tunnel.send(table.concat({"main", gate.getGateType(), state, ener, enmax, gate.dialedAddress, add, gate.getIrisType(), gate.getIrisState()}, sym))
  if(ener/enmax < 1 and state == "idle") then
  event.timer(10, tunmessage)
  end
 end
tunmessagebool = true
end 
 
function delaytunmessage()
os.sleep(3)
tunmessage()
end
--send tunnel message--
 
--end program--
function fclose()
event.ignore("modem_message", main)
rep = false
end
--end program--
 
--work with text messages--
function messagework (mess)
print(mess)
pc.beep(300, 1.5)
pc.beep(500, 1.5)
end
 
function tunnelmessagework (mess)
print(mess)
pc.beep(300, 1)
pc.beep(400, 1)
pc.beep(500, 1)
end
--work with text messages--
 
--gate abort dial / disengage gate--
function diseng(_, myad, _, _, _, msg)
 if (msg == "abort") then
 disen = true
 end
end
--gate abort dial / disengage gate--
 
--short address check--
function addcheck(add)
local gate = com.stargate
local timed7 = {}
local timed8 = {}
local timed9 = {}
local timed = {}
 for i = 1, #add-1 do
 timed7[i]= i<7 and add[i] or nil
 timed8[i]= i<8 and add[i] or nil
 timed9[i]= add[i]
 end
table.insert(timed7, add[#add])
table.insert(timed8, add[#add])
table.insert(timed9, add[#add])
local check7, _ = gate.getEnergyRequiredToDial(table.unpack(timed7))
local check8, _ = gate.getEnergyRequiredToDial(table.unpack(timed8))
timed = check7 ~= "address_malformed" and check7 ~= "not_merged" and timed7 or check8 ~= "address_malformed" and check8 ~= "not_merged" and timed8 or timed9
return (timed)
end
--short address check--
 
--main message work--
function main(_, myad, sadd, chan, dist, msg, msga, radd)
local gate = com.stargate
local state, _ = gate.getGateStatus()
rec = sadd
 if (msg == "link") then
  if (tun and myad == tunnel.address) then
  os.sleep(0.25)
  tunmessstate = ""
  tunmessage()
  else 
  local state, _ = gate.getGateStatus()
  send(sadd, 100, {gate.getGateType(), state, gate.dialedAddress, serial.serialize(gate.stargateAddress)})
  end
 elseif (msg == "mess" and radd ~= myad) then
 if (tun and myad == tunnel.address) then tunnelmessagework(msga) else messagework(msga) end
 os.sleep(0.1)
 elseif (msg == "abort") then
 gate.disengageGate()
 gate.engageGate()
 tunidle = true
 disen = true
 event.listen("modem_message", diseng)
 event.listen("stargate_iris_closed", tunmessage)
 event.listen("stargate_iris_opened", tunmessage)
 event.listen("stargate_incoming_wormhole", tunmessage)
 event.listen("stargate_open", tunmessage)
 event.listen("stargate_wormhole_closed_fully", tunmessage)
 event.listen("stargate_wormhole_stabilized", tunmessage)
 event.listen("stargate_close", delaytunmessage)
 event.listen("stargate_dhd_chevron_engaged", tunmessage)
 event.listen("stargate_spin_chevron_engaged", tunmessage)
 event.listen("comonent_available", tunmessage)
 event.listen("stargate_failed", delaytunmessage)
 event.listen("key_down", keylisten)
 os.sleep(0.1)
 elseif (msg == "get") then
  if (state == "open") then
  modem.broadcast(101, "getrep")
  local get, _, _, _, _, msg = event.pull(2, "modem_message", nil, nil, 101)
   if (tun and myad == tunnel.address) then
   tunnel.send(get ~= nil and msg or "None")
   else
   send(sadd, 100, get ~= nil and decode(mess) or "None")
   end
  else 
   if (tun and myad == tunnel.address) then
   tunnel.send(get ~= nil and msg or "None")
   else
   send(sadd, 100, get ~= nil and decode(mess) or "None")
   end
  end
 os.sleep(0)
 elseif (msg == "getrep" and state == "open") then
 os.sleep(0)
 local mass = {}
 local gate = com.stargate
 mass[1] = serial.serialize({table.unpack(gate.stargateAddress.MILKYWAY)})
 mass[2] = serial.serialize({table.unpack(gate.stargateAddress.PEGASUS)})
 mass[3] = serial.serialize({table.unpack(gate.stargateAddress.UNIVERSE)})
 mass[4] = gate.getGateType()
 modem.send(sadd, 101, table.concat(mass, sym))
 elseif (msg == "getmain") then
 os.sleep(0)
 local mass = {}
 local gate = com.stargate
 mass[1] = serial.serialize({table.unpack(gate.stargateAddress.MILKYWAY)})
 mass[2] = serial.serialize({table.unpack(gate.stargateAddress.PEGASUS)})
 mass[3] = serial.serialize({table.unpack(gate.stargateAddress.UNIVERSE)})
 mass[4] = gate.getGateType()
 tunnel.send(table.concat(mass, sym))
 elseif (msg == "upd") then
 if (tun and myad == tunnel.address) then tunnel.send(table.concat({serial.serialize(gate.stargateAddress)}, sym)) else send(sadd, 100, {serial.serialize(gate.stargateAddress)}) end
 os.sleep(0)
 elseif (msg == "add") then
 tunidle = false
 event.listen("modem_message", diseng)
 event.ignore("stargate_incoming_wormhole", tunmessage)
 event.ignore("stargate_iris_closed", tunmessage)
 event.ignore("stargate_iris_opened", tunmessage)
 event.ignore("stargate_open", tunmessage)
 event.ignore("stargate_wormhole_closed_fully", tunmessage)
 event.ignore("stargate_wormhole_stabilized", tunmessage)
 event.ignore("stargate_close", delaytunmessage)
 event.ignore("stargate_dhd_chevron_engaged", tunmessage)
 event.ignore("stargate_spin_chevron_engaged", tunmessage)
 event.ignore("comonent_available", tunmessage)
 event.ignore("stargate_failed", delaytunmessage)
 event.ignore("key_down", keylisten)
 os.sleep(0.01)
  if (msga == "{}") then
  if (tun and myad == tunnel.address) then tunnel.send(table.concat({"empty address"}, sym)) else send(sadd, 100, {"empty address"}) end
  else
  gadd = serial.unserialize(msga)
  local check = gate.getEnergyRequiredToDial(table.unpack(gadd))
   if (check == "address_malformed") then
   if (tun and myad == tunnel.address) then tunnel.send(table.concat({"address malformed"}, sym)) else send(sadd, 100, {"address malformed"}) end
   elseif (check == "not_merged") then
   if (tun and myad == tunnel.address) then tunnel.send(table.concat({"not merged"}, sym)) else send(sadd, 100, {"not merged"}) end
   elseif (gate.getEnergyStored() - check.open < 0) then
   if (tun and myad == tunnel.address) then tunnel.send(table.concat({"not enough energy"}, sym)) else send(sadd, 100, {"not enough energy"}) end
   elseif (gadd[#gadd] ~= "Point of Origin" and gadd[#gadd] ~= "Glyph 17" and gadd[#gadd] ~= "Subido") then
   local gatetype = gate.getGateType()
    if (tun and myad == tunnel.address) then
    tunnel.send(table.concat({string.format("Missing %s", gatetype == "MILKYWAY" and "Point of Origin" or gatetype == "UNIVERSE" and "Glyph 17" or gatetype == "PEGASUS" and "Subido")}, sym))
    else
    send(sadd, 100, {string.format("Missing %s", gatetype == "MILKYWAY" and "Point of Origin" or gatetype == "UNIVERSE" and "Glyph 17" or gatetype == "PEGASUS" and "Subido")})
    end
   else 
   os.sleep(0.01)
   ser = {}
   gadd = addcheck(gadd)
   if (tun and myad == tunnel.address) then tunnel.send(table.concat({"dialing", #gadd}, sym)) else send(sadd, 100, {"dialing", #gadd})  end
   os.sleep(0.02)
    for _, val in ipairs(gadd) do
     while (gate.getGateStatus() ~= "idle") do
     os.sleep(0)
     end
     os.sleep(0.16)
     if (disen) then
	 gadd = {}
     if (tun and myad == tunnel.address) then tunnel.send(table.concat({"abort"}, sym)) else send(sadd, 100, {"abort"}) end
     gate.disengageGate()
     disen = false
     tunidle = true
     event.listen("stargate_incoming_wormhole", tunmessage)
     event.listen("stargate_iris_closed", tunmessage)
     event.listen("stargate_iris_opened", tunmessage)
     event.listen("stargate_incoming_wormhole", incomeIris)
     event.listen("stargate_open", tunmessage)
     event.listen("stargate_wormhole_closed_fully", tunmessage)
     event.listen("stargate_wormhole_stabilized", tunmessage)
     event.listen("stargate_close", delaytunmessage)
     event.listen("stargate_dhd_chevron_engaged", tunmessage)
     event.listen("stargate_spin_chevron_engaged", tunmessage)
     event.listen("comonent_available", tunmessage)
     event.listen("stargate_failed", delaytunmessage)
     event.listen("key_down", keylisten)
     break
     else
     gate.engageSymbol(val)
     table.insert(ser, val)
     if (tun and myad == tunnel.address) then tunnel.send(table.concat({serial.serialize({ser})}, sym)) else send(sadd, 100, {serial.serialize(ser)}) end
     end
    end
    while (gate.getGateStatus() ~= "idle") do
    os.sleep(0)
    end
    event.ignore("modem_message", diseng)
    if gate.getIrisType() ~= "NULL" then
    if gate.getIrisState() == "OPENED" then gate.toggleIris() end
    while(gate.getIrisState() ~= "CLOSED") do os.sleep(0) end
    end
   os.sleep(0.16)
   gate.engageGate()
   os.sleep(3)
    if gate.getIrisType() ~= "NULL" then
    if gate.getIrisState() == "CLOSED" then gate.toggleIris() end
    while(gate.getIrisState() ~= "OPENED") do os.sleep(0) end
    end
    if (tun and myad == tunnel.address) then tunnel.send(table.concat({"dialed"}, sym)) else send(sadd, 100, {"dialed"}) end
   event.listen("modem_message", main)
   tunidle = true
   event.listen("stargate_incoming_wormhole", tunmessage)
   event.listen("stargate_iris_closed", tunmessage)
   event.listen("stargate_iris_opened", tunmessage)
   event.listen("stargate_incoming_wormhole", incomeIris)
   event.listen("stargate_open", tunmessage)
   event.listen("stargate_wormhole_closed_fully", tunmessage)
   event.listen("stargate_wormhole_stabilized", tunmessage)
   event.listen("stargate_close", delaytunmessage)
   event.listen("stargate_dhd_chevron_engaged", tunmessage)
   event.listen("stargate_spin_chevron_engaged", tunmessage)
   event.listen("comonent_available", tunmessage)
   event.listen("stargate_failed", delaytunmessage)
   event.listen("key_down", keylisten)
   end
  end
 elseif (msg == "dis") then 
 if (tun and myad == tunnel.address) then tunnel.send(table.concat({"disengage"}, sym)) else send(sadd, 100, {"disengage"}) end
 gate.disengageGate()
 fclose()
 tunidle = true
 elseif (msg == "code" and msga ~= nil and myad == tunnel.address) then
 irisCode = msga
 os.sleep(0.1)
 tunnel.send(table.concat({"code", "Changed"}, sym))
 elseif (msg == "iopen" and (myad == tunnel.address or msga == irisCode)) then 
  if gate.getIrisState() == "CLOSED" then
  gate.toggleIris()
  os.sleep(0)
   if (myad == tunnel.address) then
   while (gate.getIrisState() ~= "OPENED") do os.sleep(0) end
   os.sleep(0.1)
   else
   send(sadd, 100, {"iris", "opened"})
   end
  end
 elseif (msg == "iclose") then
  if gate.getIrisType() ~= "NULL" and gate.getIrisState() == "OPENED" then
  gate.toggleIris()
  os.sleep(0)
  while (gate.getIrisState() ~= "CLOSED") do os.sleep(0) end
  if (myad ~= tunnel.address) then send(sadd, 100, {"iris", "closed"}) end
  os.sleep(0.1)
  end
 elseif (msg == "iopensend") then 
 gdorepeat("iopen", msga)
 send(sadd, 100, {"iris", "luck"})
 elseif (msg == "iclosesend") then
 gdorepeat("iclose")
 send(sadd, 100, {"iris", "closed"})
 end
end
--main message work--
 
--start program--
function start()
 if com.stargate.getIrisState() == "CLOSED" then
 com.stargate.toggleIris()
 os.sleep(0)
 end
modem.open(100)
modem.open(101)
modem.setStrength(50)
if (rep) then
term.clear()
event.listen("modem_message", main)
if (tun) then 
tunnel.send(table.concat({"link"}, sym))
end
end
--if (tunidle) then
event.listen("stargate_incoming_wormhole", tunmessage)
event.listen("stargate_iris_closed", tunmessage)
event.listen("stargate_iris_opened", tunmessage)
event.listen("stargate_incoming_wormhole", incomeIris)
event.listen("stargate_open", tunmessage)
event.listen("stargate_wormhole_closed_fully", tunmessage)
event.listen("stargate_wormhole_stabilized", tunmessage)
event.listen("stargate_close", delaytunmessage)
event.listen("stargate_dhd_chevron_engaged", tunmessage)
event.listen("stargate_spin_chevron_engaged", tunmessage)
event.ignore("comonent_available", tunmessage)
event.ignore("stargate_failed", delaytunmessage)
event.ignore("modem_message", diseng)
if (com.isAvailable("stargate")) then
com.stargate.disengageGate()
com.stargate.engageGate()
event.listen("comonent_available", tunmessage)
event.listen("stargate_failed", delaytunmessage)
event.listen("key_down", keylisten)
--end
--else tunidle = true
end
end
 
while (rep) do
if(startcheck) then 
start()
startcheck = false
end
os.sleep(2)
end
 
--start()
--start program--
