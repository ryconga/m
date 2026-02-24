local Modular = {}

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
local RbxAnalyticsService = GetService("RbxAnalyticsService")

local LocalPlayer = Players.LocalPlayer
local CoreGui = GetService("CoreGui")

-- Exploit Compatibility
local function IsFunctionSupported(funcName)
    local env = getgenv and getgenv() or _G
    if funcName == "getgenv" then return getgenv ~= nil end
    if funcName == "writefile" then return writefile ~= nil end
    if funcName == "readfile" then return readfile ~= nil end
    if funcName == "isfolder" then return isfolder ~= nil end
    if funcName == "makefolder" then return makefolder ~= nil end
    if funcName == "isfile" then return isfile ~= nil end
    return false
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

local GlobalEnv = getgenv and getgenv() or _G
if not GlobalEnv.ModularStorage then
    GlobalEnv.ModularStorage = {}
end

-- Cleanup
local function CleanupExisting()
    local existing = CoreGui:FindFirstChild("ModularUI")
    if existing then
        pcall(function() existing:Destroy() end)
    end
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") and v.Name == "ModularBlur" then
            pcall(function() v:Destroy() end)
        end
    end
end

CleanupExisting()

-- Vape V4 Style Theme
Modular.Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(255, 182, 193),
    Stroke = Color3.fromRGB(40, 40, 40),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    DarkContainer = Color3.fromRGB(30, 30, 30),
    Hover = Color3.fromRGB(45, 45, 45),
    Selected = Color3.fromRGB(35, 35, 35)
}

-- Accent Tracking
local AccentElements = {Frames = {}, Strokes = {}, TextLabels = {}, Sliders = {}}
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

-- Update Accent
local function UpdateAccentColor(newColor)
    if typeof(newColor) ~= "Color3" then return end
    Modular.Theme.Accent = newColor

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
end

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModularUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local Blur = Instance.new("BlurEffect")
Blur.Name = "ModularBlur"
Blur.Size = 0
Blur.Enabled = true
Blur.Parent = Lighting

Modular.ScreenGui = ScreenGui
Modular.Blur = Blur

-- WATERMARK (Top Right - Vape Style)
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "Watermark"
WatermarkFrame.Parent = ScreenGui
WatermarkFrame.BackgroundColor3 = Modular.Theme.Background
WatermarkFrame.Position = UDim2.new(1, -210, 0, 10)
WatermarkFrame.Size = UDim2.new(0, 200, 0, 30)
WatermarkFrame.BorderSizePixel = 0

local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0, 4)
WatermarkCorner.Parent = WatermarkFrame

local WatermarkStroke = Instance.new("UIStroke")
WatermarkStroke.Color = Modular.Theme.Stroke
WatermarkStroke.Thickness = 1
WatermarkStroke.Parent = WatermarkFrame

local WatermarkLayout = Instance.new("UIListLayout")
WatermarkLayout.Parent = WatermarkFrame
WatermarkLayout.FillDirection = Enum.FillDirection.Horizontal
WatermarkLayout.SortOrder = Enum.SortOrder.LayoutOrder
WatermarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WatermarkLayout.Padding = UDim.new(0, 8)

local WatermarkPadding = Instance.new("UIPadding")
WatermarkPadding.Parent = WatermarkFrame
WatermarkPadding.PaddingLeft = UDim.new(0, 10)
WatermarkPadding.PaddingRight = UDim.new(0, 10)

local NameLabel = Instance.new("TextLabel")
NameLabel.Parent = WatermarkFrame
NameLabel.BackgroundTransparency = 1
NameLabel.Font = Enum.Font.GothamBold
NameLabel.Text = "MODULAR"
NameLabel.TextColor3 = Modular.Theme.Accent
NameLabel.TextSize = 12
NameLabel.Size = UDim2.new(0, 60, 1, 0)

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Parent = WatermarkFrame
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamMedium
fpsLabel.Text = "0 FPS"
fpsLabel.TextColor3 = Modular.Theme.TextMain
fpsLabel.TextSize = 11
fpsLabel.Size = UDim2.new(0, 40, 1, 0)

