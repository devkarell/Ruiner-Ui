--[=[

	== Hello there! This 'Handler' LocalScript is the unique & main script that's used for run the Ruiner V0.4 :D ==
	
	== Basic description:
	" A Ui/Ux project named Ruiner, with a special design and modern colors.
	A dynamic background with real-time 3D Preview of your character & insane features for an Action Game "

	== Advanced description:
	" A modern Ui with nice red tones, should be used as the main Menu of your game. Called 'Ruiner',
	this project was officially launched in 12/31/2023 taking approximately 9 days of work to put together
	its main style and another 2 days programming and creating life for it "
	
	All of this code is my property, all of this project is my property including the Place, Models, Scripts & Ui's.
	Ruiner Ui V0.4 made & in-devlopment by Karell Lukmeier (@kareu_uu)
	
	RUINER REPO: github.com/kareu-uu/Ruiner-Ui
	PORTFOLIO: kareu-uu.carrd.co
	RELEASES: kareu-uu-releases.carrd.co
	
	Document created in 1/8/2024 at 5:38PM (UTC-3, Brazil)
	
]=]

-- 'RUINER_CONFIG' contains all of usefull & global variables to make Ruiner run better
local RUINER_CONFIG = {
	RUINER_VERSION = 0.4,
	RUINER_STARTER_VISUAL_SELECTION = "NewGame", -- the section that's is automatically selected after Ruiner's system starts
	RUINER_INACCESSIBLE_BUTTONS = {"Continue"}, -- sections that are no available in this time
	RUINER_SECTIONS_ORDER = {"NewGame", "Continue", "SelectLevel", "GameModes", "Settings"} -- just used for check-ups and get the index from especified section name
}

-- = >> > >< ><> >>>> SERVICES = >> > >< ><> >>>>
local Player = game:GetService("Players").LocalPlayer
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
-- = >> > >< ><> >>>>

-- = >> > >< ><> >>>> GLOBAL UI'S VARIABLES = >> > >< ><> >>>>
local Elements = script.Parent:WaitForChild("Ui"):WaitForChild("Elements") :: CanvasGroup
local Sections = Elements:WaitForChild("Sections") :: Folder
local Preview = script.Parent:WaitForChild("Ui"):WaitForChild("Player") :: ViewportFrame
local EnterOnRuinerPrompt = workspace.Light.Light.ProximityPrompt :: ProximityPrompt
-- = >> > >< ><> >>>>

--[[
		============= Welcome to 1st section: "Selector" =============
		
		In Selector's table, i put some functions and values that's used for the best and main functionality of the Ruiner's main
		menu: Hovering on buttons (Sections)
		
		The Selector's codes just manage all of the basic "moving" from the ui
]]
local Selector = {}
Selector.CurrentSectionName = "NewGame" -- current detected section name that's selected from user (by Keyboard or Mouse)
Selector.CurrentSectionID = 1 -- current detected section ID (always linked with current section name)
Selector.SectionsAmount = #Sections:GetChildren() -- amount of sections in the main menu

-- Completely usefull to get the next section that be selected/hovered, this function calculate the ID and the Next ID from the Current Section
-- 'idx' is 'index', a reference for the ID of the section that's be hovered
function Selector.GetNextSelectedLabel(dir: string): number
	local idx

	if dir:lower() == "down" then
		idx = Selector.CurrentSectionID < Selector.SectionsAmount and Selector.CurrentSectionID + 1 or 1

	elseif dir:lower() == "up" then
		idx = Selector.CurrentSectionID > 1 and Selector.CurrentSectionID - 1 or Selector.SectionsAmount
	end

	return idx
end

--[[

	===== UnHoverLabel =====
	Used mainly for visual, this function does not affect the global functionalityes from the system
	Because that, just the Background from the Current section (TextLabel) is modified (makin a Hover effect)
	
	Used to remove the Hover Effect.
]]
function Selector.UnHoverLabel()
	local LastSection = Sections:FindFirstChild(Selector.CurrentSectionName) :: TextLabel
	
	if table.find(RUINER_CONFIG.RUINER_INACCESSIBLE_BUTTONS, LastSection.Name) then
		return
	end

	LastSection.BackgroundTransparency = 1
	LastSection:FindFirstChild("Title").TextColor3 = Color3.fromRGB(239, 26, 58)
end

--[[

	===== HoverLabel =====
	Used mainly for visual, this function does not affect the global functionalityes from the system
	Because that, just the Background from the Current section (TextLabel) is modified (makin a Hover effect)
	
	Used to add the Hover Effect.
]]
function Selector.HoverLabel()
	local NewSection = Sections:FindFirstChild(Selector.CurrentSectionName) :: TextLabel
	NewSection.BackgroundTransparency = 0
	NewSection:FindFirstChild("Title").TextColor3 = Color3.fromRGB(0,0,0)
