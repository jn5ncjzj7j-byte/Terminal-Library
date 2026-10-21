--[=[
	TerminalLib - A lightweight command-driven TUI library for Roblox.
	Author: YourName
]=]

local TerminalLib = {}
TerminalLib.__index = TerminalLib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

function TerminalLib.new(titleText)
	local self = setmetatable({}, TerminalLib)
	
	self.Commands = {}
	self.ScreenGui = nil
	self.Window = nil
	self.OutputScroll = nil
	self.SuggestionsFrame = nil
	self.CommandInput = nil
	self.IsOpen = true
	self.Title = titleText or "Terminal CLI"
	
	local playerGui = player:WaitForChild("PlayerGui")
	self:BuildGui(playerGui)
	self:SetupDefaults()
	
	return self
end

function TerminalLib:BuildGui(playerGui)
	local oldGui = playerGui:FindFirstChild("TerminalLibraryGui")
	if oldGui then oldGui:Destroy() end

	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "TerminalLibraryGui"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Parent = playerGui

	self.Window = Instance.new("Frame")
	self.Window.Size = UDim2.new(0, 500, 0, 320)
	self.Window.Position = UDim2.new(0.5, -250, 0.5, -160)
	self.Window.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	self.Window.BorderSizePixel = 0
	self.Window.Active = true
	self.Window.Draggable = true
	self.Window.Parent = self.ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = self.Window

	local titleBar = Instance.new("TextLabel")
	titleBar.Size = UDim2.new(1, 0, 0, 26)
	titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	titleBar.TextColor3 = Color3.fromRGB(200, 200, 200)
	titleBar.TextSize = 12
	titleBar.Font = Enum.Font.Code
	titleBar.Text = "  " .. self.Title .. " [Press Insert to Toggle]"
	titleBar.TextXAlignment = Enum.TextXAlignment.Left
	titleBar.Parent = self.Window

	self.OutputScroll = Instance.new("ScrollingFrame")
	self.OutputScroll.Size = UDim2.new(1, -16, 1, -105)
	self.OutputScroll.Position = UDim2.new(0, 8, 0, 32)
	self.OutputScroll.BackgroundTransparency = 1
	self.OutputScroll.BorderSizePixel = 0
	self.OutputScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.OutputScroll.ScrollBarThickness = 4
	self.OutputScroll.Parent = self.Window

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutIndex
	listLayout.Padding = UDim.new(0, 3)
	listLayout.Parent = self.OutputScroll

	self.SuggestionsFrame = Instance.new("ScrollingFrame")
	self.SuggestionsFrame.Size = UDim2.new(1, -16, 0, 60)
	self.SuggestionsFrame.Position = UDim2.new(0, 8, 1, -95)
	self.SuggestionsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	self.SuggestionsFrame.BorderSizePixel = 0
	self.SuggestionsFrame.Visible = false
	self.SuggestionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	self.SuggestionsFrame.ScrollBarThickness = 3
	self.SuggestionsFrame.Parent = self.Window

	local sugLayout = Instance.new("UIListLayout")
	sugLayout.SortOrder = Enum.SortOrder.LayoutIndex
	sugLayout.Padding = UDim.new(0, 2)
	sugLayout.Parent = self.SuggestionsFrame

	self.CommandInput = Instance.new("TextBox")
	self.CommandInput.Size = UDim2.new(1, -16, 0, 28)
	self.CommandInput.Position = UDim2.new(0, 8, 1, -32)
	self.CommandInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	self.CommandInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.CommandInput.PlaceholderText = "Type command here..."
	self.CommandInput.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
	self.CommandInput.TextSize = 12
	self.CommandInput.Font = Enum.Font.Code
	self.CommandInput.ClearTextOnFocus = false
	self.CommandInput.Parent = self.Window

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 4)
	inputCorner.Parent = self.CommandInput

	self:ConnectEvents()
end

function TerminalLib:Print(text, color)
	if not self.OutputScroll then return end
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 16)
	label.BackgroundTransparency = 1
	label.TextColor3 = color or Color3.fromRGB(0, 255, 128)
	label.TextSize = 12
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "  " .. text
	label.Parent = self.OutputScroll
	self.OutputScroll.CanvasPosition = Vector2.new(0, self.OutputScroll.AbsoluteCanvasSize.Y)
end

function TerminalLib:AddCommand(name, description, callback)
	self.Commands[string.lower(name)] = { Description = description, Callback = callback }
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
			btn.Size = UDim2.new(1, 0, 0, 20)
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			btn.TextColor3 = Color3.fromRGB(180, 255, 180)
			btn.TextSize = 12
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
		local fullText = selfRef.CommandInput.Text
		selfRef.CommandInput.Text = ""
		selfRef.SuggestionsFrame.Visible = false
		if fullText == "" then return end
		
		selfRef:Print("> " .. fullText, Color3.fromRGB(170, 170, 170))
		
		local split = string.split(fullText, " ")
		local cmdName = string.lower(split[1])
		local args = {}
		for i = 2, #split do table.insert(args, split[i]) end
		
		if selfRef.Commands[cmdName] then
			local success, err = pcall(function() selfRef.Commands[cmdName].Callback(args) end)
			if not success then selfRef:Print("Error: " .. tostring(err), Color3.fromRGB(255, 50, 50)) end
		else
			selfRef:Print("Unknown command: '" .. cmdName .. "'.", Color3.fromRGB(255, 50, 50))
		end
		selfRef.CommandInput:CaptureFocus()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
			selfRef.IsOpen = not selfRef.IsOpen
			selfRef.Window.Visible = selfRef.IsOpen
		end
	end)
end

function TerminalLib:SetupDefaults()
	self:AddCommand("help", "Lists all available commands", function()
		self:Print("=== COMMAND LIST ===", Color3.fromRGB(255, 255, 0))
		for name, data in pairs(self.Commands) do
			self:Print(string.format("  %-10s : %s", name, data.Description), Color3.fromRGB(0, 255, 255))
		end
	end)

	self:AddCommand("clear", "Clears the terminal output screen", function()
		for _, child in ipairs(self.OutputScroll:GetChildren()) do
			if child:IsA("TextLabel") then child:Destroy() end
		end
	end)
	
	self:Print("Terminal CLI Hub Loaded Successfully.")
end

return TerminalLib
