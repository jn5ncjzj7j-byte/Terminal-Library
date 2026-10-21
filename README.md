# TerminalLib

A custom terminal-style (TUI) UI library for Roblox. Add your own commands, get auto-suggestions, drag the window around, and toggle it with a key or a button. The toggle button supports web image links.

## Features

- Draggable terminal window (mouse and touch)
- Custom commands with descriptions and arguments
- Auto-suggestions while typing
- Live FPS and ping display
- Toggle with a keybind or an on-screen button
- Customizable toggle button (text, size, position, colors, image)
- Image support for `rbxassetid://` and web links (`https://`)
- Built-in commands: `help`, `clear`, `keybind`

## Installation

Upload `TerminalLib.lua` to your repo, then load it with its raw link:

```lua
local TerminalLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/TerminalLib.lua"))()
```

Replace `USERNAME` and `REPO` with your GitHub username and repository name.

## Quick Start

```lua
local TerminalLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/TerminalLib.lua"))()

local Terminal = TerminalLib.new("My Hub @" .. game.Players.LocalPlayer.Name)

Terminal:AddCommand("hello", "Says hello", function(args)
	Terminal:Print("Hello, world!", Color3.fromRGB(0, 255, 100))
end)
```

Press `RightControl` (default) or click the toggle button to show or hide the terminal.

## API

### `TerminalLib.new(titleText)`

Creates the terminal.

| Parameter | Type | Description |
|-----------|------|-------------|
| `titleText` | string (optional) | Text shown in the top bar. Defaults to `Misg-Hub @PlayerName~` |

Returns a terminal object.

### `Terminal:AddCommand(name, description, callback)`

Registers a command.

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Command name (not case-sensitive) |
| `description` | string | Shown in `help` and in suggestions |
| `callback` | function | Called with a table of arguments |

```lua
Terminal:AddCommand("speed", "Sets walk speed (Usage: speed [number])", function(args)
	local value = tonumber(args[1])
	if not value then
		Terminal:Print("Usage: speed [number]", Color3.fromRGB(255, 80, 80))
		return
	end
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
	Terminal:Print("Walk speed set to " .. value, Color3.fromRGB(0, 255, 100))
end)
```

> Input is lowercased before it is processed, so command names and arguments always arrive in lowercase.

### `Terminal:Print(text, color)`

Prints a line to the terminal.

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | string | The message |
| `color` | Color3 (optional) | Text color. Defaults to light gray |

```lua
Terminal:Print("Success!", Color3.fromRGB(0, 255, 100))
Terminal:Print("Something went wrong", Color3.fromRGB(255, 80, 80))
```

### `Terminal:ConfigureToggle(config)`

Customizes the toggle button. Every field is optional.

| Field | Type | Description |
|-------|------|-------------|
| `Text` | string | Button text (used when no image is set) |
| `Image` | string | `rbxassetid://...` or a web link (`https://...`) |
| `Size` | UDim2 | Button size |
| `Position` | UDim2 | Button position |
| `BackgroundColor` | Color3 | Button background |
| `TextColor` | Color3 | Button text color |

```lua
Terminal:ConfigureToggle({
	Text = "Open",
	Size = UDim2.new(0, 100, 0, 40),
	Position = UDim2.new(0, 20, 0, 20),
	BackgroundColor = Color3.fromRGB(30, 30, 30),
	TextColor = Color3.fromRGB(0, 255, 100)
})
```

Using an image:

```lua
-- Roblox asset
Terminal:ConfigureToggle({ Image = "rbxassetid://123456789" })

-- Web link
Terminal:ConfigureToggle({ Image = "https://example.com/icon.png" })
```

To go back to text, set `Image = ""`.

### `Terminal:ToggleVisibility()`

Shows or hides the terminal.

```lua
Terminal:ToggleVisibility()
```

### `Terminal.ToggleKey`

The keybind that toggles the terminal. Default is `Enum.KeyCode.RightControl`.

```lua
Terminal.ToggleKey = Enum.KeyCode.Insert
```

Players can also change it in-game with the `keybind` command.

## Built-in Commands

| Command | Description |
|---------|-------------|
| `help` | Lists all available commands |
| `clear` | Clears the terminal history |
| `keybind [key]` | Changes the toggle key, e.g. `keybind f` or `keybind insert`. Run it without a key to see the current one |

## Full Example

```lua
local TerminalLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/TerminalLib.lua"))()

local Terminal = TerminalLib.new("Misg-Hub @" .. game.Players.LocalPlayer.Name .. "~")

Terminal:ConfigureToggle({
	Text = "Misg Hub",
	BackgroundColor = Color3.fromRGB(30, 30, 30),
	TextColor = Color3.fromRGB(0, 255, 100)
})

Terminal:AddCommand("hello", "Says hello", function()
	Terminal:Print("Hello!", Color3.fromRGB(0, 255, 100))
end)

Terminal:AddCommand("jump", "Makes you jump", function()
	local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
		Terminal:Print("Jumped!", Color3.fromRGB(0, 255, 100))
	else
		Terminal:Print("No character found.", Color3.fromRGB(255, 80, 80))
	end
end)
```

## Notes

- Web image links need an executor that supports `writefile`, `getcustomasset`, and `game:HttpGet`. Without them, use an `rbxassetid://` image instead.
- The GUI is parented to `gethui()` / `get_hidden_gui()` when available, otherwise `CoreGui`.
- Creating a new terminal removes any previous `TerminalLibraryGui`.

## License

Add your license here (for example, MIT).
