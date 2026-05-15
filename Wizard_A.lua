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

-- button save

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

local InfInv = FarmTab:Button({
    Title = "Inf Inventory",
    Desc = "Keep your inventory infinite\nBlueberry will bug",
    Callback = function()
        func.InfInv()
    end
})

Config:Register("InfInv", InfInv)

Config:Load()

WindUI:Notify({
    Title = "Syn0xz Hub",
    Content = "Syn0xz Hub is loadded.",
    Duration = 3, -- 3 seconds
    Icon = "bird",
})
