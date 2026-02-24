local Sakura = {}
Sakura.__index = Sakura

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
local CoreGui = GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local function IsFunctionSupported(funcName)
    local env = getgenv and getgenv() or _G
    return env[funcName] ~= nil
end

local SafeFileSystem = {
    Write = function(path, content)
        if IsFunctionSupported("writefile") then
            pcall(function() writefile(path, content) end)
        end
    end,
    Read = function(path)
        if IsFunctionSupported("readfile") and IsFunctionSupported("isfile") then
            if isfile(path) then
                local ok, data = pcall(function() return readfile(path) end)
                if ok then return data end
            end
        end
        return nil
    end,
    MakeFolder = function(path)
        if IsFunctionSupported("makefolder") and IsFunctionSupported("isfolder") then
            if not isfolder(path) then
                pcall(function() makefolder(path) end)
            end
        end
    end
}

Sakura.Theme = {
    GlassBackground = Color3.fromRGB(18, 18, 22),
    GlassSurface = Color3.fromRGB(28, 26, 32),
    GlassHover = Color3.fromRGB(38, 36, 44),
    SakuraPink = Color3.fromRGB(255, 183, 197),
    SakuraDark = Color3.fromRGB(237, 123, 141),
    SakuraLight = Color3.fromRGB(251, 201, 228),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 175, 185),
    TextMuted = Color3.fromRGB(110, 105, 115),
    Border = Color3.fromRGB(255, 183, 197),
    BorderTransparency = 0.6,
    BackgroundTransparency = 0.08,
    Success = Color3.fromRGB(140, 200, 120),
    Error = Color3.fromRGB(255, 100, 100)
}

local function CleanupExisting()
    local existing = CoreGui:FindFirstChild("SakuraUI")
    if existing then
        pcall(function() existing:Destroy() end)
    end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") and v.Name == "SakuraBlur" then
            pcall(function() v:Destroy() end)
        end
    end
end

CleanupExisting()

local function SafeTween(obj, properties, duration, style, direction)
    if not obj or not obj.Parent then return nil end
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    
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

local function AddGlassEffects(parent, radius)
    if not parent then return nil end
    radius = radius or 6
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Sakura.Theme.Border
    stroke.Transparency = Sakura.Theme.BorderTransparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    
    return stroke
end

local function CreateShadow(parent, intensity)
    intensity = intensity or 0.35
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131604521558887"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 1 - intensity
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SakuraUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local Blur = Instance.new("BlurEffect")
Blur.Name = "SakuraBlur"
Blur.Size = 0
Blur.Enabled = true
Blur.Parent = Lighting

Sakura.ScreenGui = ScreenGui
Sakura.Blur = Blur

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Sakura.Theme.GlassBackground
MainFrame.BackgroundTransparency = Sakura.Theme.BackgroundTransparency
MainFrame.Size = UDim2.new(0, 800, 0, 500)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

AddGlassEffects(MainFrame, 0)
CreateShadow(MainFrame, 0.4)

Sakura.MainFrame = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Sakura.Theme.GlassSurface
Header.BackgroundTransparency = 0.15
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BorderSizePixel = 0

local HeaderAccent = Instance.new("Frame")
HeaderAccent.Parent = Header
HeaderAccent.BackgroundColor3 = Sakura.Theme.SakuraPink
HeaderAccent.Size = UDim2.new(1, 0, 0, 2)
HeaderAccent.Position = UDim2.new(0, 0, 1, -2)
HeaderAccent.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "SAKURA"
TitleLabel.TextColor3 = Sakura.Theme.SakuraPink
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 2)
CloseBtn.Text = ""
CloseBtn.AutoButtonColor = false

local CloseIcon = Instance.new("ImageLabel")
CloseIcon.Parent = CloseBtn
CloseIcon.BackgroundTransparency = 1
CloseIcon.Size = UDim2.new(0, 16, 0, 16)
CloseIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
CloseIcon.Image = "rbxassetid://6031094678"
CloseIcon.ImageColor3 = Sakura.Theme.TextSecondary

CloseBtn.MouseEnter:Connect(function()
    SafeTween(CloseIcon, {ImageColor3 = Sakura.Theme.Error})
end)

CloseBtn.MouseLeave:Connect(function()
    SafeTween(CloseIcon, {ImageColor3 = Sakura.Theme.TextSecondary})
end)

CloseBtn.MouseButton1Click:Connect(function()
    Sakura.ToggleUI()
end)

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Parent = Header
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Size = UDim2.new(0, 40, 0, 40)
SettingsBtn.Position = UDim2.new(1, -85, 0, 2)
SettingsBtn.Text = ""
SettingsBtn.AutoButtonColor = false

