local Ashuna = {}

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
local CoreGui = GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Exploit Compatibility
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
    end,
    IsFolder = function(path)
        if IsFunctionSupported("isfolder") then
            return isfolder(path)
        end
        return false
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

-- Global Storage
local GlobalEnv = getgenv and getgenv() or _G
if not GlobalEnv.AshunaStorage then
    GlobalEnv.AshunaStorage = {}
end

-- Cleanup Existing
local function CleanupExisting()
    local existing = CoreGui:FindFirstChild("AshunaUI")
    if existing then
        pcall(function() existing:Destroy() end)
    end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") and v.Name == "AshunaBlur" then
            pcall(function() v:Destroy() end)
        end
    end
end

CleanupExisting()

-- Theme System (Neverlose-inspired dark premium)
Ashuna.Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Surface = Color3.fromRGB(25, 25, 30),
    SurfaceHover = Color3.fromRGB(35, 35, 40),
    Accent = Color3.fromRGB(88, 101, 242),
    AccentHover = Color3.fromRGB(108, 121, 255),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(150, 150, 150),
    TextMuted = Color3.fromRGB(100, 100, 100),
    Border = Color3.fromRGB(40, 40, 45),
    Success = Color3.fromRGB(59, 165, 93),
    Warning = Color3.fromRGB(250, 168, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Rainbow = false
}

-- Accent Tracking
local AccentElements = {Frames = {}, Strokes = {}, TextLabels = {}, Sliders = {}, Toggles = {}}

local function TrackAccentElement(obj, elemType)
    local list = AccentElements[elemType .. "s"] or AccentElements[elemType]
    if list then
        table.insert(list, obj)
    end
end

-- Safe Tween
local function SafeTween(obj, properties, duration, style, direction)
    if not obj or not obj.Parent then return nil end
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
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

-- Update Accent Color
local function UpdateAccentColor(newColor)
    if typeof(newColor) ~= "Color3" then return end
    Ashuna.Theme.Accent = newColor

    for _, obj in pairs(AccentElements.Frames) do
        if obj and obj.Parent then
            SafeTween(obj, {BackgroundColor3 = newColor})
        end
    end

    for _, obj in pairs(AccentElements.Strokes) do
        if obj and obj.Parent then
            SafeTween(obj, {Color = newColor})
        end
    end

    for _, obj in pairs(AccentElements.TextLabels) do
        if obj and obj.Parent then
            SafeTween(obj, {TextColor3 = newColor})
        end
    end

    for _, obj in pairs(AccentElements.Sliders) do
        if obj and obj.Parent then
            SafeTween(obj, {BackgroundColor3 = newColor})
        end
    end

    for _, data in pairs(AccentElements.Toggles) do
        if data and data.Box and data.Box.Parent then
            local color = data.IsToggled and newColor or Ashuna.Theme.Surface
            SafeTween(data.Box, {BackgroundColor3 = color})
        end
    end
end

-- UI Construction Helpers
local function AddEffects(parent, radius)
    if not parent then return nil end
    radius = radius or 6
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Ashuna.Theme.Border
    stroke.Transparency = 0.8
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent

    return stroke
end

local function CreateShadow(parent, intensity)
    intensity = intensity or 0.5
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131604521558887"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 1 - intensity
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- Main UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AshunaUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local Blur = Instance.new("BlurEffect")
Blur.Name = "AshunaBlur"
Blur.Size = 0
Blur.Enabled = true
Blur.Parent = Lighting

Ashuna.ScreenGui = ScreenGui
Ashuna.Blur = Blur

-- Main Container (4-Panel Layout)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Ashuna.Theme.Background
MainFrame.Size = UDim2.new(0, 1000, 0, 600)
MainFrame.Position = UDim2.new(0.5, -500, 0.5, -300)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

AddEffects(MainFrame, 8)
CreateShadow(MainFrame, 0.6)

