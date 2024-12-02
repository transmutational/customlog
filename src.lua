return (function()
	local function getGlobalEnvironment()
		if getgenv then
			return getgenv()
		end
		return getfenv()
	end

	local genv = getGlobalEnvironment()

	if genv.customLog ~= nil then
		return genv.customLog
	end

	local coreUI = game:GetService("CoreGui")
	local httpService = game:GetService("HttpService")
	local devConsole = nil
	local devContainer = nil

	local pastConnections = {} -- [RBXScriptConnection, ...]
	local sentMessages = {} -- {[guid(false)]: [icon, time, text, color]}

	-- adds a message to the log table for later use in searching
	local function _internalAddMessage(icon, time, message, color)
		local searchGUID = httpService:GenerateGUID(false)
		warn(searchGUID)
		sentMessages[searchGUID] = {icon = icon, time = time, message = message, color = color}
	end

	-- pads a number with a zero if it is less than 10 so numbers are always 2 digits
	local function _internalPadZero(num)
		return (num < 10 and "0" or "") .. num
	end

	-- converts a timestamp to a string in the format of HH:MM:SS
	local function _internalConvertTime(timeStamp)
		local localTime = math.floor(timeStamp - os.time() + tick())
		local dayTime = localTime % 86400
	
		local hour = math.floor(dayTime / 3600)
	
		dayTime = dayTime - (hour * 3600)
		local minute = math.floor(dayTime / 60)
	
		dayTime = dayTime - (minute * 60)
	
		local h = _internalPadZero(hour)
		local m = _internalPadZero(minute)
		local s = _internalPadZero(dayTime)
	
		return string.format("%s:%s:%s", h, m, s)
	end

	-- wrapper function for creating custom log methods
	local function _printf(icon, color)
		return function(...)
			local message = table.concat({ ... }, ' ')
			_internalAddMessage(icon, _internalConvertTime(os.time()), message, color)
			return nil
		end
	end

	-- globals & presets for developers to use
	genv.folder = _printf("rbxasset://textures/DeveloperStorybook/Folder.png", Color3.fromRGB(116, 166, 253))
	genv.star = _printf("rbxasset://textures/StudioToolbox/AssetPreview/star_filled.png", Color3.fromRGB(246, 183, 2))
	genv.roblox = _printf("rbxasset://textures/ui/PlayerList/AdminIcon.png", Color3.fromRGB(255, 255, 255))
	genv.badge = _printf("rbxasset://textures/ui/icon_placeowner.png", Color3.fromRGB(255, 151, 2))
	genv.check = _printf("rbxasset://textures/AudioDiscovery/done.png", Color3.fromRGB(69, 218, 68))

	genv.customLog = _printf

	-- unloads the custom log, removing globals, as well as any connections that were made
	-- you shouldn't call this function if you're trying to use the custom log twice,
	-- --because it's better to just keep using the same custom log instance (obviously)
	genv.unloadCustomLog = function()
		for _, connection in pastConnections do
			connection:Disconnect()
		end
		genv.folder = nil
		genv.star = nil
		genv.roblox = nil
		genv.badge = nil
		genv.check = nil
		genv.customLog = nil
		genv.unloadCustomLog = nil
	end

	-- replaces the sample warning message with the custom log message data
	local function applyMessage(descendant)
		for guid, data in pairs(sentMessages) do
			if #(descendant.Text:split(guid)) ~= 1 then
				local logHolder = descendant.Parent
				logHolder.image.Image = data.icon
				logHolder.msg.TextColor3 = data.color
				logHolder.msg.Text = data.time .. " -- " .. data.message
			end
		end
	end

	local function onViewAdded(view)
		local clientLog = view:WaitForChild("ClientLog");
		local function descendantAdded(descendant)
			if descendant:IsA("TextLabel") and descendant.Name == "msg" then
				table.insert(pastConnections, descendant:GetPropertyChangedSignal("Text"):Connect(function()
					applyMessage(descendant)
				end))
				applyMessage(descendant)
			end
		end

		table.insert(pastConnections, clientLog.DescendantAdded:Connect(descendantAdded))

		for _, message in pairs(clientLog:GetDescendants()) do
			descendantAdded(message)
		end
	end

	devConsole = coreUI:WaitForChild("DevConsoleMaster")
	devContainer = devConsole.DevConsoleWindow.DevConsoleUI

	table.insert(pastConnections, devContainer.ChildAdded:Connect(function(child)
		if child.Name == "MainView" then
			onViewAdded(child)
		end
	end))
	if devContainer:FindFirstChild("MainView") ~= nil then
		onViewAdded(devContainer:FindFirstChild("MainView"))
	end

	return genv.customLog
end)();
