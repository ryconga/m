local Sakura = {}
Sakura.__index = Sakura

-- Services
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

-- Exploit Compatibility
local function IsFunctionSupported(funcName)
    local env = getgenv and getgenv() or _G
    return env[funcName] ~= nil
end

-- File System
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

-- Sakura Theme - Glassmorphism + Cherry Blossom
Sakura.Theme = {
    -- Glass backgrounds with transparency
    GlassBackground = Color3.fromRGB(20, 18, 24),
    GlassSurface = Color3.fromRGB(30, 26, 32),
    GlassHover = Color3.fromRGB(40, 34, 42),
    
    -- Sakura Pink Palette
    SakuraPink = Color3.fromRGB(255, 183, 197),      -- #FFB7C5 Main pink
    SakuraDark = Color3.fromRGB(237, 123, 141),      -- #ED7B8D Darker pink
    SakuraLight = Color3.fromRGB(251, 201, 228),     -- #FBC9E4 Light pink
    SakuraAccent = Color3.fromRGB(255, 163, 195),    -- #FFA3C3 Accent
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 190, 195),
    TextMuted = Color3.fromRGB(130, 120, 125),
    
    -- UI elements
    Border = Color3.fromRGB(255, 183, 197),
    BorderTransparency = 0.7,
    BackgroundTransparency = 0.15,
    BlurIntensity = 15,
    
    -- Utility colors
    Success = Color3.fromRGB(163, 200, 140),
    Warning = Color3.fromRGB(255, 200, 120),
    Error = Color3.fromRGB(255, 130, 130)
}

-- Cleanup existing UI
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

-- Utility Functions
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
    radius = radius or 8
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    
    -- Glass border (sakura tinted)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Sakura.Theme.SakuraPink
    stroke.Transparency = Sakura.Theme.BorderTransparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    
    return stroke
end

local function CreateShadow(parent, intensity)
    intensity = intensity or 0.4
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://131604521558887"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 1 - intensity
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

-- Main UI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SakuraUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Blur Effect
local Blur = Instance.new("BlurEffect")
Blur.Name = "SakuraBlur"
Blur.Size = 0
Blur.Enabled = true
Blur.Parent = Lighting

Sakura.ScreenGui = ScreenGui
Sakura.Blur = Blur

-- Compact Main Frame (700x450 instead of 1000x600)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Sakura.Theme.GlassBackground
MainFrame.BackgroundTransparency = Sakura.Theme.BackgroundTransparency
MainFrame.Size = UDim2.new(0, 700, 0, 450)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

AddGlassEffects(MainFrame, 12)
CreateShadow(MainFrame, 0.5)

Sakura.MainFrame = MainFrame

-- Header (Compact)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Sakura.Theme.GlassSurface
Header.BackgroundTransparency = 0.2
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 0)
HeaderCorner.Parent = Header

-- Sakura accent line at bottom
local HeaderAccent = Instance.new("Frame")
HeaderAccent.Parent = Header
HeaderAccent.BackgroundColor3 = Sakura.Theme.SakuraPink
HeaderAccent.Size = UDim2.new(1, 0, 0, 2)
HeaderAccent.Position = UDim2.new(0, 0, 1, -2)
HeaderAccent.BorderSizePixel = 0

-- Title with sakura icon
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🌸 SAKURA"
TitleLabel.TextColor3 = Sakura.Theme.SakuraPink
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Header
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Sakura.Theme.TextSecondary
CloseBtn.TextSize = 24
CloseBtn.Font = Enum.Font.GothamBold

CloseBtn.MouseEnter:Connect(function()
    SafeTween(CloseBtn, {TextColor3 = Sakura.Theme.Error})
end)

CloseBtn.MouseLeave:Connect(function()
    SafeTween(CloseBtn, {TextColor3 = Sakura.Theme.TextSecondary})
end)

CloseBtn.MouseButton1Click:Connect(function()
    Sakura.ToggleUI()
end)