Ashuna.MainFrame = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Ashuna.Theme.Surface
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local HeaderBottom = Instance.new("Frame")
HeaderBottom.Parent = Header
HeaderBottom.BackgroundColor3 = Ashuna.Theme.Surface
HeaderBottom.BorderSizePixel = 0
HeaderBottom.Size = UDim2.new(1, 0, 0, 10)
HeaderBottom.Position = UDim2.new(0, 0, 1, -10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "ASHUNA"
TitleLabel.TextColor3 = Ashuna.Theme.TextPrimary
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local AccentBar = Instance.new("Frame")
AccentBar.Parent = Header
AccentBar.BackgroundColor3 = Ashuna.Theme.Accent
AccentBar.Size = UDim2.new(0, 3, 0, 20)
AccentBar.Position = UDim2.new(0, 10, 0.5, -10)
AccentBar.BorderSizePixel = 0

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(1, 0)
AccentCorner.Parent = AccentBar

TrackAccentElement(AccentBar, "Frame")

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Ashuna.Theme.TextSecondary
CloseBtn.TextSize = 28
CloseBtn.Font = Enum.Font.GothamBold

CloseBtn.MouseEnter:Connect(function()
    SafeTween(CloseBtn, {TextColor3 = Ashuna.Theme.Error})
end)

CloseBtn.MouseLeave:Connect(function()
    SafeTween(CloseBtn, {TextColor3 = Ashuna.Theme.TextSecondary})
end)

CloseBtn.MouseButton1Click:Connect(function()
    Ashuna.ToggleUI()
end)

-- 4-Panel Layout
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 50)
ContentFrame.Size = UDim2.new(1, 0, 1, -50)

-- Panel 1: Sidebar (Navigation)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = ContentFrame
Sidebar.BackgroundColor3 = Ashuna.Theme.Surface
Sidebar.Size = UDim2.new(0, 200, 1, 0)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 2)

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.Parent = Sidebar
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)

-- Panel 2: Main Content (Tabs)
local MainContent = Instance.new("Frame")
MainContent.Name = "MainContent"
MainContent.Parent = ContentFrame
MainContent.BackgroundTransparency = 1
MainContent.Position = UDim2.new(0, 200, 0, 0)
MainContent.Size = UDim2.new(0, 500, 1, 0)

local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Parent = MainContent
PageContainer.BackgroundTransparency = 1
PageContainer.Size = UDim2.new(1, 0, 1, 0)

-- Panel 3: Right Panel (Module Settings/Info)
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Parent = ContentFrame
RightPanel.BackgroundColor3 = Ashuna.Theme.Surface
RightPanel.Position = UDim2.new(0, 700, 0, 0)
RightPanel.Size = UDim2.new(0, 180, 1, 0)
RightPanel.BorderSizePixel = 0

local RightPanelLayout = Instance.new("UIListLayout")
RightPanelLayout.Parent = RightPanel
RightPanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightPanelLayout.Padding = UDim.new(0, 10)

local RightPanelPadding = Instance.new("UIPadding")
RightPanelPadding.Parent = RightPanel
RightPanelPadding.PaddingTop = UDim.new(0, 15)
RightPanelPadding.PaddingLeft = UDim.new(0, 15)
RightPanelPadding.PaddingRight = UDim.new(0, 15)

-- Panel 4: Bottom Panel (Console/Logs)
local BottomPanel = Instance.new("Frame")
BottomPanel.Name = "BottomPanel"
BottomPanel.Parent = ContentFrame
BottomPanel.BackgroundColor3 = Ashuna.Theme.Surface
BottomPanel.Position = UDim2.new(0, 200, 1, -120)
BottomPanel.Size = UDim2.new(0, 500, 0, 120)
BottomPanel.BorderSizePixel = 0
BottomPanel.Visible = false

-- Tab System
local Tabs = {}
local TabButtons = {}
local CurrentTab = nil

function Ashuna.SwitchTab(tabName)
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
                SafeTween(btn, {BackgroundColor3 = Ashuna.Theme.SurfaceHover})
                SafeTween(indicator, {BackgroundTransparency = 0})
            else
                SafeTween(btn, {BackgroundColor3 = Ashuna.Theme.Surface})
                SafeTween(indicator, {BackgroundTransparency = 1})
            end
        end
    end

    CurrentTab = tabName
