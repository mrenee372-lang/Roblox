local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local messageEvent = ReplicatedStorage:WaitForChild("GameMessage")
local gui = Instance.new("ScreenGui")
gui.Name = "MidnightMunchiesHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "StatusPanel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 18)
panel.Size = UDim2.new(0.82, 0, 0, 112)
panel.BackgroundColor3 = Color3.fromRGB(25, 18, 34)
panel.BackgroundTransparency = 0.12
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 94, 165)
stroke.Thickness = 2
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 14, 0, 7)
title.Size = UDim2.new(1, -28, 0, 34)
title.Font = Enum.Font.FredokaOne
title.Text = "MIDNIGHT MUNCHIES  👻🍕"
title.TextColor3 = Color3.fromRGB(255, 218, 112)
title.TextScaled = true
title.Parent = panel

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 14, 0, 46)
status.Size = UDim2.new(1, -28, 0, 54)
status.Font = Enum.Font.GothamBold
status.Text = "Find 3 cursed snacks. Don't let the Snack Goblin catch you!"
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextScaled = true
status.TextWrapped = true
status.Parent = panel

local banner = Instance.new("TextLabel")
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.Position = UDim2.fromScale(0.5, 0.67)
banner.Size = UDim2.new(0.84, 0, 0, 80)
banner.BackgroundColor3 = Color3.fromRGB(100, 25, 64)
banner.BackgroundTransparency = 0.1
banner.Font = Enum.Font.FredokaOne
banner.TextColor3 = Color3.fromRGB(255, 245, 220)
banner.TextScaled = true
banner.TextWrapped = true
banner.Visible = false
banner.Parent = gui
local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(0, 16)
bannerCorner.Parent = banner

local function showBanner(text, color)
	banner.Text = text
	banner.BackgroundColor3 = color or Color3.fromRGB(100, 25, 64)
	banner.Visible = true
	banner.TextTransparency = 0
	banner.BackgroundTransparency = 0.1
	local fade = TweenService:Create(banner, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 2), {
		TextTransparency = 1,
		BackgroundTransparency = 1,
	})
	fade:Play()
	fade.Completed:Once(function()
		banner.Visible = false
	end)
end

messageEvent.OnClientEvent:Connect(function(kind, count, goal, text)
	if kind == "progress" then
		status.Text = string.format("Cursed snacks: %d / %d\n%s", count, goal, text)
	elseif kind == "notice" then
		status.Text = string.format("Cursed snacks: %d / %d", count, goal)
		showBanner(text, Color3.fromRGB(105, 70, 30))
	elseif kind == "scare" then
		status.Text = string.format("Cursed snacks: %d / %d  ·  BEHIND YOU!", count, goal)
		showBanner(text, Color3.fromRGB(126, 28, 66))
	elseif kind == "win" then
		status.Text = "Cursed snacks: 3 / 3 · YOU WIN!"
		showBanner(text, Color3.fromRGB(28, 112, 78))
	end
end)