end

--[[

	===== SwitchSelection =====
	This the main function from Selector's section, your purpose is manually/automatically sets and update the
	values of CurrentSectionName, CurrentSectionID...
	
	Used to update the system values, making the best functionality of the ui. This function is connected with BindAction's events from
	the ContextActionService
	
	Direction: string -> 'down' / 'up' -  indicates what's the direction from the keyboard arrow's are pressed
	HoldingState: InputObject/State - indicates the state of the pressing keyboard arrow ("End" state is preffered)
]]
function Selector.SwitchSelection(Direction: string, HoldingState)
	if HoldingState and HoldingState ~= Enum.UserInputState.End then return end
	
	-- get next section to be selected in the visual ui
	local NEW_SECTION_ID = Selector.GetNextSelectedLabel(Direction)
	
	-- get the label instance referenced by your ID in RUINER_CONFIG
	local NEW_SECTION_LABEL = Sections:FindFirstChild(RUINER_CONFIG.RUINER_SECTIONS_ORDER[NEW_SECTION_ID]) :: TextLabel
	
	-- unhover last hovered section in the ui
	Selector.UnHoverLabel()
	
	-- if the next section to be hovered is a unavailable section, the system re-call this function to re-calculate the next section
	if table.find(RUINER_CONFIG.RUINER_INACCESSIBLE_BUTTONS, NEW_SECTION_LABEL.Name) then 
		Selector.CurrentSectionID = NEW_SECTION_ID
		Selector.CurrentSectionName = NEW_SECTION_LABEL.Name
		
		return Selector.SwitchSelection(Direction)
	end
	
	-- update all of important e global values to the next thread execute fast & precise.
	Selector.CurrentSectionID = NEW_SECTION_ID
	Selector.CurrentSectionName = NEW_SECTION_LABEL.Name
	Selector.HoverLabel()
end

--[[
		============= Welcome to section: "Model" =============
		
		In Model's section, i put some functions and values that's used for the 3D preview in
		the background of the ui
		
		The Model's codes just manage the model from the Local Character
]]
local Player3DPreview_Model = {}
Player3DPreview_Model.Template = nil :: Model -- soon this value is setted to the player's character model, but some properties is setted to make it better for 3D preview

--[[

	===== GetModel =====
	This function just return the Player3DPreview_Model.Template -> Model for the code, this model have already setted up properties and is ready for use
]]
function Player3DPreview_Model.GetModel(): Model
	
	-- if currently does't exit a template available, wait some seconds for it, else, cancel the execution (in this case no 3D preview are available)
	if not Player3DPreview_Model.Template then
		local RemainingTimeReachingTemplate = tick()

		while not Player3DPreview_Model.Template do
			if tick() - RemainingTimeReachingTemplate > 2 then break end
			task.wait()
		end

		if not Player3DPreview_Model.Template then return end
	end
	
	-- return a clone of the configured template
	local NewPlayerModelPreview = Player3DPreview_Model.Template:Clone()
	return NewPlayerModelPreview
end

--[[

	===== SetupModel =====
	This function load the local player character, give a clone of it and configure for the best use
]]
function Player3DPreview_Model.SetupModel()
	
	-- wait for char
	local ElapsedTimeReachingForChar = tick()

	while not Player3DPreview_Model.Template do
		if tick() - ElapsedTimeReachingForChar > 2 then break end
		Player3DPreview_Model.Template = Player.Character
		task.wait()
	end

	if not Player3DPreview_Model.Template then return end
	
	-- configure
	Player.Character.Archivable = true
	Player3DPreview_Model.Template = Player.Character:Clone()
	Player3DPreview_Model.Template.PrimaryPart.Anchored = true
	Player3DPreview_Model.Template.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

--[[
		============= Welcome to section: "Preview" =============
		
		In Previews's section, i put some functions and values that's used for the 3D preview in
		the background of the ui
		
		The Preview's codes just manage the ViewportFrame from the ui, making the 3D feature functional and managing it
]]
local Player3DPreview_Preview = {}