local SettingsIcon = Instance.new("ImageLabel")
SettingsIcon.Parent = SettingsBtn
SettingsIcon.BackgroundTransparency = 1
SettingsIcon.Size = UDim2.new(0, 18, 0, 18)
SettingsIcon.Position = UDim2.new(0.5, -9, 0.5, -9)
SettingsIcon.Image = "rbxassetid://6031280882"
SettingsIcon.ImageColor3 = Sakura.Theme.TextSecondary

SettingsBtn.MouseEnter:Connect(function()
    SafeTween(SettingsIcon, {ImageColor3 = Sakura.Theme.SakuraPink})
end)

SettingsBtn.MouseLeave:Connect(function()
    SafeTween(SettingsIcon, {ImageColor3 = Sakura.Theme.TextSecondary})
end)

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 45)
ContentFrame.Size = UDim2.new(1, 0, 1, -45)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = ContentFrame
Sidebar.BackgroundColor3 = Sakura.Theme.GlassSurface
Sidebar.BackgroundTransparency = 0.25
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 2)

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.Parent = Sidebar
SidebarPadding.PaddingTop = UDim.new(0, 15)
SidebarPadding.PaddingLeft = UDim.new(0, 12)
SidebarPadding.PaddingRight = UDim.new(0, 12)

local MainContent = Instance.new("Frame")
MainContent.Name = "MainContent"
MainContent.Parent = ContentFrame
MainContent.BackgroundTransparency = 1
MainContent.Position = UDim2.new(0, 140, 0, 0)
MainContent.Size = UDim2.new(1, -140, 1, 0)

local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Parent = MainContent
PageContainer.BackgroundTransparency = 1
PageContainer.Size = UDim2.new(1, 0, 1, 0)

local SettingsPanel = Instance.new("Frame")
SettingsPanel.Name = "SettingsPanel"
SettingsPanel.Parent = ContentFrame
SettingsPanel.BackgroundColor3 = Sakura.Theme.GlassSurface
SettingsPanel.BackgroundTransparency = 0.1
SettingsPanel.Position = UDim2.new(0, -200, 0, 0)
SettingsPanel.Size = UDim2.new(0, 200, 1, 0)
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Visible = false
SettingsPanel.ZIndex = 100

AddGlassEffects(SettingsPanel, 0)

local SettingsHeader = Instance.new("Frame")
SettingsHeader.Parent = SettingsPanel
SettingsHeader.BackgroundColor3 = Sakura.Theme.GlassHover
SettingsHeader.BackgroundTransparency = 0.2
SettingsHeader.Size = UDim2.new(1, 0, 0, 40)
SettingsHeader.BorderSizePixel = 0

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Parent = SettingsHeader
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Size = UDim2.new(1, -20, 1, 0)
SettingsTitle.Position = UDim2.new(0, 15, 0, 0)
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.Text = "UI SETTINGS"
SettingsTitle.TextColor3 = Sakura.Theme.SakuraPink
SettingsTitle.TextSize = 14
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left

local SettingsContent = Instance.new("ScrollingFrame")
SettingsContent.Parent = SettingsPanel
SettingsContent.BackgroundTransparency = 1
SettingsContent.Position = UDim2.new(0, 0, 0, 40)
SettingsContent.Size = UDim2.new(1, 0, 1, -40)
SettingsContent.ScrollBarThickness = 2
SettingsContent.ScrollBarImageColor3 = Sakura.Theme.SakuraPink

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Parent = SettingsContent
SettingsLayout.Padding = UDim.new(0, 10)
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SettingsContentPadding = Instance.new("UIPadding")
SettingsContentPadding.Parent = SettingsContent
SettingsContentPadding.PaddingTop = UDim.new(0, 15)
SettingsContentPadding.PaddingLeft = UDim.new(0, 15)
SettingsContentPadding.PaddingRight = UDim.new(0, 15)

SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SettingsContent.CanvasSize = UDim2.new(0, 0, 0, SettingsLayout.AbsoluteContentSize.Y + 30)
end)

local settingsOpen = false
SettingsBtn.MouseButton1Click:Connect(function()
    settingsOpen = not settingsOpen
    SettingsPanel.Visible = true
    SafeTween(SettingsPanel, {
        Position = settingsOpen and UDim2.new(0, 0, 0, 0) or UDim2.new(0, -200, 0, 0)
    }, 0.4, Enum.EasingStyle.Quart)
end)