-- 3-Panel Layout (Sidebar, Content, Info)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.Size = UDim2.new(1, 0, 1, -40)

-- Panel 1: Sidebar (Navigation) - Compact
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = ContentFrame
Sidebar.BackgroundColor3 = Sakura.Theme.GlassSurface
Sidebar.BackgroundTransparency = 0.3
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.Parent = Sidebar
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)

-- Panel 2: Main Content (Tabs)
local MainContent = Instance.new("Frame")
MainContent.Name = "MainContent"
MainContent.Parent = ContentFrame
MainContent.BackgroundTransparency = 1
MainContent.Position = UDim2.new(0, 140, 0, 0)
MainContent.Size = UDim2.new(1, -260, 1, 0)

local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Parent = MainContent
PageContainer.BackgroundTransparency = 1
PageContainer.Size = UDim2.new(1, 0, 1, 0)

-- Panel 3: Right Info Panel (Compact)
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Parent = ContentFrame
RightPanel.BackgroundColor3 = Sakura.Theme.GlassSurface
RightPanel.BackgroundTransparency = 0.3
RightPanel.Position = UDim2.new(1, -120, 0, 0)
RightPanel.Size = UDim2.new(0, 120, 1, 0)
RightPanel.BorderSizePixel = 0

local RightPanelLayout = Instance.new("UIListLayout")
RightPanelLayout.Parent = RightPanel
RightPanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightPanelLayout.Padding = UDim.new(0, 8)

local RightPanelPadding = Instance.new("UIPadding")
RightPanelPadding.Parent = RightPanel
RightPanelPadding.PaddingTop = UDim.new(0, 10)
RightPanelPadding.PaddingLeft = UDim.new(0, 10)
RightPanelPadding.PaddingRight = UDim.new(0, 10)

-- Tab System
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
                SafeTween(btn, {BackgroundColor3 = Sakura.Theme.SakuraPink, BackgroundTransparency = 0.8})
                SafeTween(indicator, {BackgroundTransparency = 0})
                SafeTween(btnData.Label, {TextColor3 = Sakura.Theme.TextPrimary})
            else
                SafeTween(btn, {BackgroundColor3 = Sakura.Theme.GlassHover, BackgroundTransparency = 0.5})
                SafeTween(indicator, {BackgroundTransparency = 1})
                SafeTween(btnData.Label, {TextColor3 = Sakura.Theme.TextSecondary})
            end
        end
    end

    CurrentTab = tabName
end

function Sakura.AddTab(name, iconId)
    local btnContainer = Instance.new("TextButton")
    btnContainer.Name = name .. "Tab"
    btnContainer.Size = UDim2.new(1, 0, 0, 32)
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
    indicator.Size = UDim2.new(0, 3, 0, 16)
    indicator.Position = UDim2.new(0, 0, 0.5, -8)
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = btnContainer
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(0, 10, 0.5, -9)
    icon.Image = iconId or "rbxassetid://6034684930"
    icon.ImageColor3 = Sakura.Theme.TextSecondary

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = btnContainer
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 34, 0, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Sakura.Theme.SakuraPink
    page.Parent = PageContainer

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = page
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pagePadding = Instance.new("UIPadding")
    pagePadding.Parent = page
    pagePadding.PaddingRight = UDim.new(0, 8)

    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 16)
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

