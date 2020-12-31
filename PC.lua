--libraries--
local comp = require("component")
local computer = require("computer")
local gpu = comp.gpu
local event = require("event")
local term = require("term")
local serial = require("serialization")
local math = require("math")
local string = require("string")
--libraries--
 
--global variables--
local gateadd = comp.stargate.address
local startcheck = true
local tunidle = false
local tunmessagebool = true
local tunmessstate = ""
local gadd = {}
local disen = false
local ser = {}
local rep = true
local tun = comp.isAvailable("tunnel")
local tunnel
if (tun) then tunnel = comp.tunnel tunnel.setWakeMessage("link", true) end
 
local modem
if (comp.isAvailable("modem") == false or comp.modem.isWireless() == false) then computer.beep(500, 1) computer.beep(400, 1) computer.beep(500, 1) computer.beep(400, 1) rep = false  os.exit(false) else modem = comp.modem modem.setWakeMessage("link") end 
--global variables--
 
--send modem message--
function send(add, chan, a, b, c)
if (c == nil) then
 if (b == nil) then
 modem.send(add, chan, a)
 modem.send(add, chan, a)
 modem.send(add, chan, a)
 else
 modem.send(add, chan, a, b)
 modem.send(add, chan, a, b)
 modem.send(add, chan, a, b)
 end
 else
modem.send(add, chan, a, b, c)
modem.send(add, chan, a, b, c)
modem.send(add, chan, a, b, c)
end
end
--send modem message--
 
--send tunnel message--
function tunenergymessage()
local gate = comp.stargate
local state, _ = gate.getGateStatus()
tunnel.send("ener", gate.getEnergyStored(), gate.getMaxEnergyStored())
if(gate.getEnergyStored()/gate.getMaxEnergyStored() < 1 and gate.getGateStatus == "idle") then
event.timer(10, tunenergymessage)
end
end
 
function tunmessage()
 local gate = comp.stargate
 local state, _ = gate.getGateStatus()
 if (tunmessagebool and (tunmessstate ~= state or gateadd ~= gate.address)) then
 tunmessstate = state
 tunmessagebool = false
 gateadd = gate.address
 tunnel.send("main", gate.getGateType(), state, gate.getEnergyStored(), gate.getMaxEnergyStored(), gate.dialedAddress, serial.serialize(gate.stargateAddress))
 if(gate.getEnergyStored()/gate.getMaxEnergyStored() < 1 and gate.getGateStatus == "idle") then
 event.timer(10, tunenergymessage)
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
computer.beep(300, 1.5)
computer.beep(500, 1.5)
end
 
function tunnelmessagework (mess)
print(mess)
computer.beep(300, 1)
computer.beep(400, 1)
computer.beep(500, 1)
end
--work with text messages--
 
--gate abort dial / disengage gate--
function diseng(_, myad, _, _, _, msg)
 if (msg == "abort") then
 disen = true
end
end
--end--
--gate abort dial / disengage gate--
 