local Tabs = {}
local TabButtons = {}
local CurrentTab = nil

function Sakura.SwitchTab(tabName)
    for name, page in pairs(Tabs) do
        if page and page.Parent then
            page.Visible = (name == tabName)
        end
    end

    for name, btnData in pairs(TabButtons) do
        local btn = btnData.Button
        local indicator = btnData.Indicator
        if btn and btn.Parent then
            if name == tabName then
                SafeTween(btn, {BackgroundColor3 = Sakura.Theme.SakuraPink, BackgroundTransparency = 0.75})
                SafeTween(indicator, {BackgroundTransparency = 0})
                SafeTween(btnData.Label, {TextColor3 = Sakura.Theme.TextPrimary})
                SafeTween(btnData.Icon, {ImageColor3 = Sakura.Theme.SakuraPink})
            else
                SafeTween(btn, {BackgroundColor3 = Sakura.Theme.GlassHover, BackgroundTransparency = 0.5})
                SafeTween(indicator, {BackgroundTransparency = 1})
                SafeTween(btnData.Label, {TextColor3 = Sakura.Theme.TextSecondary})
                SafeTween(btnData.Icon, {ImageColor3 = Sakura.Theme.TextSecondary})
            end
        end
    end

    CurrentTab = tabName
end

function Sakura.AddTab(name, iconId)
    local btnContainer = Instance.new("TextButton")
    btnContainer.Name = name .. "Tab"
    btnContainer.Size = UDim2.new(1, 0, 0, 36)
    btnContainer.BackgroundColor3 = Sakura.Theme.GlassHover
    btnContainer.BackgroundTransparency = 0.5
    btnContainer.Text = ""
    btnContainer.AutoButtonColor = false
    btnContainer.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btnContainer

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Parent = btnContainer
    indicator.BackgroundColor3 = Sakura.Theme.SakuraPink
    indicator.Size = UDim2.new(0, 3, 0, 18)
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = btnContainer
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0.5, -10)
    icon.Image = iconId or "rbxassetid://6034684930"
    icon.ImageColor3 = Sakura.Theme.TextSecondary

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = btnContainer
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 40, 0, 0)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -30, 1, -30)
    page.Position = UDim2.new(0, 15, 0, 15)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Sakura.Theme.SakuraPink
    page.Parent = PageContainer

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 15)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
    end)

    Tabs[name] = page
    TabButtons[name] = {Button = btnContainer, Indicator = indicator, Icon = icon, Label = label}

    btnContainer.MouseButton1Click:Connect(function()
        Sakura.SwitchTab(name)
    end)

    btnContainer.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            SafeTween(btnContainer, {BackgroundTransparency = 0.3})
        end
    end)

    btnContainer.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            SafeTween(btnContainer, {BackgroundTransparency = 0.5})
        end
    end)

    return page
end

function Sakura.CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Sakura.Theme.GlassSurface
    section.BackgroundTransparency = 0.35
    section.BorderSizePixel = 0
    section.Parent = parent

    AddGlassEffects(section, 8)

    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Parent = section
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 38)
    header.Text = ""
    header.AutoButtonColor = false

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Parent = header
    headerLabel.BackgroundTransparency = 1
    headerLabel.Position = UDim2.new(0, 15, 0, 0)
    headerLabel.Size = UDim2.new(1, -50, 1, 0)
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.Text = title
    headerLabel.TextColor3 = Sakura.Theme.TextPrimary
    headerLabel.TextSize = 13
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left

    local arrow = Instance.new("ImageLabel")
    arrow.Parent = header
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -31, 0.5, -8)
    arrow.Image = "rbxassetid://6031091004"
    arrow.ImageColor3 = Sakura.Theme.SakuraPink
    arrow.Rotation = 0

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = section
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 38)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.ClipsDescendants = true

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = content
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)

    local collapsed = false
    local contentHeight = 0

    header.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        SafeTween(arrow, {Rotation = collapsed and -90 or 0}, 0.3)
        if collapsed then
            contentHeight = contentLayout.AbsoluteContentSize.Y + 15
            SafeTween(content, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            SafeTween(section, {Size = UDim2.new(1, 0, 0, 38)}, 0.3)
        else
            SafeTween(content, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.3)
            SafeTween(section, {Size = UDim2.new(1, 0, 0, 38 + contentHeight)}, 0.3)
        end
    end)

    return content
end

