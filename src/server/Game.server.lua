local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local messageEvent = ReplicatedStorage:WaitForChild("GameMessage")
local SNACK_GOAL = 3
local CATCH_DISTANCE = 7
local MONSTER_SPEED = 13

-- Keep the prototype self-contained: the world is built from ordinary Parts.
Lighting.ClockTime = 0
Lighting.Brightness = 1
Lighting.Ambient = Color3.fromRGB(34, 30, 48)
Lighting.OutdoorAmbient = Color3.fromRGB(12, 10, 20)
Lighting.FogColor = Color3.fromRGB(38, 29, 52)
Lighting.FogStart = 35
Lighting.FogEnd = 145

local oldWorld = Workspace:FindFirstChild("MidnightMunchies")
if oldWorld then oldWorld:Destroy() end
local world = Instance.new("Folder")
world.Name = "MidnightMunchies"
world.Parent = Workspace

local function part(name, size, position, color, material, parent)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.Anchored = true
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent or world
	return object
end

part("Shop Floor", Vector3.new(120, 1, 90), Vector3.new(0, -0.5, 0), Color3.fromRGB(55, 48, 62), Enum.Material.Slate)
part("Back Wall", Vector3.new(120, 18, 2), Vector3.new(0, 8.5, -45), Color3.fromRGB(39, 31, 47), Enum.Material.Brick)
part("Left Wall", Vector3.new(2, 18, 90), Vector3.new(-60, 8.5, 0), Color3.fromRGB(39, 31, 47), Enum.Material.Brick)
part("Right Wall", Vector3.new(2, 18, 90), Vector3.new(60, 8.5, 0), Color3.fromRGB(39, 31, 47), Enum.Material.Brick)
-- Two front wall sections leave a generous, obvious exit opening.
part("Front Left Wall", Vector3.new(43, 18, 2), Vector3.new(-38.5, 8.5, 45), Color3.fromRGB(39, 31, 47), Enum.Material.Brick)
part("Front Right Wall", Vector3.new(43, 18, 2), Vector3.new(38.5, 8.5, 45), Color3.fromRGB(39, 31, 47), Enum.Material.Brick)

local exit = part("EXIT - need 3 snacks", Vector3.new(30, 12, 2), Vector3.new(0, 5.5, 45), Color3.fromRGB(30, 255, 130), Enum.Material.Neon)
exit.Transparency = 0.42
exit.CanCollide = false
local exitLight = Instance.new("PointLight")
exitLight.Color = Color3.fromRGB(30, 255, 130)
exitLight.Range = 22
exitLight.Brightness = 2
exitLight.Parent = exit

-- Makes the shop feel like a cluttered maze while leaving walkable lanes.
for _, location in ipairs({
	Vector3.new(-32, 3, -20), Vector3.new(-8, 3, -20), Vector3.new(20, 3, -20),
	Vector3.new(-32, 3, 5), Vector3.new(-8, 3, 5), Vector3.new(20, 3, 5),
	Vector3.new(-32, 3, 28), Vector3.new(20, 3, 28),
}) do
	local shelf = part("Suspiciously Tall Snack Shelf", Vector3.new(13, 6, 3), location, Color3.fromRGB(92, 48, 71), Enum.Material.Wood)
	local trim = part("Shelf neon trim", Vector3.new(13.2, 0.25, 3.2), location + Vector3.new(0, 2.8, 0), Color3.fromRGB(255, 88, 160), Enum.Material.Neon)
	trim.CanCollide = false
	local sign = Instance.new("PointLight")
	sign.Color = Color3.fromRGB(255, 78, 140)
	sign.Range = 10
	sign.Brightness = 0.55
	sign.Parent = shelf
end

for _, position in ipairs({Vector3.new(-48, 4, -35), Vector3.new(48, 4, -35), Vector3.new(-48, 4, 25), Vector3.new(48, 4, 25)}) do
	local lamp = part("Flickery-looking lamp", Vector3.new(1, 1, 1), position, Color3.fromRGB(255, 198, 102), Enum.Material.Neon)
	lamp.Shape = Enum.PartType.Ball
	lamp.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = lamp.Color
	light.Range = 24
	light.Brightness = 1.4
	light.Parent = lamp
end

local snackPositions = {
	Vector3.new(-45, 1.5, -5),
	Vector3.new(8, 1.5, -35),
	Vector3.new(43, 1.5, 20),
}
local snackNames = {"Doom Donut", "Cursed Cheese Puff", "Haunted Juice Box"}
local collectedByPlayer = {}

local function playerCount(player)
	return collectedByPlayer[player] or 0
end

