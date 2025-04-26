--[[
    Enhanced Notification System
    - Improved visuals with UIStroke and refined layout.
    - Smoother animations.
    - Uses UIPadding for better internal spacing.
]]

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local CONFIG = {
    NotificationWidth = 350,
    NotificationHeight = 80,  -- Base height, might grow with content
    Padding = 10,             -- Space between notifications
    InternalPadding = 10,     -- Padding inside the notification frame
    IconSize = 40,
    DisplayTime = 5,          -- How long notifications stay visible

    BackgroundColor = Color3.fromRGB(45, 45, 45),
    BackgroundTransparency = 0.1,
    StrokeColor = Color3.fromRGB(80, 80, 80),
    StrokeThickness = 1,
    TextColor = Color3.fromRGB(240, 240, 240),

    TitleFont = Enum.Font.SourceSansSemibold,
    TitleSize = 18,
    ContentFont = Enum.Font.SourceSans,
    ContentSize = 15,

    EntryEasingStyle = Enum.EasingStyle.Back,
    EntryEasingDirection = Enum.EasingDirection.Out,
    EntryTime = 0.5,

    ExitEasingStyle = Enum.EasingStyle.Quad, -- Changed for a smoother exit
    ExitEasingDirection = Enum.EasingDirection.In,
    ExitTime = 0.4,

    Icons = {
        Info = "rbxassetid://112082878863231", -- Example: Using Roblox default icons
        Warn = "rbxassetid://117107314745025",
        Error = "rbxassetid://77067602950967",
    }
}

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EnhancedNotifUI"
screenGui.Parent = playerGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999 -- Make sure it renders above most other UI

-- NOTE: getgenv() is typically used in exploit environments.
-- For regular game development, consider using ModuleScripts or local variables within one script.
getgenv().notif = {}
getgenv().notif.List = {}

-- Function to update notification positions smoothly
local function updateNotificationPositions()
    local currentY = -CONFIG.Padding -- Start position for the topmost notification
    for i = 1, #getgenv().notif.List do
        local notifFrame = getgenv().notif.List[i]
        if not notifFrame or not notifFrame.Parent then -- Check if frame still exists
             table.remove(getgenv().notif.List, i)
             i = i - 1 -- Adjust index after removal
             continue
        end

        local targetPos = UDim2.new(
            1, -CONFIG.Padding,          -- X: Right side with padding
            1, currentY                  -- Y: Calculated stacked position
        )

        -- Use Sine for repositioning for a slightly softer feel than Quart
        notifFrame:TweenPosition(
            targetPos,
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Sine,
            0.3, -- Faster repositioning
            true
        )
        -- Update Y position for the next notification, considering its actual height
        currentY = currentY - (notifFrame.AbsoluteSize.Y + CONFIG.Padding)
    end
end


