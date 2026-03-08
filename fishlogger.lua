-- FISH IT LOGGER V3

local CONFIG = {
WEBHOOK_URL = "https://discord.com/api/webhooks/1453095234719322304/31F7c7UgA3tbyHh_7FIgRwemVmEfvixQdssDiixagr8E2zdKKpnNHAtA45pfkT4mkOz4",
COOLDOWN = 5
}

local HttpService = game:GetService("HttpService")

local RARITY_COLORS = {
Common = 8421504,
Rare = 3447003,
Epic = 15105570,
Legendary = 15844367,
Secret = 10181046
}

local EVENT_FISH = {
"Santa Salmon",
"Ghost Shark",
"Pumpkin Carp",
"Frostbite Eel",
"Lunar Koi"
}

local function getLocation()

local char = game.Players.LocalPlayer.Character
if not char then return "Unknown" end

local root = char:FindFirstChild("HumanoidRootPart")
if not root then return "Unknown" end

local pos = root.Position

return string.format("X: %.0f Y: %.0f Z: %.0f",pos.X,pos.Y,pos.Z)
end

local function getFishImage(tool)

if tool.TextureId and tool.TextureId ~= "" then
return "https://www.roblox.com/asset-thumbnail/image?assetId="..
tool.TextureId:gsub("%D","").."&width=420&height=420&format=png"
end

if tool:FindFirstChild("Handle") then
local mesh = tool.Handle:FindFirstChildOfClass("SpecialMesh")

if mesh and mesh.TextureId then
return "https://www.roblox.com/asset-thumbnail/image?assetId="..
mesh.TextureId:gsub("%D","").."&width=420&height=420&format=png"
end
end

return ""
end

local function isEventFish(name)

for _,fish in ipairs(EVENT_FISH) do
if name:lower():find(fish:lower()) then
return true
end
end

return false
end

local function sendWebhook(data)

local embed = {
title = "🎣 Fish Tracker",
color = RARITY_COLORS[data.rarity] or 8421504,

fields = {
{name="Player",value=data.player,inline=true},
{name="Fish",value=data.name,inline=true},
{name="Weight",value=data.weight.." kg",inline=true},

{name="Mutation",value=data.mutation,inline=true},
{name="Rarity",value=data.rarity,inline=true},
{name="Location",value=data.location,inline=false}
},

thumbnail = {url=data.image},
footer = {text=os.date("%d/%m/%Y %H:%M:%S")}
}

local payload = {
username = "Fish Tracker",
embeds = {embed}
}

local req = (syn and syn.request) or request or http_request

if req then
req({
Url = CONFIG.WEBHOOK_URL,
Method = "POST",
Headers = {["Content-Type"]="application/json"},
Body = HttpService:JSONEncode(payload)
})
end
end

local FishLogger = {}
FishLogger.Queue = {}
FishLogger.LastSend = 0
FishLogger.Processing = false

function FishLogger:add(data)

table.insert(self.Queue,data)

if not self.Processing then
self:process()
end
end

function FishLogger:process()

self.Processing = true

while #self.Queue > 0 do

if tick()-self.LastSend < CONFIG.COOLDOWN then
task.wait(2)
end

local data = table.remove(self.Queue,1)

pcall(function()
sendWebhook(data)
end)

self.LastSend = tick()

task.wait(math.random(2,4))
end

self.Processing = false
end

function FishLogger:checkTool(tool)

if not tool:IsA("Tool") then return end

local weight =
tool:GetAttribute("Weight") or
(tool:FindFirstChild("Weight") and tool.Weight.Value)

if not weight then return end

local rarity =
tool:GetAttribute("Rarity") or
(tool:FindFirstChild("Rarity") and tool.Rarity.Value) or
"Common"

local mutation =
tool:GetAttribute("Mutation") or
(tool:FindFirstChild("Mutation") and tool.Mutation.Value) or
"Normal"

local location = getLocation()

local name = tool.Name

if rarity == "Legendary" or rarity == "Secret" then
print("RARE FISH:",name)
end

if isEventFish(name) then
rarity = "Event"
end

local data = {
player = game.Players.LocalPlayer.Name,
name = name,
weight = tonumber(weight) or 0,
rarity = rarity,
mutation = mutation,
image = getFishImage(tool),
location = location
}

self:add(data)
end

function FishLogger:start()

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

backpack.ChildAdded:Connect(function(item)
task.wait(1)
self:checkTool(item)
end)

local char = player.Character or player.CharacterAdded:Wait()

char.ChildAdded:Connect(function(item)
task.wait(0.5)
self:checkTool(item)
end)

player.CharacterAdded:Connect(function(c)
c.ChildAdded:Connect(function(item)
task.wait(0.5)
self:checkTool(item)
end)
end)

print("Fish Logger V3 Started")
end

FishLogger:start()