local pingLabel = Instance.new("TextLabel")
pingLabel.Parent = WatermarkFrame
pingLabel.BackgroundTransparency = 1
pingLabel.Font = Enum.Font.GothamMedium
pingLabel.Text = "0 MS"
pingLabel.TextColor3 = Modular.Theme.TextMain
pingLabel.TextSize = 11
pingLabel.Size = UDim2.new(0, 40, 1, 0)

local timeLabel = Instance.new("TextLabel")
timeLabel.Parent = WatermarkFrame
timeLabel.BackgroundTransparency = 1
timeLabel.Font = Enum.Font.GothamMedium
timeLabel.Text = "00:00"
timeLabel.TextColor3 = Modular.Theme.TextDim
timeLabel.TextSize = 11
timeLabel.Size = UDim2.new(0, 40, 1, 0)

RunService.RenderStepped:Connect(function(dt)
    fpsLabel.Text = math.floor(1/dt) .. " FPS"
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    pingLabel.Text = math.floor(ping) .. " MS"
    timeLabel.Text = os.date("%H:%M")
end)

-- MAIN UI CONTAINER (Top Left - Vape V4 Style Dropdown)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Modular.Theme.Background
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.Size = UDim2.new(0, 220, 0, 35) -- Compact header only initially
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 4)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Modular.Theme.Stroke
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

Modular.MainFrame = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Modular.Theme.DarkContainer
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 4)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Header
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "MODULAR"
TitleLabel.TextColor3 = Modular.Theme.TextMain
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = Header
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Position = UDim2.new(1, -35, 0, 0)
ToggleBtn.Size = UDim2.new(0, 35, 1, 0)
ToggleBtn.Text = "+"
ToggleBtn.TextColor3 = Modular.Theme.TextMain
ToggleBtn.TextSize = 18
ToggleBtn.Font = Enum.Font.GothamBold

-- Categories Container
local CategoriesContainer = Instance.new("Frame")
CategoriesContainer.Name = "Categories"
CategoriesContainer.Parent = MainFrame
CategoriesContainer.BackgroundTransparency = 1
CategoriesContainer.Position = UDim2.new(0, 0, 0, 35)
CategoriesContainer.Size = UDim2.new(1, 0, 1, -35)

local CategoriesLayout = Instance.new("UIListLayout")
CategoriesLayout.Parent = CategoriesContainer
CategoriesLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- State
local isExpanded = false
local Categories = {}
local ActiveCategory = nil

-- Toggle Animation
local function UpdateToggleIcon()
    SafeTween(ToggleBtn, {Rotation = isExpanded and 45 or 0}, 0.2)
    ToggleBtn.Text = isExpanded and "×" or "+"
end

