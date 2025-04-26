
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotifUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling


local notif = {}
notif.List = {}

local notificationWidth = 361
local notificationHeight = 165
local padding = 10
local displayTime = 4


local icons = {
	Info = "rbxassetid://112082878863231",
	Warn = "rbxassetid://117107314745025", 
	Error = "rbxassetid://77067602950967" 
}


local function updateNotificationPositions()
	for i, notifFrame in ipairs(notif.List) do
		local targetY = -((notificationHeight + padding) * (i - 1) + padding)
		notifFrame:TweenPosition(
			UDim2.new(1, -10, 1, targetY),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quart,
			0.4,
			true
		)
	end
end

local function createNotification(contentText, titleText, notifType)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, notificationWidth, 0, notificationHeight)
	frame.Position = UDim2.new(1, 10, 1, 110)
	frame.AnchorPoint = Vector2.new(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	frame.BackgroundTransparency = 0.16
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	frame.ClipsDescendants = true

	local uiCorner = Instance.new("UICorner")
	uiCorner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Parent = frame
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0.0249, 0, 0.0606, 0)
	title.Size = UDim2.new(0, 275, 0, 40)
	title.Font = Enum.Font.SourceSansBold
	title.Text = titleText or "Notification"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextScaled = true
	title.TextWrapped = true
	title.TextXAlignment = Enum.TextXAlignment.Left

	local content = Instance.new("TextLabel")
	content.Name = "Content"
	content.Parent = frame
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0.0249, 0, 0.3757, 0)
	content.Size = UDim2.new(0, 338, 0, 82)
	content.Font = Enum.Font.SourceSansBold
	content.Text = contentText or "Notification Contnet"
	content.TextColor3 = Color3.new(1, 1, 1)
	content.TextSize = 23
	content.TextWrapped = true
	content.TextXAlignment = Enum.TextXAlignment.Left
	content.TextYAlignment = Enum.TextYAlignment.Top

	local image = Instance.new("ImageLabel")
	image.Parent = frame
	image.BackgroundTransparency = 1
	image.Position = UDim2.new(0.8171, 0, 0.0606, 0)
	image.Size = UDim2.new(0, 52, 0, 52)
	image.Image = icons[notifType] or icons.Info 

	table.insert(notif.List, 1, frame)

	updateNotificationPositions()

	frame:TweenPosition(
		UDim2.new(1, -10, 1, -padding),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Back,
		0.5,
		true
	)

	task.delay(displayTime, function()
		frame:TweenPosition(
			UDim2.new(1, 10, 1, frame.Position.Y.Offset + 20),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Quad,
			0.5,
			true
		)
		task.wait(0.5)
		frame:Destroy()

		for i, v in ipairs(notif.List) do
			if v == frame then
				table.remove(notif.List, i)
				break
			end
		end

		updateNotificationPositions()
	end)
end


function notif:Info(content, title)
	createNotification(content or "Uh?", title or "Notification", "Info")
end

function notif:Warn(content, title)
	createNotification(content or "Uh?", title or "Warning", "Warn")
end

function notif:Error(content, title)
	createNotification(content or "Uh?", title or "Error", "Error")
end
