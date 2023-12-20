local Settings = {}
Settings.system = {}
Settings.legit_settings = {}

local allLoaded = false

function Settings.GetLegit(Name: string): {setting: any} | string
	if not Name or typeof(Name) ~= "string" then return end

	while not allLoaded do
		task.wait()
	end

	local RemainingTimeReachingToLegit = tick()

	while not Settings.legit_settings[Name] do
		if tick() - RemainingTimeReachingToLegit > 3 then
			break
		end

		task.wait()
	end

	if Settings.legit_settings[Name] then
		return Settings.legit_settings[Name]
	else
		return "system:failure"
	end
end

function Settings.GetClient(Name: string): {setting: any}? | string
	if not Name or typeof(Name) ~= "string" then return end

	if script:FindFirstChild(Name) then
		return require(script[Name])
	else
		return "system:failure"
	end
end

function Settings.Init(LEGITMATE_SETTINGS)
	for SettingType: string, Configs: {any} in LEGITMATE_SETTINGS do
		if typeof(Configs) ~= "table" then continue end

		Settings.legit_settings[SettingType] = Configs
		task.wait()
	end

	allLoaded = true
end

return Settings