--[[
    Vape V5 Dropdown UI Library
    A sleek, modern UI library with dropdown-focused design
    Compatible with Roblox exploits (Hydrogen, Synapse, Wave, etc.)
]]

local VapeV5 = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Color Palette (Vape V5 Style)
local Colors = {
    Background = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(20, 20, 20),
    Header = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(124, 37, 255), -- Vape Purple
    AccentHover = Color3.fromRGB(147, 71, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    ElementBg = Color3.fromRGB(35, 35, 35),
    ElementHover = Color3.fromRGB(45, 45, 45),
    Border = Color3.fromRGB(50, 50, 50),
    Success = Color3.fromRGB(0, 255, 128),
    Error = Color3.fromRGB(255, 50, 50)
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
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
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Dropdown Component
function VapeV5:CreateDropdown(config)
    config = config or {}
    local dropdown = {}
    
    -- Main Container
    dropdown.Container = CreateInstance("Frame", {
        Name = "Dropdown",
        Size = config.Size or UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = config.Parent
    })
    
    -- Corner
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdown.Container
    })
    
    -- Stroke
    CreateInstance("UIStroke", {
        Color = Colors.Border,
        Thickness = 1,
        Parent = dropdown.Container
    })
    
    -- Header Button
    dropdown.Header = CreateInstance("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        Parent = dropdown.Container
    })
    
    -- Label
    dropdown.Label = CreateInstance("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or "Select Option",
        TextColor3 = Colors.Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown.Header
    })
    
    -- Icon
    dropdown.Icon = CreateInstance("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031091004", -- Dropdown arrow
        ImageColor3 = Colors.TextDark,
        Parent = dropdown.Header
    })
    
    -- Options Container
    dropdown.OptionsContainer = CreateInstance("Frame", {
        Name = "Options",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundTransparency = 1,
        Parent = dropdown.Container
    })
    
    local UIListLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = dropdown.OptionsContainer
    })
    
    -- State
    dropdown.Opened = false
    dropdown.Options = {}
    dropdown.Selected = nil
    dropdown.Callback = config.Callback or function() end
    
    -- Methods
    function dropdown:AddOption(text, value)
        local option = CreateInstance("TextButton", {
            Name = text,
            Size = UDim2.new(1, -8, 0, 32),
            Position = UDim2.new(0, 4, 0, 0),
            BackgroundColor3 = Colors.ElementBg,
            BorderSizePixel = 0,
            Text = "",
            Parent = dropdown.OptionsContainer
        })
        
        CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = option
        })
        
        local label = CreateInstance("TextLabel", {
            Size = UDim2.new(1, -12, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Colors.TextDark,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = option
        })
        
        -- Hover Effects
        option.MouseEnter:Connect(function()
            Tween(option, {BackgroundColor3 = Colors.ElementHover}, 0.2)
            Tween(label, {TextColor3 = Colors.Text}, 0.2)
        end)
        
        option.MouseLeave:Connect(function()
            Tween(option, {BackgroundColor3 = Colors.ElementBg}, 0.2)
            Tween(label, {TextColor3 = Colors.TextDark}, 0.2)
        end)
        
        option.MouseButton1Click:Connect(function()
            dropdown:Select(text, value)
        end)
        
        table.insert(dropdown.Options, {Instance = option, Text = text, Value = value})
        return option
    end
    
    function dropdown:Select(text, value)
        self.Selected = {Text = text, Value = value}
        self.Label.Text = text
        self:Close()
        self.Callback(value or text)
    end
    
    function dropdown:Open()
        if self.Opened then return end
        self.Opened = true
        
        local targetHeight = math.min(#self.Options * 36 + 45, 200)
        Tween(self.Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.3, Enum.EasingStyle.Back)
        Tween(self.Icon, {Rotation = 180}, 0.3)
        
        -- Expand options container
        Tween(self.OptionsContainer, {Size = UDim2.new(1, 0, 0, targetHeight - 45)}, 0.3)
    end
    
    function dropdown:Close()
        if not self.Opened then return end
        self.Opened = false
        
        Tween(self.Container, {Size = UDim2.new(1, 0, 0, 40)}, 0.3, Enum.EasingStyle.Quart)
        Tween(self.Icon, {Rotation = 0}, 0.3)
        Tween(self.OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
    end
    
    function dropdown:Toggle()
        if self.Opened then
            self:Close()
        else
            self:Open()
        end
    end
    
    -- Click Handler
    dropdown.Header.MouseButton1Click:Connect(function()
        dropdown:Toggle()
    end)
    
    -- Close when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = UserInputService:GetMouseLocation()
            local absPos = dropdown.Container.AbsolutePosition
            local absSize = dropdown.Container.AbsoluteSize
            
            if pos.X < absPos.X or pos.X > absPos.X + absSize.X or 
               pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
                dropdown:Close()
            end
        end
    end)
    
    return dropdown
end

-- Window Component
function VapeV5:CreateWindow(title)
    local window = {}
    
    -- ScreenGui
    window.ScreenGui = CreateInstance("ScreenGui", {
        Name = "VapeV5_" .. tostring(math.random(1000, 9999)),
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame
    window.Main = CreateInstance("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Parent = window.ScreenGui
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = window.Main
    })
    
    -- Shadow
    local shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = window.Main
    })
    
    -- Title Bar
    window.TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Colors.Header,
        BorderSizePixel = 0,
        Parent = window.Main
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = window.TitleBar
    })
    
    -- Fix corners
    local titleBarFix = CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Colors.Header,
        BorderSizePixel = 0,
        Parent = window.TitleBar
    })
    
    -- Title
    CreateInstance("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Vape V5",
        TextColor3 = Colors.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.TitleBar
    })
    
    -- Accent Line
    CreateInstance("Frame", {
        Name = "Accent",
        Size = UDim2.new(0, 4, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Parent = window.TitleBar
    })
    
    -- Close Button
    local closeBtn = CreateInstance("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Colors.TextDark,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Parent = window.TitleBar
    })
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {TextColor3 = Colors.Error}, 0.2)
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {TextColor3 = Colors.TextDark}, 0.2)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- Content Area
    window.Content = CreateInstance("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Parent = window.Main
    })
    
    CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 10),
        Parent = window.Content
    })
    
    -- Make Draggable
    MakeDraggable(window.Main, window.TitleBar)
    
    -- Methods
    function window:AddDropdown(config)
        config.Parent = self.Content
        return VapeV5:CreateDropdown(config)
    end
    
    function window:AddLabel(text)
        local label = CreateInstance("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Colors.TextDark,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Content
        })
        return label
    end
    
    function window:AddSection(text)
        local section = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = self.Content
        })
        
        CreateInstance("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Colors.Accent,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section
        })
        
        local line = CreateInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -5),
            BackgroundColor3 = Colors.Border,
            BorderSizePixel = 0,
            Parent = section
        })
        
        return section
    end
    
    function window:Destroy()
        self.ScreenGui:Destroy()
    end
    
    -- Intro Animation
    window.Main.Size = UDim2.new(0, 0, 0, 0)
    window.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(window.Main, {
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200)
    }, 0.5, Enum.EasingStyle.Back)
    
    return window