local function ToggleUI()
    isExpanded = not isExpanded
    local targetSize = isExpanded and UDim2.new(0, 220, 0, math.min(400, 35 + (#Categories * 40) + 10)) or UDim2.new(0, 220, 0, 35)
    
    SafeTween(MainFrame, {Size = targetSize}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    UpdateToggleIcon()
    
    -- Close all categories when collapsing
    if not isExpanded then
        for _, cat in pairs(Categories) do
            if cat.Expanded then
                cat.Toggle()
            end
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleUI)
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y < Header.AbsolutePosition.Y + 35 then
        ToggleUI()
    end
end)

-- Make Draggable
local dragging, dragInput, dragStart, startPos
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
        SafeTween(MainFrame, {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }, 0.1)
    end
end)

-- CATEGORY SYSTEM (Vape V4 Style)
function Modular.AddCategory(name)
    local category = {}
    category.Expanded = false
    category.Modules = {}
    
    -- Category Button
    local CatBtn = Instance.new("TextButton")
    CatBtn.Parent = CategoriesContainer
    CatBtn.BackgroundColor3 = Modular.Theme.Background
    CatBtn.Size = UDim2.new(1, 0, 0, 35)
    CatBtn.Text = ""
    CatBtn.BorderSizePixel = 0
    CatBtn.AutoButtonColor = false
    
    local CatLabel = Instance.new("TextLabel")
    CatLabel.Parent = CatBtn
    CatLabel.BackgroundTransparency = 1
    CatLabel.Position = UDim2.new(0, 10, 0, 0)
    CatLabel.Size = UDim2.new(1, -40, 1, 0)
    CatLabel.Font = Enum.Font.GothamMedium
    CatLabel.Text = name
    CatLabel.TextColor3 = Modular.Theme.TextDim
    CatLabel.TextSize = 13
    CatLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local ArrowLabel = Instance.new("TextLabel")
    ArrowLabel.Parent = CatBtn
    ArrowLabel.BackgroundTransparency = 1
    ArrowLabel.Position = UDim2.new(1, -25, 0, 0)
    ArrowLabel.Size = UDim2.new(0, 25, 1, 0)
    ArrowLabel.Font = Enum.Font.GothamMedium
    ArrowLabel.Text = "›"
    ArrowLabel.TextColor3 = Modular.Theme.TextDim
    ArrowLabel.TextSize = 16
    
    -- Dropdown Panel (appears to the right)
    local DropdownPanel = Instance.new("Frame")
    DropdownPanel.Name = name .. "Panel"
    DropdownPanel.Parent = ScreenGui
    DropdownPanel.BackgroundColor3 = Modular.Theme.Background
    DropdownPanel.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 225, 0, MainFrame.AbsolutePosition.Y + CatBtn.AbsolutePosition.Y)
    DropdownPanel.Size = UDim2.new(0, 200, 0, 0)
    DropdownPanel.BorderSizePixel = 0
    DropdownPanel.ClipsDescendants = true
    DropdownPanel.Visible = false
    DropdownPanel.ZIndex = 10
    
    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 4)
    PanelCorner.Parent = DropdownPanel
    
    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Modular.Theme.Stroke
    PanelStroke.Thickness = 1
    PanelStroke.Parent = DropdownPanel
    
    local PanelLayout = Instance.new("UIListLayout")
    PanelLayout.Parent = DropdownPanel
    PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PanelLayout.Padding = UDim.new(0, 2)
    
    local PanelPadding = Instance.new("UIPadding")
    PanelPadding.Parent = DropdownPanel
    PanelPadding.PaddingTop = UDim.new(0, 5)
    PanelPadding.PaddingBottom = UDim.new(0, 5)
    
    -- Update panel position when main moves
    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if category.Expanded then
            DropdownPanel.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 225, 0, MainFrame.AbsolutePosition.Y + CatBtn.LayoutOrder * 35 + 35)
        end
    end)
    
    function category.Toggle()
        category.Expanded = not category.Expanded
        
        if category.Expanded then
            -- Close other categories
            for _, cat in pairs(Categories) do
                if cat ~= category and cat.Expanded then
                    cat.Toggle()
                end
            end
            
            CatBtn.BackgroundColor3 = Modular.Theme.Selected
            CatLabel.TextColor3 = Modular.Theme.TextMain
            ArrowLabel.TextColor3 = Modular.Theme.Accent
            SafeTween(ArrowLabel, {Rotation = 90}, 0.2)
            
            DropdownPanel.Visible = true
            local contentHeight = PanelLayout.AbsoluteContentSize.Y + 10
            SafeTween(DropdownPanel, {Size = UDim2.new(0, 200, 0, contentHeight)}, 0.2)
            DropdownPanel.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 225, 0, MainFrame.AbsolutePosition.Y + CatBtn.AbsolutePosition.Y)
        else
            CatBtn.BackgroundColor3 = Modular.Theme.Background
            CatLabel.TextColor3 = Modular.Theme.TextDim
            ArrowLabel.TextColor3 = Modular.Theme.TextDim
            SafeTween(ArrowLabel, {Rotation = 0}, 0.2)
            
            SafeTween(DropdownPanel, {Size = UDim2.new(0, 200, 0, 0)}, 0.2)
            task.delay(0.2, function()
                if not category.Expanded then
                    DropdownPanel.Visible = false
                end
            end)
        end
    end
    
    CatBtn.MouseButton1Click:Connect(category.Toggle)
    
    CatBtn.MouseEnter:Connect(function()
        if not category.Expanded then
            SafeTween(CatBtn, {BackgroundColor3 = Modular.Theme.Hover}, 0.1)
        end
    end)
    
    CatBtn.MouseLeave:Connect(function()
        if not category.Expanded then
            SafeTween(CatBtn, {BackgroundColor3 = Modular.Theme.Background}, 0.1)
        end
    end)
    
    -- Container for modules
    category.Container = DropdownPanel
    category.Layout = PanelLayout
    
    Categories[name] = category
    return category
end