function Sakura.CreateDualColumnSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Sakura.Theme.GlassSurface
    section.BackgroundTransparency = 0.35
    section.BorderSizePixel = 0
    section.Parent = parent

    AddGlassEffects(section, 8)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = section
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 38)

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Parent = header
    headerLabel.BackgroundTransparency = 1
    headerLabel.Position = UDim2.new(0, 15, 0, 0)
    headerLabel.Size = UDim2.new(1, -30, 1, 0)
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.Text = title
    headerLabel.TextColor3 = Sakura.Theme.TextPrimary
    headerLabel.TextSize = 13
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = section
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 38)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = content
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)

    local leftColumn = Instance.new("Frame")
    leftColumn.Name = "LeftColumn"
    leftColumn.Parent = content
    leftColumn.BackgroundTransparency = 1
    leftColumn.Size = UDim2.new(0.48, 0, 0, 0)
    leftColumn.AutomaticSize = Enum.AutomaticSize.Y

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Parent = leftColumn
    leftLayout.Padding = UDim.new(0, 8)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local rightColumn = Instance.new("Frame")
    rightColumn.Name = "RightColumn"
    rightColumn.Parent = content
    rightColumn.BackgroundTransparency = 1
    rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
    rightColumn.Size = UDim2.new(0.48, 0, 0, 0)
    rightColumn.AutomaticSize = Enum.AutomaticSize.Y

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Parent = rightColumn
    rightLayout.Padding = UDim.new(0, 8)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder

    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local maxHeight = math.max(leftLayout.AbsoluteContentSize.Y, rightLayout.AbsoluteContentSize.Y)
        content.Size = UDim2.new(1, 0, 0, maxHeight + 15)
    end)

    return leftColumn, rightColumn
end

