-- // 1. AUTO-QUEUE CONFIGURATION
getgenv().ScriptToLoad = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/Dainstro/Tower/refs/heads/main/main.lua"))()]]

-- // 2. LOAD OBSIDIAN LIBRARY
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

-- // 3. VARIABLES
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local currentIndex = 1
getgenv().WalkSpeedValue = 16
getgenv().NotificationsEnabled = true
getgenv().AutoQueueEnabled = true

-- // 4. FUNCTIONS

local function TriggerQueue()
    if not getgenv().AutoQueueEnabled then return end
    
    local scriptString = getgenv().ScriptToLoad
    if typeof(scriptString) == "string" and scriptString ~= "" then
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport(scriptString)
        elseif queue_on_teleport then
            queue_on_teleport(scriptString)
        end
    end
end

local function SendNotify(title, text)
    if getgenv().NotificationsEnabled then
        Library.Notify(text, 3)
    end
end

-- Sorting rank: Advanced (1), Air (2), Safe (3), Others (4)
local function GetPriorityValue(name)
    if string.find(name, "^Advanced") then return 1 end
    if string.find(name, "^Air") then return 2 end
    if string.find(name, "^Safe") then return 3 end
    return 4
end

local function TeleportToNextKey(rootPart)
    local foundKeys = {}
    
    for _, object in ipairs(Workspace:GetDescendants()) do
        if (object:IsA("BasePart") or object:IsA("Model") or object:IsA("Tool")) and string.find(object.Name, "Key") then
            table.insert(foundKeys, object)
        end
    end

    if #foundKeys == 0 then
        SendNotify("Error", "No keys found!")
        currentIndex = 1
        return
    end

    -- Automatic Internal Priority Sorting
    table.sort(foundKeys, function(a, b)
        return GetPriorityValue(a.Name) < GetPriorityValue(b.Name)
    end)

    if currentIndex > #foundKeys then currentIndex = 1 end

    local target = foundKeys[currentIndex]
    
    if target then
        rootPart.CFrame = target:GetPivot() + Vector3.new(0, 10, 0)
        print("Teleported to: " .. target.Name .. " (Priority: " .. GetPriorityValue(target.Name) .. ")")
        SendNotify("Success", "Teleported to " .. target.Name)
        
        currentIndex = currentIndex + 1
        TriggerQueue()
    end
end

local function TeleportToFlare(rootPart)
    local flare = Workspace:FindFirstChild("Flare", true)
    if flare then
        rootPart.CFrame = flare:GetPivot() + Vector3.new(0, 10, 0)
        SendNotify("Success", "Teleported to Flare")
        TriggerQueue()
    else
        SendNotify("Error", "Flare not found!")
    end
end

-- Speed Loop
task.spawn(function()
    while task.wait() do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
        end
    end
end)

-- // 5. UI SETUP
local Window = Library:CreateWindow({
    Name = "Tower Hub | Daniel",
    Themeable = { Info = "Dainstro" }
})

local Tab = Window:AddTab("Main", "home")
local SettingsTab = Window:AddTab("Settings", "settings")

local MainSection = Tab:AddLeftGroupbox("Teleport Controls")
local SpeedSection = Tab:AddLeftGroupbox("Movement")

-- Main Buttons
MainSection:AddButton({
    Text = "Cycle Next Key (R)",
    Func = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            TeleportToNextKey(char.HumanoidRootPart)
        end
    end
})

MainSection:AddButton({
    Text = "Teleport to Flare (T)",
    Func = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            TeleportToFlare(char.HumanoidRootPart)
        end
    end
})

-- Speed Slider
SpeedSection:AddSlider("WalkSpeedSlider", {
    Text = "Walkspeed",
    Default = 16,
    Min = 16,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        getgenv().WalkSpeedValue = Value
    end
})

-- Settings Tab
local GeneralSettings = SettingsTab:AddLeftGroupbox("General")

GeneralSettings:AddToggle("NotifToggle", {
    Text = "Show Notifications",
    Default = true,
    Callback = function(Value) getgenv().NotificationsEnabled = Value end
})

GeneralSettings:AddToggle("QueueToggle", {
    Text = "Auto-Queue Script",
    Default = true,
    Callback = function(Value) getgenv().AutoQueueEnabled = Value end
})

GeneralSettings:AddButton({
    Text = "Reset Cycle Index",
    Func = function() currentIndex = 1 SendNotify("System", "Index Reset") end
})

-- // KEYBINDS
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if input.KeyCode == Enum.KeyCode.R then
        TeleportToNextKey(root)
    elseif input.KeyCode == Enum.KeyCode.T then
        TeleportToFlare(root)
    end
end)

Library:SetWatermark("Daniel Hub | " .. os.date("%X"))
SendNotify("Loaded", "Welcome back, Daniel.")
