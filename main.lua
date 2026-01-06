-- // 1. AUTO-QUEUE CONFIGURATION
getgenv().ScriptToLoad = [[
    -- PASTE YOUR SCRIPT HERE
    print("Script re-executed after teleport")
]]

-- // 2. LOAD OBSIDIAN LIBRARY
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

-- // 3. VARIABLES
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local currentIndex = 1

-- // 4. FUNCTIONS

local function TriggerQueue()
    local scriptString = getgenv().ScriptToLoad
    if typeof(scriptString) == "string" and scriptString ~= "" then
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport(scriptString)
        elseif queue_on_teleport then
            queue_on_teleport(scriptString)
        end
        print("[Queue] Script queued.")
    end
end

-- Sorting logic: Advanced > Air > Safe > Everything else
local function GetPriorityValue(name)
    if string.find(name, "^Advanced") then return 1 end
    if string.find(name, "^Air") then return 2 end
    if string.find(name, "^Safe") then return 3 end
    return 4
end

local function TeleportToNextKey(rootPart)
    local foundKeys = {}
    
    print("[Scan] Scanning and prioritizing: Advanced > Air > Safe")

    -- Collect all keys
    for _, object in ipairs(Workspace:GetDescendants()) do
        if (object:IsA("BasePart") or object:IsA("Model") or object:IsA("Tool")) and string.find(object.Name, "Key") then
            table.insert(foundKeys, object)
        end
    end

    if #foundKeys == 0 then
        Library.Notify("No keys found in Workspace!")
        currentIndex = 1
        return
    end

    -- Sort based on the naming priority
    table.sort(foundKeys, function(a, b)
        return GetPriorityValue(a.Name) < GetPriorityValue(b.Name)
    end)

    if currentIndex > #foundKeys then
        currentIndex = 1
    end

    local target = foundKeys[currentIndex]
    
    if target then
        -- Teleport 10 studs above
        rootPart.CFrame = target:GetPivot() + Vector3.new(0, 10, 0)
        
        -- Print confirmation
        print("TP #" .. currentIndex .. " | Priority Rank: " .. GetPriorityValue(target.Name) .. " | Name: " .. target.Name)
        Library.Notify("Teleported to: " .. target.Name)
        
        currentIndex = currentIndex + 1
        TriggerQueue()
    end
end

local function TeleportToFlare(rootPart)
    local flare = Workspace:FindFirstChild("Flare", true)
    
    if flare then
        rootPart.CFrame = flare:GetPivot() + Vector3.new(0, 10, 0)
        print("Teleported to Flare")
        Library.Notify("At Flare")
        TriggerQueue()
    else
        Library.Notify("No Flare Found")
    end
end

-- // 5. UI SETUP
local Window = Library:CreateWindow({
    Name = "Key & Flare Hub",
    Themeable = {
        Info = "Dainstro Scripts"
    }
})

local Tab = Window:AddTab("Main", "user")
local Section = Tab:AddLeftGroupbox("Controls")

Section:AddLabel("Auto-Priority: Advanced > Air > Safe")

Section:AddButton({
    Text = "Cycle Next Key (R)",
    Func = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            TeleportToNextKey(char.HumanoidRootPart)
        end
    end
})

Section:AddButton({
    Text = "Teleport to Flare (T)",
    Func = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            TeleportToFlare(char.HumanoidRootPart)
        end
    end
})

Section:AddButton({
    Text = "Reset Cycle Index",
    Func = function()
        currentIndex = 1
        Library.Notify("Cycle reset to start")
    end
})

-- // KEYBINDS
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root then return end

    if input.KeyCode == Enum.KeyCode.R then
        TeleportToNextKey(root)
    elseif input.KeyCode == Enum.KeyCode.T then
        TeleportToFlare(root)
    end
end)
