-- TrinityUI - Modern 3-Panel Interface Library
-- Features: Glassmorphism, 60fps animations, icon system, responsive layout

local Trinity = {}
Trinity.__index = Trinity

-- Service Caching
local Services = {}
local function GetService(name)
    if not Services[name] then
        Services[name] = game:GetService(name)
    end
    return Services[name]
end

local Players = GetService("Players")
local RunService = GetService("RunService")
local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local Lighting = GetService("Lighting")
local Stats = GetService("Stats")
local HttpService = GetService("HttpService")
local TextService = GetService("TextService")
local MarketplaceService = GetService("MarketplaceService")
local ReplicatedStorage = GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local CoreGui = GetService("CoreGui")

-- File System Compatibility
local SafeFile = {
    Write = function(path, content)
        if writefile then pcall(function() writefile(path, content) end) end
    end,
    Read = function(path)
        if readfile and isfile then
            if isfile(path) then
                local ok, data = pcall(function() return readfile(path) end)
                if ok then return data end
            end
        end
        return nil
    end,
    MakeFolder = function(path)
        if makefolder and isfolder then
            if not isfolder(path) then
                pcall(function() makefolder(path) end)
            end
        end
    end,
    JSONEncode = function(data)
        local ok, result = pcall(function() return HttpService:JSONEncode(data) end)
        return ok and result or "{}"
    end,
    JSONDecode = function(str)
        local ok, result = pcall(function() return HttpService:JSONDecode(str) end)
        return ok and result or {}
    end
}

-- Theme System
Trinity.Theme = {
    -- Backgrounds (Glassmorphism)
    PanelBg = Color3.fromRGB(25, 25, 30),
    PanelBgTransparent = Color3.fromRGB(25, 25, 30),
    ContainerBg = Color3.fromRGB(35, 35, 42),
    ElevatedBg = Color3.fromRGB(45, 45, 55),
    
    -- Accents
    Primary = Color3.fromRGB(99, 102, 241),      -- Indigo
    Secondary = Color3.fromRGB(139, 92, 246),    -- Violet
    Success = Color3.fromRGB(34, 197, 94),       -- Green
    Warning = Color3.fromRGB(251, 146, 60),      -- Orange
    Danger = Color3.fromRGB(239, 68, 68),        -- Red
    Info = Color3.fromRGB(59, 130, 246),         -- Blue
    
    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    TextMuted = Color3.fromRGB(120, 120, 130),
    
    -- Effects
    GlassTransparency = 0.15,
    BorderColor = Color3.fromRGB(60, 60, 70),
    GlowColor = Color3.fromRGB(99, 102, 241),
    
    -- Animation
    AnimationSpeed = 0.3,
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out
}

-- State Management
Trinity.State = {
    CurrentTab = nil,
    Tabs = {},
    Components = {},
    Accents = {},
    Draggables = {},
    Config = {},
    StreamerMode = false,
    UIVisible = true,
    Keybinds = {}
}

-- Utility Functions
local function SafeTween(obj, properties, duration, style, direction)
    if not obj or not obj.Parent then return nil end
    duration = duration or Trinity.Theme.AnimationSpeed
    style = style or Trinity.Theme.EasingStyle
    direction = direction or Trinity.Theme.EasingDirection
    
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local ok, tween = pcall(function()
        return TweenService:Create(obj, tweenInfo, properties)
    end)
    
    if ok and tween then
        tween:Play()
        return tween
    end
    return nil
end

local function AddGlassEffects(parent, cornerRadius)
    cornerRadius = cornerRadius or 8
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = parent
    
    -- Subtle border
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Trinity.Theme.BorderColor
    stroke.Transparency = 0.6
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    
    -- Shadow/Glow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, 8, 1, 8)
    shadow.Image = "rbxassetid://131604521937018"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    
    return stroke, shadow
end

local function CreateIcon(name, size, color)
    local iconMap = {
        home = "rbxassetid://7733960981",
        settings = "rbxassetid://7734053495",
        user = "rbxassetid://7733955740",
        search = "rbxassetid://7733954762",
        bell = "rbxassetid://7733955740",
        menu = "rbxassetid://7733959095",
        close = "rbxassetid://7733955740",
        check = "rbxassetid://7733955740",
        edit = "rbxassetid://7733955740",
        trash = "rbxassetid://7733955740",
        plus = "rbxassetid://7733955740",
        minus = "rbxassetid://7733955740",
        sun = "rbxassetid://7733955740",
        moon = "rbxassetid://7733955740",
        game = "rbxassetid://7733955740",
        code = "rbxassetid://7733955740",
        terminal = "rbxassetid://7733955740",
        shield = "rbxassetid://7733955740",
        zap = "rbxassetid://7733955740",
        activity = "rbxassetid://7733955740"
    }
    
    local icon = Instance.new("ImageLabel")
    icon.Size = size or UDim2.fromOffset(20, 20)
    icon.BackgroundTransparency = 1
    icon.Image = iconMap[name] or iconMap.menu
    icon.ImageColor3 = color or Trinity.Theme.TextPrimary
    return icon
end