end

function Ashuna.AddTab(name, iconId)
    local btnContainer = Instance.new("TextButton")
    btnContainer.Name = name .. "Tab"
    btnContainer.Size = UDim2.new(1, 0, 0, 40)
    btnContainer.BackgroundColor3 = Ashuna.Theme.Surface
    btnContainer.Text = ""
    btnContainer.AutoButtonColor = false
    btnContainer.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btnContainer

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Parent = btnContainer
    indicator.BackgroundColor3 = Ashuna.Theme.Accent
    indicator.Size = UDim2.new(0, 3, 0, 20)
    indicator.Position = UDim2.new(0, 0, 0.5, -10)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1

    TrackAccentElement(indicator, "Frame")

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = btnContainer
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0.5, -10)
    icon.Image = iconId or "rbxassetid://6034684930"
    icon.ImageColor3 = Ashuna.Theme.TextSecondary

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = btnContainer
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 42, 0, 0)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Ashuna.Theme.TextSecondary
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Ashuna.Theme.Accent
    page.Parent = PageContainer

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 15)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pagePadding = Instance.new("UIPadding")
    pagePadding.Parent = page
    pagePadding.PaddingRight = UDim.new(0, 10)

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
    end)

    Tabs[name] = page
    TabButtons[name] = {Button = btnContainer, Indicator = indicator, Icon = icon, Label = label}

    btnContainer.MouseButton1Click:Connect(function()
        Ashuna.SwitchTab(name)
    end)

    btnContainer.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            SafeTween(btnContainer, {BackgroundColor3 = Ashuna.Theme.SurfaceHover})
        end
    end)

    btnContainer.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            SafeTween(btnContainer, {BackgroundColor3 = Ashuna.Theme.Surface})
        end
    end)

    return page
end

-- Component Functions
function Ashuna.CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Ashuna.Theme.Surface
    section.BorderSizePixel = 0
    section.Parent = parent

    AddEffects(section, 6)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = section
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 35)

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Parent = header
    headerLabel.BackgroundTransparency = 1
    headerLabel.Position = UDim2.new(0, 15, 0, 0)
    headerLabel.Size = UDim2.new(1, -30, 1, 0)
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.Text = title:upper()
    headerLabel.TextColor3 = Ashuna.Theme.TextPrimary
    headerLabel.TextSize = 12
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left

    local accentLine = Instance.new("Frame")
    accentLine.Parent = header
    accentLine.BackgroundColor3 = Ashuna.Theme.Accent
    accentLine.Size = UDim2.new(0, 30, 0, 2)
    accentLine.Position = UDim2.new(0, 15, 1, -2)
    accentLine.BorderSizePixel = 0

    TrackAccentElement(accentLine, "Frame")

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = section
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 35)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = content
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)

    return content
end