function Sakura.AddToggle(parent, text, default, callback)
    local api = {}
    local state = default or false
    local safeCallback = callback or function() end

    local container = Instance.new("TextButton")
    container.Name = text .. "Toggle"
    container.Size = UDim2.new(1, 0, 0, 26)
    container.BackgroundTransparency = 1
    container.Text = ""
    container.AutoButtonColor = false
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "Background"
    toggleBg.Parent = container
    toggleBg.BackgroundColor3 = Sakura.Theme.GlassHover
    toggleBg.Size = UDim2.new(0, 34, 0, 18)
    toggleBg.Position = UDim2.new(1, -38, 0.5, -9)
    toggleBg.BorderSizePixel = 0

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = toggleBg

    local toggleFill = Instance.new("Frame")
    toggleFill.Name = "Fill"
    toggleFill.Parent = toggleBg
    toggleFill.BackgroundColor3 = state and Sakura.Theme.SakuraPink or Sakura.Theme.GlassHover
    toggleFill.Size = state and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)
    toggleFill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = toggleFill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = toggleBg
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BorderSizePixel = 0

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function updateVisual()
        SafeTween(toggleFill, {
            Size = state and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = state and Sakura.Theme.SakuraPink or Sakura.Theme.GlassHover
        }, 0.2)
        SafeTween(knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
        label.TextColor3 = state and Sakura.Theme.TextPrimary or Sakura.Theme.TextSecondary
    end

    function api:Set(value)
        value = not not value
        if state == value then return end
        state = value
        updateVisual()
        safeCallback(state)
    end

    function api:Get()
        return state
    end

    container.MouseButton1Click:Connect(function()
        api:Set(not state)
    end)

    updateVisual()
    return api
end

function Sakura.AddSlider(parent, text, min, max, default, decimals, suffix, callback)
    local api = {}
    decimals = decimals or 0
    suffix = suffix or ""
    local value = default or min
    local power = 10 ^ decimals

    local container = Instance.new("Frame")
    container.Name = text .. "Slider"
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.5, 0, 0, 16)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = container
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.Size = UDim2.new(0.5, 0, 0, 16)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Sakura.Theme.SakuraPink
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local barBg = Instance.new("Frame")
    barBg.Parent = container
    barBg.BackgroundColor3 = Sakura.Theme.GlassHover
    barBg.Position = UDim2.new(0, 0, 0, 24)
    barBg.Size = UDim2.new(1, 0, 0, 4)
    barBg.BorderSizePixel = 0

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = barBg

    local fill = Instance.new("Frame")
    fill.Parent = barBg
    fill.BackgroundColor3 = Sakura.Theme.SakuraPink
    fill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Parent = fill
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(1, -6, 0.5, -6)
    knob.BorderSizePixel = 0

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local function round(v)
        return math.floor(v * power + 0.5) / power
    end

    local function updateVisual()
        local percent = math.clamp((value - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(value) .. suffix
    end

    function api:Set(v)
        v = tonumber(v) or value
        v = math.clamp(round(v), min, max)
        if v == value then return end
        value = v
        updateVisual()
        if callback then callback(value) end
    end

    function api:Get()
        return value
    end

    local dragging = false

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            api:Set(min + ((max - min) * pos))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            api:Set(min + ((max - min) * pos))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    updateVisual()
    return api
end

function Sakura.AddButton(parent, text, callback)
    local safeCallback = callback or function() end

    local btn = Instance.new("TextButton")
    btn.Name = text .. "Button"
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Sakura.Theme.SakuraPink
    btn.BackgroundTransparency = 0.15
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        SafeTween(btn, {BackgroundTransparency = 0})
    end)

    btn.MouseLeave:Connect(function()
        SafeTween(btn, {BackgroundTransparency = 0.15})
    end)

    btn.MouseButton1Click:Connect(function()
        SafeTween(btn, {Size = UDim2.new(0.97, 0, 0, 26)}, 0.08)
        task.delay(0.08, function()
            SafeTween(btn, {Size = UDim2.new(1, 0, 0, 28)}, 0.08)
        end)
        safeCallback()
    end)

    return btn
end

function Sakura.AddDropdown(parent, text, options, default, callback)
    local api = {}
    local selected = default or options[1]
    local isOpen = false

    local container = Instance.new("Frame")
    container.Name = text .. "Dropdown"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = parent
    container.ZIndex = 10

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.BackgroundColor3 = Sakura.Theme.GlassHover
    btn.BackgroundTransparency = 0.3
    btn.Position = UDim2.new(0, 0, 0, 20)
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Text = "  " .. selected
    btn.TextColor3 = Sakura.Theme.TextPrimary
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local arrow = Instance.new("ImageLabel")
    arrow.Parent = btn
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -26, 0.5, -7)
    arrow.Image = "rbxassetid://6031091004"
    arrow.ImageColor3 = Sakura.Theme.SakuraPink

    local list = Instance.new("Frame")
    list.Parent = container
    list.BackgroundColor3 = Sakura.Theme.GlassSurface
    list.BackgroundTransparency = 0.05
    list.Position = UDim2.new(0, 0, 0, 48)
    list.Size = UDim2.new(1, 0, 0, 0)
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 20

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = list

    local layout = Instance.new("UIListLayout")
    layout.Parent = list
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function updateArrow()
        SafeTween(arrow, {Rotation = isOpen and 180 or 0}, 0.2)
    end

    local function close()
        isOpen = false
        updateArrow()
        SafeTween(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        task.delay(0.2, function()
            if not isOpen then list.Visible = false end
        end)
    end

    local function open()
        isOpen = true
        list.Visible = true
        updateArrow()
        SafeTween(list, {Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)}, 0.2)
    end

    btn.MouseButton1Click:Connect(function()
        if isOpen then close() else open() end
    end)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Parent = list
        optBtn.BackgroundTransparency = 1
        optBtn.Size = UDim2.new(1, 0, 0, 24)
        optBtn.Text = "  " .. opt
        optBtn.TextColor3 = Sakura.Theme.TextSecondary
        optBtn.TextSize = 11
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 21

        optBtn.MouseEnter:Connect(function()
            SafeTween(optBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = Sakura.Theme.SakuraPink})
        end)

        optBtn.MouseLeave:Connect(function()
            SafeTween(optBtn, {BackgroundTransparency = 1})
        end)

        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            btn.Text = "  " .. selected
            close()
            if callback then callback(selected) end
        end)
    end

    function api:Set(val)
        if table.find(options, val) then
            selected = val
            btn.Text = "  " .. selected
            if callback then callback(selected) end
        end
    end

    function api:Get()
        return selected
    end

    return api
end

