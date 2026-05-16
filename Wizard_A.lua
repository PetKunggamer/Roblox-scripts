if not game:IsLoaded() then
    game.Loaded:Wait()
end

local func = {}

local plr = game.Players.LocalPlayer


local RS = game:GetService("ReplicatedStorage")
local Msg = RS:WaitForChild("Msg")
local RemoteEvent = Msg:WaitForChild("RemoteEvent")
local RemoteEvent2 = RemoteEvent:WaitForChild("RemoteEvent")
local ReleaseGroupSkill = RemoteEvent:WaitForChild("ReleaseGroupSkill")
local Function = Msg:WaitForChild("Function")
local TalkFunc = Function:WaitForChild("TalkFunc")


local getgenv = getgenv or function() return _G end

getgenv().Loops = getgenv().Loops or {}

local RS = game:GetService("ReplicatedStorage")

local function StartLoop(name, callback)
    if getgenv().Loops[name] then
        task.cancel(getgenv().Loops[name])
    end

    getgenv().Loops[name] = task.spawn(callback)
end

local function StopLoop(name)
    if getgenv().Loops[name] then
        task.cancel(getgenv().Loops[name])
        getgenv().Loops[name] = nil
    end
end

function func.ToggleButton()
    local folder = game:GetService("CoreGui").RobloxGui
    for _,v in ipairs(folder:GetChildren()) do
        if v.Name == "WindUI/Toggle" then
            v:Destroy()
        end
    end

    local Toggle = Instance.new("ScreenGui")
    Toggle.Name = "WindUI/Toggle"
    Toggle.ResetOnSpawn = false
    Toggle.Parent = folder

    local button = Instance.new("ImageButton")
    button.Name = "ToggleButton"
    button.Parent = Toggle

    button.Size = UDim2.new(0, 50, 0, 50)
    button.Position = UDim2.new(0.5, -25, 0, 20)

    button.BackgroundColor3 = Color3.fromRGB(255,255,255)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true

    button.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=11154422911&width=420&height=420&format=png"

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(.2,0)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        local Hub = folder:FindFirstChild("WindUI")
        if Hub then
            Hub.Enabled = not Hub.Enabled
        end
    end)
end

function func.AntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    plr.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

func.AntiAFK()

function func.DestroyUI()
    for i,v in pairs(game:GetService("CoreGui").RobloxGui:GetChildren()) do
        if string.match(v.Name, "WindUI") then
            v:Destroy()
        end
    end
end

func.DestroyUI()

local id_list = {
    ["Blueberry"] = 2000001,
    ["Withered Mushroom"] = 2000002,
    ["Seagull Egg"] = 2000003,
    ["Dwarf Emblem"] = 2000004,
    ["Golden Tooth"] = 2000005,
    ["Flame Crest"] = 2000006,
    ["Goblin Finger"] = 2000007,
    ["Goblin Bone"] = 2000008,
    ["Copper Earring"] = 2000009,
    ["Furnace Core"] = 2000010,
    ["Fire Shard"] = 2000016,
}

function func.GetRoot()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

function func.GetMob()
    local mob, dist = nil, math.huge
    for _, v in pairs(workspace.Monster:GetChildren()) do
        if v:IsA("Model") then
            local root = v:FindFirstChild("Root") or v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local mag = (func.GetRoot().Position - root.Position).Magnitude
                if mag < dist then
                    mob, dist = v, mag
                end
            end
        end
    end
    return mob
end

local currentHighlight = nil

function func.Attack()
    local mob = func.GetMob()
    
    -- clear highlight เก่า
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
    
    if mob then
        local root = mob:FindFirstChild("Root") or mob:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- สร้าง highlight ใหม่
        currentHighlight = Instance.new("Highlight")
        currentHighlight.FillColor = Color3.fromRGB(255, 0, 0)
        currentHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        currentHighlight.FillTransparency = 0.5
        currentHighlight.OutlineTransparency = 0
        currentHighlight.Parent = mob

        -- ถ้า mob ตายให้ลบ highlight
        local hum = mob:FindFirstChild("Humanoid")
        if hum then
            hum.Died:Once(function()
                if currentHighlight then
                    currentHighlight:Destroy()
                    currentHighlight = nil
                end
            end)
        end

        local args = {
            4,
            {
                targetCF = root.CFrame,
                releaseCF = root.CFrame,
            }
        }
        ReleaseGroupSkill:FireServer(unpack(args))
    end
end

function func.AutoPickUp()
    if not workspace.Drops[plr.UserId] then
        workspace.Drops:WaitForChild(plr.UserId)
    end
    for i,v in pairs(workspace.Drops[plr.UserId]:GetChildren()) do
        if v:IsA("Vector3Value") then
            local args = {
                "pick",
                tostring(v)
            }
            RemoteEvent2:FireServer(unpack(args))
        end
    end