--[[

	===== SetPlayerPreview =====
	This function load the model on the Viewport preview, setup the Camera and not make it visible in this moment because other function make it visible on future.. 
]]
function Player3DPreview_Preview.SetPlayerPreview(Model: Model): ViewportFrame
	if not Model or typeof(Model) ~= "Instance" or Model.ClassName ~= "Model" then return end

	local PreviewCamera = Preview:FindFirstChildWhichIsA("Camera") :: Camera? do
		if PreviewCamera then
			PreviewCamera:Destroy()
		end

		PreviewCamera = Instance.new("Camera")
		PreviewCamera.CFrame = CFrame.lookAt(Model.Head.Position + (Model.Head.CFrame.LookVector - Vector3.new(0,0,3)), Model.Head.Position)
		PreviewCamera.Parent = Preview
	end

	local WorldModelPreview = Preview:FindFirstChildWhichIsA("WorldModel") do
		if not WorldModelPreview then
			WorldModelPreview = Instance.new("WorldModel")
			WorldModelPreview.Scale = 1.2
			WorldModelPreview.Parent = Preview
		end
	end

	if WorldModelPreview:FindFirstChildWhichIsA("Model") then
		WorldModelPreview:FindFirstChildWhichIsA("Model"):Destroy()
	end

	Preview.CurrentCamera = PreviewCamera
	Model.Parent = WorldModelPreview

	return Preview
end

--[[
		============= Welcome to section: "Player3DPreview" =============
		
		In Player3DPreview's section, there are some functionalities that's make the 3D preview feature run with stability and animations
		
		The Player3DPreview's codes just manage the ViewportFrame from the ui, making the 3D feature functional and managing it
]]
local Player3DPreview = {}
Player3DPreview.JumpingThread = nil :: RBXScriptConnection

-- this function deactive all of the CoreScripts Ui's, remove the Jumping from player, remove the Camera moving and walking from character making the total focus on the Menu
function Player3DPreview.Prepare3DPreview()
	local Human = Player.Character:FindFirstChildWhichIsA("Humanoid")
	if Human then
		Human.WalkSpeed = 0
	end
	
	-- if no there a JumpingThread, create them, this is used for deactvate the jump.
	if not Player3DPreview.JumpingThread then
		Player3DPreview.JumpingThread = UserInputService.JumpRequest:Connect(function()
			Human:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end)
	end
	
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	
	-- this is a while loop that's have the functionality to disable the Reset Button. A loop with pcall is very usefull for "SetCore" functions, bacause
	-- for a game loading, the script certainement will be disable the reset button
	local ResetButtonCallbackSettedUp: boolean do
		local RemainingTimeToSetUpResetButtonCallback = tick()

		while not ResetButtonCallbackSettedUp do
			if tick() - RemainingTimeToSetUpResetButtonCallback > 2 then break end

			ResetButtonCallbackSettedUp = pcall(function()
				return StarterGui:SetCore("ResetButtonCallback", false)
			end)
			
			if ResetButtonCallbackSettedUp then break end
			task.wait(.2)
		end
	end
end

--[[
	This function load all of the 3d preview
]]
function Player3DPreview.SetupActive3DPreview()
	local PreviewCharacter = Player3DPreview_Model.GetModel() :: Model
	local PreviewFrame = Player3DPreview_Preview.SetPlayerPreview(PreviewCharacter) :: ViewportFrame

	--Player3DPreview.Prepare3DPreview()
end

--== == == == ======= BINDS & LOADER FUNCTIONS HERE: == == == == =======--
Selector.HoverLabel()
Player3DPreview_Model.SetupModel()
Player3DPreview.SetupActive3DPreview()
ContextActionService:BindAction("Down", Selector.SwitchSelection, false, Enum.KeyCode.Down)
ContextActionService:BindAction("Up", Selector.SwitchSelection, false, Enum.KeyCode.Up)

--== == == == ======= HOVERING EVENTS FOR SECTIONS HERE: == == == == =======--
for _, SectionLabel: TextLabel in Sections:GetChildren() do
	if SectionLabel.ClassName ~= "TextLabel" then continue end
	if table.find(RUINER_CONFIG.RUINER_INACCESSIBLE_BUTTONS, SectionLabel.Name) then continue end
	
	SectionLabel:WaitForChild("Title").MouseEnter:Connect(function()
		Selector.UnHoverLabel()
		
		Selector.CurrentSectionName = SectionLabel.Name
		Selector.CurrentSectionID = table.find(RUINER_CONFIG.RUINER_SECTIONS_ORDER, SectionLabel.Name)
		
		Selector.HoverLabel()
	end)
	
	task.wait()
end

--== == == == ======= PROXIMITY PROMPT DETECTIONS &	ANIMS ON ENTER HERE: == == == == =======--
EnterOnRuinerPrompt.Triggered:Connect(function()
	EnterOnRuinerPrompt.Enabled = false
	
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	
	Player3DPreview.Prepare3DPreview()
	
	local Background = script.Parent:WaitForChild("Ui"):WaitForChild("Background") :: Frame
	Background.BackgroundColor3 = Color3.fromRGB(0,0,0)
	
	local GradientTween = TweenService:Create(Background,
		TweenInfo.new(.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{BackgroundColor3 = Color3.fromRGB(255,255,255)}
	)
	
	script.Parent.Enabled = true
	GradientTween:Play()
end)