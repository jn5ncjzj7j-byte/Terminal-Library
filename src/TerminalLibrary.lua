--[=[
	TerminalLib - Custom TUI Library for Roblox (With Web Image Link Support)
]=]

local TerminalLib = {}
TerminalLib.__index = TerminalLib

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

function TerminalLib.new(titleText)
	local env = (getgenv and getgenv()) or _G
	if env.__TerminalLibInstance and env.__TerminalLibInstance.Destroy then
		pcall(function()
			env.__TerminalLibInstance:Destroy()
		end)
	end

	local self = setmetatable({}, TerminalLib)
	env.__TerminalLibInstance = self

	self.Commands = {}
	self.Connections = {}
	self.OutputLines = {}
	self.LineCounter = 0
	self.MaxLines = 200
	self.History = {}
	self.HistoryIndex = 1
	self.Matches = {}
	self.ImageCache = {}
	self.TempFiles = {}
	self.Destroyed = false

	self.Player = Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self.ProtectedParent = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or CoreGui
	self.IsOpen = true
	self.Title = titleText or ("Misg-Hub @" .. self.Player.Name .. "~")

	self.ToggleKey = Enum.KeyCode.RightControl

	self.ToggleConfig = {
		Text = "Misg Hub",
		Image = nil,
		Size = UDim2.new(0, 110, 0, 45),
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundColor = Color3.fromRGB(30, 30, 30),
		TextColor = Color3.fromRGB(0, 255, 100)
	}

	self:BuildGui()
	self:SetupDefaults()

	return self
end