for index, position in ipairs(snackPositions) do
	local snack = part(snackNames[index], Vector3.new(2.4, 2.4, 2.4), position, Color3.fromRGB(255, 190, 45), Enum.Material.Neon)
	snack.Shape = Enum.PartType.Ball
	snack.CanCollide = false
	local sparkle = Instance.new("PointLight")
	sparkle.Color = snack.Color
	sparkle.Range = 12
	sparkle.Brightness = 1.5
	sparkle.Parent = snack
	local taken = false
	snack.Touched:Connect(function(hit)
		if taken then return end
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player then return end
		taken = true
		collectedByPlayer[player] = math.min(SNACK_GOAL, playerCount(player) + 1)
		messageEvent:FireClient(player, "progress", playerCount(player), SNACK_GOAL, snackNames[index] .. " acquired! Probably safe to eat.")
		snack:Destroy()
	end)
end

local function makeMonster()
	local model = Instance.new("Model")
	model.Name = "The Snack Goblin"
	model.Parent = world

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.CanCollide = false
	root.Anchored = false
	root.Position = Vector3.new(0, 4, -32)
	root.Parent = model

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(3.2, 4, 2)
	torso.Color = Color3.fromRGB(92, 210, 115)
	torso.Material = Enum.Material.SmoothPlastic
	torso.Anchored = false
	torso.Position = root.Position
	torso.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(3, 3, 3)
	head.Color = Color3.fromRGB(130, 239, 143)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = false
	head.Position = root.Position + Vector3.new(0, 3.4, 0)
	head.Parent = model

	local function weld(a, b)
		local joint = Instance.new("WeldConstraint")
		joint.Part0 = a
		joint.Part1 = b
		joint.Parent = a
	end
	weld(root, torso)
	weld(torso, head)

	local face = Instance.new("BillboardGui")
	face.Name = "RidiculousFace"
	face.Size = UDim2.fromOffset(150, 70)
	face.StudsOffset = Vector3.new(0, 0.2, -1.55)
	face.AlwaysOnTop = true
	face.Parent = head
	local expression = Instance.new("TextLabel")
	expression.Size = UDim2.fromScale(1, 1)
	expression.BackgroundTransparency = 1
	expression.Text = "● ᴥ ●"
	expression.TextColor3 = Color3.fromRGB(32, 22, 38)
	expression.TextScaled = true
	expression.Font = Enum.Font.FredokaOne
	expression.Parent = face

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = "Snack Goblin (probably friendly)"
	humanoid.WalkSpeed = MONSTER_SPEED
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.Parent = model
	model.PrimaryPart = root
	return model, humanoid, root
end

local monster, monsterHumanoid, monsterRoot = makeMonster()
local jokes = {
	"The Snack Goblin got you! Its stand-up routine is a crime.",
	"Caught! The goblin says: 'I came, I saw, I con-snacked.'",
	"Boo! The goblin's favorite movie is Snack to the Future.",
}
local lastCatch = {}

local function getNearestPlayer()
	local closestPlayer, closestDistance
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 then
			local distance = (root.Position - monsterRoot.Position).Magnitude
			if not closestDistance or distance < closestDistance then
				closestPlayer, closestDistance = player, distance
			end
		end
	end
	return closestPlayer, closestDistance
end

local function tryEscape(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	if not player then return end
	if playerCount(player) >= SNACK_GOAL then
		messageEvent:FireClient(player, "win", SNACK_GOAL, SNACK_GOAL, "YOU ESCAPED! The shop is closed forever. (Probably.)")
	else
		messageEvent:FireClient(player, "notice", playerCount(player), SNACK_GOAL, "The exit is locked! Find all 3 cursed snacks first.")
	end
end
exit.Touched:Connect(tryEscape)

Players.PlayerAdded:Connect(function(player)
	collectedByPlayer[player] = 0
	player.CharacterAdded:Connect(function(character)
		task.wait(0.3)
		local root = character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = CFrame.new(0, 4, 36) end
		messageEvent:FireClient(player, "progress", playerCount(player), SNACK_GOAL, "Welcome to Midnight Munchies. The customer service desk is... not staffed.")
	end)
end)
Players.PlayerRemoving:Connect(function(player)
	collectedByPlayer[player] = nil
	lastCatch[player] = nil
end)

-- Recalculate a short path regularly so the goblin can navigate the shelves.
task.spawn(function()
	while monster.Parent do
		local target, distance = getNearestPlayer()
		if target and target.Character then
			local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 6, AgentCanJump = true})
				local ok = pcall(function() path:ComputeAsync(monsterRoot.Position, targetRoot.Position) end)
				local waypoints = ok and path.Status == Enum.PathStatus.Success and path:GetWaypoints() or nil
				if waypoints and #waypoints > 1 then
					monsterHumanoid:MoveTo(waypoints[2].Position)
				else
					monsterHumanoid:MoveTo(targetRoot.Position)
				end
				if distance and distance < CATCH_DISTANCE and (not lastCatch[target] or os.clock() - lastCatch[target] > 4) then
					lastCatch[target] = os.clock()
					messageEvent:FireClient(target, "scare", playerCount(target), SNACK_GOAL, jokes[math.random(1, #jokes)])
					local character = target.Character
					local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
					if playerRoot then playerRoot.CFrame = CFrame.new(0, 4, 36) end
				end
			end
		end
		task.wait(1.1)
	end
end)