-- COMPONENT FUNCTIONS (Adapted for Dropdown Style)

function Modular.AddToggle(category, name, default, callback)
    local api = {}
    local state = default or false
    local safeCallback = callback or function() end
    
    local container = Instance.new("TextButton")
    container.Parent = category.Container
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 28)
    container.Text = ""
    container.AutoButtonColor = false
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -35, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = state and Modular.Theme.TextMain or Modular.Theme.TextDim
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local indicator = Instance.new("Frame")
    indicator.Parent = container
    indicator.Size = UDim2.new(0, 4, 0, 4)
    indicator.Position = UDim2.new(1, -15, 0.5, -2)
    indicator.BackgroundColor3 = state and Modular.Theme.Accent or Modular.Theme.Stroke
    indicator.BorderSizePixel = 0
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    if state then
        TrackAccentElement(indicator, "Frame")
    end
    
    function api:Set(value)
        value = not not value
        if state == value then return end
        state = value
        label.TextColor3 = state and Modular.Theme.TextMain or Modular.Theme.TextDim
        indicator.BackgroundColor3 = state and Modular.Theme.Accent or Modular.Theme.Stroke
        if state then
            TrackAccentElement(indicator, "Frame")
        end
        safeCallback(state)
    end
    
    function api:Get()
        return state
    end
    
    container.MouseButton1Click:Connect(function()
        api:Set(not state)
    end)
    
    container.MouseEnter:Connect(function()
        if not state then
            SafeTween(label, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.1)
        end
    end)
    
    container.MouseLeave:Connect(function()
        if not state then
            SafeTween(label, {TextColor3 = Modular.Theme.TextDim}, 0.1)
        end
    end)
    
    return api
end

function Modular.AddSlider(category, name, min, max, default, decimals, suffix, callback)
    local api = {}
    local safeCallback = callback or function() end
    suffix = suffix or ""
    decimals = decimals or 0
    local value = default or min
    
    local container = Instance.new("Frame")
    container.Parent = category.Container
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 45)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Modular.Theme.TextDim
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Parent = container
    valLabel.BackgroundTransparency = 1
    valLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valLabel.Size = UDim2.new(0.3, -10, 0, 20)
    valLabel.Font = Enum.Font.GothamMedium
    valLabel.Text = tostring(value) .. suffix
    valLabel.TextColor3 = Modular.Theme.TextMain
    valLabel.TextSize = 11
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local barBg = Instance.new("Frame")
    barBg.Parent = container
    barBg.BackgroundColor3 = Modular.Theme.DarkContainer
    barBg.Position = UDim2.new(0, 10, 0, 28)
    barBg.Size = UDim2.new(1, -20, 0, 4)
    barBg.BorderSizePixel = 0
    
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(0, 2)
    barBgCorner.Parent = barBg
    
    local fill = Instance.new("Frame")
    fill.Parent = barBg
    fill.BackgroundColor3 = Modular.Theme.Accent
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    TrackAccentElement(fill, "Frame")
    
    local knob = Instance.new("Frame")
    knob.Parent = fill
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.Position = UDim2.new(1, -4, 0.5, -4)
    knob.BorderSizePixel = 0
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local function round(v)
        local power = 10 ^ decimals
        return math.floor(v * power + 0.5) / power
    end
    
    local function updateVisual()
        local percent = math.clamp((value - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valLabel.Text = tostring(value) .. suffix
    end
    
    function api:Set(v)
        v = tonumber(v) or value
        v = math.clamp(round(v), min, max)
        if v == value then return end
        value = v
        updateVisual()
        safeCallback(value)
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

function Modular.AddKeybind(category, name, defaultKey, callback)
    local api = {}
    local currentKey = defaultKey or Enum.KeyCode.Unknown
    local listening = false
    local safeCallback = callback or function() end
    
    local container = Instance.new("TextButton")
    container.Parent = category.Container
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 28)
    container.Text = ""
    container.AutoButtonColor = false
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Modular.Theme.TextDim
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyBox = Instance.new("Frame")
    keyBox.Parent = container
    keyBox.BackgroundColor3 = Modular.Theme.DarkContainer
    keyBox.Position = UDim2.new(1, -50, 0.5, -9)
    keyBox.Size = UDim2.new(0, 45, 0, 18)
    keyBox.BorderSizePixel = 0
    
    local keyBoxCorner = Instance.new("UICorner")
    keyBoxCorner.CornerRadius = UDim.new(0, 3)
    keyBoxCorner.Parent = keyBox
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Parent = keyBox
    keyLabel.BackgroundTransparency = 1
    keyLabel.Size = UDim2.new(1, 0, 1, 0)
    keyLabel.Font = Enum.Font.GothamMedium
    keyLabel.Text = currentKey.Name ~= "Unknown" and currentKey.Name or "None"
    keyLabel.TextColor3 = Modular.Theme.TextMain
    keyLabel.TextSize = 10
    
    function api:Set(key)
        if typeof(key) == "EnumItem" then
            currentKey = key
            keyLabel.Text = currentKey.Name ~= "Unknown" and currentKey.Name or "None"
        end
    end
    
    function api:Get()
        return currentKey
    end
    
    container.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyLabel.Text = "..."
        
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                api:Set(input.KeyCode)
                safeCallback(input.KeyCode)
            end
            listening = false
            conn:Disconnect()
        end)
    end)
    
    return api