-- Function to create a single notification
local function createNotification(contentText, titleText, notifType)
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    -- Start off-screen to the right, slightly below the final position for the Back easing effect
    frame.Position = UDim2.new(1, CONFIG.NotificationWidth + 50, 1, 0)
    frame.Size = UDim2.new(0, CONFIG.NotificationWidth, 0, CONFIG.NotificationHeight) -- Initial height
    frame.AnchorPoint = Vector2.new(1, 1) -- Anchor to BottomRight
    frame.BackgroundColor3 = CONFIG.BackgroundColor
    frame.BackgroundTransparency = CONFIG.BackgroundTransparency
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.LayoutOrder = -#getgenv().notif.List -- Ensure new notifications appear on top visually if siblings overlap briefly
    frame.Parent = screenGui
    frame.AutomaticSize = Enum.AutomaticSize.Y -- Allow frame height to adjust to content

    -- Styling
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 6)
    uiCorner.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = CONFIG.StrokeColor
    uiStroke.Thickness = CONFIG.StrokeThickness
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = frame

    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, CONFIG.InternalPadding)
    uiPadding.PaddingBottom = UDim.new(0, CONFIG.InternalPadding)
    uiPadding.PaddingLeft = UDim.new(0, CONFIG.InternalPadding)
    uiPadding.PaddingRight = UDim.new(0, CONFIG.InternalPadding)
    uiPadding.Parent = frame

    -- Icon
    local iconImage = Instance.new("ImageLabel")
    iconImage.Name = "Icon"
    iconImage.Size = UDim2.new(0, CONFIG.IconSize, 0, CONFIG.IconSize)
    iconImage.BackgroundTransparency = 1
    iconImage.Image = CONFIG.Icons[notifType] or CONFIG.Icons.Info
    iconImage.ScaleType = Enum.ScaleType.Fit
    iconImage.AnchorPoint = Vector2.new(0, 0.5) -- Anchor to vertical center-left
    iconImage.Position = UDim2.new(0, 0, 0.5, 0) -- Position left, vertical center (relative to padding)
    iconImage.Parent = frame

    local iconAspectRatio = Instance.new("UIAspectRatioConstraint")
    iconAspectRatio.AspectRatio = 1.0
    iconAspectRatio.DominantAxis = Enum.DominantAxis.Height
    iconAspectRatio.Parent = iconImage

    -- Text Container (to hold title and content, allowing icon to be separate)
    local textFrame = Instance.new("Frame")
    textFrame.Name = "TextContainer"
    textFrame.BackgroundTransparency = 1
    textFrame.Size = UDim2.new(1, -(CONFIG.IconSize + CONFIG.InternalPadding + 5), 1, 0) -- Fill width minus icon and some spacing
    textFrame.Position = UDim2.new(0, CONFIG.IconSize + 5, 0, 0) -- Position next to icon
    textFrame.Parent = frame
    textFrame.AutomaticSize = Enum.AutomaticSize.Y -- Let this frame adjust height based on text

    local textListLayout = Instance.new("UIListLayout")
    textListLayout.FillDirection = Enum.FillDirection.Vertical
    textListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textListLayout.Padding = UDim.new(0, 2) -- Small padding between title and content
    textListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    textListLayout.Parent = textFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = titleText or "Notification"
    title.Font = CONFIG.TitleFont
    title.TextSize = CONFIG.TitleSize
    title.TextColor3 = CONFIG.TextColor
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.AutomaticSize = Enum.AutomaticSize.Y -- Let height adjust based on text
    title.Size = UDim2.new(1, 0, 0, CONFIG.TitleSize) -- Width = 100%, initial height based on font size
    title.LayoutOrder = 1
    title.Parent = textFrame

    -- Content
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Text = contentText or "Notification Content"
    content.Font = CONFIG.ContentFont
    content.TextSize = CONFIG.ContentSize
    content.TextColor3 = CONFIG.TextColor
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y -- Let height adjust based on text
    content.Size = UDim2.new(1, 0, 0, CONFIG.ContentSize) -- Width = 100%, initial height based on font size
    content.LayoutOrder = 2
    content.Parent = textFrame

    -- Add to the list and update positions
    table.insert(getgenv().notif.List, 1, frame)
    updateNotificationPositions() -- Shift existing notifications down first

    -- Entry Animation
    -- Need to calculate the correct initial target position based on the list order AFTER updating positions
    local initialTargetY = -CONFIG.Padding
    local initialTargetPos = UDim2.new(1, -CONFIG.Padding, 1, initialTargetY)

    frame:TweenPosition(
        initialTargetPos,
        CONFIG.EntryEasingDirection,
        CONFIG.EntryEasingStyle,
        CONFIG.EntryTime,
        true
    )

    -- Schedule removal
    task.delay(CONFIG.DisplayTime, function()
        -- Check if frame still exists before trying to tween/destroy
        if frame and frame.Parent then
            -- Exit Animation (Slide out to the right and fade slightly)
            local exitPos = UDim2.new(1, CONFIG.NotificationWidth + 50, frame.Position.Y.Scale, frame.Position.Y.Offset)

            -- Use TweenService for multiple property tweening (optional, but good practice for complex fades)
            local tweenInfo = TweenInfo.new(CONFIG.ExitTime, CONFIG.ExitEasingStyle, CONFIG.ExitEasingDirection)
            local tween = game:GetService("TweenService"):Create(frame, tweenInfo, {Position = exitPos, BackgroundTransparency = 1})
            local strokeTween = game:GetService("TweenService"):Create(uiStroke, tweenInfo, {Transparency = 1}) -- Fade stroke too
            local iconTween = game:GetService("TweenService"):Create(iconImage, tweenInfo, {ImageTransparency = 1})
            local titleTween = game:GetService("TweenService"):Create(title, tweenInfo, {TextTransparency = 1})
            local contentTween = game:GetService("TweenService"):Create(content, tweenInfo, {TextTransparency = 1})

            tween:Play()
            strokeTween:Play()
            iconTween:Play()
            titleTween:Play()
            contentTween:Play()

            -- Wait for the tween to finish before destroying and updating
            task.wait(CONFIG.ExitTime)

            -- Remove from list
            for i, v in ipairs(getgenv().notif.List) do
                if v == frame then
                    table.remove(getgenv().notif.List, i)
                    break
                end
            end

            -- Destroy the frame *after* removing from list
            frame:Destroy()

            -- Update positions of remaining notifications
            updateNotificationPositions()
        end
    end)
end

-- API Functions
getgenv().notif.Info = function(content, title)
    createNotification(content or "Information", title or "Info", "Info")
end

getgenv().notif.Warn = function(content, title)
    createNotification(content or "Warning occurred", title or "Warning", "Warn")
end

getgenv().notif.Error = function(content, title)
    createNotification(content or "An error occurred", title or "Error", "Error")
end


-- Example Usage (You can run these in your command bar/script):
task.wait(2)
getgenv().notif.Info("This is an informational message.", "System Update")
task.wait(0.5)
getgenv().notif.Warn("This is a warning message with slightly longer content to test wrapping and automatic sizing.", "Potential Issue")
task.wait(0.5)
getgenv().notif.Error("This is an error message.", "Critical Failure")
task.wait(1)
getgenv().notif.Info("Another message to show stacking.")

task.wait(1)
getgenv().notif.Warn()
