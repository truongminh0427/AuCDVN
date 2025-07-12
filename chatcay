local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ArrowMinigame")

-- ✅ Bật/tắt bằng cách thay đổi biến này trong Console
autoEnabled = true

-- 🎯 Map góc xoay → phím
local rotationToKey = {
	[0] = Enum.KeyCode.Right,
	[180] = Enum.KeyCode.Left,
	[90] = Enum.KeyCode.Down,
	[-90] = Enum.KeyCode.Up,
}

-- 👟 Hàm nhấn phím mô phỏng
local function pressKey(keycode)
	VirtualInputManager:SendKeyEvent(true, keycode, false, game)
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(false, keycode, false, game)
end

-- ⏱️ Đợi vạch trắng đến đúng vị trí → nhấn Space
local function waitAndPressSpace(strike)
	local finalX = strike.Final.AbsolutePosition.X

	while true do
		if not autoEnabled or not gui.Enabled then return end
		local moveX = strike.Move.AbsolutePosition.X
		if math.abs(moveX - finalX) <= 5 then
			pressKey(Enum.KeyCode.Space)
			break
		end
		RunService.RenderStepped:Wait()
	end
end

-- 🔁 Vòng lặp chính
task.spawn(function()
	while autoEnabled do
		if gui.Enabled then
			local arrowList = gui.Arrow.List
			local strike = gui.Strike

			-- 🧭 Đọc các mũi tên cần nhấn
			local arrowSequence = {}
			for i = 1, #arrowList:GetChildren() do
				local arrowItem = arrowList:FindFirstChild(tostring(i))
				if arrowItem and arrowItem:FindFirstChild("ImageLabel") then
					local rotation = math.floor(arrowItem.ImageLabel.AbsoluteRotation + 0.5)
					local key = rotationToKey[rotation]
					if key then
						table.insert(arrowSequence, key)
					end
				end
			end

			-- 🕹️ Nhấn từng phím mũi tên
			task.wait(0.3)
			for _, keycode in ipairs(arrowSequence) do
				if not autoEnabled or not gui.Enabled then return end
				pressKey(keycode)
				task.wait(0.2)
			end

			waitAndPressSpace(strike)
		end

		-- ⏳ Đợi vòng tiếp theo hoặc chờ Arrow UI bật lại
		repeat
			task.wait(0.2)
		until gui.Enabled or not autoEnabled
	end

	print("❌ Đã dừng auto.")
end)
