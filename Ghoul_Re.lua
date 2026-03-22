-- Wait for the game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local TS = game:GetService('TeleportService')
local GuiService = game:GetService('GuiService')
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService('VirtualUser')
local UIS = game:GetService("UserInputService")
local players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:FindFirstChild("Remotes")
local GetLives = Remotes:FindFirstChild("GetLives")

-- Wait for LocalPlayer's HumanoidRootPart
local player = players.LocalPlayer
local playergui = player.PlayerGui
repeat
    wait()
until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

print("Game and HumanoidRootPart are loaded!")

if game.PlaceId ~= 89413197677760 and game.PlaceId ~= 91797414023830 then return end

local hub = game:GetService("CoreGui")

for i,v in ipairs(hub:GetChildren()) do
    if v:IsA("ScreenGui") and v.Name == "ScreenGui" then
        v:Destroy()
    end
end

local env = _G

env.JobId = ""
env.Values = ""
env.wl_Clan = ""
env.Region = {}
env.QoL = false
env.Health_Below = 0

local char = player.Character or player.CharacterAdded:Wait()
local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
local cf_of_hrp = CFrame.new()

local Drawing_Exist, _ = pcall(function() Drawing.new("Text"):Remove() return nil end)

function worldpoint_to_viewpoint(pos)
    local pos, in_fov = workspace.CurrentCamera:WorldToViewportPoint(pos)
    return {Vector2.new(pos.X,pos.Y),in_fov}
