local TerminalLib = loadstring(game:HttpGet("https://github.com/jn5ncjzj7j-byte/Terminal-Library/raw/refs/heads/main/src/TerminalLibrary.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local GREEN = Color3.fromRGB(0, 255, 100)
local RED = Color3.fromRGB(255, 80, 80)
local YELLOW = Color3.fromRGB(255, 255, 100)
local GRAY = Color3.fromRGB(150, 150, 150)
local WHITE = Color3.fromRGB(255, 255, 255)

-- Create the terminal (title is optional)
local Terminal = TerminalLib.new("Excample-Hub @" .. LocalPlayer.Name .. "~")

-- Keep up to 300 lines on screen
Terminal.MaxLines = 300

-- Change the keybind that shows/hides the terminal
Terminal.ToggleKey = Enum.KeyCode.RightControl

-- Customize the toggle button
Terminal:ConfigureToggle({
	Text = "Misg Hub",
	Size = UDim2.new(0, 110, 0, 45),
	Position = UDim2.new(0, 20, 0, 20),
	BackgroundColor = Color3.fromRGB(30, 30, 30),
	TextColor = GREEN
})

local function getHumanoid()
	local character = LocalPlayer.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function findPlayer(partial)
	partial = string.lower(partial)
	for _, plr in ipairs(Players:GetPlayers()) do
		if string.sub(string.lower(plr.Name), 1, #partial) == partial
			or string.sub(string.lower(plr.DisplayName), 1, #partial) == partial then
			return plr
		end
	end
end

-- Simple command, no arguments
Terminal:AddCommand("hello", "Says hello", function()
	Terminal:Print("Hello, " .. LocalPlayer.DisplayName .. "!", GREEN)
end)

-- Command with a number argument
Terminal:AddCommand("speed", "Sets walk speed (Usage: speed [number])", function(args)
	local value = tonumber(args[1])
	local hum = getHumanoid()
	if not value then
		Terminal:Print("Usage: speed [number]", RED)
	elseif not hum then
		Terminal:Print("No character found.", RED)
	else
		hum.WalkSpeed = value
		Terminal:Print("Walk speed set to " .. value, GREEN)
	end
end)

Terminal:AddCommand("jumppower", "Sets jump power (Usage: jumppower [number])", function(args)
	local value = tonumber(args[1])
	local hum = getHumanoid()
	if not value then
		Terminal:Print("Usage: jumppower [number]", RED)
	elseif not hum then
		Terminal:Print("No character found.", RED)
	else
		hum.UseJumpPower = true
		hum.JumpPower = value
		Terminal:Print("Jump power set to " .. value, GREEN)
	end
end)

Terminal:AddCommand("jump", "Makes your character jump", function()
	local hum = getHumanoid()
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
		Terminal:Print("Jumped!", GREEN)
	else
		Terminal:Print("No character found.", RED)
	end
end)

Terminal:AddCommand("fov", "Sets camera field of view (Usage: fov [number])", function(args)
	local value = tonumber(args[1])
	if not value then
		Terminal:Print("Usage: fov [number]", RED)
		return
	end
	Workspace.CurrentCamera.FieldOfView = math.clamp(value, 1, 120)
	Terminal:Print("FOV set to " .. Workspace.CurrentCamera.FieldOfView, GREEN)
end)

-- Command that uses a player name (arguments keep their casing)
Terminal:AddCommand("tp", "Teleports to a player (Usage: tp [name])", function(args)
	if not args[1] then
		Terminal:Print("Usage: tp [name]", RED)
		return
	end

	local target = findPlayer(args[1])
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")

	if not target then
		Terminal:Print("Player not found: " .. args[1], RED)
	elseif not (myRoot and targetRoot) then
		Terminal:Print("Character not loaded.", RED)
	else
		myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
		Terminal:Print("Teleported to " .. target.Name, GREEN)
	end
end)

Terminal:AddCommand("players", "Lists everyone in the server", function()
	Terminal:Print("Players (" .. #Players:GetPlayers() .. "):", YELLOW)
	for _, plr in ipairs(Players:GetPlayers()) do
		Terminal:Print(string.format(" - %s (@%s)", plr.DisplayName, plr.Name), WHITE)
	end
end)

-- Command that uses all arguments as one sentence
Terminal:AddCommand("echo", "Prints your text back (Usage: echo [text])", function(args)
	if #args == 0 then
		Terminal:Print("Usage: echo [text]", RED)
		return
	end
	Terminal:Print(table.concat(args, " "), WHITE)
end)

Terminal:AddCommand("info", "Shows info about you and the server", function()
	local hum = getHumanoid()
	Terminal:Print("=== INFO ===", YELLOW)
	Terminal:Print("User     : " .. LocalPlayer.Name, WHITE)
	Terminal:Print("Place ID : " .. game.PlaceId, WHITE)
	Terminal:Print("Players  : " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers, WHITE)
	if hum then
		Terminal:Print(string.format("Health   : %d/%d", hum.Health, hum.MaxHealth), WHITE)
		Terminal:Print("Speed    : " .. hum.WalkSpeed, WHITE)
	end
end)

Terminal:AddCommand("reset", "Resets your character", function()
	local hum = getHumanoid()
	if hum then
		hum.Health = 0
		Terminal:Print("Character reset.", GREEN)
	else
		Terminal:Print("No character found.", RED)
	end
end)

Terminal:AddCommand("colors", "Shows the colors used by Print", function()
	Terminal:Print("Green  - success", GREEN)
	Terminal:Print("Red    - error", RED)
	Terminal:Print("Yellow - headings", YELLOW)
	Terminal:Print("Gray   - hints", GRAY)
	Terminal:Print("White  - normal output", WHITE)
end)

-- Uses Terminal.MaxLines
Terminal:AddCommand("maxlines", "Sets the max output lines (Usage: maxlines [number])", function(args)
	local value = tonumber(args[1])
	if not value or value < 10 then
		Terminal:Print("Usage: maxlines [number 10 or higher]", RED)
		return
	end
	Terminal.MaxLines = math.floor(value)
	Terminal:Print("Max lines set to " .. Terminal.MaxLines, GREEN)
end)

-- Uses ConfigureToggle to change the button while running
Terminal:AddCommand("icon", "Sets the toggle icon (Usage: icon [link or rbxassetid] | icon off)", function(args)
	local value = args[1]
	if not value then
		Terminal:Print("Usage: icon [https link or rbxassetid://id] | icon off", RED)
	elseif string.lower(value) == "off" then
		Terminal:ConfigureToggle({ Image = "" })
		Terminal:Print("Toggle button is back to text.", GREEN)
	else
		Terminal:ConfigureToggle({ Image = value })
		Terminal:Print("Toggle icon updated.", GREEN)
	end
end)

Terminal:AddCommand("rename", "Changes the toggle button text (Usage: rename [text])", function(args)
	if #args == 0 then
		Terminal:Print("Usage: rename [text]", RED)
		return
	end
	Terminal:ConfigureToggle({ Image = "", Text = table.concat(args, " ") })
	Terminal:Print("Toggle text updated.", GREEN)
end)

-- Uses ToggleVisibility
Terminal:AddCommand("hide", "Hides the terminal (press the toggle key or button to show it)", function()
	Terminal:Print("Hiding terminal...", GRAY)
	task.delay(0.3, function()
		Terminal:ToggleVisibility()
	end)
end)

-- Uses Destroy
Terminal:AddCommand("exit", "Closes the terminal completely", function()
	Terminal:Print("Goodbye!", YELLOW)
	task.delay(0.5, function()
		Terminal:Destroy()
	end)
end)

-- Print after setup
Terminal:Print("Welcome, " .. LocalPlayer.DisplayName .. "! Type 'help' to see everything.", YELLOW)
Terminal:Print("Tip: Up/Down = history, Tab = autocomplete, 'keybind [key]' changes the toggle key.", GRAY)