end

function func.Get_Blueberry()
	local berry = nil
    for i,v in pairs(plr.PlayerGui.ScreenGui.SellPop.ContentClip.Main._BagFrame:GetChildren()) do
        if v:IsA("TextButton") then
            local Name = v:FindFirstChild("Name")
			if Name and Name.Text and Name.Text == "Blueberry" then
				berry = v:GetAttribute("onlyID")
			end
        end
    end
	return berry
end


function func.InfInv()
    local berryID = func.Get_Blueberry()
    if not berryID then return end  -- safety guard
	local RF = game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteFunction"):WaitForChild("RemoteFunction")
	local res = RF:InvokeServer("\229\135\186\229\148\174\232\131\140\229\140\133\231\137\169\229\147\129", {
		onlyIDList = { berryID },
		countList = { 0/0 } -- nan = sell all
	})
	print("Sell result:", res)
	if type(res) == "table" then table.foreach(res, warn) end
end

function func.AutoQuest()
    local quest = {
        "\228\187\187\229\138\1611",
        "\228\187\187\229\138\1612",
        "\228\187\187\229\138\1613",
        "\228\187\187\229\138\1614",
        "\228\187\187\229\138\1615",
        "\228\187\187\229\138\1616",
        }
    for i,v in pairs(quest) do
        local args = {
            "\229\143\145\230\148\190\228\187\187\229\138\161",
            {
                tostring(v)
            }
        }
        TalkFunc:InvokeServer(unpack(args))
    end
    -- Talk with harry
    local harry = {
        "\228\187\187\229\138\16110",
        "\228\187\187\229\138\16111",
        "\228\187\187\229\138\16112",
        "\228\187\187\229\138\16113",
        "\228\187\187\229\138\16114",
        "\228\187\187\229\138\16115",
        }
    for i,v in pairs(harry) do
        local args = {
            "\229\174\140\230\136\144\228\187\187\229\138\161",
            {
                tostring(v)
            }
        }
        TalkFunc:InvokeServer(unpack(args))
    end
end

local found = false

function func.AutoChest()
    local folder = workspace["\229\174\162\230\136\183\231\171\175\229\174\157\231\174\177"]
    local playerRoot = func.GetRoot()
    local originalCF = playerRoot.CFrame
    for _, v in pairs(folder:GetChildren()) do
        if v:IsA("Model") then
            local root = v:FindFirstChild("HumanoidRootPart")
            if root then
                found = true
                local prompt = root:FindFirstChild("ChestPrompt")
                if prompt and prompt.Enabled then
                    fireproximityprompt(prompt)
                    task.wait(0.1)
                end
            end
        end
    end
    if not found then return end
    wait(1) -- wait for chest to open
    -- วาปกลับจุดเดิม
    playerRoot.CFrame = originalCF
    found = false
end

function func.UnlockGamepass()
    for _,v in pairs(plr.GamePass:GetChildren()) do
        if v:IsA("NumberValue") then
            v.Value = 1
        end
    end
end

local selectedMaterials = {}

local function getMaterialList()
    if not next(selectedMaterials) then return "Empty" end
    local lines = {}
    for idStr, count in pairs(selectedMaterials) do
        -- หาชื่อจาก id
        local name = idStr
        for n, id in pairs(id_list) do
            if tostring(id) == idStr then name = n break end
        end
        table.insert(lines, string.format("• %s x%d", name, count))
    end
    return table.concat(lines, "\n")
end


-- AutoBrew ใช้ selectedMaterials
function func.AutoBrew()
    if not next(selectedMaterials) then return end
    local RF = game:GetService("ReplicatedStorage"):WaitForChild("Msg")
        :WaitForChild("RemoteFunction"):WaitForChild("RemoteFunction")
    local cauldronID = 8000001

    local res1 = RF:InvokeServer("\231\130\188\232\141\175\230\184\184\230\136\143\229\188\128\229\167\139", {
        cauldronID = cauldronID,
        materials = selectedMaterials,
    })
    if not res1 then return end
    task.wait(0.5)
    RF:InvokeServer("\231\130\188\232\141\175", {
        cauldronID = cauldronID,
        materials = selectedMaterials,
        gameScore = 100
    })
end












-- Stats tracking
local sessionStart = os.time()
local startGold = nil
local startLevel = nil

local function parseGold(text)
    local clean = text:gsub("<[^>]+>", ""):gsub("/.*", "")
    local num = tonumber(clean:match("[%d%.]+")) or 0
    local suffix = clean:match("[KMB]") or ""
    local mult = suffix == "K" and 1000 or suffix == "M" and 1000000 or suffix == "B" and 1000000000 or 1
    return num * mult
end

