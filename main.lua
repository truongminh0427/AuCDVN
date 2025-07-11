local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local deliveryPoints = workspace:WaitForChild("GrabDelivery"):WaitForChild("DeliveryPoints")

local boxStartPos = Vector3.new(831.759216, 20.4433231, -490.5047)
local tempPos
local KnitRemote = ReplicatedStorage:WaitForChild("KnitPackages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")
    :WaitForChild("JobService")
    :WaitForChild("RE")
    :WaitForChild("arrow")

local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer

local function pressKey(keycode)
    VirtualInputManager:SendKeyEvent(true, keycode, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, keycode, false, game)
end

-- Hàm chờ game load hoàn toàn sau khi Teleport
local function waitForGameLoaded()
	repeat
		task.wait()
	until game:IsLoaded() and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local REJOIN_DELAY = 540 -- 9 phút

task.delay(REJOIN_DELAY, function()
	--print("🔁 9 phút đã trôi qua → đang tự động rejoin game...")
	TeleportService:Teleport(game.PlaceId, player)
end)

player.OnKick:Connect(function()
	print("🚪 Bị kick khỏi server! Thử vào lại sau 5 giây...")
	task.wait(5)
	TeleportService:Teleport(game.PlaceId)
end)

-- Khi Teleport thành công và quay lại → nhấn 2 lần phím N
player.OnTeleport:Connect(function(state)
	if state == Enum.TeleportState.Started then
		print("🔁 Đang chuyển server...")
	elseif state == Enum.TeleportState.Completed then
		print("✅ Teleport hoàn tất → chờ game load để nhấn phím N")

		waitForGameLoaded()

		task.wait(2) -- đợi thêm tí cho chắc chắn
		--print("⌨️ Nhấn 2 lần phím N")
		pressKey(Enum.KeyCode.N)
		task.wait(1)
		pressKey(Enum.KeyCode.N)
	end
end)

local autoDeliveryEnabled = true -- 🔁 Biến bật/tắt tự động

local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function pressKey(keycode)
    VirtualInputManager:SendKeyEvent(true, keycode, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, keycode, false, game)
end

-- Hàm thiết lập theo dõi nhân vật mới
local function monitorCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")

	RunService.Heartbeat:Connect(function()
		if humanoid.Sit then
			--print("🪑 Nhân vật đang ngồi → nhảy lên!")
			pressKey(Enum.KeyCode.Space)
		end
	end)
end

-- Áp dụng khi nhân vật xuất hiện
if player.Character then
	monitorCharacter(player.Character)
end

-- Áp dụng lại sau khi respawn
player.CharacterAdded:Connect(monitorCharacter)




local function setPromptsHoldDurationZero()
    for _, p in ipairs(deliveryPoints:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            p.HoldDuration = 0
            --print("✅ HoldDuration set to 0:", p:GetFullName())
        end
    end
end

deliveryPoints.DescendantAdded:Connect(function(p)
    if autoDeliveryEnabled and p:IsA("ProximityPrompt") then
        p.HoldDuration = 0
        --print("🆕 ProximityPrompt mới - HoldDuration = 0:", p:GetFullName())
    end
end)

local function Teleport(destination)
    if autoDeliveryEnabled then

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    if not character.PrimaryPart then character.PrimaryPart = hrp end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    TweenService:Create(hrp, TweenInfo.new(0.5), {
        CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
    }):Play()
    task.wait(0.5)

    local flyTarget = destination + Vector3.new(0, 1, 0)
    local dist = (hrp.Position - flyTarget).Magnitude
    TweenService:Create(hrp, TweenInfo.new(dist / 50, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(flyTarget)
    }):Play()
    task.wait(dist / 50)

    character:SetPrimaryPartCFrame(CFrame.new(destination))

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end

    --print("✅ Đã dịch chuyển đến:", destination)
    if destination ~= boxStartPos then
        setPromptsHoldDurationZero()
        task.wait(0.5)
        pressKey(Enum.KeyCode.E)
        --print("🟢 Đã mô phỏng phím E")
    elseif destination == boxStartPos then
        task.wait(0.5)
        local box = workspace.GrabDelivery.Box:FindFirstChild("Start")
        if box then
            box.ProximityPrompt.HoldDuration = 0 
        end
        task.wait(0.5)
        pressKey(Enum.KeyCode.F)
    end
    end
end


KnitRemote.OnClientEvent:Connect(function(...)
    if not autoDeliveryEnabled then return end
    local args = {...}
    local target = args[2]
    --print("📡 arrow RemoteEvent nhận args[2]:", target)

    if typeof(target) == "Vector3" then
        task.delay(0.5, function() 
       local var = workspace:FindFirstChild("Var")
       if var then
	  var.Position = target
	else
        local newPart = Instance.new("Part")
        newPart.Name = "Var"
        newPart.Size = Vector3.new(1, 1, 1)
        newPart.Position = target
        newPart.Anchored = true
        newPart.Parent = workspace
	end
        Teleport(target) 
        
        end)
    elseif typeof(target) == "string" and string.find(target, ",") then
        local x, y, z = unpack(table.pack(unpack(string.split(target, ","))))
        if x and y and z then
            task.delay(0.5, function()
                tempPos = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
                Teleport(tempPos)
            end)
        else
            warn("❌ Không thể phân tích tọa độ:", target)
        end
    else
        --warn("⚠️ args[2] không hợp lệ:", target)
        Teleport(boxStartPos)
        
    end
end)

local function checkArrowSpawnChildren()
    local arrowSpawn = workspace:FindFirstChild("ArrowSpawn")
    if not arrowSpawn then
        warn("❌ Không tìm thấy ArrowSpawn trong workspace.")
        return
    end

    local children = arrowSpawn:GetChildren()
    if #children == 0 then
        --print("ℹ️ ArrowSpawn không chứa tệp con nào.")
        Teleport(boxStartPos)
    else
    local part = workspace:FindFirstChild("Var")
if part then
	Teleport(part.Position)
else
	 Teleport(boxStartPos)
end

       
    end
end



-- ⚙️ Khởi tạo
if autoDeliveryEnabled then
    checkArrowSpawnChildren()
    Teleport(boxStartPos)
    workspace.GrabDelivery.Box.Start.ProximityPrompt.HoldDuration = 0
    --print("🔧 HoldDuration BoxStart = 0")
    task.wait(0.5)
    pressKey(Enum.KeyCode.F)
    --print("🟢 Đã mô phỏng phím F")
    setPromptsHoldDurationZero()
end

--print("✅ Auto Grab Delivery is running...")

spawn(function()
    while autoDeliveryEnabled do
        checkArrowSpawnChildren()
        task.wait(3)
    end
end)