-- Component Functions
function Sakura.CreateSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundColor3 = Sakura.Theme.GlassSurface
    section.BackgroundTransparency = 0.4
    section.BorderSizePixel = 0
    section.Parent = parent

    AddGlassEffects(section, 8)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = section
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 30)

    local headerLabel = Instance.new("TextLabel")
    headerLabel.Parent = header
    headerLabel.BackgroundTransparency = 1
    headerLabel.Position = UDim2.new(0, 12, 0, 0)
    headerLabel.Size = UDim2.new(1, -24, 1, 0)
    headerLabel.Font = Enum.Font.GothamBold
    headerLabel.Text = "🌸 " .. title:upper()
    headerLabel.TextColor3 = Sakura.Theme.SakuraPink
    headerLabel.TextSize = 11
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = section
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 0, 0, 30)
    content.Size = UDim2.new(1, 0, 0, 0)
    content.AutomaticSize = Enum.AutomaticSize.Y

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Parent = content
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = content
    contentPadding.PaddingLeft = UDim.new(0, 12)
    contentPadding.PaddingRight = UDim.new(0, 12)
    contentPadding.PaddingBottom = UDim.new(0, 12)

    return content
end

function Sakura.AddToggle(parent, text, default, callback)
    local api = {}
    local state = default or false
    local safeCallback = callback or function() end

    local container = Instance.new("TextButton")
    container.Name = text .. "Toggle"
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Text = ""
    container.AutoButtonColor = false
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -44, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "Background"
    toggleBg.Parent = container
    toggleBg.BackgroundColor3 = Sakura.Theme.GlassHover
    toggleBg.Size = UDim2.new(0, 36, 0, 18)
    toggleBg.Position = UDim2.new(1, -40, 0.5, -9)
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
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.5, 0, 0, 18)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = container
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    valueLabel.Size = UDim2.new(0.5, 0, 0, 18)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = Sakura.Theme.SakuraPink
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local barBg = Instance.new("Frame")
    barBg.Parent = container
    barBg.BackgroundColor3 = Sakura.Theme.GlassHover
    barBg.Position = UDim2.new(0, 0, 0, 26)
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
    knob.Size = UDim2.new(0, 10, 0, 10)
    knob.Position = UDim2.new(1, -5, 0.5, -5)
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
    btn.BackgroundTransparency = 0.2
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
        SafeTween(btn, {BackgroundTransparency = 0.2})
    end)

    btn.MouseButton1Click:Connect(function()
        SafeTween(btn, {Size = UDim2.new(0.98, 0, 0, 26)}, 0.1)
        task.delay(0.1, function()
            SafeTween(btn, {Size = UDim2.new(1, 0, 0, 28)}, 0.1)
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
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.Parent = parent
    container.ZIndex = 10

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.BackgroundColor3 = Sakura.Theme.GlassHover
    btn.BackgroundTransparency = 0.3
    btn.Position = UDim2.new(0, 0, 0, 22)
    btn.Size = UDim2.new(1, 0, 0, 28)
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
    arrow.Position = UDim2.new(1, -24, 0.5, -7)
    arrow.Image = "rbxassetid://6031091004"
    arrow.ImageColor3 = Sakura.Theme.SakuraPink

    local list = Instance.new("Frame")
    list.Parent = container
    list.BackgroundColor3 = Sakura.Theme.GlassSurface
    list.BackgroundTransparency = 0.1
    list.Position = UDim2.new(0, 0, 0, 52)
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
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1
    container.Text = ""
    container.AutoButtonColor = false
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local keyBox = Instance.new("Frame")
    keyBox.Parent = container
    keyBox.BackgroundColor3 = Sakura.Theme.GlassHover
    keyBox.Size = UDim2.new(0, 50, 0, 22)
    keyBox.Position = UDim2.new(1, -55, 0.5, -11)
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
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextColor3 = Sakura.Theme.TextSecondary
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = container
    box.BackgroundColor3 = Sakura.Theme.GlassHover
    box.BackgroundTransparency = 0.3
    box.Position = UDim2.new(0, 0, 0, 22)
    box.Size = UDim2.new(1, 0, 0, 26)
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

-- Right Panel Info Cards
function Sakura.AddInfoCard(title, value)
    local card = Instance.new("Frame")
    card.Parent = RightPanel
    card.BackgroundColor3 = Sakura.Theme.GlassBackground
    card.BackgroundTransparency = 0.5
    card.Size = UDim2.new(1, 0, 0, 50)
    
    AddGlassEffects(card, 6)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = card
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 8, 0, 6)
    titleLabel.Size = UDim2.new(1, -16, 0, 14)
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.Text = title
    titleLabel.TextColor3 = Sakura.Theme.TextMuted
    titleLabel.TextSize = 10
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = card
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0, 8, 0, 20)
    valueLabel.Size = UDim2.new(1, -16, 0, 20)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = value
    valueLabel.TextColor3 = Sakura.Theme.SakuraPink
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left

    return valueLabel
