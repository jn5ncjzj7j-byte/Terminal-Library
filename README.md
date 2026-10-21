# ⚡ Terminal-Library

A lightweight, command-driven Terminal User Interface (TUI) library built in Luau for Roblox. Designed as a clean, minimalist alternative to traditional script hubs with cluttered tabs, buttons, and sliders.

Features a real-time **FPS & Ping monitor**, smooth **dragging**, **mobile toggle support**, and **smart command auto-completion** with dropdown suggestions.

---

## 🚀 Features

- **Command-Driven**: Execute functions, scripts, or toggles entirely through text commands.
- **Smart Auto-Complete**: Type a letter (e.g., `s`) and instantly get clickable dropdown suggestions matching your registered commands.
- **Live Stats Header**: Built-in real-time FPS and server ping tracking.
- **Cross-Platform**: Built-in support for both PC (`Right Ctrl` to toggle) and Mobile (Custom floating GUI button).
- **Draggable Window**: Easily move the terminal interface anywhere on your screen.

---

## 📦 Installation & Usage

You can easily load and use this library directly in your Roblox scripts via `loadstring` from your GitHub repository[span_0](start_span)[span_0](end_span):

```lua
-- Load the library from GitHub
local TerminalLib = loadstring(game:HttpGet("[https://raw.githubusercontent.com/jn5ncjzj7j-byte/Terminal-Library/refs/heads/main/src/TerminalLibrary.lua](https://raw.githubusercontent.com/jn5ncjzj7j-byte/Terminal-Library/refs/heads/main/src/TerminalLibrary.lua)"))()

-- Initialize your terminal window
local Terminal = TerminalLib.new("My Script Hub")

-- Add a custom command
Terminal:AddCommand("speed", "Changes your walk speed (Usage: speed [number])", function(args)
	local newSpeed = tonumber(args[1])
	local character = game.Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if newSpeed and humanoid then
		humanoid.WalkSpeed = newSpeed
		Terminal:Print("WalkSpeed updated to: " .. tostring(newSpeed), Color3.fromRGB(0, 255, 100))
	else
		Terminal:Print("Error: Please provide a valid number.", Color3.fromRGB(255, 80, 80))
	end
end)
