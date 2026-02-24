local Library = {
    Flags = {},
    Theme = "Discord",
    SectionsOpened = true,
    AccentColor = Color3.fromRGB(88, 101, 242) -- Discord blurple
}

Library.flags = Library.Flags
Library.theme = Library.Theme

local Themes = {
    ["Discord"] = {
        -- Main
        Background = Color3.fromRGB(54, 57, 63),
        BackgroundSecondary = Color3.fromRGB(47, 49, 54),
        BackgroundTertiary = Color3.fromRGB(32, 34, 37),
        BackgroundFloating = Color3.fromRGB(24, 25, 28),
        
        -- Accents
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(71, 82, 196),
        AccentLight = Color3.fromRGB(123, 139, 255),
        
        -- Text
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(185, 187, 190),
        TextMuted = Color3.fromRGB(142, 146, 151),
        
        -- Interactive
        Hover = Color3.fromRGB(66, 70, 77),
        Active = Color3.fromRGB(60, 63, 69),
        Selected = Color3.fromRGB(57, 60, 67),
        
        -- Borders
        Border = Color3.fromRGB(32, 34, 37),
        BorderLight = Color3.fromRGB(66, 70, 77),
        
        -- Status
        Success = Color3.fromRGB(59, 165, 93),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        
        -- Components
        ToggleOn = Color3.fromRGB(88, 101, 242),
        ToggleOff = Color3.fromRGB(114, 118, 125),
        SliderFill = Color3.fromRGB(88, 101, 242),
        SliderBg = Color3.fromRGB(79, 84, 92),
        InputBg = Color3.fromRGB(64, 68, 75),
        InputPlaceholder = Color3.fromRGB(114, 118, 125),
        
        -- Scrollbar
        Scrollbar = Color3.fromRGB(32, 34, 37),
        ScrollbarThumb = Color3.fromRGB(24, 25, 28)
    }
}

-- Services
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utility Functions
local function MakeDraggable(topbar, main)
    local dragging, dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

local function Tween(object, info, properties)
    return TweenService:Create(object, info, properties)
end

-- Notification System
local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = HttpService:GenerateGUID(true)
NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotificationGui.Parent = CoreGui

local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Position = UDim2.new(1, -10, 1, -10)
NotificationHolder.AnchorPoint = Vector2.new(1, 1)
NotificationHolder.Size = UDim2.new(0, 300, 1, 0)
NotificationHolder.Parent = NotificationGui

local NotificationList = Instance.new("UIListLayout")
NotificationList.Padding = UDim.new(0, 8)
NotificationList.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationList.SortOrder = Enum.SortOrder.LayoutOrder
NotificationList.Parent = NotificationHolder

