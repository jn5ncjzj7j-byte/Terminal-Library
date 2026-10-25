# TerminalLib

A custom terminal-style (TUI) UI library for Roblox. Add your own commands, get auto-suggestions, command history, and a draggable window you can toggle with a key or a button. The toggle button supports web image links.

## Features

- Draggable terminal window (mouse and touch)
- Custom commands with descriptions and arguments
- Auto-suggestions while typing, with `Tab` to autocomplete
- Command history with `Up` / `Down`
- Live FPS and ping display
- Toggle with a keybind or an on-screen button
- Customizable toggle button (text, size, position, colors, image)
- Image support for `rbxassetid://` and web links (`https://`)
- Wrapped output lines and an automatic line limit
- Clean `Destroy()` that removes the GUI and disconnects everything
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

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Enter` | Run the command |
| `Up` / `Down` | Browse command history |
| `Tab` | Autocomplete the top suggestion |
| `RightControl` | Show / hide the terminal (changeable) |

## API

### `TerminalLib.new(titleText)`

Creates the terminal. If an older terminal from this library is still open, it is destroyed first.

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

> Only the command name is case-insensitive. Arguments keep the casing the user typed, so player names and text work as expected.

### `Terminal:Print(text, color)`

Prints a line to the terminal. Long lines wrap automatically.

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | string | The message |
| `color` | Color3 (optional) | Text color. Defaults to light gray |

```lua
Terminal:Print("Success!", Color3.fromRGB(0, 255, 100))
Terminal:Print("Something went wrong", Color3.fromRGB(255, 80, 80))
```

### `Terminal:Clear()`

Clears all output lines. The `clear` command uses this.

### `Terminal.MaxLines`

Maximum number of output lines kept on screen. Older lines are removed first. Default is `200`.

```lua
Terminal.MaxLines = 500
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
Terminal:ConfigureToggle({ Image = "rbxassetid://123456789" })

Terminal:ConfigureToggle({ Image = "https://example.com/icon.png" })
```

To go back to text, set `Image = ""`. Web images are downloaded once per link and reused.

### `Terminal:ToggleVisibility()`

Shows or hides the terminal.

### `Terminal.ToggleKey`

The keybind that toggles the terminal. Default is `Enum.KeyCode.RightControl`.

```lua
Terminal.ToggleKey = Enum.KeyCode.Insert
```

Players can also change it in-game with the `keybind` command.

### `Terminal:Destroy()`

Removes the GUI, disconnects all events, and deletes any temporary image files it created.

```lua
Terminal:Destroy()
```

## Built-in Commands

| Command | Description |
|---------|-------------|
| `help` | Lists all available commands (sorted A to Z) |
| `clear` | Clears the terminal history |
| `keybind [key]` | Changes the toggle key, e.g. `keybind f` or `keybind insert`. Key names are not case-sensitive. Run it without a key to see the current one |

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
- Running the script again destroys the previous terminal first, so you won't get duplicate windows or leftover connections.

## License

Add your license here (for example, MIT).
