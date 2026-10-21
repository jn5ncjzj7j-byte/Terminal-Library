-- 1. โหลดไลบรารี Terminal จาก GitHub ของคุณ (พร้อมตัวกันแคช)
local TerminalLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jn5ncjzj7j-byte/Terminal-Library/refs/heads/main/src/TerminalLibraryBeta.lua?cache=" .. math.random(1, 999999)))()

-- 2. สร้างหน้าต่าง Terminal Hub
local Terminal = TerminalLib.new("Misg Hub [Web Image Logo Test]")

-- ==========================================
-- ตั้งค่าปุ่ม Toggle ด้วยเว็บลิงก์รูปภาพตรงๆ
-- ==========================================
Terminal:ConfigureToggle({
	Text = "", -- ปล่อยว่างไว้เมื่อใช้รูปภาพโลโก้
	Image = "https://static.wikia.nocookie.net/characterprofile/images/c/c8/BotW_Link.png/revision/latest?cb=20170306180639", -- ลิงก์รูปภาพจากเว็บที่คุณต้องการ
	Size = UDim2.new(0, 48, 0, 48), -- ขนาดปุ่มแบบสี่เหลี่ยมจัตุรัสพอดีสวยๆ
	Position = UDim2.new(0, 25, 0, 25), -- ตำแหน่งมุมซ้ายบน
	BackgroundColor = Color3.fromRGB(20, 20, 20)
})

-- ==========================================
-- เพิ่มคำสั่งทดสอบระบบ
-- ==========================================

-- คำสั่งเทสระบบรันและเว็บรูปภาพ
Terminal:AddCommand("test", "Tests custom web image and command execution", function(args)
	Terminal:Print("SUCCESS! Web image loaded and commands are firing correctly!", Color3.fromRGB(0, 255, 100))
end)

-- คำสั่งปรับความเร็ว (พิมพ์ speed 50)
Terminal:AddCommand("speed", "Changes walk speed (Usage: speed [number])", function(args)
	local val = tonumber(args[1])
	local char = game.Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	
	if val and hum then
		hum.WalkSpeed = val
		Terminal:Print("WalkSpeed updated to: " .. tostring(val), Color3.fromRGB(0, 255, 100))
	else
		Terminal:Print("Error: Please provide a valid number. e.g. 'speed 50'", Color3.fromRGB(255, 80, 80))
	end
end)

-- คำสั่งพ่นข้อความ (พิมพ์ say สวัสดีทุกคน)
Terminal:AddCommand("say", "Broadcasts message to terminal", function(args)
	if #args == 0 then
		Terminal:Print("Error: No message provided.", Color3.fromRGB(255, 80, 80))
		return
	end
	Terminal:Print("BROADCAST: " .. table.concat(args, " "), Color3.fromRGB(255, 255, 255))
end)