local function getGold()
    local ok, res = pcall(function()
        return plr.PlayerGui.TopbarStandard.Holders.Left.Money.IconButton.Menu.IconSpot.Contents.IconLabelContainer.IconLabel.Text
    end)
    return ok and parseGold(res) or 0
end

local function getLevel()
    local ok, res = pcall(function()
        return plr.PlayerGui.ScreenGui.Main.BottomLeft.Lv.CurLv.Text
    end)
    return ok and (tonumber(res:match("%d+")) or 0) or 0
end

local function formatTime(secs)
    return string.format("%02d:%02d:%02d", math.floor(secs/3600), math.floor((secs%3600)/60), secs%60)
end

local function formatNum(n)
    if n >= 1000000 then return string.format("%.1fM", n/1000000)
    elseif n >= 1000 then return string.format("%.1fK", n/1000)
    else return tostring(math.floor(n)) end
end

task.delay(1, function()
    startGold = getGold()
    startLevel = getLevel()
end)

print('Function loadded!!')

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Skyra Hub",
    Icon = "cloud", -- lucide icon
    Author = "by Syn0xz",
    Folder = "SkyraHub/"..tostring(game.PlaceId).."",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(650, 480),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.RightShift,
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = false,
})

func.ToggleButton()

WindUI:AddTheme({
    Name = "Syn0xz Hub",

    Accent = WindUI:Gradient({
        ["0"] = {Color = Color3.fromHex("#09090b"), Transparency = 0},
        ["30"] = {Color = Color3.fromHex("#18181b"), Transparency = 0.4},
        ["65"] = {Color = Color3.fromHex("#1d4ed8"), Transparency = 0.2},
        ["100"] = {Color = Color3.fromHex("#09090b"), Transparency = 0},
    }, {
        Rotation = 45
    }),
    Outline = Color3.fromHex("#27272a"),
    Text = Color3.fromHex("#fafafa"),
    Placeholder = Color3.fromHex("#71717a"),
    Button = Color3.fromHex("#6ac769"),
    Icon = Color3.fromHex("#a1a1aa")
})


WindUI:SetTheme("Syn0xz Hub")

local ConfigManager = Window.ConfigManager
local Config = ConfigManager:CreateConfig("Config")

local saveDebounce = false

local function AutoSave(callback)
    return function(...)
        if callback then
            callback(...)
        end

        if not saveDebounce then
            saveDebounce = true
            task.delay(1,function()
                Config:Save()
                saveDebounce = false
            end)
        end
    end
end

local MainSection = Window:Section({
    Title = "Main",
    Opened = true
})

-- Create FarmTab
local FarmTab = MainSection:Tab({
    Title = "Main",
    Icon = "joystick", -- lucide icon
})

FarmTab:Select()

-- Create FarmTab
local Brew = MainSection:Tab({
    Title = "Brew",
    Icon = "bottle-wine", -- lucide icon
})

local Shop = MainSection:Tab({
    Title = "Shop",
    Icon = "shopping-cart", -- lucide icon
})

local Misc = MainSection:Tab({
    Title = "Misc",
    Icon = "settings", -- lucide icon
})

-- button save

local StatsParagraph = FarmTab:Paragraph({
    Title = "📊 Session Stats",
    Desc = "Loading...",
})

local BrewParagraph = Brew:Paragraph({
    Title = "🧪 Brew Materials",
    Desc = "Empty",
})

local function updateParagraph()
    BrewParagraph:SetDesc(getMaterialList())
end


task.spawn(function()
    while task.wait(1) do
        local elapsed = os.time() - sessionStart
        local hrs = math.max(elapsed / 3600, 0.0001)
        local curGold = getGold()
        local curLevel = getLevel()
        local goldPerHr = (curGold - (startGold or curGold)) / hrs
        local lvGain = curLevel - (startLevel or curLevel)

        StatsParagraph:SetDesc(string.format(
            "⏱ %s\n💰 %s/hr\n⚔ +%d levels",
            formatTime(elapsed),
            formatNum(goldPerHr),
            lvGain
        ))
    end
end)

local Attack = FarmTab:Toggle({
    Title = "Auto Farm",
    Desc = "Auto attack mobs around you.",
    Callback = AutoSave(function(state)
        if state then
            StartLoop("Attack", function()
                while task.wait(.1) do
                    func.Attack()
                end
            end)
        else
            StopLoop("Attack")
        end
    end)
})

Config:Register("Attack", Attack)

local AutoPickUp = FarmTab:Toggle({
    Title = "Auto Pick Up",
    Desc = "Auto pick up items around you.",
    Callback = AutoSave(function(state)
        if state then
            StartLoop("AutoPickUp", function()
                while task.wait(.1) do
                    func.AutoPickUp()
                end
            end)
        else
            StopLoop("AutoPickUp")
        end
    end)
})

Config:Register("AutoPickUp", AutoPickUp)