end

function Modular.AddDropdown(category, name, options, default, callback, config)
    local safeCallback = callback or function() end
    config = config or {}
    local isMulti = config.Multi == true
    local selected = isMulti and {} or (default or options[1])
    
    if isMulti and default then
        for _, v in ipairs(default) do
            selected[v] = true
        end
    end
    
    local container = Instance.new("Frame")
    container.Parent = category.Container
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 50)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Modular.Theme.TextDim
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton")
    btn.Parent = container
    btn.BackgroundColor3 = Modular.Theme.DarkContainer
    btn.Position = UDim2.new(0, 10, 0, 22)
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Text = ""
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 3)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Modular.Theme.Stroke
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    local btnLabel = Instance.new("TextLabel")
    btnLabel.Parent = btn
    btnLabel.BackgroundTransparency = 1
    btnLabel.Position = UDim2.new(0, 8, 0, 0)
    btnLabel.Size = UDim2.new(1, -25, 1, 0)
    btnLabel.Font = Enum.Font.GothamMedium
    btnLabel.Text = isMulti and "None" or tostring(selected)
    btnLabel.TextColor3 = Modular.Theme.TextMain
    btnLabel.TextSize = 11
    btnLabel.TextXAlignment = Enum.TextXAlignment.Left
    btnLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    local arrow = Instance.new("TextLabel")
    arrow.Parent = btn
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Font = Enum.Font.GothamMedium
    arrow.Text = "▼"
    arrow.TextColor3 = Modular.Theme.TextDim
    arrow.TextSize = 10
    
    local list = Instance.new("Frame")
    list.Parent = category.Container
    list.BackgroundColor3 = Modular.Theme.DarkContainer
    list.Position = UDim2.new(0, 10, 0, 48)
    list.Size = UDim2.new(1, -20, 0, 0)
    list.BorderSizePixel = 0
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 20
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 3)
    listCorner.Parent = list
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Modular.Theme.Stroke
    listStroke.Thickness = 1
    listStroke.Parent = list
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = list
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local opened = false
    local buttons = {}
    
    local function updateText()
        if isMulti then
            local vals = {}
            for k, v in pairs(selected) do
                if v then table.insert(vals, k) end
            end
            btnLabel.Text = #vals > 0 and table.concat(vals, ", ") or "None"
            safeCallback(vals)
        else
            btnLabel.Text = tostring(selected)
            safeCallback(selected)
        end
    end
    
    local function toggleList()
        opened = not opened
        if opened then
            list.Visible = true
            SafeTween(list, {Size = UDim2.new(1, -20, 0, math.min(#options * 25, 150))}, 0.2)
            SafeTween(arrow, {Rotation = 180}, 0.2)
        else
            SafeTween(list, {Size = UDim2.new(1, -20, 0, 0)}, 0.2)
            SafeTween(arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function()
                if not opened then list.Visible = false end
            end)
        end
    end
    
    btn.MouseButton1Click:Connect(toggleList)
    
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Parent = list
        optBtn.BackgroundTransparency = 1
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.Text = ""
        optBtn.ZIndex = 21
        
        local optLabel = Instance.new("TextLabel")
        optLabel.Parent = optBtn
        optLabel.BackgroundTransparency = 1
        optLabel.Position = UDim2.new(0, 8, 0, 0)
        optLabel.Size = UDim2.new(1, 0, 1, 0)
        optLabel.Font = Enum.Font.GothamMedium
        optLabel.Text = opt
        optLabel.TextColor3 = Modular.Theme.TextDim
        optLabel.TextSize = 11
        optLabel.TextXAlignment = Enum.TextXAlignment.Left
        optLabel.ZIndex = 21
        
        optBtn.MouseEnter:Connect(function()
            SafeTween(optBtn, {BackgroundTransparency = 0.8}, 0.1)
            optLabel.TextColor3 = Modular.Theme.TextMain
        end)
        
        optBtn.MouseLeave:Connect(function()
            SafeTween(optBtn, {BackgroundTransparency = 1}, 0.1)
            optLabel.TextColor3 = Modular.Theme.TextDim
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            if isMulti then
                selected[opt] = not selected[opt]
                optLabel.TextColor3 = selected[opt] and Modular.Theme.Accent or Modular.Theme.TextDim
            else
                selected = opt
                toggleList()
            end
            updateText()
        end)
        
        buttons[opt] = optBtn
    end
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not opened then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UserInputService:GetMouseLocation()
            if not (mouse.X >= list.AbsolutePosition.X and mouse.X <= list.AbsolutePosition.X + list.AbsoluteSize.X and
                    mouse.Y >= list.AbsolutePosition.Y and mouse.Y <= list.AbsolutePosition.Y + list.AbsoluteSize.Y) and
               not (mouse.X >= btn.AbsolutePosition.X and mouse.X <= btn.AbsolutePosition.X + btn.AbsoluteSize.X and
                    mouse.Y >= btn.AbsolutePosition.Y and mouse.Y <= btn.AbsolutePosition.Y + btn.AbsoluteSize.Y) then
                toggleList()
            end
        end
    end)
    
    return {
        Get = function()
            if isMulti then
                local result = {}
                for k, v in pairs(selected) do if v then table.insert(result, k) end end
                return result
            else
                return selected
            end
        end,
        Set = function(val)
            if isMulti then
                selected = {}
                for _, v in ipairs(val or {}) do selected[v] = true end
            else
                selected = val
            end
            updateText()
        end
    }
end

function Modular.AddButton(category, text, callback)
    local safeCallback = callback or function() end
    
    local btn = Instance.new("TextButton")
    btn.Parent = category.Container
    btn.BackgroundColor3 = Modular.Theme.DarkContainer
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.Text = text
    btn.TextColor3 = Modular.Theme.TextMain
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Modular.Theme.Stroke
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        SafeTween(btn, {BackgroundColor3 = Modular.Theme.Hover}, 0.1)
    end)
    
    btn.MouseLeave:Connect(function()
        SafeTween(btn, {BackgroundColor3 = Modular.Theme.DarkContainer}, 0.1)
    end)
    
    btn.MouseButton1Click:Connect(safeCallback)
    
    return btn
end

function Modular.AddTextbox(category, name, default, placeholder, callback)
    local safeCallback = callback or function() end
    
    local container = Instance.new("Frame")
    container.Parent = category.Container
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 50)
    
    local label = Instance.new("TextLabel")
    label.Parent = container
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = name
    label.TextColor3 = Modular.Theme.TextDim
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("Frame")
    box.Parent = container
    box.BackgroundColor3 = Modular.Theme.DarkContainer
    box.Position = UDim2.new(0, 10, 0, 22)
    box.Size = UDim2.new(1, -20, 0, 25)
    box.BorderSizePixel = 0
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 3)
    boxCorner.Parent = box
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Modular.Theme.Stroke
    boxStroke.Thickness = 1
    boxStroke.Parent = box
    
    local textbox = Instance.new("TextBox")
    textbox.Parent = box
    textbox.BackgroundTransparency = 1
    textbox.Size = UDim2.new(1, -16, 1, 0)
    textbox.Position = UDim2.new(0, 8, 0, 0)
    textbox.Font = Enum.Font.GothamMedium
    textbox.Text = default or ""
    textbox.PlaceholderText = placeholder or ""
    textbox.TextColor3 = Modular.Theme.TextMain
    textbox.TextSize = 11
    textbox.ClearTextOnFocus = false
    
    textbox.Focused:Connect(function()
        SafeTween(boxStroke, {Color = Modular.Theme.Accent}, 0.2)
    end)
    
    textbox.FocusLost:Connect(function()
        SafeTween(boxStroke, {Color = Modular.Theme.Stroke}, 0.2)
        safeCallback(textbox.Text)
    end)
    
    return {
        Get = function() return textbox.Text end,
        Set = function(val) textbox.Text = val end
    }