function TerminalLib:Connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function TerminalLib:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	for _, connection in ipairs(self.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	self.Connections = {}

	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end

	local deleter = delfile or (syn and syn.delfile)
	if deleter then
		for _, fileName in ipairs(self.TempFiles) do
			pcall(deleter, fileName)
		end
	end
	self.TempFiles = {}
	self.ImageCache = {}

	local env = (getgenv and getgenv()) or _G
	if env.__TerminalLibInstance == self then
		env.__TerminalLibInstance = nil
	end
end

function TerminalLib:ResolveImage(imgTarget)
	if type(imgTarget) ~= "string" or not imgTarget:match("^https?://") then
		return imgTarget
	end

	if self.ImageCache[imgTarget] then
		return self.ImageCache[imgTarget]
	end

	local writer = writefile or (syn and syn.writefile)
	local assetGetter = getcustomasset or (syn and syn.getcustomasset)
	if not (writer and assetGetter) then
		return imgTarget
	end

	local resolved = imgTarget
	pcall(function()
		local ok, response = pcall(function()
			return game:HttpGet(imgTarget)
		end)
		if ok and response then
			local fileName = "terminal_img_" .. math.random(10000, 99999) .. ".png"
			writer(fileName, response)
			table.insert(self.TempFiles, fileName)
			resolved = assetGetter(fileName)
		end
	end)

	self.ImageCache[imgTarget] = resolved
	return resolved
end

function TerminalLib:ConfigureToggle(config)
	if not config then return end
	if config.Text ~= nil then self.ToggleConfig.Text = config.Text end
	if config.Image ~= nil then self.ToggleConfig.Image = config.Image end
	if config.Size ~= nil then self.ToggleConfig.Size = config.Size end
	if config.Position ~= nil then self.ToggleConfig.Position = config.Position end
	if config.BackgroundColor ~= nil then self.ToggleConfig.BackgroundColor = config.BackgroundColor end
	if config.TextColor ~= nil then self.ToggleConfig.TextColor = config.TextColor end

	if self.ToggleBtn then
		self.ToggleBtn.Size = self.ToggleConfig.Size
		self.ToggleBtn.Position = self.ToggleConfig.Position
		self.ToggleBtn.BackgroundColor3 = self.ToggleConfig.BackgroundColor
		self.ToggleBtn.TextColor3 = self.ToggleConfig.TextColor

		if self.ToggleConfig.Image ~= "" and self.ToggleConfig.Image ~= nil then
			self.ToggleBtn.Text = ""
			local icon = self.ToggleBtn:FindFirstChild("ToggleIcon") or Instance.new("ImageLabel")
			icon.Name = "ToggleIcon"
			icon.Size = UDim2.new(1, -10, 1, -10)
			icon.Position = UDim2.new(0, 5, 0, 5)
			icon.BackgroundTransparency = 1
			icon.Image = self:ResolveImage(self.ToggleConfig.Image)
			icon.Parent = self.ToggleBtn
		else
			self.ToggleBtn.Text = self.ToggleConfig.Text
			local icon = self.ToggleBtn:FindFirstChild("ToggleIcon")
			if icon then icon:Destroy() end
		end
	end
end

function TerminalLib:ToggleVisibility()
	self.IsOpen = not self.IsOpen
	if self.TerminalFrame then
		self.TerminalFrame.Visible = self.IsOpen
	end
end

function TerminalLib:BuildGui()
	local oldGui = self.ProtectedParent:FindFirstChild("TerminalLibraryGui") or self.PlayerGui:FindFirstChild("TerminalLibraryGui")
	if oldGui then oldGui:Destroy() end

	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "TerminalLibraryGui"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.DisplayOrder = 2147483647
	self.ScreenGui.Parent = self.ProtectedParent

	self.TerminalFrame = Instance.new("Frame")
	self.TerminalFrame.Name = "TerminalFrame"
	self.TerminalFrame.Size = UDim2.new(0, 520, 0, 320)
	self.TerminalFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
	self.TerminalFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	self.TerminalFrame.BorderSizePixel = 0
	self.TerminalFrame.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = self.TerminalFrame

	self.TopBar = Instance.new("Frame")
	self.TopBar.Size = UDim2.new(1, 0, 0, 30)
	self.TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	self.TopBar.BorderSizePixel = 0
	self.TopBar.Parent = self.TerminalFrame

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 8)
	topCorner.Parent = self.TopBar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = self.Title
	titleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.Code
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = self.TopBar

	local statsLabel = Instance.new("TextLabel")
	statsLabel.Size = UDim2.new(0.5, -12, 1, 0)
	statsLabel.Position = UDim2.new(0.5, 0, 0, 0)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "FPS: 0 | Ping: 0ms"
	statsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
	statsLabel.TextSize = 12
	statsLabel.Font = Enum.Font.Code
	statsLabel.TextXAlignment = Enum.TextXAlignment.Right
	statsLabel.Parent = self.TopBar

	local frameCount, lastUpdate = 0, tick()
	self:Connect(RunService.RenderStepped, function()
		frameCount += 1
		local now = tick()
		if now - lastUpdate >= 0.1 then
			local fps = math.round(frameCount / (now - lastUpdate))
			local ping = 0
			pcall(function()
				ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			statsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
			frameCount, lastUpdate = 0, now
		end
	end)

	local dragging, dragStart, startPos
	self:Connect(self.TopBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.TerminalFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	self:Connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			self.TerminalFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	self.OutputScroll = Instance.new("ScrollingFrame")
	self.OutputScroll.Size = UDim2.new(1, -20, 1, -85)
	self.OutputScroll.Position = UDim2.new(0, 10, 0, 40)
	self.OutputScroll.BackgroundTransparency = 1
	self.OutputScroll.BorderSizePixel = 0
	self.OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.OutputScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.OutputScroll.Parent = self.TerminalFrame

	local uiList = Instance.new("UIListLayout")
	uiList.SortOrder = Enum.SortOrder.LayoutOrder
	uiList.Padding = UDim.new(0, 4)
	uiList.Parent = self.OutputScroll

	self.SuggestionsFrame = Instance.new("ScrollingFrame")
	self.SuggestionsFrame.Size = UDim2.new(1, -20, 0, 65)
	self.SuggestionsFrame.Position = UDim2.new(0, 10, 1, -112)
	self.SuggestionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	self.SuggestionsFrame.BorderSizePixel = 0
	self.SuggestionsFrame.Visible = false
	self.SuggestionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.SuggestionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.SuggestionsFrame.ScrollBarThickness = 3
	self.SuggestionsFrame.Parent = self.TerminalFrame

	local sugList = Instance.new("UIListLayout")
	sugList.SortOrder = Enum.SortOrder.LayoutOrder
	sugList.Padding = UDim.new(0, 2)
	sugList.Parent = self.SuggestionsFrame

	local inputBar = Instance.new("Frame")
	inputBar.Size = UDim2.new(1, -20, 0, 35)
	inputBar.Position = UDim2.new(0, 10, 1, -42)
	inputBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	inputBar.BorderSizePixel = 0
	inputBar.Parent = self.TerminalFrame

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 6)
	inputCorner.Parent = inputBar

	local promptLabel = Instance.new("TextLabel")
	promptLabel.Size = UDim2.new(0, 20, 1, 0)
	promptLabel.Position = UDim2.new(0, 8, 0, 0)
	promptLabel.BackgroundTransparency = 1
	promptLabel.Text = ">"
	promptLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	promptLabel.TextSize = 14
	promptLabel.Font = Enum.Font.Code
	promptLabel.Parent = inputBar

	self.CommandInput = Instance.new("TextBox")
	self.CommandInput.Size = UDim2.new(1, -35, 1, 0)
	self.CommandInput.Position = UDim2.new(0, 28, 0, 0)
	self.CommandInput.BackgroundTransparency = 1
	self.CommandInput.Text = ""
	self.CommandInput.PlaceholderText = "type command here..."
	self.CommandInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
	self.CommandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.CommandInput.TextSize = 14
	self.CommandInput.Font = Enum.Font.Code
	self.CommandInput.TextXAlignment = Enum.TextXAlignment.Left
	self.CommandInput.ClearTextOnFocus = false
	self.CommandInput.Parent = inputBar

	self.ToggleBtn = Instance.new("TextButton")
	self.ToggleBtn.Name = "ToggleTerminalButton"
	self.ToggleBtn.Size = self.ToggleConfig.Size
	self.ToggleBtn.Position = self.ToggleConfig.Position
	self.ToggleBtn.BackgroundColor3 = self.ToggleConfig.BackgroundColor
	self.ToggleBtn.TextColor3 = self.ToggleConfig.TextColor
	self.ToggleBtn.Text = self.ToggleConfig.Text
	self.ToggleBtn.TextSize = 14
	self.ToggleBtn.Font = Enum.Font.Code
	self.ToggleBtn.Parent = self.ScreenGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = self.ToggleBtn

	self:ConfigureToggle({})

	self:Connect(self.ToggleBtn.MouseButton1Click, function()
		self:ToggleVisibility()
	end)

	self:Connect(UserInputService.InputBegan, function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == self.ToggleKey then
			self:ToggleVisibility()
		end
	end)

	self:ConnectEvents()
end

function TerminalLib:Print(text, color)
	if self.Destroyed then return end

	self.LineCounter += 1

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Text = tostring(text)
	label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
	label.TextSize = 13
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = true
	label.LayoutOrder = self.LineCounter
	label.Parent = self.OutputScroll

	table.insert(self.OutputLines, label)
	while #self.OutputLines > self.MaxLines do
		local oldest = table.remove(self.OutputLines, 1)
		if oldest then oldest:Destroy() end
	end

	task.defer(function()
		task.wait()
		if self.Destroyed then return end
		self.OutputScroll.CanvasPosition = Vector2.new(0, self.OutputScroll.AbsoluteCanvasSize.Y)
	end)
end

function TerminalLib:Clear()
	for _, label in ipairs(self.OutputLines) do
		label:Destroy()
	end
	self.OutputLines = {}
end

function TerminalLib:AddCommand(name, description, callback)
	self.Commands[string.lower(name)] = {
		Description = description,
		Callback = callback
	}
end

function TerminalLib:GetSortedCommandNames()
	local names = {}
	for name in pairs(self.Commands) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

function TerminalLib:UpdateSuggestions(query)
	for _, child in ipairs(self.SuggestionsFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	self.Matches = {}

	query = string.lower(string.match(query, "^%s*(.-)%s*$") or "")
	if query == "" then
		self.SuggestionsFrame.Visible = false
		return
	end

	for _, name in ipairs(self:GetSortedCommandNames()) do
		if string.sub(name, 1, #query) == query then
			table.insert(self.Matches, name)
		end
	end

	if #self.Matches > 0 then
		self.SuggestionsFrame.Visible = true
		for index, name in ipairs(self.Matches) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			btn.TextColor3 = Color3.fromRGB(180, 255, 180)
			btn.TextSize = 13
			btn.Font = Enum.Font.Code
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Text = "  " .. name .. " — " .. self.Commands[name].Description
			btn.LayoutOrder = index
			btn.Parent = self.SuggestionsFrame

			btn.MouseButton1Click:Connect(function()
				self.CommandInput.Text = name .. " "
				self.SuggestionsFrame.Visible = false
				self.CommandInput:CaptureFocus()
			end)
		end
	else
		self.SuggestionsFrame.Visible = false
	end
end

function TerminalLib:SetInputText(text)
	self.CommandInput.Text = text
	self.CommandInput.CursorPosition = #text + 1
end

function TerminalLib:ConnectEvents()
	local selfRef = self

	self:Connect(self.CommandInput:GetPropertyChangedSignal("Text"), function()
		local current = selfRef.CommandInput.Text
		if current:find("\t") then
			selfRef.CommandInput.Text = (current:gsub("\t", ""))
			return
		end
		selfRef:UpdateSuggestions(current)
	end)

	local function processCommand()
		local raw = selfRef.CommandInput.Text:match("^%s*(.-)%s*$") or ""
		selfRef.CommandInput.Text = ""
		selfRef.SuggestionsFrame.Visible = false

		if raw == "" then return end

		if selfRef.History[#selfRef.History] ~= raw then
			table.insert(selfRef.History, raw)
		end
		selfRef.HistoryIndex = #selfRef.History + 1

		selfRef:Print("> " .. raw, Color3.fromRGB(255, 255, 255))

		local args = {}
		for word in raw:gmatch("%S+") do
			table.insert(args, word)
		end
		local cmdName = string.lower(table.remove(args, 1))

		local command = selfRef.Commands[cmdName]
		if command then
			local success, err = pcall(function()
				command.Callback(args)
			end)
			if not success then
				selfRef:Print("Execution Error: " .. tostring(err), Color3.fromRGB(255, 80, 80))
			end
		else
			selfRef:Print("Unknown command. Type 'help' for options.", Color3.fromRGB(255, 80, 80))
		end

		task.defer(function()
			if not selfRef.Destroyed then
				selfRef.CommandInput:CaptureFocus()
			end
		end)
	end

	self:Connect(self.CommandInput.FocusLost, function(enterPressed)
		if enterPressed then
			processCommand()
		end
	end)

	self:Connect(UserInputService.InputBegan, function(input)
		if not selfRef.CommandInput:IsFocused() then return end

		if input.KeyCode == Enum.KeyCode.Up then
			if #selfRef.History == 0 then return end
			selfRef.HistoryIndex = math.max(1, selfRef.HistoryIndex - 1)
			selfRef:SetInputText(selfRef.History[selfRef.HistoryIndex])
		elseif input.KeyCode == Enum.KeyCode.Down then
			if #selfRef.History == 0 then return end
			selfRef.HistoryIndex = math.min(#selfRef.History + 1, selfRef.HistoryIndex + 1)
			selfRef:SetInputText(selfRef.History[selfRef.HistoryIndex] or "")
		elseif input.KeyCode == Enum.KeyCode.Tab then
			local top = selfRef.Matches[1]
			if top then
				task.defer(function()
					selfRef:SetInputText(top .. " ")
					selfRef.SuggestionsFrame.Visible = false
				end)
			end
		end
	end)
end

function TerminalLib:SetupDefaults()
	self:AddCommand("help", "Lists all available commands", function()
		self:Print("=== COMMAND LIST ===", Color3.fromRGB(255, 255, 100))
		for _, name in ipairs(self:GetSortedCommandNames()) do
			self:Print(string.format(" - %-10s : %s", name, self.Commands[name].Description), Color3.fromRGB(200, 200, 200))
		end
	end)

	self:AddCommand("clear", "Clears terminal history", function()
		self:Clear()
	end)

	self:AddCommand("keybind", "Changes UI toggle key (Usage: keybind [KeyCode])", function(args)
		local keyName = args[1]
		if not keyName then
			self:Print("Current Toggle Key: " .. tostring(self.ToggleKey.Name), Color3.fromRGB(0, 255, 100))
			self:Print("Usage: keybind [key] (e.g. keybind f, keybind insert, keybind return)", Color3.fromRGB(150, 150, 150))
			return
		end

		local target = string.lower(keyName)
		local found
		for _, item in ipairs(Enum.KeyCode:GetEnumItems()) do
			if string.lower(item.Name) == target then
				found = item
				break
			end
		end

		if found then
			self.ToggleKey = found
			self:Print("Success! Toggle keybind changed to: " .. found.Name, Color3.fromRGB(0, 255, 100))
		else
			self:Print("Error: Invalid key name. Try values like F, Return, Insert, LeftControl", Color3.fromRGB(255, 80, 80))
		end
	end)

	self:Print("Terminal GUI Library Initialized.", Color3.fromRGB(0, 255, 100))
	self:Print("Type 'help' or try typing 's' for auto-suggestions.", Color3.fromRGB(150, 150, 150))
	self:Print("------------------------------------------------", Color3.fromRGB(60, 60, 60))
end

return TerminalLib