local AutoAscend = FarmTab:Toggle({
    Title = "Auto Ascend",
    Desc = "Auto ascend when you can.",
    Callback = AutoSave(function(state)
        if state then
            StartLoop("AutoAscend", function()
                while task.wait(.1) do
                    local RF = game:GetService("ReplicatedStorage"):WaitForChild("Msg"):WaitForChild("RemoteFunction"):WaitForChild("RemoteFunction")
                    RF:InvokeServer("\233\135\141\231\148\159") -- ascend
                end
            end)
        else
            StopLoop("AutoAscend")
        end
    end)
})

Config:Register("AutoAscend", AutoAscend)

local AutoQuest = FarmTab:Toggle({
    Title = "Auto Quest",
    Desc = "Auto complete quests.",
    Callback = AutoSave(function(state)
        if state then
            StartLoop("AutoQuest", function()
                while task.wait(1) do
                    func.AutoQuest()
                end
            end)
        else
            StopLoop("AutoQuest")
        end
    end)
})

Config:Register("AutoQuest", AutoQuest)

local AutoChest = FarmTab:Toggle({
    Title = "Auto Chest",
    Desc = "Auto open chests around you.",
    Callback = AutoSave(function(state)
        if state then
            StartLoop("AutoChest", function()
                while task.wait(1) do
                    func.AutoChest()
                end
            end)
        else
            StopLoop("AutoChest")
        end
    end)
})

Config:Register("AutoChest", AutoChest)

local AutoBrew = Brew:Toggle({
    Title = "Auto Brew",
    Desc = "Auto brew potions when you have materials.",
    Callback = AutoSave(function(state)
        if state then
            StartLoop("AutoBrew", function()
                while task.wait(1) do
                    func.AutoBrew()
                end
            end)
        else
            StopLoop("AutoBrew")
        end
    end)
})

local selectedItem = nil
local BrewDropdown = Brew:Dropdown({
    Title = "Material",
    Desc = "Select material to add",
    Values = (function()
        local t = {}
        for name in pairs(id_list) do table.insert(t, name) end
        table.sort(t)
        return t
    end)(),
    Multi = false,
    AllowNone = true,
    Callback = function(val)
        selectedItem = val
    end
})

-- Slider เลือกจำนวน
local selectedCount = 1

local BrewSlider = Brew:Slider({
    Title = "Count",
    Desc = "Amount to add",
    Step = 1,
    Value = { Min = 1, Max = 10, Default = 1 },
    Callback = function(val)
        selectedCount = val  -- แค่เก็บตัวเลขไว้
    end
})

-- ปุ่ม Add
local BrewAdd = Brew:Button({
    Title = "➕ Add Material",
    Callback = function()
        if not selectedItem then return end
        local id = tostring(id_list[selectedItem])
        selectedMaterials[id] = (selectedMaterials[id] or 0) + selectedCount  -- บวก count ที่นี่
        updateParagraph()
    end
})
-- ปุ่ม Clear
local ClearBrew = Brew:Button({
    Title = "🗑 Clear Materials",
    Desc = "Clear all materials from brew list",
    Callback = function()
        selectedMaterials = {}
        updateParagraph()
        WindUI:Notify({ Title = "Brew", Content = "Cleared!", Duration = 2, Icon = "trash" })
    end
})

local FarmSpot = FarmTab:Button({
    Title = "Farm Spot",
    Desc = "Teleport to the best farm spot",
    Callback = function()
        local root = func.GetRoot()
        if not root then return end
        root.CFrame = CFrame.new(221, 193, 126)
    end
})

local SellPop = Shop:Button({
    Title = "Sell Pop",
    Desc = "Open Sell UI",
    Callback = function()
        local args = {
            "\230\137\147\229\188\128\231\149\140\233\157\162",
            {
                "SellPop"
            }
        }
        TalkFunc:InvokeServer(unpack(args))
    end
})

local ShopPop = Shop:Button({
    Title = "Shop Pop",
    Desc = "Open Shop UI",
    Callback = function()
        local args = {
            "\230\137\147\229\188\128\231\149\140\233\157\162",
            {
                "EquipShop"
            }
        }
        TalkFunc:InvokeServer(unpack(args))
    end
})

local InfInv = Misc:Button({
    Title = "Inf Inventory Storage",
    Desc = "Get inf inventory storage but berries will bug (open material sell pop first)",
    Callback = function()
        func.InfInv()
    end
})


local UnlockGamepass = Misc:Button({
    Title = "Unlock Gamepass",
    Desc = "Unlock all gamepasses.",
    Callback = function()
        func.UnlockGamepass()
    end
})

Config:Load()

WindUI:Notify({
    Title = "Syn0xz Hub",
    Content = "Syn0xz Hub is loadded.",
    Duration = 3, -- 3 seconds
    Icon = "bird",
})