function Sakura.AddKeybind(parent, text, defaultKey, callback)
    local api = {}
    local currentKey = defaultKey or Enum.KeyCode.Unknown
    local listening = false

    local container = Instance.new("TextButton")
    container.Name = text .. "Keybind"
    container.Size = UDim2.new(1, 0, 0, 26)
    container.BackgroundTransparency = 1
    container.Text = ""
    container.AutoButtonColor = false
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local keyBox = Instance.new("Frame")
    keyBox.Parent = container
    keyBox.BackgroundColor3 = Sakura.Theme.GlassHover
    keyBox.Size = UDim2.new(0, 45, 0, 20)
    keyBox.Position = UDim2.new(1, -50, 0.5, -10)
    keyBox.BorderSizePixel = 0

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = keyBox

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Parent = keyBox
    keyLabel.BackgroundTransparency = 1
    keyLabel.Size = UDim2.new(1, 0, 1, 0)
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.Text = currentKey.Name ~= "Unknown" and currentKey.Name or "None"
    keyLabel.TextColor3 = Sakura.Theme.TextPrimary
    keyLabel.TextSize = 10

    local function updateVisual()
        keyLabel.Text = listening and "..." or (currentKey.Name ~= "Unknown" and currentKey.Name or "None")
        SafeTween(keyBox, {
            BackgroundColor3 = listening and Sakura.Theme.SakuraPink or Sakura.Theme.GlassHover
        }, 0.2)
    end

    container.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        updateVisual()

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode
                listening = false
                updateVisual()
                conn:Disconnect()
            end
        end)
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or listening then return end
        if input.KeyCode == currentKey and callback then
            callback(currentKey)
        end
    end)

    function api:Set(key)
        if typeof(key) == "EnumItem" then
            currentKey = key
            updateVisual()
        end
    end

    function api:Get()
        return currentKey
    end

    return api
end

function Sakura.AddTextbox(parent, text, placeholder, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Textbox"
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = container
    box.BackgroundColor3 = Sakura.Theme.GlassHover
    box.BackgroundTransparency = 0.3
    box.Position = UDim2.new(0, 0, 0, 20)
    box.Size = UDim2.new(1, 0, 0, 24)
    box.Text = ""
    box.PlaceholderText = placeholder or "Enter text..."
    box.TextColor3 = Sakura.Theme.TextPrimary
    box.PlaceholderColor3 = Sakura.Theme.TextMuted
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 12
    box.ClearTextOnFocus = false

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box

    box.Focused:Connect(function()
        SafeTween(box, {BackgroundTransparency = 0.1, BackgroundColor3 = Sakura.Theme.GlassSurface})
    end)

    box.FocusLost:Connect(function(enterPressed)
        SafeTween(box, {BackgroundTransparency = 0.3, BackgroundColor3 = Sakura.Theme.GlassHover})
        if callback then callback(box.Text, enterPressed) end
    end)

    return {
        Get = function() return box.Text end,
        Set = function(val) box.Text = val end
    }
end

function Sakura.AddColorPicker(parent, text, defaultColor, callback)
    local api = {}
    local color = defaultColor or Color3.fromRGB(255, 183, 197)

    local container = Instance.new("Frame")
    container.Name = text .. "ColorPicker"
    container.Size = UDim2.new(1, 0, 0, 26)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("TextButton")
    preview.Parent = container
    preview.BackgroundColor3 = color
    preview.Size = UDim2.new(0, 36, 0, 20)
    preview.Position = UDim2.new(1, -41, 0.5, -10)
    preview.Text = ""
    preview.AutoButtonColor = false

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = preview

    local stroke = Instance.new("UIStroke")
    stroke.Parent = preview
    stroke.Color = Sakura.Theme.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.5

    local pickerFrame = Instance.new("Frame")
    pickerFrame.Parent = container
    pickerFrame.BackgroundColor3 = Sakura.Theme.GlassSurface
    pickerFrame.BackgroundTransparency = 0.05
    pickerFrame.Position = UDim2.new(0, 0, 0, 30)
    pickerFrame.Size = UDim2.new(1, 0, 0, 0)
    pickerFrame.ClipsDescendants = true
    pickerFrame.Visible = false
    pickerFrame.ZIndex = 50

    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 8)
    pickerCorner.Parent = pickerFrame

    local isOpen = false

    local rSlider = Sakura.AddSlider(pickerFrame, "R", 0, 255, color.R * 255, 0, "", function(v)
        color = Color3.fromRGB(v, color.G * 255, color.B * 255)
        preview.BackgroundColor3 = color
        if callback then callback(color) end
    end)
    rSlider.Set(color.R * 255)

    local gSlider = Sakura.AddSlider(pickerFrame, "G", 0, 255, color.G * 255, 0, "", function(v)
        color = Color3.fromRGB(color.R * 255, v, color.B * 255)
        preview.BackgroundColor3 = color
        if callback then callback(color) end
    end)
    gSlider.Set(color.G * 255)

    local bSlider = Sakura.AddSlider(pickerFrame, "B", 0, 255, color.B * 255, 0, "", function(v)
        color = Color3.fromRGB(color.R * 255, color.G * 255, v)
        preview.BackgroundColor3 = color
        if callback then callback(color) end
    end)
    bSlider.Set(color.B * 255)

    preview.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        pickerFrame.Visible = true
        SafeTween(pickerFrame, {Size = isOpen and UDim2.new(1, 0, 0, 140) or UDim2.new(1, 0, 0, 0)}, 0.3)
        if not isOpen then
            task.delay(0.3, function()
                pickerFrame.Visible = false
            end)
        end
    end)

    function api:Set(newColor)
        color = newColor
        preview.BackgroundColor3 = color
        rSlider.Set(color.R * 255)
        gSlider.Set(color.G * 255)
        bSlider.Set(color.B * 255)
        if callback then callback(color) end
    end

    function api:Get()
        return color
    end

    return api