-- Cleanup Previous Instances
local function Cleanup()
    local existing = CoreGui:FindFirstChild("TrinityUI")
    if existing then
        pcall(function() existing:Destroy() end)
    end
    
    for _, v in ipairs(Lighting:GetChildren()) do
        if v.Name:find("Trinity") then
            pcall(function() v:Destroy() end)
        end
    end
end

Cleanup()

-- Initialize Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrinityUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

Trinity.ScreenGui = ScreenGui

-- Blur Effect
local Blur = Instance.new("BlurEffect")
Blur.Name = "TrinityBlur"
Blur.Size = 0
Blur.Enabled = true
Blur.Parent = Lighting

-- Main Container (3 Panels)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundTransparency = 1
MainFrame.Position = UDim2.new(0.5, -550, 0.5, -300)
MainFrame.Size = UDim2.new(0, 1100, 0, 600)
MainFrame.ClipsDescendants = true

Trinity.MainFrame = MainFrame

-- ==========================================
-- PANEL 1: NAVIGATION SIDEBAR (Left, 240px)
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Trinity.Theme.PanelBg
Sidebar.BackgroundTransparency = Trinity.Theme.GlassTransparency
Sidebar.Size = UDim2.new(0, 240, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)

AddGlassEffects(Sidebar, 12)

-- Sidebar Header
local SidebarHeader = Instance.new("Frame")
SidebarHeader.Name = "Header"
SidebarHeader.Parent = Sidebar
SidebarHeader.BackgroundTransparency = 1
SidebarHeader.Size = UDim2.new(1, 0, 0, 80)

local LogoFrame = Instance.new("Frame")
LogoFrame.Parent = SidebarHeader
LogoFrame.BackgroundTransparency = 1
LogoFrame.Position = UDim2.new(0, 20, 0, 20)
LogoFrame.Size = UDim2.new(1, -40, 0, 40)

local LogoIcon = CreateIcon("zap", UDim2.fromOffset(32, 32), Trinity.Theme.Primary)
LogoIcon.Parent = LogoFrame
LogoIcon.Position = UDim2.new(0, 0, 0, 4)

local LogoText = Instance.new("TextLabel")
LogoText.Parent = LogoFrame
LogoText.BackgroundTransparency = 1
LogoText.Position = UDim2.new(0, 42, 0, 0)
LogoText.Size = UDim2.new(1, -42, 1, 0)
LogoText.Font = Enum.Font.GothamBold
LogoText.Text = "TRINITY"
LogoText.TextColor3 = Trinity.Theme.TextPrimary
LogoText.TextSize = 24
LogoText.TextXAlignment = Enum.TextXAlignment.Left

local LogoSub = Instance.new("TextLabel")
LogoSub.Parent = LogoFrame
LogoSub.BackgroundTransparency = 1
LogoSub.Position = UDim2.new(0, 42, 0, 28)
LogoSub.Size = UDim2.new(1, -42, 0, 16)
LogoSub.Font = Enum.Font.GothamMedium
LogoSub.Text = "v2.0.0"
LogoSub.TextColor3 = Trinity.Theme.TextMuted
LogoSub.TextSize = 12
LogoSub.TextXAlignment = Enum.TextXAlignment.Left

-- Navigation Container
local NavContainer = Instance.new("ScrollingFrame")
NavContainer.Name = "NavContainer"
NavContainer.Parent = Sidebar
NavContainer.BackgroundTransparency = 1
NavContainer.Position = UDim2.new(0, 0, 0, 90)
NavContainer.Size = UDim2.new(1, 0, 1, -180)
NavContainer.ScrollBarThickness = 2
NavContainer.ScrollBarImageColor3 = Trinity.Theme.Primary
NavContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local NavLayout = Instance.new("UIListLayout")
NavLayout.Parent = NavContainer
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Section Template
local function CreateSection(title)
    local section = Instance.new("Frame")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 30)
    section.LayoutOrder = #Trinity.State.Tabs * 10
    
    local label = Instance.new("TextLabel")
    label.Parent = section
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 20, 0, 10)
    label.Size = UDim2.new(1, -40, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = title:upper()
    label.TextColor3 = Trinity.Theme.TextMuted
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    return section
end

-- User Profile Card (Bottom)
local ProfileCard = Instance.new("Frame")
ProfileCard.Name = "ProfileCard"
ProfileCard.Parent = Sidebar
ProfileCard.BackgroundColor3 = Trinity.Theme.ElevatedBg
ProfileCard.BackgroundTransparency = 0.3
ProfileCard.Position = UDim2.new(0, 15, 1, -75)
ProfileCard.Size = UDim2.new(1, -30, 0, 60)

AddGlassEffects(ProfileCard, 8)

local Avatar = Instance.new("ImageLabel")
Avatar.Parent = ProfileCard
Avatar.BackgroundColor3 = Trinity.Theme.ContainerBg
Avatar.Position = UDim2.new(0, 10, 0.5, -20)
Avatar.Size = UDim2.fromOffset(40, 40)
Avatar.Image = ""

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 20)
AvatarCorner.Parent = Avatar

local success, thumb = pcall(function()
    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)
Avatar.Image = success and thumb or ""