function Library:Notify(info)
    info = info or {}
    local title = info.Title or "Notification"
    local description = info.Description or ""
    local duration = info.Duration or 3
    local type = info.Type or "Info" -- Info, Success, Warning, Error
    
    local Theme = Themes[Library.Theme]
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = Theme.BackgroundFloating
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(0, 280, 0, 0)
    notification.ClipsDescendants = true
    notification.LayoutOrder = -tick()
    notification.Parent = NotificationHolder
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1
    stroke.Parent = notification
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 3, 1, 0)
    
    if type == "Success" then
        accentBar.BackgroundColor3 = Theme.Success
    elseif type == "Warning" then
        accentBar.BackgroundColor3 = Theme.Warning
    elseif type == "Error" then
        accentBar.BackgroundColor3 = Theme.Error
    else
        accentBar.BackgroundColor3 = Theme.Accent
    end
    accentBar.Parent = notification
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 12, 0, 0)
    content.Size = UDim2.new(1, -24, 1, 0)
    content.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 0, 0, 8)
    titleLabel.Size = UDim2.new(1, 0, 0, 18)
    titleLabel.Parent = content
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = description
    descLabel.TextColor3 = Theme.TextSecondary
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextWrapped = true
    descLabel.BackgroundTransparency = 1
    descLabel.Position = UDim2.new(0, 0, 0, 28)
    descLabel.Size = UDim2.new(1, 0, 0, 40)
    descLabel.Parent = content
    
    -- Calculate height based on text
    local textHeight = math.max(60, 28 + descLabel.TextBounds.Y + 12)
    notification.Size = UDim2.new(0, 280, 0, 0)
    
    -- Animate in
    Tween(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 280, 0, textHeight)
    }):Play()
    
    -- Auto remove
    task.delay(duration, function()
        Tween(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 280, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- Main Window Creation
function Library:Window(info)
    info = info or {}
    local title = info.Title or "Modular UI"
    local size = info.Size or UDim2.new(0, 700, 0, 450)
    
    local Theme = Themes[Library.Theme]
    local Window = {}
    
    -- Main GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = HttpService:GenerateGUID(true)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = CoreGui
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    Main.Size = size
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = Main
    
    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.BackgroundColor3 = Theme.BackgroundSecondary
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.Parent = Main
    
    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 8)
    TopbarCorner.Parent = Topbar
    
    -- Fix corners
    local TopbarFix = Instance.new("Frame")
    TopbarFix.BackgroundColor3 = Theme.BackgroundSecondary
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Position = UDim2.new(0, 0, 1, -8)
    TopbarFix.Size = UDim2.new(1, 0, 0, 8)
    TopbarFix.Parent = Topbar
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Parent = Topbar
    
    -- Window Controls
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.BackgroundTransparency = 1
    Controls.Position = UDim2.new(1, -80, 0, 0)
    Controls.Size = UDim2.new(0, 80, 1, 0)
    Controls.Parent = Topbar
    
    local ControlsList = Instance.new("UIListLayout")
    ControlsList.FillDirection = Enum.FillDirection.Horizontal
    ControlsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsList.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsList.Padding = UDim.new(0, 8)
    ControlsList.Parent = Controls
    
    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "−"
    MinimizeBtn.TextColor3 = Theme.TextSecondary
    MinimizeBtn.TextSize = 18
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Parent = Controls
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextSecondary
    CloseBtn.TextSize = 20
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Parent = Controls
    
    -- Hover effects for controls
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextPrimary}):Play()
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Theme.Error}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    local Minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, size.X.Offset, 0, 40)
            }):Play()
        else
            Tween(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = size
            }):Play()
        end
    end)
    
    -- Make draggable
    MakeDraggable(Topbar, Main)
    
    -- Content Container
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 40)
    Content.Size = UDim2.new(1, 0, 1, -40)
    Content.Parent = Main
    
    -- Left Sidebar (Collapsible)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = Theme.BackgroundTertiary
    Sidebar.BorderSizePixel = 0
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.Parent = Content
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 0)
    SidebarCorner.Parent = Sidebar
    
    local SidebarFix = Instance.new("Frame")
    SidebarFix.BackgroundColor3 = Theme.BackgroundTertiary
    SidebarFix.BorderSizePixel = 0
    SidebarFix.Size = UDim2.new(1, 0, 0, 8)
    SidebarFix.Position = UDim2.new(0, 0, 0, -8)
    SidebarFix.Parent = Sidebar
    
    -- Sidebar Header
    local SidebarHeader = Instance.new("Frame")
    SidebarHeader.Name = "Header"
    SidebarHeader.BackgroundColor3 = Theme.BackgroundTertiary
    SidebarHeader.BorderSizePixel = 0
    SidebarHeader.Size = UDim2.new(1, 0, 0, 40)
    SidebarHeader.Parent = Sidebar
    
    local SidebarTitle = Instance.new("TextLabel")
    SidebarTitle.Name = "Title"
    SidebarTitle.Font = Enum.Font.GothamBold
    SidebarTitle.Text = "SECTIONS"
    SidebarTitle.TextColor3 = Theme.TextMuted
    SidebarTitle.TextSize = 11
    SidebarTitle.TextXAlignment = Enum.TextXAlignment.Left
    SidebarTitle.BackgroundTransparency = 1
    SidebarTitle.Position = UDim2.new(0, 16, 0, 0)
    SidebarTitle.Size = UDim2.new(1, -32, 1, 0)
    SidebarTitle.Parent = SidebarHeader
    
    -- Collapse Button
    local CollapseBtn = Instance.new("TextButton")
    CollapseBtn.Name = "Collapse"
    CollapseBtn.Font = Enum.Font.GothamBold
    CollapseBtn.Text = "◀"
    CollapseBtn.TextColor3 = Theme.TextMuted
    CollapseBtn.TextSize = 12
    CollapseBtn.BackgroundTransparency = 1
    CollapseBtn.Position = UDim2.new(1, -30, 0, 0)
    CollapseBtn.Size = UDim2.new(0, 30, 1, 0)
    CollapseBtn.Parent = SidebarHeader
    
    -- Sidebar Scrolling
    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Name = "Scroll"
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.Position = UDim2.new(0, 0, 0, 40)
    SidebarScroll.Size = UDim2.new(1, 0, 1, -40)
    SidebarScroll.ScrollBarThickness = 4
    SidebarScroll.ScrollBarImageColor3 = Theme.ScrollbarThumb
    SidebarScroll.CanvasSize = UDim2.new()
    SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidebarScroll.Parent = Sidebar
    
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 4)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Parent = SidebarScroll
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingBottom = UDim.new(0, 8)
    SidebarPadding.Parent = SidebarScroll
    
    -- Collapse functionality
    local SidebarCollapsed = false
    CollapseBtn.MouseButton1Click:Connect(function()
        SidebarCollapsed = not SidebarCollapsed
        
        if SidebarCollapsed then
            Tween(CollapseBtn, TweenInfo.new(0.2), {Rotation = 180}):Play()
            Tween(Sidebar, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 40, 1, 0)
            }):Play()
            SidebarTitle.Visible = false
            SidebarScroll.Visible = false
        else
            Tween(CollapseBtn, TweenInfo.new(0.2), {Rotation = 0}):Play()
            Tween(Sidebar, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 200, 1, 0)
            }):Play()
            task.delay(0.2, function()
                SidebarTitle.Visible = true
                SidebarScroll.Visible = true
            end)
        end
    end)
    
    -- Main Area (Right side)
    local MainArea = Instance.new("Frame")
    MainArea.Name = "MainArea"
    MainArea.BackgroundColor3 = Theme.Background
    MainArea.BorderSizePixel = 0
    MainArea.Position = UDim2.new(0, 200, 0, 0)
    MainArea.Size = UDim2.new(1, -200, 1, 0)
    MainArea.Parent = Content
    
    -- Resizer handle
    local Resizer = Instance.new("TextButton")
    Resizer.Name = "Resizer"
    Resizer.BackgroundColor3 = Theme.Border
    Resizer.BorderSizePixel = 0
    Resizer.Position = UDim2.new(0, -2, 0, 0)
    Resizer.Size = UDim2.new(0, 4, 1, 0)
    Resizer.AutoButtonColor = false
    Resizer.Text = ""
    Resizer.Parent = MainArea
    
    -- Resize functionality
    local Resizing = false
    Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newWidth = math.clamp(input.Position.X - Main.AbsolutePosition.X, 150, 400)
            Sidebar.Size = UDim2.new(0, newWidth, 1, 0)
            MainArea.Position = UDim2.new(0, newWidth, 0, 0)
            MainArea.Size = UDim2.new(1, -newWidth, 1, 0)
        end
    end)
    
    -- Page Container (for sections)
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.BackgroundTransparency = 1
    PageContainer.Size = UDim2.new(1, 0, 1, 0)
    PageContainer.Parent = MainArea
    
    -- Left and Right columns
    local LeftColumn = Instance.new("ScrollingFrame")
    LeftColumn.Name = "Left"
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Position = UDim2.new(0, 0, 0, 0)
    LeftColumn.Size = UDim2.new(0.5, -8, 1, 0)
    LeftColumn.ScrollBarThickness = 4
    LeftColumn.ScrollBarImageColor3 = Theme.ScrollbarThumb
    LeftColumn.CanvasSize = UDim2.new()
    LeftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LeftColumn.Parent = PageContainer
    
    local LeftList = Instance.new("UIListLayout")
    LeftList.Padding = UDim.new(0, 12)
    LeftList.SortOrder = Enum.SortOrder.LayoutOrder
    LeftList.Parent = LeftColumn
    
    local LeftPadding = Instance.new("UIPadding")
    LeftPadding.PaddingLeft = UDim.new(0, 16)
    LeftPadding.PaddingTop = UDim.new(0, 16)
    LeftPadding.PaddingBottom = UDim.new(0, 16)
    LeftPadding.Parent = LeftColumn
    
    local RightColumn = Instance.new("ScrollingFrame")
    RightColumn.Name = "Right"
    RightColumn.BackgroundTransparency = 1
    RightColumn.Position = UDim2.new(0.5, 8, 0, 0)
    RightColumn.Size = UDim2.new(0.5, -24, 1, 0)
    RightColumn.ScrollBarThickness = 4
    RightColumn.ScrollBarImageColor3 = Theme.ScrollbarThumb
    RightColumn.CanvasSize = UDim2.new()
    RightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
    RightColumn.Parent = PageContainer
    
    local RightList = Instance.new("UIListLayout")
    RightList.Padding = UDim.new(0, 12)
    RightList.SortOrder = Enum.SortOrder.LayoutOrder
    RightList.Parent = RightColumn
    
    local RightPadding = Instance.new("UIPadding")
    RightPadding.PaddingRight = UDim.new(0, 16)
    RightPadding.PaddingTop = UDim.new(0, 16)
    RightPadding.PaddingBottom = UDim.new(0, 16)
    RightPadding.Parent = RightColumn
    
    -- Section Creation
    function Window:Section(info)
        info = info or {}
        local sectionTitle = info.Title or "Section"
        local side = info.Side or "Left"
        local defaultOpen = info.Open ~= false
        
        local SectionObj = {}
        local TargetColumn = side == "Left" and LeftColumn or RightColumn
        
        -- Section Frame
        local Section = Instance.new("Frame")
        Section.Name = sectionTitle
        Section.BackgroundColor3 = Theme.BackgroundSecondary
        Section.BorderSizePixel = 0
        Section.Size = UDim2.new(1, 0, 0, 36)
        Section.Parent = TargetColumn
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = Section
        
        -- Header
        local Header = Instance.new("TextButton")
        Header.Name = "Header"
        Header.BackgroundTransparency = 1
        Header.Size = UDim2.new(1, 0, 0, 36)
        Header.Text = ""
        Header.AutoButtonColor = false
        Header.Parent = Section
        
        local HeaderText = Instance.new("TextLabel")
        HeaderText.Name = "Title"
        HeaderText.Font = Enum.Font.GothamBold
        HeaderText.Text = sectionTitle
        HeaderText.TextColor3 = Theme.TextPrimary
        HeaderText.TextSize = 13
        HeaderText.TextXAlignment = Enum.TextXAlignment.Left
        HeaderText.BackgroundTransparency = 1
        HeaderText.Position = UDim2.new(0, 12, 0, 0)
        HeaderText.Size = UDim2.new(1, -40, 1, 0)
        HeaderText.Parent = Header
        
        -- Chevron
        local Chevron = Instance.new("TextLabel")
        Chevron.Name = "Chevron"
        Chevron.Font = Enum.Font.GothamBold
        Chevron.Text = "▼"
        Chevron.TextColor3 = Theme.TextMuted
        Chevron.TextSize = 10
        Chevron.BackgroundTransparency = 1
        Chevron.Position = UDim2.new(1, -28, 0, 0)
        Chevron.Size = UDim2.new(0, 20, 1, 0)
        Chevron.Parent = Header
        
        -- Content Container
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.BackgroundTransparency = 1
        Container.Position = UDim2.new(0, 0, 0, 36)
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.ClipsDescendants = true
        Container.Parent = Section
        
        local ContainerList = Instance.new("UIListLayout")
        ContainerList.Padding = UDim.new(0, 8)
        ContainerList.SortOrder = Enum.SortOrder.LayoutOrder
        ContainerList.Parent = Container
        
        local ContainerPadding = Instance.new("UIPadding")
        ContainerPadding.PaddingLeft = UDim.new(0, 12)
        ContainerPadding.PaddingRight = UDim.new(0, 12)
        ContainerPadding.PaddingBottom = UDim.new(0, 12)
        ContainerPadding.Parent = Container
        
        -- Calculate content height
        local function UpdateHeight()
            local contentHeight = ContainerList.AbsoluteContentSize.Y + ContainerPadding.PaddingBottom.Offset
            local totalHeight = 36 + (Container.Visible and contentHeight or 0)
            Section.Size = UDim2.new(1, 0, 0, totalHeight)
            Container.Size = UDim2.new(1, 0, 0, contentHeight)
        end
        
        ContainerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)
        
        -- Toggle functionality
        local IsOpen = false
        local function Toggle()
            IsOpen = not IsOpen
            Container.Visible = IsOpen
            
            Tween(Chevron, TweenInfo.new(0.2), {Rotation = IsOpen and 0 or -90}):Play()
            UpdateHeight()
        end
        
        Header.MouseButton1Click:Connect(Toggle)
        
        -- Hover effect
        Header.MouseEnter:Connect(function()
            Tween(Section, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover}):Play()
        end)
        Header.MouseLeave:Connect(function()
            Tween(Section, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BackgroundSecondary}):Play()
        end)
        
        -- Set initial state
        if defaultOpen then
            Toggle()
        else
            Container.Visible = false
            Chevron.Rotation = -90
        end
        
        -- Element Creation Functions
        function SectionObj:Button(info)
            info = info or {}
            local text = info.Text or "Button"
            local callback = info.Callback or function() end
            
            local Btn = Instance.new("TextButton")
            Btn.Name = text
            Btn.Font = Enum.Font.GothamSemibold
            Btn.Text = text
            Btn.TextColor3 = Theme.TextPrimary
            Btn.TextSize = 12
            Btn.BackgroundColor3 = Theme.Accent
            Btn.BorderSizePixel = 0
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.Parent = Container
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Btn
            
            Btn.MouseEnter:Connect(function()
                Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentHover}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                Tween(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            end)
            Btn.MouseButton1Down:Connect(function()
                Tween(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 30)}):Play()
            end)
            Btn.MouseButton1Up:Connect(function()
                Tween(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 32)}):Play()
            end)
            Btn.MouseButton1Click:Connect(callback)
            
            UpdateHeight()
            return Btn
        end
        
        function SectionObj:Toggle(info)
            info = info or {}
            local text = info.Text or "Toggle"
            local default = info.Default or false
            local flag = info.Flag
            local callback = info.Callback or function() end
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = text
            ToggleFrame.BackgroundColor3 = Theme.Active
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
            ToggleFrame.Parent = Container
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 4)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Theme.TextPrimary
            ToggleLabel.TextSize = 12
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Parent = ToggleFrame
            
            -- Toggle Switch
            local Switch = Instance.new("Frame")
            Switch.Name = "Switch"
            Switch.BackgroundColor3 = Theme.ToggleOff
            Switch.BorderSizePixel = 0
            Switch.Position = UDim2.new(1, -48, 0.5, -10)
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.Parent = ToggleFrame
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch
            
            local Knob = Instance.new("Frame")
            Knob.Name = "Knob"
            Knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Knob.BorderSizePixel = 0
            Knob.Position = UDim2.new(0, 2, 0.5, -8)
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Parent = Switch
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob
            
            local Enabled = default
            local function SetState(state)
                Enabled = state
                if flag then
                    Library.Flags[flag] = state
                end
                
                local targetColor = state and Theme.ToggleOn or Theme.ToggleOff
                local targetPos = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                Tween(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                Tween(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
                
                callback(state)
            end
            
            local ClickRegion = Instance.new("TextButton")
            ClickRegion.Name = "ClickRegion"
            ClickRegion.BackgroundTransparency = 1
            ClickRegion.Size = UDim2.new(1, 0, 1, 0)
            ClickRegion.Text = ""
            ClickRegion.Parent = ToggleFrame
            
            ClickRegion.MouseButton1Click:Connect(function()
                SetState(not Enabled)
            end)
            
            SetState(default)
            UpdateHeight()
            
            return {
                Set = SetState,
                Get = function() return Enabled end
            }
        end
        
        function SectionObj:Slider(info)
            info = info or {}
            local text = info.Text or "Slider"
            local min = info.Min or 0
            local max = info.Max or 100
            local default = math.clamp(info.Default or min, min, max)
            local flag = info.Flag
            local suffix = info.Suffix or ""
            local callback = info.Callback or function() end
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = text
            SliderFrame.BackgroundColor3 = Theme.Active
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(1, 0, 0, 56)
            SliderFrame.Parent = Container
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 4)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.Text = text
            SliderLabel.TextColor3 = Theme.TextPrimary
            SliderLabel.TextSize = 12
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Position = UDim2.new(0, 12, 0, 8)
            SliderLabel.Size = UDim2.new(0.5, -12, 0, 20)
            SliderLabel.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "Value"
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = tostring(default) .. suffix
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0.5, 0, 0, 8)
            ValueLabel.Size = UDim2.new(0.5, -12, 0, 20)
            ValueLabel.Parent = SliderFrame
            
            -- Slider Track
            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.BackgroundColor3 = Theme.SliderBg
            Track.BorderSizePixel = 0
            Track.Position = UDim2.new(0, 12, 0, 36)
            Track.Size = UDim2.new(1, -24, 0, 6)
            Track.Parent = SliderFrame
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track
            
            -- Slider Fill
            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            Fill.BackgroundColor3 = Theme.SliderFill
            Fill.BorderSizePixel = 0
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.Parent = Track
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            -- Slider Knob
            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
            SliderKnob.BorderSizePixel = 0
            SliderKnob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
            SliderKnob.Size = UDim2.new(0, 12, 0, 12)
            SliderKnob.Parent = Track
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SliderKnob
            
            local function UpdateValue(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                SliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
                ValueLabel.Text = tostring(value) .. suffix
                
                if flag then
                    Library.Flags[flag] = value
                end
                
                callback(value)
            end
            
            local Dragging = false
            SliderKnob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                end
            end)
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    UpdateValue(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateValue(input)
                end
            end)
            
            UpdateHeight()
        end
        
        function SectionObj:Input(info)
            info = info or {}
            local text = info.Text or "Input"
            local placeholder = info.Placeholder or "Enter text..."
            local flag = info.Flag
            local callback = info.Callback or function() end
            
            local InputFrame = Instance.new("Frame")
            InputFrame.Name = text
            InputFrame.BackgroundColor3 = Theme.InputBg
            InputFrame.BorderSizePixel = 0
            InputFrame.Size = UDim2.new(1, 0, 0, 64)
            InputFrame.Parent = Container
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 4)
            InputCorner.Parent = InputFrame
            
            local InputLabel = Instance.new("TextLabel")
            InputLabel.Name = "Label"
            InputLabel.Font = Enum.Font.Gotham
            InputLabel.Text = text
            InputLabel.TextColor3 = Theme.TextSecondary
            InputLabel.TextSize = 11
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.BackgroundTransparency = 1
            InputLabel.Position = UDim2.new(0, 12, 0, 8)
            InputLabel.Size = UDim2.new(1, -24, 0, 16)
            InputLabel.Parent = InputFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Name = "TextBox"
            TextBox.Font = Enum.Font.Gotham
            TextBox.Text = ""
            TextBox.PlaceholderText = placeholder
            TextBox.PlaceholderColor3 = Theme.InputPlaceholder
            TextBox.TextColor3 = Theme.TextPrimary
            TextBox.TextSize = 12
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.BackgroundTransparency = 1
            TextBox.Position = UDim2.new(0, 12, 0, 28)
            TextBox.Size = UDim2.new(1, -24, 0, 28)
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = InputFrame
            
            local BottomLine = Instance.new("Frame")
            BottomLine.Name = "Line"
            BottomLine.BackgroundColor3 = Theme.BorderLight
            BottomLine.BorderSizePixel = 0
            BottomLine.Position = UDim2.new(0, 12, 1, -2)
            BottomLine.Size = UDim2.new(1, -24, 0, 2)
            BottomLine.Parent = InputFrame
            
            TextBox.Focused:Connect(function()
                Tween(BottomLine, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            end)
            
            TextBox.FocusLost:Connect(function()
                Tween(BottomLine, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BorderLight}):Play()
                if flag then
                    Library.Flags[flag] = TextBox.Text
                end
                callback(TextBox.Text)
            end)
            
            UpdateHeight()
        end
        
        function SectionObj:Dropdown(info)
            info = info or {}
            local text = info.Text or "Dropdown"
            local options = info.Options or {}
            local default = info.Default
            local flag = info.Flag
            local callback = info.Callback or function() end
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = text
            DropdownFrame.BackgroundColor3 = Theme.Active
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = Container
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 4)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Name = "Button"
            DropdownButton.Font = Enum.Font.Gotham
            DropdownButton.Text = ""
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Size = UDim2.new(1, 0, 0, 36)
            DropdownButton.Parent = DropdownFrame
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Name = "Label"
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.Text = text
            DropdownLabel.TextColor3 = Theme.TextSecondary
            DropdownLabel.TextSize = 11
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Position = UDim2.new(0, 12, 0, 4)
            DropdownLabel.Size = UDim2.new(1, -40, 0, 14)
            DropdownLabel.Parent = DropdownFrame
            
            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Name = "Selected"
            SelectedLabel.Font = Enum.Font.GothamSemibold
            SelectedLabel.Text = default or "Select..."
            SelectedLabel.TextColor3 = Theme.TextPrimary
            SelectedLabel.TextSize = 12
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Position = UDim2.new(0, 12, 0, 18)
            SelectedLabel.Size = UDim2.new(1, -40, 0, 16)
            SelectedLabel.Parent = DropdownFrame
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Name = "Arrow"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.TextMuted
            Arrow.TextSize = 10
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -28, 0, 0)
            Arrow.Size = UDim2.new(0, 20, 0, 36)
            Arrow.Parent = DropdownFrame
            
            -- Options Container
            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Name = "Options"
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Position = UDim2.new(0, 0, 0, 36)
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
            OptionsContainer.Parent = DropdownFrame
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Padding = UDim.new(0, 2)
            OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsList.Parent = OptionsContainer
            
            local OptionsPadding = Instance.new("UIPadding")
            OptionsPadding.PaddingLeft = UDim.new(0, 12)
            OptionsPadding.PaddingRight = UDim.new(0, 12)
            OptionsPadding.PaddingBottom = UDim.new(0, 8)
            OptionsPadding.Parent = OptionsContainer
            
            local IsOpen = false
            local Selected = default
            
            local function Toggle()
                IsOpen = not IsOpen
                local contentHeight = OptionsList.AbsoluteContentSize.Y + OptionsPadding.PaddingBottom.Offset
                
                Tween(Arrow, TweenInfo.new(0.2), {Rotation = IsOpen and 180 or 0}):Play()
                Tween(DropdownFrame, TweenInfo.new(0.2), {
                    Size = IsOpen and UDim2.new(1, 0, 0, 36 + contentHeight) or UDim2.new(1, 0, 0, 36)
                }):Play()
                
                UpdateHeight()
            end
            
            DropdownButton.MouseButton1Click:Connect(Toggle)
            
            -- Add options
            for _, option in ipairs(options) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Name = option
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.Text = option
                OptionBtn.TextColor3 = Theme.TextSecondary
                OptionBtn.TextSize = 12
                OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptionBtn.BackgroundColor3 = Theme.BackgroundTertiary
                OptionBtn.BorderSizePixel = 0
                OptionBtn.Size = UDim2.new(1, 0, 0, 28)
                OptionBtn.Parent = OptionsContainer
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionBtn
                
                OptionBtn.MouseEnter:Connect(function()
                    Tween(OptionBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Theme.Hover,
                        TextColor3 = Theme.TextPrimary
                    }):Play()
                end)
                OptionBtn.MouseLeave:Connect(function()
                    Tween(OptionBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Theme.BackgroundTertiary,
                        TextColor3 = Theme.TextSecondary
                    }):Play()
                end)
                OptionBtn.MouseButton1Click:Connect(function()
                    Selected = option
                    SelectedLabel.Text = option
                    if flag then
                        Library.Flags[flag] = option
                    end
                    callback(option)
                    Toggle()
                end)
            end
            
            UpdateHeight()
        end
        
        function SectionObj:Label(info)
            info = info or {}
            local text = info.Text or "Label"
            
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Name = "Label"
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Size = UDim2.new(1, 0, 0, 24)
            LabelFrame.Parent = Container
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Name = "Text"
            LabelText.Font = Enum.Font.Gotham
            LabelText.Text = text
            LabelText.TextColor3 = Theme.TextSecondary
            LabelText.TextSize = 12
            LabelText.TextWrapped = true
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.BackgroundTransparency = 1
            LabelText.Size = UDim2.new(1, 0, 1, 0)
            LabelText.Parent = LabelFrame
            
            UpdateHeight()
        end
        
        return SectionObj
    end
    
    -- Sidebar Section creation (collapsible groups in sidebar)
    function Window:SidebarSection(info)
        info = info or {}
        local title = info.Title or "Category"
        local icon = info.Icon or "📁"
        
        local SidebarSection = {}
        
        local Category = Instance.new("Frame")
        Category.Name = title
        Category.BackgroundTransparency = 1
        Category.Size = UDim2.new(1, 0, 0, 32)
        Category.Parent = SidebarScroll
        
        local CategoryBtn = Instance.new("TextButton")
        CategoryBtn.Name = "Button"
        CategoryBtn.Font = Enum.Font.GothamBold
        CategoryBtn.Text = "  " .. icon .. "  " .. title
        CategoryBtn.TextColor3 = Theme.TextSecondary
        CategoryBtn.TextSize = 12
        CategoryBtn.TextXAlignment = Enum.TextXAlignment.Left
        CategoryBtn.BackgroundColor3 = Theme.BackgroundFloating
        CategoryBtn.BorderSizePixel = 0
        CategoryBtn.Size = UDim2.new(1, 0, 1, 0)
        CategoryBtn.Parent = Category
        
        local CategoryCorner = Instance.new("UICorner")
        CategoryCorner.CornerRadius = UDim.new(0, 4)
        CategoryCorner.Parent = CategoryBtn
        
        CategoryBtn.MouseEnter:Connect(function()
            Tween(CategoryBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Hover,
                TextColor3 = Theme.TextPrimary
            }):Play()
        end)
        CategoryBtn.MouseLeave:Connect(function()
            Tween(CategoryBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.BackgroundFloating,
                TextColor3 = Theme.TextSecondary
            }):Play()
        end)
        
        function SidebarSection:Select()
            -- Reset all others
            for _, child in pairs(SidebarScroll:GetChildren()) do
                if child:IsA("Frame") and child ~= Category then
                    Tween(child.Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Theme.BackgroundFloating,
                        TextColor3 = Theme.TextSecondary
                    }):Play()
                end
            end
            
            Tween(CategoryBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Accent,
                TextColor3 = Theme.TextPrimary
            }):Play()
        end
        
        CategoryBtn.MouseButton1Click:Connect(function()
            SidebarSection:Select()
        end)
        
        return SidebarSection
    end
    
    return Window
end

return Library