end

function Modular.AddDivider(category)
    local div = Instance.new("Frame")
    div.Parent = category.Container
    div.BackgroundColor3 = Modular.Theme.Stroke
    div.Size = UDim2.new(1, -20, 0, 1)
    div.Position = UDim2.new(0, 10, 0, 0)
    div.BorderSizePixel = 0
    return div
end

-- Config System
local UI_MENU_FOLDER = "Modular"
local UI_MENU_FILE = UI_MENU_FOLDER .. "/MenuState.json"
local THEME_FILE = UI_MENU_FOLDER .. "/ui_theme.json"

local function EnsureStorage()
    SafeFileSystem.MakeFolder(UI_MENU_FOLDER)
end

local function LoadState(defaults)
    EnsureStorage()
    local data = SafeFileSystem.Read(UI_MENU_FILE)
    if data then
        local ok, decoded = pcall(function() return SafeFileSystem.JSONDecode(data) end)
        if ok and type(decoded) == "table" then
            for k, v in pairs(defaults) do
                if decoded[k] == nil then
                    decoded[k] = v
                end
            end
            return decoded
        end
    end
    SafeFileSystem.Write(UI_MENU_FILE, SafeFileSystem.JSONEncode(defaults))
    return defaults
end

local function SaveState()
    EnsureStorage()
    SafeFileSystem.Write(UI_MENU_FILE, SafeFileSystem.JSONEncode(GlobalEnv.ModularStorage.MenuDefaults or {}))