end

function Sakura.AddLabel(parent, text, options)
    options = options or {}
    local isBold = options.Bold or false
    local color = options.Color or Sakura.Theme.TextSecondary

    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = isBold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = color
    label.TextSize = options.Size or 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true

    return label
end

function Sakura.AddSeparator(parent)
    local line = Instance.new("Frame")
    line.Parent = parent
    line.BackgroundColor3 = Sakura.Theme.SakuraPink
    line.BackgroundTransparency = 0.8
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BorderSizePixel = 0
    return line
end

local PlayerCard = Instance.new("Frame")
PlayerCard.Name = "PlayerCard"
PlayerCard.Parent = ScreenGui
PlayerCard.BackgroundColor3 = Sakura.Theme.GlassBackground
PlayerCard.BackgroundTransparency = 0.1
PlayerCard.Position = UDim2.new(0, 15, 1, -85)
PlayerCard.Size = UDim2.new(0, 240, 0, 70)
PlayerCard.BorderSizePixel = 0

AddGlassEffects(PlayerCard, 8)
CreateShadow(PlayerCard, 0.3)

local PlayerAccent = Instance.new("Frame")
PlayerAccent.Parent = PlayerCard
PlayerAccent.BackgroundColor3 = Sakura.Theme.SakuraPink
PlayerAccent.Size = UDim2.new(0, 3, 1, 0)
PlayerAccent.BorderSizePixel = 0

local HeadshotFrame = Instance.new("Frame")
HeadshotFrame.Parent = PlayerCard
HeadshotFrame.BackgroundColor3 = Sakura.Theme.GlassSurface
HeadshotFrame.Size = UDim2.new(0, 50, 0, 50)
HeadshotFrame.Position = UDim2.new(0, 12, 0.5, -25)
HeadshotFrame.BorderSizePixel = 0

local HeadshotCorner = Instance.new("UICorner")
HeadshotCorner.CornerRadius = UDim.new(0, 6)
HeadshotCorner.Parent = HeadshotFrame

local HeadshotImage = Instance.new("ImageLabel")
HeadshotImage.Parent = HeadshotFrame
HeadshotImage.BackgroundTransparency = 1
HeadshotImage.Size = UDim2.new(1, -4, 1, -4)
HeadshotImage.Position = UDim2.new(0, 2, 0, 2)
HeadshotImage.Image = ""

local success, userId = pcall(function()
    return LocalPlayer.UserId
end)

if success then
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    HeadshotImage.Image = content
end

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Parent = PlayerCard
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Position = UDim2.new(0, 72, 0, 12)
UsernameLabel.Size = UDim2.new(0, 150, 0, 20)
UsernameLabel.Font = Enum.Font.GothamBold
UsernameLabel.Text = LocalPlayer.Name
UsernameLabel.TextColor3 = Sakura.Theme.TextPrimary
UsernameLabel.TextSize = 14
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Parent = PlayerCard
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Position = UDim2.new(0, 72, 0, 32)
UserIdLabel.Size = UDim2.new(0, 150, 0, 16)
UserIdLabel.Font = Enum.Font.GothamMedium
UserIdLabel.Text = "ID: " .. tostring(LocalPlayer.UserId)
UserIdLabel.TextColor3 = Sakura.Theme.TextMuted
UserIdLabel.TextSize = 11
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left

local ExpiryLabel = Instance.new("TextLabel")
ExpiryLabel.Parent = PlayerCard
ExpiryLabel.BackgroundTransparency = 1
ExpiryLabel.Position = UDim2.new(0, 72, 0, 48)
ExpiryLabel.Size = UDim2.new(0, 150, 0, 16)
ExpiryLabel.Font = Enum.Font.GothamMedium
ExpiryLabel.Text = "Expires: Lifetime"
ExpiryLabel.TextColor3 = Sakura.Theme.SakuraPink
ExpiryLabel.TextSize = 11
ExpiryLabel.TextXAlignment = Enum.TextXAlignment.Left