function Ashuna.AddToggle(parent, text, default, callback)
    local api = {}
    local state = default or false
    local safeCallback = callback or function() end

    local container = Instance.new("TextButton")
    container.Name = text .. "Toggle"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Text = ""
    container.AutoButtonColor = false
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Ashuna.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "Background"
    toggleBg.Parent = container
    toggleBg.BackgroundColor3 = Ashuna.Theme.Surface
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBg.BorderSizePixel = 0

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = toggleBg

    local toggleFill = Instance.new("Frame")
    toggleFill.Name = "Fill"
    toggleFill.Parent = toggleBg
    toggleFill.BackgroundColor3 = state and Ashuna.Theme.Accent or Ashuna.Theme.SurfaceHover
    toggleFill.Size = state and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)
    toggleFill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = toggleFill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Parent = toggleBg
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BorderSizePixel = 0

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    TrackAccentElement(toggleFill, "Frame")
    table.insert(AccentElements.Toggles, {Box = toggleFill, IsToggled = function() return state end})

    local function updateVisual()
        SafeTween(toggleFill, {Size = state and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)}, 0.2)
        SafeTween(knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
        label.TextColor3 = state and Ashuna.Theme.TextPrimary or Ashuna.Theme.TextSecondary
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

function Ashuna.AddSlider(parent, text, min, max, default, decimals, suffix, callback)
    local api = {}
    decimals = decimals or 0
    suffix = suffix or ""
    local value = default or min
    local power = 10 ^ decimals

    local container = Instance.new("Frame")
    container.Name = text .. "Slider"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Ashuna.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = container
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.Size = UDim2.new(0.4, 0, 0, 20)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Ashuna.Theme.Accent
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    TrackAccentElement(valueLabel, "TextLabel")

    local barBg = Instance.new("Frame")
    barBg.Parent = container
    barBg.BackgroundColor3 = Ashuna.Theme.SurfaceHover
    barBg.Position = UDim2.new(0, 0, 0, 30)
    barBg.Size = UDim2.new(1, 0, 0, 6)
    barBg.BorderSizePixel = 0

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = barBg

    local fill = Instance.new("Frame")
    fill.Parent = barBg
    fill.BackgroundColor3 = Ashuna.Theme.Accent
    fill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    TrackAccentElement(fill, "Slider")

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

function Ashuna.AddButton(parent, text, callback)
    local safeCallback = callback or function() end

    local btn = Instance.new("TextButton")
    btn.Name = text .. "Button"
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Ashuna.Theme.Accent
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    TrackAccentElement(btn, "Frame")

    btn.MouseEnter:Connect(function()
        SafeTween(btn, {BackgroundColor3 = Ashuna.Theme.AccentHover})
    end)

    btn.MouseLeave:Connect(function()
        SafeTween(btn, {BackgroundColor3 = Ashuna.Theme.Accent})
    end)

    btn.MouseButton1Click:Connect(function()
        SafeTween(btn, {Size = UDim2.new(0.95, 0, 0, 30)}, 0.1)
        task.delay(0.1, function()
            SafeTween(btn, {Size = UDim2.new(1, 0, 0, 32)}, 0.1)
        end)
        safeCallback()
    end)

    return btn
end

function Ashuna.AddDropdown(parent, text, options, default, callback)
    local api = {}
    local selected = default or options[1]
    local isOpen = false

    local container = Instance.new("Frame")
    container.Name = text .. "Dropdown"
    container.Size = UDim2.new(1, 0, 0, 65)
    container.BackgroundTransparency = 1
    container.Parent = parent
    container.ZIndex = 10

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Ashuna.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.BackgroundColor3 = Ashuna.Theme.SurfaceHover
    btn.Position = UDim2.new(0, 0, 0, 25)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Text = "  " .. selected
    btn.TextColor3 = Ashuna.Theme.TextPrimary
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local arrow = Instance.new("ImageLabel")
    arrow.Parent = btn
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -26, 0.5, -8)
    arrow.Image = "rbxassetid://6031091004"
    arrow.ImageColor3 = Ashuna.Theme.TextSecondary

    local list = Instance.new("Frame")
    list.Parent = container
    list.BackgroundColor3 = Ashuna.Theme.SurfaceHover
    list.Position = UDim2.new(0, 0, 0, 62)
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
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.Text = "  " .. opt
        optBtn.TextColor3 = Ashuna.Theme.TextSecondary
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.AutoButtonColor = false
        optBtn.ZIndex = 21

        optBtn.MouseEnter:Connect(function()
            SafeTween(optBtn, {BackgroundTransparency = 0.9, BackgroundColor3 = Ashuna.Theme.Accent})
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

    function api:Refresh(newOptions)
        options = newOptions
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(options) do
            -- Rebuild options (simplified for brevity)
        end
    end

    return api
end

function Ashuna.AddKeybind(parent, text, defaultKey, callback)
    local api = {}
    local currentKey = defaultKey or Enum.KeyCode.Unknown
    local listening = false

    local container = Instance.new("TextButton")
    container.Name = text .. "Keybind"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Text = ""
    container.AutoButtonColor = false
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Ashuna.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local keyBox = Instance.new("Frame")
    keyBox.Parent = container
    keyBox.BackgroundColor3 = Ashuna.Theme.SurfaceHover
    keyBox.Size = UDim2.new(0, 60, 0, 24)
    keyBox.Position = UDim2.new(1, -65, 0.5, -12)
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
    keyLabel.TextColor3 = Ashuna.Theme.TextPrimary
    keyLabel.TextSize = 11

    local function updateVisual()
        keyLabel.Text = listening and "..." or (currentKey.Name ~= "Unknown" and currentKey.Name or "None")
        SafeTween(keyBox, {BackgroundColor3 = listening and Ashuna.Theme.Accent or Ashuna.Theme.SurfaceHover}, 0.2)
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

function Ashuna.AddTextbox(parent, text, placeholder, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Textbox"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Ashuna.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = container
    box.BackgroundColor3 = Ashuna.Theme.SurfaceHover
    box.Position = UDim2.new(0, 0, 0, 25)
    box.Size = UDim2.new(1, 0, 0, 32)
    box.Text = ""
    box.PlaceholderText = placeholder or "Enter text..."
    box.TextColor3 = Ashuna.Theme.TextPrimary
    box.PlaceholderColor3 = Ashuna.Theme.TextMuted
    box.Font = Enum.Font.GothamMedium
    box.TextSize = 13
    box.ClearTextOnFocus = false

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box

    box.Focused:Connect(function()
        SafeTween(box, {BackgroundColor3 = Ashuna.Theme.Surface}, 0.2)
    end)

    box.FocusLost:Connect(function(enterPressed)
        SafeTween(box, {BackgroundColor3 = Ashuna.Theme.SurfaceHover}, 0.2)
        if callback then callback(box.Text, enterPressed) end
    end)

    return {
        Get = function() return box.Text end,
        Set = function(val) box.Text = val end
    }
end

function Ashuna.AddColorPicker(parent, text, defaultColor, callback)
    local api = {}
    local color = defaultColor or Color3.fromRGB(255, 255, 255)
    local isOpen = false

    local container = Instance.new("Frame")
    container.Name = text .. "ColorPicker"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Ashuna.Theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("TextButton")
    preview.Parent = container
    preview.BackgroundColor3 = color
    preview.Size = UDim2.new(0, 40, 0, 24)
    preview.Position = UDim2.new(1, -45, 0.5, -12)
    preview.Text = ""
    preview.AutoButtonColor = false

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = preview

    local stroke = Instance.new("UIStroke")
    stroke.Parent = preview
    stroke.Color = Ashuna.Theme.Border
    stroke.Thickness = 1

    -- Simplified color picker popup would go here
    -- For brevity, using a basic RGB input approach

    preview.MouseButton1Click:Connect(function()
        -- Toggle color picker popup
        isOpen = not isOpen
    end)

    function api:Set(newColor)
        color = newColor
        preview.BackgroundColor3 = color
        if callback then callback(color) end
    end

    function api:Get()
        return color
    end

    return api
end

function Ashuna.AddLabel(parent, text, options)
    options = options or {}
    local isBold = options.Bold or false
    local color = options.Color or Ashuna.Theme.TextSecondary

    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = isBold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = color
    label.TextSize = options.Size or 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true

    return label
end

function Ashuna.AddSeparator(parent)
    local line = Instance.new("Frame")
    line.Parent = parent
    line.BackgroundColor3 = Ashuna.Theme.Border
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BorderSizePixel = 0
    return line
end

-- Right Panel Components
function Ashuna.AddInfoCard(title, value)
    local card = Instance.new("Frame")
    card.Parent = RightPanel
    card.BackgroundColor3 = Ashuna.Theme.Background
    card.Size = UDim2.new(1, 0, 0, 60)
    
    AddEffects(card, 6)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = card
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.Size = UDim2.new(1, -20, 0, 16)
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.Text = title
    titleLabel.TextColor3 = Ashuna.Theme.TextMuted
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = card
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0, 10, 0, 26)
    valueLabel.Size = UDim2.new(1, -20, 0, 24)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = value
    valueLabel.TextColor3 = Ashuna.Theme.TextPrimary
    valueLabel.TextSize = 18
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left

    return valueLabel
end

-- Watermark
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Parent = ScreenGui
WatermarkFrame.BackgroundColor3 = Ashuna.Theme.Background
WatermarkFrame.Position = UDim2.new(0, 20, 0, 20)
WatermarkFrame.Size = UDim2.new(0, 300, 0, 40)

AddEffects(WatermarkFrame, 6)
CreateShadow(WatermarkFrame, 0.4)

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Parent = WatermarkFrame
WatermarkText.BackgroundTransparency = 1
WatermarkText.Size = UDim2.new(1, -20, 1, 0)
WatermarkText.Position = UDim2.new(0, 10, 0, 0)
WatermarkText.Font = Enum.Font.GothamBold
WatermarkText.Text = "ASHUNA | FPS: 0 | PING: 0"
WatermarkText.TextColor3 = Ashuna.Theme.TextPrimary
WatermarkText.TextSize = 13

local WatermarkAccent = Instance.new("Frame")
WatermarkAccent.Parent = WatermarkFrame
WatermarkAccent.BackgroundColor3 = Ashuna.Theme.Accent
WatermarkAccent.Size = UDim2.new(0, 3, 1, 0)
WatermarkAccent.BorderSizePixel = 0

TrackAccentElement(WatermarkAccent, "Frame")

RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    WatermarkText.Text = string.format("ASHUNA | FPS: %d | PING: %d", fps, math.floor(ping))
end)