end

-- Compact Watermark
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Parent = ScreenGui
WatermarkFrame.BackgroundColor3 = Sakura.Theme.GlassBackground
WatermarkFrame.BackgroundTransparency = 0.2
WatermarkFrame.Position = UDim2.new(0, 15, 0, 15)
WatermarkFrame.Size = UDim2.new(0, 220, 0, 32)

AddGlassEffects(WatermarkFrame, 6)
CreateShadow(WatermarkFrame, 0.3)

local WatermarkText = Instance.new("TextLabel")
WatermarkText.Parent = WatermarkFrame
WatermarkText.BackgroundTransparency = 1
WatermarkText.Size = UDim2.new(1, -12, 1, 0)
WatermarkText.Position = UDim2.new(0, 6, 0, 0)
WatermarkText.Font = Enum.Font.GothamBold
WatermarkText.Text = "🌸 SAKURA | FPS: 0 | PING: 0"
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
    WatermarkText.Text = string.format("🌸 SAKURA | FPS: %d | PING: %d", fps, math.floor(ping))
end)

-- UI State Management
local isVisible = true
local uiKey = Enum.KeyCode.RightAlt -- Changed to RightAlt

function Sakura.ToggleUI()
    isVisible = not isVisible
    local targetBlur = isVisible and Sakura.Theme.BlurIntensity or 0
    
    SafeTween(MainFrame, {
        Position = isVisible and UDim2.new(0.5, -350, 0.5, -225) or UDim2.new(0.5, -350, 1.5, 0)
    }, 0.4, Enum.EasingStyle.Quart)
    SafeTween(Blur, {Size = targetBlur}, 0.4)
    SafeTween(WatermarkFrame, {
        Position = isVisible and UDim2.new(0, 15, 0, 15) or UDim2.new(0, 15, 0, -50)
    }, 0.4)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == uiKey then
        Sakura.ToggleUI()
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

-- Notification System
function Sakura.Notify(title, message, notifType, duration)
    duration = duration or 3
    notifType = notifType or "info"
    
    local colors = {
        info = Sakura.Theme.SakuraPink,
        success = Sakura.Theme.Success,
        warning = Sakura.Theme.Warning,
        error = Sakura.Theme.Error
    }

    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.BackgroundColor3 = Sakura.Theme.GlassSurface
    notif.BackgroundTransparency = 0.1
    notif.Size = UDim2.new(0, 260, 0, 70)
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
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.Size = UDim2.new(1, -25, 0, 18)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "🌸 " .. title
    titleLabel.TextColor3 = Sakura.Theme.TextPrimary
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Parent = notif
    msgLabel.BackgroundTransparency = 1
    msgLabel.Position = UDim2.new(0, 15, 0, 28)
    msgLabel.Size = UDim2.new(1, -25, 0, 30)
    msgLabel.Font = Enum.Font.GothamMedium
    msgLabel.Text = message
    msgLabel.TextColor3 = Sakura.Theme.TextSecondary
    msgLabel.TextSize = 11
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true

    SafeTween(notif, {Position = UDim2.new(1, -280, 1, -90)}, 0.4, Enum.EasingStyle.Quart)

    task.delay(duration, function()
        SafeTween(notif, {Position = UDim2.new(1, 20, 1, -90)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.4)
        notif:Destroy()
    end)
end

-- Initialize
Sakura.SwitchTab(next(Tabs) or "General")

return Sakura