end

-- ==================== WORKING EXAMPLE ====================

-- Example Usage Function
function VapeV5:ShowExample()
    -- Create Window
    local window = self:CreateWindow("Vape V5 - Example")
    
    -- Section 1: Basic Dropdown
    window:AddSection("Basic Dropdown")
    
    local basicDropdown = window:AddDropdown({
        Text = "Select Game",
        Callback = function(value)
            print("Selected game:", value)
        end
    })
    
    basicDropdown:AddOption("Bedwars", "bedwars")
    basicDropdown:AddOption("Skywars", "skywars")
    basicDropdown:AddOption("Murder Mystery 2", "mm2")
    basicDropdown:AddOption("Blox Fruits", "blox_fruits")
    basicDropdown:AddOption("Doors", "doors")
    
    -- Section 2: Settings Dropdown
    window:AddSection("Settings")
    
    local themeDropdown = window:AddDropdown({
        Text = "Select Theme",
        Callback = function(value)
            print("Theme changed to:", value)
            -- You could apply theme changes here
        end
    })
    
    themeDropdown:AddOption("Default Purple", "purple")
    themeDropdown:AddOption("Blood Red", "red")
    themeDropdown:AddOption("Ocean Blue", "blue")
    themeDropdown:AddOption("Midnight Black", "black")
    themeDropdown:AddOption("Forest Green", "green")
    
    -- Section 3: Multi-purpose
    window:AddSection("Combat Settings")
    
    local aimbotDropdown = window:AddDropdown({
        Text = "Aimbot Mode",
        Callback = function(value)
            print("Aimbot set to:", value)
        end
    })
    
    aimbotDropdown:AddOption("Silent Aim", "silent")
    aimbotDropdown:AddOption("Legit", "legit")
    aimbotDropdown:AddOption("Rage", "rage")
    aimbotDropdown:AddOption("Off", false)
    
    -- Notification
    local notif = CreateInstance("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 250, 0, 60),
        Position = UDim2.new(1, 260, 1, -80),
        BackgroundColor3 = Colors.ElementBg,
        BorderSizePixel = 0,
        Parent = window.ScreenGui
    })
    
    CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notif
    })
    
    CreateInstance("UIStroke", {
        Color = Colors.Accent,
        Thickness = 1,
        Parent = notif
    })
    
    CreateInstance("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "✓ Vape V5 Loaded Successfully",
        TextColor3 = Colors.Success,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    -- Slide in notification
    Tween(notif, {Position = UDim2.new(1, -270, 1, -80)}, 0.5, Enum.EasingStyle.Back)
    
    -- Remove notification after 3 seconds
    delay(3, function()
        Tween(notif, {Position = UDim2.new(1, 260, 1, -80)}, 0.5, Enum.EasingStyle.Quart)
        wait(0.5)
        notif:Destroy()
    end)
    
    return window
end

-- Return the library
return VapeV5
