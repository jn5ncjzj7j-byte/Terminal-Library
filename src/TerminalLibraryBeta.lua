--[=[
	TerminalLib - Custom TUI Library for Roblox (Fixed Auto-Complete & Execution)
]=]

local TerminalLib = {}
TerminalLib.__index = TerminalLib

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

function TerminalLib.new(titleText)
	local self = setmetatable({}, TerminalLib)
	
	self.Commands = {}
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
			icon.Image = self.ToggleConfig.Image
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
	self.ScreenGui.DisplayOrder = math.huge
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
	RunService.RenderStepped:Connect(function()
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
	self.TopBar.InputBegan:Connect(function(input)
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

	UserInputService.InputChanged:Connect(function(input)
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

	self.ToggleBtn.MouseButton1Click:Connect(function()
		self:ToggleVisibility()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == self.ToggleKey then
			self:ToggleVisibility()
		end
	end)

	self:ConnectEvents()
end

function TerminalLib:Print(text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
	label.TextSize = 13
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Parent = self.OutputScroll
	
	task.defer(function()
		self.OutputScroll.CanvasPosition = Vector2.new(0, self.OutputScroll.AbsoluteCanvasSize.Y)
	end)
end

function TerminalLib:AddCommand(name, description, callback)
	self.Commands[string.lower(name)] = {
		Description = description,
		Callback = callback
	}
end

function TerminalLib:UpdateSuggestions(query)
	for _, child in ipairs(self.SuggestionsFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	
	query = string.lower(string.match(query, "^%s*(.-)%s*$") or "")
	if query == "" then
		self.SuggestionsFrame.Visible = false
		return
	end
	
	local matches = {}
	for name, data in pairs(self.Commands) do
		if string.sub(name, 1, #query) == query then
			table.insert(matches, {Name = name, Desc = data.Description})
		end
	end
	
	if #matches > 0 then
		self.SuggestionsFrame.Visible = true
		for _, match in ipairs(matches) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			btn.TextColor3 = Color3.fromRGB(180, 255, 180)
			btn.TextSize = 13
			btn.Font = Enum.Font.Code
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Text = "  " .. match.Name .. " — " .. match.Desc
			btn.Parent = self.SuggestionsFrame
			
			btn.MouseButton1Click:Connect(function()
				self.CommandInput.Text = match.Name .. " "
				self.SuggestionsFrame.Visible = false
				self.CommandInput:CaptureFocus()
			end)
		end
	else
		self.SuggestionsFrame.Visible = false
	end
end

function TerminalLib:ConnectEvents()
	local selfRef = self

	self.CommandInput:GetPropertyChangedSignal("Text"):Connect(function()
		selfRef:UpdateSuggestions(selfRef.CommandInput.Text)
	end)

	self.CommandInput.FocusLost:Connect(function(enterPressed)
		if not enterPressed then return end
		
		local text = selfRef.CommandInput.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
		selfRef.CommandInput.Text = ""
		selfRef.SuggestionsFrame.Visible = false
		
		if text == "" then return end
		
		selfRef:Print("> " + text, Color3.fromRGB(255, 255, 255))
		
		local split = string.split(text, " ")
		local cmdName = split[1]
		local args = {}
		for i = 2, #split do table.insert(args, split[i]) end
		
		if selfRef.Commands[cmdName] then
			local success, err = pcall(function()
				selfRef.Commands[cmdName].Callback(args)
			end)
			if not success then
				selfRef:Print("Execution Error: " .. tostring(err), Color3.fromRGB(255, 80, 80))
			end
		else
			selfRef:Print("Unknown command. Type 'help' for options.", Color3.fromRGB(255, 80, 80))
		end
		
		selfRef.CommandInput:CaptureFocus()
	end)
end

function TerminalLib:SetupDefaults()
	self:AddCommand("help", "Lists all available commands", function()
		self:Print("=== COMMAND LIST ===", Color3.fromRGB(255, 255, 100))
		for name, data in pairs(self.Commands) do
			self:Print(string.format(" - %-10s : %s", name, data.Description), Color3.fromRGB(200, 200, 200))
		end
	end)

	self:AddCommand("clear", "Clears terminal history", function()
		for _, child in ipairs(self.OutputScroll:GetChildren()) do
			if child:IsA("TextLabel") then child:Destroy() end
		end
	end)

	self:AddCommand("keybind", "Changes UI toggle key (Usage: keybind [KeyCode])", function(args)
		local keyName = args[1]
		if not keyName then
			self:Print("Current Toggle Key: " .. tostring(self.ToggleKey.Name), Color3.fromRGB(0, 255, 100))
			self:Print("Usage: keybind [key] (e.g. keybind f, keybind insert, keybind return)", Color3.fromRGB(150, 150, 150))
			return
		end
		
		keyName = string.upper(keyName)
		local success, enumItem = pcall(function()
			return Enum.KeyCode[keyName]
		end)
		
		if success and enumItem then
			self.ToggleKey = enumItem
			self:Print("Success! Toggle keybind changed to: " .. enumItem.Name, Color3.fromRGB(0, 255, 100))
		else
			self:Print("Error: Invalid key name. Try values like F, Return, Insert, LeftControl", Color3.fromRGB(255, 80, 80))
		end
	end)
	
	self:Print("Terminal GUI Library Initialized.", Color3.fromRGB(0, 255, 100))
	self:Print("Type 'help' or try typing 's' for auto-suggestions.", Color3.fromRGB(150, 150, 150))
	self:Print("------------------------------------------------", Color3.fromRGB(60, 60, 60))
end

return TerminalLib