local UserName = Instance.new("TextLabel")
UserName.Parent = ProfileCard
UserName.BackgroundTransparency = 1
UserName.Position = UDim2.new(0, 60, 0, 12)
UserName.Size = UDim2.new(1, -70, 0, 20)
UserName.Font = Enum.Font.GothamBold
UserName.Text = LocalPlayer.Name
UserName.TextColor3 = Trinity.Theme.TextPrimary
UserName.TextSize = 14
UserName.TextXAlignment = Enum.TextXAlignment.Left

local UserStatus = Instance.new("TextLabel")
UserStatus.Parent = ProfileCard
UserStatus.BackgroundTransparency = 1
UserStatus.Position = UDim2.new(0, 60, 0, 32)
UserStatus.Size = UDim2.new(1, -70, 0, 16)
UserStatus.Font = Enum.Font.GothamMedium
UserStatus.Text = "Premium"
UserStatus.TextColor3 = Trinity.Theme.Success
UserStatus.TextSize = 11
UserStatus.TextXAlignment = Enum.TextXAlignment.Left

-- ==========================================
-- PANEL 2: MAIN CONTENT (Center, 620px)
-- ==========================================
local ContentPanel = Instance.new("Frame")
ContentPanel.Name = "ContentPanel"
ContentPanel.Parent = MainFrame
ContentPanel.BackgroundColor3 = Trinity.Theme.PanelBg
ContentPanel.BackgroundTransparency = Trinity.Theme.GlassTransparency
ContentPanel.Position = UDim2.new(0, 250, 0, 0)
ContentPanel.Size = UDim2.new(0, 620, 1, 0)

AddGlassEffects(ContentPanel, 12)

-- Content Header
local ContentHeader = Instance.new("Frame")
ContentHeader.Name = "Header"
ContentHeader.Parent = ContentPanel
ContentHeader.BackgroundTransparency = 1
ContentHeader.Size = UDim2.new(1, 0, 0, 70)

local Breadcrumb = Instance.new("TextLabel")
Breadcrumb.Parent = ContentHeader
Breadcrumb.BackgroundTransparency = 1
Breadcrumb.Position = UDim2.new(0, 25, 0, 15)
Breadcrumb.Size = UDim2.new(0.5, 0, 0, 20)
Breadcrumb.Font = Enum.Font.GothamMedium
Breadcrumb.Text = "Dashboard / Overview"
Breadcrumb.TextColor3 = Trinity.Theme.TextMuted
Breadcrumb.TextSize = 12
Breadcrumb.TextXAlignment = Enum.TextXAlignment.Left

local PageTitle = Instance.new("TextLabel")
PageTitle.Parent = ContentHeader
PageTitle.BackgroundTransparency = 1
PageTitle.Position = UDim2.new(0, 25, 0, 35)
PageTitle.Size = UDim2.new(0.5, 0, 0, 30)
PageTitle.Font = Enum.Font.GothamBold
PageTitle.Text = "Overview"
PageTitle.TextColor3 = Trinity.Theme.TextPrimary
PageTitle.TextSize = 24
PageTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Search Bar
local SearchBox = Instance.new("Frame")
SearchBox.Parent = ContentHeader
SearchBox.BackgroundColor3 = Trinity.Theme.ContainerBg
SearchBox.Position = UDim2.new(1, -220, 0.5, -18)
SearchBox.Size = UDim2.new(0, 200, 0, 36)

AddGlassEffects(SearchBox, 18)

local SearchIcon = CreateIcon("search", UDim2.fromOffset(16, 16), Trinity.Theme.TextMuted)
SearchIcon.Parent = SearchBox
SearchIcon.Position = UDim2.new(0, 12, 0.5, -8)

local SearchInput = Instance.new("TextBox")
SearchInput.Parent = SearchBox
SearchInput.BackgroundTransparency = 1
SearchInput.Position = UDim2.new(0, 36, 0, 0)
SearchInput.Size = UDim2.new(1, -48, 1, 0)
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.Text = ""
SearchInput.PlaceholderText = "Search..."
SearchInput.TextColor3 = Trinity.Theme.TextPrimary
SearchInput.PlaceholderColor3 = Trinity.Theme.TextMuted
SearchInput.TextSize = 14
SearchInput.TextXAlignment = Enum.TextXAlignment.Left

-- Content Area (Two Columns)
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Parent = ContentPanel
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, 0, 0, 80)
ContentArea.Size = UDim2.new(1, 0, 1, -90)

local LeftColumn = Instance.new("ScrollingFrame")
LeftColumn.Name = "LeftColumn"
LeftColumn.Parent = ContentArea
LeftColumn.BackgroundTransparency = 1
LeftColumn.Position = UDim2.new(0, 20, 0, 0)
LeftColumn.Size = UDim2.new(0.5, -30, 1, 0)
LeftColumn.ScrollBarThickness = 0
LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)

local RightColumn = Instance.new("ScrollingFrame")
RightColumn.Name = "RightColumn"
RightColumn.Parent = ContentArea
RightColumn.BackgroundTransparency = 1
RightColumn.Position = UDim2.new(0.5, 10, 0, 0)
RightColumn.Size = UDim2.new(0.5, -30, 1, 0)
RightColumn.ScrollBarThickness = 0
RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Layout managers
local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Parent = LeftColumn
LeftLayout.Padding = UDim.new(0, 16)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder

local RightLayout = Instance.new("UIListLayout")
RightLayout.Parent = RightColumn
RightLayout.Padding = UDim.new(0, 16)
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Auto-canvas sizing
LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LeftColumn.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 20)
end)

RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    RightColumn.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 20)
end)

-- ==========================================
-- PANEL 3: INSPECTOR/PROPERTIES (Right, 220px)
-- ==========================================
local InspectorPanel = Instance.new("Frame")
InspectorPanel.Name = "InspectorPanel"
InspectorPanel.Parent = MainFrame
InspectorPanel.BackgroundColor3 = Trinity.Theme.PanelBg
InspectorPanel.BackgroundTransparency = Trinity.Theme.GlassTransparency
InspectorPanel.Position = UDim2.new(0, 880, 0, 0)
InspectorPanel.Size = UDim2.new(0, 220, 1, 0)

AddGlassEffects(InspectorPanel, 12)

-- Inspector Header
local InspectorHeader = Instance.new("Frame")
InspectorHeader.Name = "Header"
InspectorHeader.Parent = InspectorPanel
InspectorHeader.BackgroundTransparency = 1
InspectorHeader.Size = UDim2.new(1, 0, 0, 70)

local InspectorTitle = Instance.new("TextLabel")
InspectorTitle.Parent = InspectorHeader
InspectorTitle.BackgroundTransparency = 1
InspectorTitle.Position = UDim2.new(0, 20, 0, 25)
InspectorTitle.Size = UDim2.new(1, -40, 0, 30)
InspectorTitle.Font = Enum.Font.GothamBold
InspectorTitle.Text = "Properties"
InspectorTitle.TextColor3 = Trinity.Theme.TextPrimary
InspectorTitle.TextSize = 18
InspectorTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Inspector Content
local InspectorContent = Instance.new("ScrollingFrame")
InspectorContent.Name = "Content"
InspectorContent.Parent = InspectorPanel
InspectorContent.BackgroundTransparency = 1
InspectorContent.Position = UDim2.new(0, 0, 0, 80)
InspectorContent.Size = UDim2.new(1, 0, 1, -90)
InspectorContent.ScrollBarThickness = 2
InspectorContent.ScrollBarImageColor3 = Trinity.Theme.Primary
InspectorContent.CanvasSize = UDim2.new(0, 0, 0, 0)

local InspectorLayout = Instance.new("UIListLayout")
InspectorLayout.Parent = InspectorContent
InspectorLayout.Padding = UDim.new(0, 12)
InspectorLayout.SortOrder = Enum.SortOrder.LayoutOrder

InspectorLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    InspectorContent.CanvasSize = UDim2.new(0, 0, 0, InspectorLayout.AbsoluteContentSize.Y + 20)
end)

-- ==========================================
-- COMPONENT SYSTEM
-- ==========================================

-- Group Box (Modern Card)
function Trinity.CreateGroupBox(title, column, height)
    column = column or "left"
    height = height or 200
    
    local parent = column == "left" and LeftColumn or RightColumn
    
    local card = Instance.new("Frame")
    card.Name = title .. "Card"
    card.Parent = parent
    card.BackgroundColor3 = Trinity.Theme.ContainerBg
    card.BackgroundTransparency = 0.2
    card.Size = UDim2.new(1, 0, 0, height)
    
    AddGlassEffects(card, 10)
    
    -- Header with accent line
    local header = Instance.new("Frame")
    header.Parent = card
    header.BackgroundColor3 = Trinity.Theme.Primary
    header.BorderSizePixel = 0
    header.Position = UDim2.new(0, 0, 0, 0)
    header.Size = UDim2.new(0, 4, 0, 40)
    
    local headerBg = Instance.new("Frame")
    headerBg.Parent = card
    headerBg.BackgroundColor3 = Trinity.Theme.ElevatedBg
    headerBg.BackgroundTransparency = 0.5
    headerBg.BorderSizePixel = 0
    headerBg.Position = UDim2.new(0, 0, 0, 0)
    headerBg.Size = UDim2.new(1, 0, 0, 40)
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = headerBg
    
    -- Fix corner for accent line area
    local mask = Instance.new("Frame")
    mask.Parent = headerBg
    mask.BackgroundColor3 = Trinity.Theme.ElevatedBg
    mask.BorderSizePixel = 0
    mask.Position = UDim2.new(0, 0, 0, 0)
    mask.Size = UDim2.new(0, 4, 0, 40)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = headerBg
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Trinity.Theme.TextPrimary
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = card
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 15, 0, 50)
    content.Size = UDim2.new(1, -30, 1, -60)
    
    -- Auto-height adjustment
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local newHeight = contentLayout.AbsoluteContentSize.Y + 70
        card.Size = UDim2.new(1, 0, 0, newHeight)
    end)
    
    return content
end