local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Parent = ScreenGui
WatermarkFrame.BackgroundColor3 = Sakura.Theme.GlassBackground
WatermarkFrame.BackgroundTransparency = 0.1
WatermarkFrame.Position = UDim2.new(1, -235, 1, -50)
WatermarkFrame.Size = UDim2.new(0, 220, 0, 32)
WatermarkFrame.BorderSizePixel = 0

AddGlassEffects(WatermarkFrame, 6)
CreateShadow(WatermarkFrame, 0.3)

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Parent = WatermarkFrame
WatermarkText.BackgroundTransparency = 1
WatermarkText.Size = UDim2.new(1, -12, 1, 0)
WatermarkText.Position = UDim2.new(0, 6, 0, 0)
WatermarkText.Font = Enum.Font.GothamBold
WatermarkText.Text = "SAKURA | FPS: 0 | PING: 0ms"
WatermarkText.TextColor3 = Sakura.Theme.TextPrimary
WatermarkText.TextSize = 11

local WatermarkAccent = Instance.new("Frame")
WatermarkAccent.Parent = WatermarkFrame
WatermarkAccent.BackgroundColor3 = Sakura.Theme.SakuraPink
WatermarkAccent.Size = UDim2.new(0, 2, 1, 0)
WatermarkAccent.BorderSizePixel = 0

RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    WatermarkText.Text = string.format("SAKURA | FPS: %d | PING: %dms", fps, math.floor(ping))
end)

local isVisible = true
local uiKey = Enum.KeyCode.RightAlt

function Sakura.ToggleUI()
    isVisible = not isVisible
    local targetBlur = isVisible and 15 or 0
    
    SafeTween(MainFrame, {
        Position = isVisible and UDim2.new(0.5, -400, 0.5, -250) or UDim2.new(0.5, -400, 1.5, 0)
    }, 0.4, Enum.EasingStyle.Quart)
    SafeTween(Blur, {Size = targetBlur}, 0.4)
    SafeTween(PlayerCard, {
        Position = isVisible and UDim2.new(0, 15, 1, -85) or UDim2.new(0, 15, 1, 20)
    }, 0.4)
    SafeTween(WatermarkFrame, {
        Position = isVisible and UDim2.new(1, -235, 1, -50) or UDim2.new(1, -235, 1, 20)
    }, 0.4)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == uiKey then
        Sakura.ToggleUI()
    end
end)

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

function Sakura.Notify(title, message, notifType, duration)
    duration = duration or 3
    notifType = notifType or "info"
    
    local colors = {
        info = Sakura.Theme.SakuraPink,
        success = Sakura.Theme.Success,
        error = Sakura.Theme.Error
    }

    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.BackgroundColor3 = Sakura.Theme.GlassSurface
    notif.BackgroundTransparency = 0.05
    notif.Size = UDim2.new(0, 280, 0, 70)
    notif.Position = UDim2.new(1, 20, 1, -90)
    
    AddGlassEffects(notif, 8)
    CreateShadow(notif, 0.3)

    local accent = Instance.new("Frame")
    accent.Parent = notif
    accent.BackgroundColor3 = colors[notifType]
    accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notif
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 18, 0, 10)
    titleLabel.Size = UDim2.new(1, -28, 0, 18)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Sakura.Theme.TextPrimary
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Parent = notif
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 18, 0, 30)
    msgLabel.Size = UDim2.new(1, -28, 0, 30)
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.Text = message
    msgLabel.TextColor3 = Sakura.Theme.TextSecondary
    msgLabel.TextSize = 11
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true

    SafeTween(notif, {Position = UDim2.new(1, -300, 1, -90)}, 0.4, Enum.EasingStyle.Quart)

    task.delay(duration, function()
        SafeTween(notif, {Position = UDim2.new(1, 20, 1, -90)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.4)
        notif:Destroy()
    end)
end

local SettingsSection = Sakura.CreateSection(SettingsContent, "Theme")
Sakura.AddColorPicker(SettingsSection, "Accent Color", Sakura.Theme.SakuraPink, function(color)
    Sakura.Theme.SakuraPink = color
    Sakura.Theme.Border = color
end)

Sakura.AddSlider(SettingsSection, "Transparency", 0, 0.5, 0.08, 2, "", function(value)
    MainFrame.BackgroundTransparency = value
    SettingsPanel.BackgroundTransparency = value + 0.02
end)

Sakura.AddSlider(SettingsSection, "Blur Intensity", 0, 50, 15, 0, "", function(value)
    Blur.Size = value
end)

Sakura.SwitchTab(next(Tabs) or "General")

return Sakura