end
if not Drawing_Exist then
    local ProtectGui = protectgui or (syn and syn.protect_gui) or function() warn("protect_gui No Exist!") end
    Drawing = env._fake_Drawing
    if not Drawing then
        Drawing = {}
        Drawing._objs = {}
        Drawing._update_loop = RunService.RenderStepped:Connect(function()
            for property, _internal_obj in pairs(Drawing._objs) do
                if not property._removed then
                    _internal_obj.Text = property["Text"]
                    _internal_obj.Visible = property["Visible"]
                    _internal_obj.TextSize = property["Size"]
                    _internal_obj.TextTransparency = property["Transparency"]
                    _internal_obj.TextStrokeTransparency = property["Outline"] and 0 or 1
                    _internal_obj.Position = UDim2.new(0,property["Position"].X,0,property["Position"].Y)
                    property.TextBounds = _internal_obj.TextBounds
                end
            end
        end)
        Drawing._gui = Instance.new("ScreenGui", RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"))
        ProtectGui(Drawing._gui)
        Drawing._gui.Name = "Fake Drawing"
        Drawing._fake = true
    end
    function Drawing.new(Type)
        if Type ~= "Text" then
            error(string.format("s% not Supported", Type))
            return
        end
        local _internal_obj = Instance.new("TextLabel",Drawing._gui)
        _internal_obj.BackgroundTransparency = 1
        local obj_property = {
            Font = 0,
            Size = 24,
            Text = "Place",
            Color = Color3.new(255/255, 0/255, 0/255),
            Center = true,
            Outline = true,
            _removed = false,
            Position = Vector2.new(0, 0),
            TextBounds = _internal_obj.TextBounds,
            Transparency = 0,
            OutlineColor = Color3.new(0, 0, 0)
        }
        function obj_property:Remove()
            obj_property._removed = true
            _internal_obj:Destory()
        end
        Drawing._objs[obj_property] = _internal_obj
        return obj_property
    end
    if not env._fake_Drawing then
        env._fake_Drawing = Drawing
    end
end   
function DrawTextLabel()
    if not env._Drawing then
        env._Drawing = {}
    end
    local TextLabel = Drawing.new("Text")
    env._Drawing[#env._Drawing+1] = TextLabel
    TextLabel.Text = "Place"
    TextLabel.Size = 24
    TextLabel.Center = true
    TextLabel.Outline = true
    TextLabel.Color = Color3.new(255/255, 0/255, 0/255)
    TextLabel.OutlineColor = Color3.new(0, 0, 0)
    return TextLabel
end
local Visualize = env.Visualize
env.Enable_Visualize = false
if not Visualize then 
    Visualize = DrawTextLabel()
    env.Visualize = Visualize
else
    RunService:UnbindFromRenderStep("Visualize CF_hrp_point")
end     
RunService:BindToRenderStep("Visualize CF_hrp_point", 0,function()
    local cf_p = cf_of_hrp.p
    local point_fov = worldpoint_to_viewpoint(cf_p)
    Visualize.Text = string.format("Current Point: [X: %.2f][Y: %.2f][Z: %.2f]",cf_p.X,cf_p.Y,cf_p.Z)
    Visualize.Position = point_fov[1]
    Visualize.Visible = point_fov[2] and env.Enable_Visualize
end)

player.CharacterAdded:Connect(function(newchar)
    char = newchar
    while char.PrimaryPart == nil do
        RunService.Stepped:Wait()
    end
    root = char.HumanoidRootPart
    cf_of_hrp = char:GetPrimaryPartCFrame()
end)

-- caching function
local caching_result = {}
local ticks = {}
function caching_getchild(path)
    if not ticks[path] then
        ticks[path] = tick() - 10
    end
    if tick() - ticks[path] > 1/60 then
        ticks[path] = tick()
        caching_result[path] = path:GetChildren()
    end
    return caching_result[path]
end
-- Function

local function AFK()
    if env.Anti_AFK then
        env.Anti_AFK:Disconnect()
    end
    env.Anti_AFK = player.Idled:connect(function()
    	env.Anti_AFK:CaptureController()
    	env.Anti_AFK:ClickButton2(Vector2.new())
    end)
end

local function Get_Board(faction)
    for _,board in ipairs(caching_getchild(workspace.MissionBoards[faction])) do
        if board:IsA("Model") then
            local Holder = board:FindFirstChild("Holder")
            if Holder then
                for i,v in ipairs(caching_getchild(Holder)) do
                    if v:IsA("Part") then
                        local SurfaceGui = v:FindFirstChild("SurfaceGui")
                        local cd = v:FindFirstChild("ClickDetector")
                        if SurfaceGui then
                            local Rating = SurfaceGui:FindFirstChild("Rating")
                            if Rating and table.find(env.Values, Rating.Text) then
                                fireclickdetector(cd)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function Get_Quest()
    local race = char:FindFirstChild("Race")
    if race then
        if race.Value == "Human" then
            Get_Board('CCG')
        else
            Get_Board('Ghoul')
        end
    end
end

local function Auto_Loot()
    pcall(function()
        local bag = playergui:FindFirstChild("BagGui")
        if bag then
            local frame = bag:FindFirstChild("Frame")
            if frame then
                local ItemsFrame = frame:FindFirstChild('ItemsFrame')
                if ItemsFrame then
                    for i,v in ipairs(ItemsFrame:GetChildren()) do
                        if v:IsA("TextButton") then
                            GuiService.SelectedCoreObject = v
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            task.wait()
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            task.wait()
                        end
                    end
                end
            end
        end
    end)
end

local function Get_Loot()
    for i,v in ipairs(caching_getchild(workspace)) do
        if v:IsA("Model") and v.Name:find("giftbox_blend") then
            local box = v.PrimaryPart
            if root and box then
                local mag = (root.Position - box.Position).magnitude
                if mag < 10 then
                    local cd = v:FindFirstChild("ClickDetector")
                    if cd then
                        fireclickdetector(cd)
                    end
                end
            end
        end
    end
end
local has_sethiddenproperty = false
if sethiddenproperty then
    if type(sethiddenproperty) == "function" then
        has_sethiddenproperty = true
    end
end

local has_gethiddenproperty = false
if gethiddenproperty then
    if type(gethiddenproperty) == "function" then
        has_gethiddenproperty = true
    end
end

local function Instant()
    for i,v in ipairs(caching_getchild(workspace.Entities)) do
        if v:IsA("Model") and v.Name ~= char.Name then
            local target = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChild("Humanoid")
            local ExpG = v:FindFirstChild("ExpGain")
            if target and root and hum and ExpG then
                local mag = (target.Position - root.Position).magnitude
                if mag < 100 and hum.Health > 0 then
                    local percentage = ((hum.Health / hum.MaxHealth) * 100)
                    if percentage < env.Health_Below and isnetworkowner(target) then
                        hum.Health = -math.huge
                    end
                end
            end
        end
    end
end

local function Bring_Mob()
    for i,v in ipairs(caching_getchild(workspace.Entities)) do
        if v:IsA("Model") and v.Name ~= char.Name then
            local target = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChild("Humanoid")
            if target and root and hum then
                local mag = (target.Position - root.Position).magnitude
                if mag < 100 and hum.Health > 0 then
                    if isnetworkowner(target) then
                        target.CFrame = root.CFrame * CFrame.new(0,10,0)
                    end
                end
            end
        end
    end
end

local function webhooks()
    local OSTime = os.time();
    local Time = os.date('!*t', OSTime);
    local Avatar = 'https://cdn.discordapp.com/embed/avatars/4.png';
    local Content = '';
    local Embed = {
        title = game.JobId;
        color = '99999';
        footer = { text = game };
        author = {
            name = 'ROBLOX';
            url = 'https://www.roblox.com/';
        };
        fields = {
            {
                name = game.Players.LocalPlayer.Name;
                value = '';
            }
        };
        timestamp = string.format('%d-%d-%dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec);
    };
    (syn and syn.request or http_request) {
        Url = env.Webhook;
        Method = 'POST';
        Headers = {
            ['Content-Type'] = 'application/json';
        };
        Body = game:GetService'HttpService':JSONEncode( { content = Content; embeds = { Embed } } );
    };
end


local function Store_Item()
    local bank = playergui:FindFirstChild("BankInterface")
    if bank and bank:FindFirstChild("Overlay") then
        local overlay = bank.Overlay
        -- Remove existing button if it exists
        local existingButton = overlay:FindFirstChild("Store Item")
        if existingButton then return end
        -- Create new button
        local button = Instance.new('TextButton')
        button.Name = "Store Item"
        button.Text = 'Store Item'
        button.TextSize = 30
        button.Size = UDim2.new(.24, 0, .15, 0)
        button.Position = UDim2.new(.4, 0, .55, 0)
        button.Font = Enum.Font.SourceSansBold
        button.Parent = overlay
    
        -- Connect the click event
        button.MouseButton1Click:Connect(function()
            for i,v in ipairs(char:GetChildren()) do
                if v:IsA("Tool") then
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PutInBank"):FireServer(tostring(v))
                end
            end
        end)
    else
        warn("Hold Item")
    end
end

local function moveCharacterBySteps(targetCFrame, stepDistance)
    local plr = game.Players.LocalPlayer
    local chr = plr.Character or plr.CharacterAdded:Wait()
    local root = chr and chr:FindFirstChild("HumanoidRootPart")
    
    if not root then
        warn("HumanoidRootPart not found.")
        return
    end
    
    local currentCFrame = root.CFrame
    local direction = (targetCFrame.Position - currentCFrame.Position).unit
    local targetPosition = targetCFrame.Position
    
    while (currentCFrame.Position - targetPosition).Magnitude > stepDistance do
        currentCFrame = currentCFrame + direction * stepDistance
        root.CFrame = currentCFrame  -- Move the player smoothly
        root.Velocity = Vector3.zero
        task.wait()  -- Adjust for speed control
    end
    
    root.CFrame = targetCFrame  -- Ensure exact final position
end


local function Goto_Mission()
    local icon = nil
    local lp = game.Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if char and hrp then
        for i,v in ipairs(char:GetChildren()) do
            if v:IsA("Part") and v.Name == "MissionIcon" then
                moveCharacterBySteps(CFrame.new(v.Position.X,10,v.Position.Z), _G.SpeedQuest)
                hrp.Anchored = true
                wait(2)
                hrp.Anchored = false
            end
        end
    end
end

local function Find_Region()
    local plr = game:GetService("Players").LocalPlayer
    local playergui = plr:FindFirstChild("PlayerGui")
    if playergui then
        local ServerListUI = playergui:FindFirstChild("ServerListUI")
        if ServerListUI then
            local Container = ServerListUI:FindFirstChild("Container")
            if Container then
                local Cosmetic = Container:FindFirstChild("CosmeticInterface")
                if Cosmetic then
                    local SF = Cosmetic:FindFirstChild("ScrollingFrame")
                    if SF then
                        for i, v in ipairs(SF:GetChildren()) do
                            if v:IsA("TextButton") then
                                local Region = v:FindFirstChild("Region")
                                if Region and string.match(Region.Text, "Singapore, North West") then
                                    v.Visible = true
                                else
                                    v.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function Find_Region_Off()
    local plr = game:GetService("Players").LocalPlayer
    local playergui = plr:FindFirstChild("PlayerGui")
    if playergui then
        local ServerListUI = playergui:FindFirstChild("ServerListUI")
        if ServerListUI then
            local Container = ServerListUI:FindFirstChild("Container")
            if Container then
                local Cosmetic = Container:FindFirstChild("CosmeticInterface")
                if Cosmetic then
                    local SF = Cosmetic:FindFirstChild("ScrollingFrame")
                    if SF then
                        for i, v in ipairs(SF:GetChildren()) do
                            if v:IsA("TextButton") then
                                v.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end
end

local function Find_Permadeath()
    local plr = game:GetService("Players").LocalPlayer
    local playergui = plr:FindFirstChild("PlayerGui")
    if playergui then
        local ServerListUI = playergui:FindFirstChild("ServerListUI")
        if ServerListUI then
            local Container = ServerListUI:FindFirstChild("Container")
            if Container then
                local Cosmetic = Container:FindFirstChild("CosmeticInterface")
                if Cosmetic then
                    local SF = Cosmetic:FindFirstChild("ScrollingFrame")
                    if SF then
                        for i, v in ipairs(SF:GetChildren()) do
                            if v:IsA("TextButton") then
                                local ServerName = v:FindFirstChild("ServerName")
                                if ServerName and not string.match(ServerName.Text, "PERMADEATH") then
                                    v.Visible = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


local function Talk()
local args = {
    [1] = {
        [1] = {
            ["Message"] = "Oh, you have come Light. What are you here for?",
            ["Choice"] = "I seek a new start.",
            ["Name"] = "???",
            ["Choices"] = {
                [1] = "I seek a new start.",
                [2] = "I should go.",
                [3] = "I want to go back."
            },
            ["Properties"] = {
                ["RegularDelay"] = 0.02,
                ["DotDelay"] = 0,
                ["Name"] = "?",
                ["Sound"] = "rbxassetid://6929790120"
            },
            ["Part"] = 1,
            ["NPCName"] = ""
        },
        [2] = "\3"
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))

local args = {
    [1] = {
        [1] = {
            ["Message"] = "Do you seek a new beginning, or perhaps do you seek something else?",
            ["Choice"] = "Im ready for a new beginning.",
            ["Name"] = "???",
            ["Choices"] = {
                [1] = "Im ready for a new beginning.",
                [2] = "I'm not too sure."
            },
            ["Properties"] = {
                ["RegularDelay"] = 0.02,
                ["DotDelay"] = 0,
                ["Name"] = "?",
                ["Sound"] = "rbxassetid://6929790120"
            },
            ["Part"] = 2,
            ["NPCName"] = ""
        },
        [2] = "\3"
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))

local args = {
    [1] = {
        [1] = {
            ["Message"] = "Very well... But know this: once your past is erased, theres no going back.",
            ["Choice"] = "I accept my fate.",
            ["Name"] = "???",
            ["Choices"] = {
                [1] = "I accept my fate.",
                [2] = "Wait, Im not sure."
            },
            ["Properties"] = {
                ["RegularDelay"] = 0.02,
                ["DotDelay"] = 0,
                ["Name"] = "?",
                ["Sound"] = "rbxassetid://6929790120"
            },
            ["Part"] = 3,
            ["NPCName"] = ""
        },
        [2] = "\3"
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
end

local function Get_Dialogue(Text)
    local plr = game:GetService("Players").LocalPlayer
    if plr then
        local pgui =plr:FindFirstChild("PlayerGui")
        if pgui then
            local Dialogue = pgui:FindFirstChild('Dialogue')
            if Dialogue then
                local MF = Dialogue:FindFirstChild('MainFrame')
                if MF then
                    local Options = MF:FindFirstChild('Options')
                    if Options then
                        for i,v in ipairs(Options:GetChildren()) do
                            if v:IsA('TextButton') then
                                local Option = v:FindFirstChild('Option')
                                if Option then
                                    if Option.Text == Text then
                                        GuiService.SelectedCoreObject = Option
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function Create(Gender,Race,Name)
    local plr = game:GetService("Players").LocalPlayer
    if plr then
        local PlayerGui = plr:FindFirstChild('PlayerGui')
        if PlayerGui then
            local CUSTOMIZE = PlayerGui:FindFirstChild('CUSTOMIZE')
            if CUSTOMIZE then
                local RemoteEvent = CUSTOMIZE:FindFirstChild('RemoteEvent')
                if RemoteEvent then
                    RemoteEvent:FireServer(Gender,Race,Name)
                end
            end
        end
    end
end

local function Talk_NPC(NPC_Name)
    local root_npc, proximity = nil,nil
    for i,v in ipairs(workspace.Dialogues:GetChildren()) do
        if v:IsA("Model") then
            if v.Name == NPC_Name then
                local target = v:FindFirstChild("HumanoidRootPart")
                if target then
                    local Detector = target:FindFirstChild("Detector")
                    if Detector then
                        root_npc = target
                        proximity = Detector
                    end
                end
            end
        end
    end
    return root_npc,proximity
end

local function Get_Live()
    return GetLives:InvokeServer()
end

local function Get_Clan()
    local plr = game:GetService("Players").LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not char then return end
    if not root then return end
    if not hum then return end
    for i,v in ipairs(plr.Character:GetChildren()) do
        if v:IsA('StringValue') then
            if v.Name == "Clan" then
                if table.find(env.wl_Clan, v.Value) then
                    print('We got it', v.Value)
                    wait(1)
                elseif v.Value == "None" then
                    Create('Male','Ghoul','Light')
                    wait(.45)
                else
                    if Get_Live() == 3 then
                        hum.Health = 0
                    else
                        local npc, prompt = Talk_NPC('???')
                        if npc and root then
                            root.CFrame = npc.CFrame
                            fireproximityprompt(prompt)
                        else
                            root.CFrame = CFrame.new(15281, 9, 2)
                        end
                        Get_Dialogue('I seek a new start.')
                        Talk()
                    end
                end
            end
        end
    end
end

-- UI

AFK()

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Syn0xz Hub ",
    SubTitle = "by Chaiwat",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.J -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Character = Window:AddTab({ Title = "Character", Icon = "user" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "sun" }),
    Roll_Clan = Window:AddTab({ Title = "Roll Clan", Icon = "plane" }),
    Server = Window:AddTab({ Title = "Server", Icon = "server" }),
    QoL = Window:AddTab({ Title = "Quality Of Life", Icon = "briefcase" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
--Ruby Module Loader DONT TOUCH IT
local ModuleLoader = loadstring(game:HttpGet("https://github.com/plytalent/Roblox-Hacks/raw/refs/heads/main/Modules/Module_Loader.lua"))
local Loaded_Module = {}
function Load_Module(name,kwargs,args)
	local _args = args or {Tabs.Main,Tabs.Keybinds}
    local _kwargs = kwargs or {fluent = fluent}
	local SubModule = ModuleLoader(Fluent, name)
	if type(SubModule) == "table" then
		local Args = {}
		for _,v in pairs(SubModule.require_variables) do
			if v == "Fluent" then
				Args[v] = Fluent
			elseif v == "Window" then
				Args[v] = Window
			elseif v == "Tabs" then
				Args[v] = Tabs
			end
		end
		local _s, e = pcall(SubModule[SubModule.Main_Function_Name], Args)
		if _s then
			Fluent:Notify({
				Title = "MainModule",
				Content = "Loaded "..name.." Submodule",
				Duration = 8
			})
		else
			print(e)
			Fluent:Notify({
				Title = name.." Module",
				Content = "Internal Error",
				Duration = 8
			})
		end
	else
		local _s, e = pcall(SubModule,{Fluent = Fluent},unpack(_args))
		if _s then
			Fluent:Notify({
				Title = "MainModule",
				Content = "Loaded "..name.." Submodule",
				Duration = 8
			})
		else
			print(e)
			Fluent:Notify({
				Title = name.." Module",
				Content = "Internal Error",
				Duration = 8
			})
		end
	end
end
do
    local Auto_Quest = Tabs.Main:AddToggle("Auto_Quest", {Title = "Auto Quest", Default = false })

    Auto_Quest:OnChanged(function()
        env.Auto_Quest = Options.Auto_Quest.Value
        while env.Auto_Quest do task.wait(.1)
            Get_Quest()
        end
    end)

    local Difficult_Diff = Tabs.Main:AddDropdown("MultiDropdown", {
        Title = "Difficult",
        Description = "Select the difficult.",
        Values = {"Hard","Medium","Easy"},
        Multi = true,
        Default = {"Hard"},
    })

    Difficult_Diff:OnChanged(function(Value)
        env.Values = {}
        for Value, State in next, Value do
            table.insert(env.Values, Value)
        end
    end)

    local To_Mission = Tabs.Main:AddToggle("To_Mission", {Title = "Auto To Quest", Default = false })

    To_Mission:OnChanged(function()
        env.To_Mission = Options.To_Mission.Value
        while env.To_Mission do task.wait(.1)
            Goto_Mission()
            wait(1.75)
        end
    end)

    local Speed_Quest = Tabs.Main:AddSlider("Speed_Quest", {
        Title = "Speed to Mission",
        Description = "decrease it when lag",
        Default = 3,
        Min = 1,
        Max = 4,
        Rounding = 0,
        Callback = function(Value)
            _G.SpeedQuest = Value
        end
    })

    Tabs.Character:AddButton({
        Title = "Reset Character",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Reset Character",
                Content = "Are u sure (not pd server)",
                Buttons = {
                    {
                        Title = "Reset Character",
                        Callback = function()
                            char.Humanoid.Health = 0
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print('Cancel Reset Character')
                        end
                    }
                }
            })
        end
    })

    local Noclip_Func = Tabs.Character:AddToggle("Noclip_Func", {
        Title = "Noclip",
        Default = false
    })

    Noclip_Func:OnChanged(function()
        env.Noclip = Options.Noclip_Func.Value
    end)

    local Tab_Auto_Roll_Clan = Tabs.Roll_Clan:AddToggle("Tab_Auto_Roll_Clan", {
        Title = "Auto Roll Clan Work on PD Only",
        Default = false
    })

    Tab_Auto_Roll_Clan:OnChanged(function()
        env.Clan_Roll = Options.Tab_Auto_Roll_Clan.Value
        print(env.Clan_Roll)
        while env.Clan_Roll do task.wait(.125)
            Get_Clan()
        end
    end)

    local WL_ROLL_CLAN = Tabs.Roll_Clan:AddDropdown("WL_ROLL_CLAN", {
        Title = "Whitelist Clan",
        Description = "Select Clans.",
        Values = {"Abara", "Akashi", "Aliza", "Ami", "Arima", "Atou", "Banjou", "Fujimi", "Fueguchi", "Gehner", "Ginshi", "Hachikawa", "Hazuki", "Hirako", "Hoito", "Hogi", "Hooguro", "Hori", "Hsiao", "Iba", "Ichimi", "Ihei", "Jin", "Kaiko", "Kamishiro", "Kaneki", "Kanou", "Kazuichi", "Kirishima", "Kobayashi", "Koma", "Koutarou", "Kureha", "Kureo", "Kuroiwa", "Kusaba", "Mado", "Ōmaeda", "Mikage", "Minami", "Mitsuki", "Momochi", "Mutsuki", "Nagachika", "Naki", "Nakajima", "Nishio", "Porpora", "Sasada", "Sasaki", "Sato", "Shimoguchi", "Shikorae", "Shiono", "Shirazu", "Suzuya", "Tagata", "Tainaka", "Takizawa", "Takeomi", "Tokage", "Toga", "Torso", "Tsuneyoshi", "Uruka", "Urie", "Von Rosewald", "Yamada", "Yoshimura", "Yukimichi"},
        Multi = true,
        Default = {'Kaneki','Yoshimura','Suzuya','Arima'},
    })

    WL_ROLL_CLAN:OnChanged(function(Value)
        env.wl_Clan = {}
        for Value, State in next, Value do
            table.insert(env.wl_Clan, Value)
        end
    end)

    local Instant_Kill = Tabs.Misc:AddToggle("Instant_Kill", {
        Title = "Auto Instant",
        Default = false
    })

    Instant_Kill:OnChanged(function()
        env.Instant = Options.Instant_Kill.Value
        print(env.Instant)
        while env.Instant do task.wait(.1)
            Instant()
        end
    end)

    local Slider = Tabs.Misc:AddSlider("Slider", {
        Title = "HP Below",
        Description = "Set hp mob below",
        Default = 95,
        Min = 0,
        Max = 101,
        Rounding = 0,
        Callback = function(Value)
            env.Health_Below = Value
        end
    })

    local Get_Loot_Tab = Tabs.Misc:AddToggle("Get_Loot_Tab", {Title = "Auto Get Loot", Default = false })

    Get_Loot_Tab:OnChanged(function()
        env.Get_Loot = Options.Get_Loot_Tab.Value
        while env.Get_Loot do task.wait(.1)
            Get_Loot()
        end
    end)

    local Auto_Loot_Tab = Tabs.Misc:AddToggle("Auto_Loot_Tab", {Title = "Auto Loot", Default = false })

    Auto_Loot_Tab:OnChanged(function()
        env.Auto_Loot = Options.Auto_Loot_Tab.Value
        while env.Auto_Loot do task.wait(.1)
            Auto_Loot()
        end
    end)

    local Auto_Bring = Tabs.Misc:AddToggle("Auto_Bring", {Title = "Auto Bring Mob", Default = false })

    Auto_Bring:OnChanged(function()
        env.Bring_Mob = Options.Auto_Bring.Value
        while env.Bring_Mob do task.wait()
            Bring_Mob()
        end
    end)

    Tabs.Server:AddParagraph({
        Title = "Find Server Region",
        Content = "Select ur Region"
    })
    
    local Auto_Find_Server = Tabs.Server:AddToggle("Auto_Find_Server", {Title = "Find Region [Singapore]", Default = false })

    Auto_Find_Server:OnChanged(function()
        env.Find_Server = Options.Auto_Find_Server.Value
        if env.Find_Server then
            Find_Region()
        else
            Find_Region_Off()
        end
    end)

    local Find_PD = Tabs.Server:AddToggle("Find_PD", {Title = "Find Permadeath", Default = false })

    Find_PD:OnChanged(function()
        env.Find_PD_Server = Options.Find_PD.Value
        if env.Find_PD_Server then
            Find_Permadeath()
        else
            Find_Region_Off()
        end
    end)

    Tabs.Server:AddParagraph({
        Title = "Join Server Function",
        Content = "Press Copy and Join"
    })
    
    Tabs.Server:AddButton({
        Title = "Copy JobId",
        Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Copy JobId",
                Content = "",
                Buttons = {
                    {
                        Title = "Copy",
                        Callback = function()
                            setclipboard(tostring(game.JobId))
                        end
                    },
                    {
                        Title = "Send to Server",
                        Callback = function()
                            spawn(webhooks)
                        end
                    }
                }
            })
        end
    })
    local Input = Tabs.Server:AddInput("Input", {
        Title = "Join Server",
        Default = "",
        Placeholder = "JobId",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            env.JobId = Value
            if env.JobId == game.JobId then
                Fluent:Notify({
                    Title = "Syn0xz Hub",
                    Content = "Already in Server",
                    SubContent = "", -- Optional
                    Duration = 3 -- Set to nil to make the notification not disappear
                })
            else
                if #env.JobId == 36 then 
                    Fluent:Notify({
                        Title = "Syn0xz Hub",
                        Content = "Joning Server",
                        SubContent = "", -- Optional
                        Duration = 3 -- Set to nil to make the notification not disappear
                    })
                    TS:TeleportToPlaceInstance(game.PlaceId, env.JobId)
                end
            end
        end
    })

    local QoL = Tabs.QoL:AddToggle("QoL", {
        Title = "QoL Enabled",
        Default = false
    })

    QoL:OnChanged(function()
        env.QoL = Options.QoL.Value
        print('Quality of life toggle : ',env.QoL)
    end)

    local Inventory = Tabs.QoL:AddKeybind("InventoryKeybind", {
        Title = "Inventory",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "Tab", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

        -- Occurs when the keybind is clicked, Value is `true`/`false`
        -- Callback = function(Value)
        --     print(env.QoL)
        --     local vim = game:GetService('VirtualInputManager')
        --     if env.QoL then
        --         vim:SendKeyEvent(true, Enum.KeyCode.Backquote, false, game)
        --         wait()
        --         vim:SendKeyEvent(false, Enum.KeyCode.Backquote, false, game)
        --     end
        -- end
    })
    Inventory:OnChanged(function(newKey)
        if typeof(newKey) == "EnumItem" then
            newKey = newKey.Name
        end
        env.InventoryKeybind = newKey:lower()
    end)
    local Bank = Tabs.QoL:AddToggle("Bank", {Title = "Bank", Default = false })

    Bank:OnChanged(function()
        env.Bank = Options.Bank.Value
        Store_Item()
        while env.Bank do task.wait()
            local BankInterface = playergui:FindFirstChild("BankInterface")
            if BankInterface then
                local Overlay = BankInterface:FindFirstChild("Overlay")
                if Overlay then
                    if env.Bank then
                        Overlay.Visible = true
                    else
                        Overlay.Visible = false
                    end
                end
            end
        end
    end)
    if env.Event_UIS_Ended then
        env.Event_UIS_Ended:Disconnect()
    end
    env.Event_UIS_Ended = UIS.InputEnded:Connect(function(input,gameProcessed)
        if k == env.InventoryKeybind and env.QoL then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Backquote, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Backquote, false, game)
        end
    end)
end
Load_Module("Movement",{Tabs.Character,Tabs.Character})

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("Fluent_Syn0xzHub")
SaveManager:SetFolder("Fluent_Syn0xzHub/Ghoul_RE")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Syn0xz Hub",
    Content = "The script has been loaded.",
    Duration = 5
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
