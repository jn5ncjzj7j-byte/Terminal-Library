-- Load your terminal library directly from GitHub
local TerminalLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jn5ncjzj7j-byte/Terminal-Library/refs/heads/main/src/TerminalLibrary.lua"))()

-- Initialize the terminal window
local Terminal = TerminalLib.new("My Terminal Hub")

-- ==========================================
-- ADD CUSTOM COMMANDS
-- ==========================================

-- 1. Speed Command (Usage: speed 50)
Terminal:AddCommand("speed", "Changes your walk speed (e.g. speed 32)", function(args)
	local val = tonumber(args[1])
	local char = game.Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	
	if val and hum then
		hum.WalkSpeed = val
		Terminal:Print("WalkSpeed updated to: " .. tostring(val), Color3.fromRGB(0, 255, 0))
	else
		Terminal:Print("Error: Provide a valid number. e.g. 'speed 40'", Color3.fromRGB(255, 50, 50))
	end
end)

-- 2. Heal Command
Terminal:AddCommand("heal", "Restores your health to maximum", function(args)
	local char = game.Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	
	if hum then
		hum.Health = hum.MaxHealth
		Terminal:Print("Health fully restored!", Color3.fromRGB(0, 255, 0))
	else
		Terminal:Print("Error: Humanoid not found.", Color3.fromRGB(255, 50, 50))
	end
end)

-- 3. Fly Simulation Command
Terminal:AddCommand("fly", "Toggles test flight mode", function(args)
	Terminal:Print("Flight mode toggled on!", Color3.fromRGB(255, 140, 0))
	-- Add your flight logic here if you want!
end)

-- 4. Print Message Command (Usage: say Hello World)
Terminal:AddCommand("say", "Prints a custom message to the terminal log", function(args)
	if #args == 0 then
		Terminal:Print("Error: No message provided.", Color3.fromRGB(255, 50, 50))
		return
	end
	local msg = table.concat(args, " ")
	Terminal:Print("MSG: " .. msg, Color3.fromRGB(255, 255, 255))
end)