-- UI State Management
local isVisible = true
local uiKey = Enum.KeyCode.RightShift

function Ashuna.ToggleUI()
    isVisible = not isVisible
    local targetBlur = isVisible and 20 or 0
    
    SafeTween(MainFrame, {Position = isVisible and UDim2.new(0.5, -500, 0.5, -300) or UDim2.new(0.5, -500, 1.5, 0)}, 0.5, Enum.EasingStyle.Quart)
    SafeTween(Blur, {Size = targetBlur}, 0.5)
    SafeTween(WatermarkFrame, {Position = isVisible and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 20, 0, -60)}, 0.5)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == uiKey then
        Ashuna.ToggleUI()
    end
end)

-- Draggable functionality
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

-- Config System
function Ashuna.SaveConfig(name)
    if not name then return end
    local data = {}
    -- Collect all registered element values
    SafeFileSystem.MakeFolder("Ashuna")
    SafeFileSystem.Write("Ashuna/" .. name .. ".json", SafeFileSystem.JSONEncode(data))
end

function Ashuna.LoadConfig(name)
    local data = SafeFileSystem.Read("Ashuna/" .. name .. ".json")
    if data then
        local decoded = SafeFileSystem.JSONDecode(data)
        -- Apply to all registered elements
    end
end

-- Notification System
function Ashuna.Notify(title, message, type, duration)
    duration = duration or 3
    type = type or "info"
    
    local colors = {
        info = Ashuna.Theme.Accent,
        success = Ashuna.Theme.Success,
        warning = Ashuna.Theme.Warning,
        error = Ashuna.Theme.Error
    }

    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.BackgroundColor3 = Ashuna.Theme.Surface
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(1, 20, 1, -100)
    
    AddEffects(notif, 6)
    CreateShadow(notif, 0.4)

    local accent = Instance.new("Frame")
    accent.Parent = notif
    accent.BackgroundColor3 = colors[type]
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notif
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 10)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Ashuna.Theme.TextPrimary
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Parent = notif
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 20, 0, 35)
    msgLabel.Size = UDim2.new(1, -30, 0, 35)
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.Text = message
    msgLabel.TextColor3 = Ashuna.Theme.TextSecondary
    msgLabel.TextSize = 12
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true

    SafeTween(notif, {Position = UDim2.new(1, -320, 1, -100)}, 0.5, Enum.EasingStyle.Quart)

    task.delay(duration, function()
        SafeTween(notif, {Position = UDim2.new(1, 20, 1, -100)}, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.5)
        notif:Destroy()
    end)
end

-- Initialize
Ashuna.SwitchTab(next(Tabs) or "General")

return Ashuna