end

-- Initialize Defaults
GlobalEnv.ModularStorage.MenuDefaults = LoadState({
    watermark_enabled = true,
    accent_color = Color3.fromRGB(255, 182, 193),
    ui_visible = true
})

local MenuDefaults = GlobalEnv.ModularStorage.MenuDefaults

-- Color Themes
local ColorThemes = {
    LightPink = Color3.fromRGB(255, 182, 193),
    LightBlue = Color3.fromRGB(173, 216, 230),
    LightMint = Color3.fromRGB(152, 255, 152),
    Orange = Color3.fromRGB(255, 160, 122),
    Red = Color3.fromRGB(255, 100, 100),
    Purple = Color3.fromRGB(147, 112, 219),
    Cyan = Color3.fromRGB(0, 255, 255)
}

-- Settings Category (Auto-added)
local SettingsCat = Modular.AddCategory("Settings")

-- Theme Dropdown
local themeOptions = {}
for name, _ in pairs(ColorThemes) do
    table.insert(themeOptions, name)
end

Modular.AddDropdown(SettingsCat, "Theme", themeOptions, "LightPink", function(selected)
    if ColorThemes[selected] then
        UpdateAccentColor(ColorThemes[selected])
        MenuDefaults.accent_color = ColorThemes[selected]
        SaveState()
    end
end)

-- Watermark Toggle
Modular.AddToggle(SettingsCat, "Watermark", MenuDefaults.watermark_enabled, function(state)
    MenuDefaults.watermark_enabled = state
    WatermarkFrame.Visible = state
    SaveState()
end)

WatermarkFrame.Visible = MenuDefaults.watermark_enabled

-- Unload Button
Modular.AddButton(SettingsCat, "Unload UI", function()
    ScreenGui:Destroy()
    if Blur then Blur:Destroy() end
end)

-- Set initial accent
if MenuDefaults.accent_color then
    UpdateAccentColor(MenuDefaults.accent_color)
end

-- Keybind to toggle UI visibility
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
        WatermarkFrame.Visible = uiVisible and MenuDefaults.watermark_enabled
    end
end)

-- Expose functions
Modular.UpdateAccentColor = UpdateAccentColor
Modular.TrackAccentElement = TrackAccentElement
Modular.SafeTween = SafeTween
Modular.ColorThemes = ColorThemes

return Modular
