-- Load your terminal library from GitHub with cache-buster
local TerminalLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jn5ncjzj7j-byte/Terminal-Library/refs/heads/main/src/TerminalLibraryBeta.lua?cache=" .. math.random(1, 999999)))()

-- Initialize the terminal hub
local Terminal = TerminalLib.new("Misg Hub [Logo CLI]")

-- ==========================================
-- CONFIGURE TOGGLE BUTTON WITH A LOGO IMAGE
-- ==========================================
Terminal:ConfigureToggle({
	Text = "", -- Keep text empty when using an image logo
	Image = "rbxassetid://6034287592", -- Replace with your own Roblox Decal/Image ID!
	Size = UDim2.new(0, 45, 0, 45),    -- Make it a clean square icon button
	Position = UDim2.new(0, 25, 0, 25),
	BackgroundColor = Color3.fromRGB(20, 20, 20),
	TextColor = Color3.fromRGB(255, 255, 255)
})

-- ==========================================
-- ADD COMMANDS FOR TESTING
-- ==========================================
Terminal:AddCommand("test", "Tests command execution", function(args)
	Terminal:Print("Logo toggle button and commands are working perfectly!", Color3.fromRGB(0, 255, 100))
end)

Terminal:AddCommand("speed", "Changes walk speed (Usage: speed [num])", function(args)
	local val = tonumber(args[1])
	local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	
	if val and hum then
		hum.WalkSpeed = val
		Terminal:Print("WalkSpeed updated to: " .. tostring(val), Color3.fromRGB(0, 255, 100))
	else
		Terminal:Print("Error: Provide a valid number.", Color3.fromRGB(255, 80, 80))
	end
end)