--short address check--
function addcheck(add)
local gate = comp.stargate
local timed = add
if (#timed > 7) then
 if (gate.getEnergyRequiredToDial(timed[1], timed[2], timed[3], timed[4], timed[5], timed[6]) ~= "address_malformed" and gate.getEnergyRequiredToDial(timed[1], timed[2], timed[3], timed[4], timed[5], timed[6]) ~= "not_merged") then
  timed[7] = timed[#timed]
  timed[#timed] = nil
  if (#add == 8) then timed[8] = nil end
 elseif ((gate.getEnergyRequiredToDial(timed[1], timed[2], timed[3], timed[4], timed[5], timed[6], timed[7]) ~= "address_malformed" and gate.getEnergyRequiredToDial(timed[1], timed[2], timed[3], timed[4], timed[5], timed[6], timed[7]) ~= "not_merged") and #timed == 9) then
 timed[8] = timed[#timed]
 timed[#timed] = nil
 end
end
return (timed)
end
--short address check--
 
--main message work--
function main(_, myad, sadd, _, _, msg, msga, radd)
local gate = comp.stargate
rec = sadd
if (tun and myad == tunnel.address) then 
 os.sleep(0.1)
if (msg == "link") then
 os.sleep(0.1)
 tunmessstate = ""
 tunmessage()
 elseif (msg == "mess" and radd ~= myad) then
 tunnelmessagework(msga)
 os.sleep(0.1)
 elseif (msg == "ener") then
 tunnel.send("ener", gate.getEnergyStored(), gate.getMaxEnergyStored())
 os.sleep(0.1)
 elseif (msg == "abort") then
 gate.disengageGate()
 gate.engageGate()
    tunidle = true
   event.listen("modem_message", diseng)
   event.listen("stargate_incoming_wormhole", tunmessage)
   event.listen("stargate_open", tunmessage)
   event.listen("stargate_wormhole_closed_fully", tunmessage)
   event.listen("stargate_wormhole_stabilized", tunmessage)
   event.listen("stargate_close", delaytunmessage)
   event.listen("stargate_dhd_chevron_engaged", tunmessage)
   event.listen("stargate_spin_chevron_engaged", tunmessage)
   event.listen("component_available", tunmessage)
   event.listen("stargate_failed", delaytunmessage)
 os.sleep(0.1)
 elseif (msg == "add") then
  event.ignore("stargate_incoming_wormhole", tunmessage)
  event.ignore("stargate_open", tunmessage)
  event.ignore("stargate_wormhole_closed_fully", tunmessage)
  event.ignore("stargate_wormhole_stabilized", tunmessage)
  event.ignore("stargate_close", delaytunmessage)
  event.ignore("stargate_dhd_chevron_engaged", tunmessage)
  event.ignore("stargate_spin_chevron_engaged", tunmessage)
  event.ignore("component_available", tunmessage)
  event.ignore("stargate_failed", delaytunmessage)
  os.sleep(0.01)
  if (msga == "{}") then
  tunnel.send("empty address")
  else
  gadd = serial.unserialize(msga)
  if (gate.getEnergyRequiredToDial(gadd) == "address_malformed") then
  tunnel.send("address malformed")
  elseif (gate.getEnergyRequiredToDial(gadd) == "not_merged") then
  tunnel.send("not merged")
  elseif (gate.getEnergyStored() - gate.getEnergyRequiredToDial(gadd).open < 0) then
  tunnel.send("not enough energy")
  elseif (gadd[#gadd] ~= "Point of Origin" and gadd[#gadd] ~= "Glyph 17") then
   if (gate.getGateType() == "MILKYWAY") then
   tunnel.send("Missing Point of Origin")
   elseif (gate.getGateType() == "UNIVERSE") then
   tunnel.send("Missing Glyph 17")
   end
  else 
  os.sleep(0.01)
  ser = {}
  gadd = addcheck(gadd)
  tunnel.send("dialing", #gadd) 
  os.sleep(0.02)
   for _, val in ipairs(gadd) do
    while (gate.getGateStatus() ~= "idle") do
    os.sleep(0)
    end
    os.sleep(0.01)
    if (disen) then
    tunnel.send("abort")
    gate.disengageGate()
    disen = false
    break
    else
    if (gate.getGateType() == "UNIVERSE") then os.sleep(0.16) end
    gate.engageSymbol(val)
    table.insert(ser, val)
    tunnel.send(serial.serialize(ser))
    os.sleep(0)
    end
   end
   while (gate.getGateStatus() ~= "idle") do
   os.sleep(0)
   end
  if (gate.getGateType() == "UNIVERSE") then os.sleep(0.16) end
  event.ignore("modem_message", diseng)
  gate.engageGate()
  tunnel.send("dialed")
  event.listen("modem_message", main)
  end
  end
 elseif (msg == "dis" and gate.getGatetatus() == "open") then 
 tunnel.send("disengage")
 gate.disengageGate()
 fclose()
 end
else
if (msg == "link") then
local state, _ = gate.getGateStatus()
send(sadd, 1, gate.getGateType(), state, gate.dialedAddress)
elseif (msg == "mess" and radd ~= myad) then
messagework(msga)
os.sleep(0.1)
elseif (msg == "abort") then
gate.disengageGate()
gate.engageGate()
   tunidle = true
   event.listen("stargate_incoming_wormhole", tunmessage)
   event.listen("stargate_open", tunmessage)
   event.listen("stargate_wormhole_closed_fully", tunmessage)
   event.listen("stargate_wormhole_stabilized", tunmessage)
   event.listen("stargate_close", delaytunmessage)
   event.listen("stargate_dhd_chevron_engaged", tunmessage)
   event.listen("stargate_spin_chevron_engaged", tunmessage)
   event.listen("component_available", tunmessage)
   event.listen("stargate_failed", delaytunmessage)
os.sleep(0.1)
elseif (msg == "add") then
tunidle = false
event.listen("modem_message", diseng)
event.ignore("stargate_incoming_wormhole", tunmessage)
event.ignore("stargate_open", tunmessage)
event.ignore("stargate_wormhole_closed_fully", tunmessage)
event.ignore("stargate_wormhole_stabilized", tunmessage)
event.ignore("stargate_close", delaytunmessage)
event.ignore("stargate_dhd_chevron_engaged", tunmessage)
event.ignore("stargate_spin_chevron_engaged", tunmessage)
event.ignore("component_available", tunmessage)
event.ignore("stargate_failed", delaytunmessage)
 os.sleep(0.01)
 if (msga == "{}") then
 send(sadd, 1, "empty address")
 else
 gadd = serial.unserialize(msga)
 if (gate.getEnergyRequiredToDial(gadd) == "address_malformed") then
 send(sadd, 1, "address malformed")
 elseif (gate.getEnergyRequiredToDial(gadd) == "not_merged") then
 send(sadd, 1, "not merged")
 elseif (gadd[#gadd] ~= "Point of Origin" and gadd[#gadd] ~= "Glyph 17") then
  if (gate.getGateType() == "MILKYWAY") then
  send(sadd, 1, "Missing Point of Origin")
  elseif (gate.getGateType() == "UNIVERSE") then
  send(sadd, 1, "Missing Glyph 17")
  end
 else 
 os.sleep(0.01)
 ser = {}
 gadd = addcheck(gadd)
 send(sadd, 1, "dialing", #gadd) 
 os.sleep(0.02)
  for _, val in ipairs(gadd) do
   while (gate.getGateStatus() ~= "idle") do
   os.sleep(0)
   end
   if (disen) then
   send(sadd, 1, "abort")
   gate.disengageGate()
   disen = false
   tunidle = true
   event.listen("stargate_incoming_wormhole", tunmessage)
   event.listen("stargate_open", tunmessage)
   event.listen("stargate_wormhole_closed_fully", tunmessage)
   event.listen("stargate_wormhole_stabilized", tunmessage)
   event.listen("stargate_close", delaytunmessage)
   event.listen("stargate_dhd_chevron_engaged", tunmessage)
   event.listen("stargate_spin_chevron_engaged", tunmessage)
   event.listen("component_available", tunmessage)
   event.listen("stargate_failed", delaytunmessage)
   break
   else
   if (gate.getGateType() == "UNIVERSE") then os.sleep(0.16) end
   gate.engageSymbol(val)
   table.insert(ser, val)
   send(sadd, 1, serial.serialize(ser))
   end
  end
  while (gate.getGateStatus() ~= "idle") do
  os.sleep(0)
  end
 if (gate.getGateType() == "UNIVERSE") then os.sleep(0.16) end
 event.ignore("modem_message", diseng)
 gate.engageGate()
 send(sadd, 1, "dialed")
 event.listen("modem_message", main)
 tunidle = true
 event.listen("stargate_incoming_wormhole", tunmessage)
 event.listen("stargate_open", tunmessage)
 event.listen("stargate_wormhole_closed_fully", tunmessage)
 event.listen("stargate_wormhole_stabilized", tunmessage)
 event.listen("stargate_close", delaytunmessage)
 event.listen("stargate_dhd_chevron_engaged", tunmessage)
 event.listen("stargate_spin_chevron_engaged", tunmessage)
 event.listen("component_available", tunmessage)
 event.listen("stargate_failed", delaytunmessage)
 end
 end
elseif (msg == "dis" and gate.getGatetatus() == "open") then 
send(sadd, 1, "disengage")
gate.disengageGate()
fclose()
tunidle = true
end
end
end
--main message work--
 
--start program--
function start()
modem.open(1)
modem.setStrength(30)
if (rep) then
term.clear()
event.listen("modem_message", main)
if (tun) then 
tunnel.send("link")
end
end
--if (tunidle) then
event.listen("stargate_incoming_wormhole", tunmessage)
event.listen("stargate_open", tunmessage)
event.listen("stargate_wormhole_closed_fully", tunmessage)
event.listen("stargate_wormhole_stabilized", tunmessage)
event.listen("stargate_close", delaytunmessage)
event.listen("stargate_dhd_chevron_engaged", tunmessage)
event.listen("stargate_spin_chevron_engaged", tunmessage)
event.ignore("component_available", tunmessage)
event.ignore("stargate_failed", delaytunmessage)
event.ignore("modem_message", diseng)
if (comp.isAvailable("stargate")) then
comp.stargate.disengageGate()
comp.stargate.engageGate()
event.listen("component_available", tunmessage)
event.listen("stargate_failed", delaytunmessage)
--end
--else tunidle = true
end
end
 
while (rep) do
if(startcheck) then 
start()
startcheck = false
end
os.sleep(10)
end
 
--start()
--start program--