-- Modern Toggle Switch
function Trinity.AddToggle(parent, text, default, callback)
    local api = {}
    local state = default or false
    local safeCallback = callback or function() end
    
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 36)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = state and Trinity.Theme.TextPrimary or Trinity.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Switch background
    local switchBg = Instance.new("TextButton")
    switchBg.Parent = container
    switchBg.BackgroundColor3 = state and Trinity.Theme.Primary or Trinity.Theme.ElevatedBg
    switchBg.Position = UDim2.new(1, -50, 0.5, -12)
    switchBg.Size = UDim2.new(0, 50, 0, 24)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBg
    
    -- Switch knob
    local knob = Instance.new("Frame")
    knob.Parent = switchBg
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    knob.Size = UDim2.new(0, 20, 0, 20)
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Glow effect when on
    local glow = Instance.new("ImageLabel")
    glow.Parent = switchBg
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.Size = UDim2.new(1.5, 0, 2, 0)
    glow.Image = "rbxassetid://131604521937018"
    glow.ImageColor3 = Trinity.Theme.Primary
    glow.ImageTransparency = state and 0.7 or 1
    glow.ZIndex = 0
    
    local function update()
        SafeTween(switchBg, {BackgroundColor3 = state and Trinity.Theme.Primary or Trinity.Theme.ElevatedBg}, 0.2)
        SafeTween(knob, {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}, 0.2)
        SafeTween(glow, {ImageTransparency = state and 0.7 or 1}, 0.2)
        SafeTween(label, {TextColor3 = state and Trinity.Theme.TextPrimary or Trinity.Theme.TextSecondary}, 0.2)
    end
    
    switchBg.MouseButton1Click:Connect(function()
        api:Set(not state)
    end)
    
    function api:Set(value)
        value = not not value
        if state == value then return end
        state = value
        update()
        safeCallback(state)
    end
    
    function api:Get()
        return state
    end
    
    return api
end

-- Modern Slider
function Trinity.AddSlider(parent, text, min, max, default, decimals, suffix, callback)
    local api = {}
    decimals = decimals or 0
    suffix = suffix or ""
    local value = default or min
    
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 50)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Trinity.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = container
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(value) .. suffix
    valueLabel.TextColor3 = Trinity.Theme.Primary
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Track
    local track = Instance.new("TextButton")
    track.Parent = container
    track.BackgroundColor3 = Trinity.Theme.ElevatedBg
    track.Position = UDim2.new(0, 0, 0, 32)
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Text = ""
    track.AutoButtonColor = false
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Parent = track
    fill.BackgroundColor3 = Trinity.Theme.Primary
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Knob
    local knob = Instance.new("Frame")
    knob.Parent = fill
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.Size = UDim2.new(0, 14, 0, 14)
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Glow
    local knobGlow = Instance.new("ImageLabel")
    knobGlow.Parent = knob
    knobGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    knobGlow.BackgroundTransparency = 1
    knobGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    knobGlow.Size = UDim2.new(2, 0, 2, 0)
    knobGlow.Image = "rbxassetid://131604521937018"
    knobGlow.ImageColor3 = Trinity.Theme.Primary
    knobGlow.ImageTransparency = 0.5
    
    local function round(v)
        local p = 10 ^ decimals
        return math.floor(v * p + 0.5) / p
    end
    
    local function updateVisual()
        local pct = math.clamp((value - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        valueLabel.Text = tostring(round(value)) .. suffix
    end
    
    local dragging = false
    
    local function updateFromInput(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = min + ((max - min) * pos)
        api:Set(raw)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromInput(input)
            SafeTween(knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            SafeTween(knob, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
        end
    end)
    
    function api:Set(v)
        v = tonumber(v) or value
        v = math.clamp(v, min, max)
        v = round(v)
        if v == value then return end
        value = v
        updateVisual()
        if callback then callback(value) end
    end
    
    function api:Get()
        return value
    end
    
    updateVisual()
    return api
end

-- Modern Button
function Trinity.AddButton(parent, text, style, callback)
    style = style or "primary" -- primary, secondary, danger, ghost
    
    local colors = {
        primary = Trinity.Theme.Primary,
        secondary = Trinity.Theme.Secondary,
        danger = Trinity.Theme.Danger,
        ghost = Trinity.Theme.ElevatedBg
    }
    
    local color = colors[style] or colors.primary
    local isGhost = style == "ghost"
    
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = isGhost and 0.5 or 0
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = isGhost and Trinity.Theme.TextSecondary or Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    -- Hover effects
    local originalColor = color
    
    btn.MouseEnter:Connect(function()
        SafeTween(btn, {BackgroundColor3 = originalColor:Lerp(Color3.fromRGB(255, 255, 255), 0.1)}, 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        SafeTween(btn, {BackgroundColor3 = originalColor}, 0.2)
    end)
    
    btn.MouseButton1Down:Connect(function()
        SafeTween(btn, {Size = UDim2.new(0.98, 0, 0, 34), Position = UDim2.new(0.01, 0, 0, 1)}, 0.1)
    end)
    
    btn.MouseButton1Up:Connect(function()
        SafeTween(btn, {Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 0, 0)}, 0.1)
    end)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

-- Modern Dropdown
function Trinity.AddDropdown(parent, text, options, default, callback)
    local api = {}
    local selected = default or options[1]
    local isOpen = false
    
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 70)
    container.ZIndex = 10
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Trinity.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Main button
    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.BackgroundColor3 = Trinity.Theme.ElevatedBg
    btn.Position = UDim2.new(0, 0, 0, 25)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Text = "  " .. selected
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = Trinity.Theme.TextPrimary
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    
    AddGlassEffects(btn, 8)
    
    -- Chevron icon
    local chevron = Instance.new("ImageLabel")
    chevron.Parent = btn
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.BackgroundTransparency = 1
    chevron.Position = UDim2.new(1, -12, 0.5, 0)
    chevron.Size = UDim2.fromOffset(16, 16)
    chevron.Image = "rbxassetid://7733959095"
    chevron.ImageColor3 = Trinity.Theme.TextMuted
    chevron.Rotation = 0
    
    -- Dropdown list
    local list = Instance.new("Frame")
    list.Parent = container
    list.BackgroundColor3 = Trinity.Theme.ElevatedBg
    list.Position = UDim2.new(0, 0, 0, 65)
    list.Size = UDim2.new(1, 0, 0, 0)
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 20
    
    AddGlassEffects(list, 8)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = list
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function toggle()
        isOpen = not isOpen
        if isOpen then
            list.Visible = true
            SafeTween(list, {Size = UDim2.new(1, 0, 0, math.min(#options * 32, 160))}, 0.25)
            SafeTween(chevron, {Rotation = 180}, 0.25)
        else
            SafeTween(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
            SafeTween(chevron, {Rotation = 0}, 0.25)
            task.delay(0.25, function()
                if not isOpen then list.Visible = false end
            end)
        end
    end
    
    btn.MouseButton1Click:Connect(toggle)
    
    -- Options
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Parent = list
        optBtn.BackgroundTransparency = 1
        optBtn.Size = UDim2.new(1, 0, 0, 32)
        optBtn.Text = "  " .. opt
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextColor3 = (opt == selected) and Trinity.Theme.Primary or Trinity.Theme.TextSecondary
        optBtn.TextSize = 13
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.AutoButtonColor = false
        
        optBtn.MouseEnter:Connect(function()
            SafeTween(optBtn, {BackgroundTransparency = 0.9}, 0.1)
        end)
        
        optBtn.MouseLeave:Connect(function()
            SafeTween(optBtn, {BackgroundTransparency = 1}, 0.1)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            btn.Text = "  " .. selected
            toggle()
            if callback then callback(selected) end
            
            -- Update colors
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (child.Text:sub(3) == selected) and Trinity.Theme.Primary or Trinity.Theme.TextSecondary
                end
            end
        end)
    end
    
    function api:Set(value)
        if table.find(options, value) then
            selected = value
            btn.Text = "  " .. selected
        end
    end
    
    function api:Get()
        return selected
    end
    
    return api
end

-- Keybind Component
function Trinity.AddKeybind(parent, text, defaultKey, callback)
    local api = {}
    local currentKey = defaultKey or Enum.KeyCode.Unknown
    local listening = false
    
    local container = Instance.new("Frame")
    container.Parent = parent
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 36)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Trinity.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Parent = container
    keyBtn.BackgroundColor3 = Trinity.Theme.ElevatedBg
    keyBtn.Position = UDim2.new(1, -60, 0.5, -14)
    keyBtn.Size = UDim2.new(0, 60, 0, 28)
    keyBtn.Text = currentKey.Name ~= "Unknown" and currentKey.Name or "None"
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextColor3 = Trinity.Theme.Primary
    keyBtn.TextSize = 11
    keyBtn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = keyBtn
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = keyBtn
    stroke.Color = Trinity.Theme.Primary
    stroke.Thickness = 1.5
    stroke.Transparency = 0.8
    
    local function updateVisual()
        keyBtn.Text = currentKey.Name ~= "Unknown" and currentKey.Name or "None"
    end
    
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        
        SafeTween(stroke, {Transparency = 0}, 0.2)
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode
                updateVisual()
                SafeTween(stroke, {Transparency = 0.8}, 0.2)
            end
            listening = false
            conn:Disconnect()
        end)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or listening then return end
        if input.KeyCode == currentKey then
            SafeTween(keyBtn, {BackgroundColor3 = Trinity.Theme.Primary, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
            task.delay(0.15, function()
                SafeTween(keyBtn, {BackgroundColor3 = Trinity.Theme.ElevatedBg, TextColor3 = Trinity.Theme.Primary}, 0.1)
            end)
            if callback then callback() end
        end
    end)
    
    function api:Set(key)
        currentKey = key
        updateVisual()
    end
    
    function api:Get()
        return currentKey
    end
    
    return api
end

-- ==========================================
-- TAB SYSTEM
-- ==========================================

function Trinity.AddTab(name, icon, section)
    section = section or "Main"
    
    -- Create section header if needed
    local existingSection = NavContainer:FindFirstChild(section .. "Section")
    if not existingSection then
        local sec = CreateSection(section)
        sec.Name = section .. "Section"
        sec.Parent = NavContainer
    end
    
    -- Tab button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "Tab"
    tabBtn.Parent = NavContainer
    tabBtn.BackgroundColor3 = Trinity.Theme.Primary
    tabBtn.BackgroundTransparency = 1
    tabBtn.Size = UDim2.new(1, -30, 0, 40)
    tabBtn.Position = UDim2.new(0, 15, 0, 0)
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tabBtn
    
    -- Icon
    local iconLabel = CreateIcon(icon or "menu", UDim2.fromOffset(20, 20), Trinity.Theme.TextSecondary)
    iconLabel.Parent = tabBtn
    iconLabel.Position = UDim2.new(0, 15, 0.5, -10)
    iconLabel.Name = "Icon"
    
    -- Text
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = tabBtn
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 45, 0, 0)
    textLabel.Size = UDim2.new(1, -60, 1, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = name
    textLabel.TextColor3 = Trinity.Theme.TextSecondary
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Active indicator
    local indicator = Instance.new("Frame")
    indicator.Parent = tabBtn
    indicator.BackgroundColor3 = Trinity.Theme.Primary
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.new(0, 0, 0.5, -12)
    indicator.Size = UDim2.new(0, 3, 0, 24)
    indicator.Visible = false
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 2)
    indCorner.Parent = indicator
    
    -- Content page
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Parent = ContentArea
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    
    -- Store tab data
    Trinity.State.Tabs[name] = {
        Button = tabBtn,
        Page = page,
        Indicator = indicator,
        Icon = iconLabel,
        Label = textLabel
    }
    
    -- Click handler
    tabBtn.MouseButton1Click:Connect(function()
        Trinity.SwitchTab(name)
    end)
    
    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if Trinity.State.CurrentTab ~= name then
            SafeTween(tabBtn, {BackgroundTransparency = 0.9}, 0.2)
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if Trinity.State.CurrentTab ~= name then
            SafeTween(tabBtn, {BackgroundTransparency = 1}, 0.2)
        end
    end)
    
    -- Auto-switch to first tab
    if not Trinity.State.CurrentTab then
        Trinity.SwitchTab(name)
    end
    
    return page
end

function Trinity.SwitchTab(name)
    local tab = Trinity.State.Tabs[name]
    if not tab then return end
    
    -- Hide all tabs
    for n, t in pairs(Trinity.State.Tabs) do
        t.Page.Visible = false
        SafeTween(t.Button, {BackgroundTransparency = 1}, 0.3)
        t.Indicator.Visible = false
        SafeTween(t.Icon, {ImageColor3 = Trinity.Theme.TextSecondary}, 0.3)
        SafeTween(t.Label, {TextColor3 = Trinity.Theme.TextSecondary}, 0.3)
    end
    
    -- Show selected
    tab.Page.Visible = true
    SafeTween(tab.Button, {BackgroundTransparency = 0.85}, 0.3)
    tab.Indicator.Visible = true
    SafeTween(tab.Icon, {ImageColor3 = Trinity.Theme.Primary}, 0.3)
    SafeTween(tab.Label, {TextColor3 = Trinity.Theme.TextPrimary}, 0.3)
    
    Trinity.State.CurrentTab = name
    
    -- Update breadcrumb
    PageTitle.Text = name
end

-- ==========================================
-- INSPECTOR WIDGETS
-- ==========================================

function Trinity.AddInspectorCard(title)
    local card = Instance.new("Frame")
    card.Parent = InspectorContent
    card.BackgroundColor3 = Trinity.Theme.ContainerBg
    card.BackgroundTransparency = 0.3
    card.Size = UDim2.new(1, -20, 0, 0)
    card.Position = UDim2.new(0, 10, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    
    AddGlassEffects(card, 8)
    
    local header = Instance.new("TextLabel")
    header.Parent = card
    header.BackgroundTransparency = 1
    header.Position = UDim2.new(0, 15, 0, 12)
    header.Size = UDim2.new(1, -30, 0, 20)
    header.Font = Enum.Font.GothamBold
    header.Text = title
    header.TextColor3 = Trinity.Theme.TextPrimary
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    
    local content = Instance.new("Frame")
    content.Parent = card
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 15, 0, 40)
    content.Size = UDim2.new(1, -30, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Padding at bottom
    local padding = Instance.new("Frame")
    padding.Parent = content
    padding.BackgroundTransparency = 1
    padding.Size = UDim2.new(1, 0, 0, 10)
    padding.LayoutOrder = 999999
    
    return content
end

-- Quick Actions Grid
function Trinity.AddQuickActions(actions)
    local grid = Instance.new("Frame")
    grid.Parent = InspectorContent
    grid.BackgroundTransparency = 1
    grid.Size = UDim2.new(1, -20, 0, 0)
    grid.Position = UDim2.new(0, 10, 0, 0)
    grid.AutomaticSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIGridLayout")
    layout.Parent = grid
    layout.CellSize = UDim2.new(0, 45, 0, 45)
    layout.CellPadding = UDim2.new(0, 8, 0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for _, action in ipairs(actions) do
        local btn = Instance.new("TextButton")
        btn.Parent = grid
        btn.BackgroundColor3 = Trinity.Theme.ElevatedBg
        btn.Size = UDim2.new(0, 45, 0, 45)
        btn.Text = action.icon or "⚡"
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = action.color or Trinity.Theme.Primary
        btn.TextSize = 20
        btn.AutoButtonColor = false
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn
        
        -- Tooltip
        local tooltip = Instance.new("TextLabel")
        tooltip.Parent = btn
        tooltip.BackgroundColor3 = Trinity.Theme.ElevatedBg
        tooltip.BackgroundTransparency = 0.1
        tooltip.BorderSizePixel = 0
        tooltip.Position = UDim2.new(0.5, 0, 0, -30)
        tooltip.AnchorPoint = Vector2.new(0.5, 0)
        tooltip.Size = UDim2.new(0, 80, 0, 24)
        tooltip.Font = Enum.Font.GothamMedium
        tooltip.Text = action.name or "Action"
        tooltip.TextColor3 = Trinity.Theme.TextPrimary
        tooltip.TextSize = 11
        tooltip.Visible = false
        tooltip.ZIndex = 100
        
        local ttCorner = Instance.new("UICorner")
        ttCorner.CornerRadius = UDim.new(0, 4)
        ttCorner.Parent = tooltip
        
        btn.MouseEnter:Connect(function()
            SafeTween(btn, {BackgroundColor3 = Trinity.Theme.Primary}, 0.2)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tooltip.Visible = true
            SafeTween(tooltip, {Position = UDim2.new(0.5, 0, 0, -35)}, 0.2)
        end)
        
        btn.MouseLeave:Connect(function()
            SafeTween(btn, {BackgroundColor3 = Trinity.Theme.ElevatedBg}, 0.2)
            btn.TextColor3 = action.color or Trinity.Theme.Primary
            SafeTween(tooltip, {Position = UDim2.new(0.5, 0, 0, -30)}, 0.2)
            tooltip.Visible = false
        end)
        
        btn.MouseButton1Click:Connect(function()
            if action.callback then action.callback() end
        end)
    end
    
    return grid
end

-- ==========================================
-- UTILITY FUNCTIONS
-- ==========================================

function Trinity.Notify(title, message, type, duration)
    type = type or "info"
    duration = duration or 5
    
    local colors = {
        info = Trinity.Theme.Info,
        success = Trinity.Theme.Success,
        warning = Trinity.Theme.Warning,
        error = Trinity.Theme.Danger
    }
    
    local color = colors[type] or colors.info
    
    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.BackgroundColor3 = Trinity.Theme.PanelBg
    notif.BackgroundTransparency = 0.1
    notif.Position = UDim2.new(1, 300, 1, -100)
    notif.Size = UDim2.new(0, 300, 0, 0)
    notif.AutomaticSize = Enum.AutomaticSize.Y
    notif.ZIndex = 1000
    
    AddGlassEffects(notif, 12)
    
    -- Accent bar
    local bar = Instance.new("Frame")
    bar.Parent = notif
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.Size = UDim2.new(0, 4, 1, 0)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notif
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 12)
    titleLabel.Size = UDim2.new(1, -40, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Trinity.Theme.TextPrimary
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Parent = notif
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 20, 0, 36)
    msgLabel.Size = UDim2.new(1, -40, 0, 0)
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.Text = message
    msgLabel.TextColor3 = Trinity.Theme.TextSecondary
    msgLabel.TextSize = 12
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    
    local closePadding = Instance.new("Frame")
    closePadding.Parent = notif
    closePadding.BackgroundTransparency = 1
    closePadding.Size = UDim2.new(1, 0, 0, 12)
    closePadding.Position = UDim2.new(0, 0, 1, 0)
    closePadding.LayoutOrder = 100
    
    -- Animate in
    SafeTween(notif, {Position = UDim2.new(1, -320, 1, -100)}, 0.5)
    
    -- Auto close
    task.delay(duration, function()
        SafeTween(notif, {Position = UDim2.new(1, 300, 1, -100)}, 0.5)
        task.wait(0.5)
        notif:Destroy()
    end)
end

function Trinity.SetVisibility(visible)
    Trinity.State.UIVisible = visible
    local targetBlur = visible and 20 or 0
    local targetTrans = visible and 0 or 1
    
    SafeTween(MainFrame, {Position = visible and UDim2.new(0.5, -550, 0.5, -300) or UDim2.new(0.5, -550, 0.5, -200)}, 0.5)
    SafeTween(Blur, {Size = targetBlur}, 0.5)
    
    for _, panel in ipairs({Sidebar, ContentPanel, InspectorPanel}) do
        SafeTween(panel, {BackgroundTransparency = visible and Trinity.Theme.GlassTransparency or 1}, 0.5)
    end
end

function Trinity.SetTheme(primary, secondary)
    Trinity.Theme.Primary = primary or Trinity.Theme.Primary
    Trinity.Theme.Secondary = secondary or Trinity.Theme.Secondary
    
    -- Update all accent elements
    for _, obj in ipairs(Trinity.State.Accents or {}) do
        if obj and obj.Parent then
            SafeTween(obj, {Color = Trinity.Theme.Primary}, 0.3)
        end
    end
end

-- Draggable Support
function Trinity.MakeDraggable(handle, target)
    target = target or handle
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Initialize blur
SafeTween(Blur, {Size = 20}, 1)

-- Make draggable from header
Trinity.MakeDraggable(ContentHeader, MainFrame)

return Trinity
