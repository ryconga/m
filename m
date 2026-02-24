function library:Window(Info)
    Info.Text = Info.Text or "Window"

    local Theme = Themes[library.Theme]
    if Theme == nil then
        error("There's no theme called: "..library.Theme, 0)
    end

    local window = {}
    local Dropdowns = {} -- Track all dropdowns for auto-close
    local SelectedTab = nil

    -- Services
    local HttpService = game:GetService("HttpService")
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Mouse = game.Players.LocalPlayer:GetMouse()

    -- Main GUI
    local unnamed = Instance.new("ScreenGui")
    unnamed.Name = HttpService:GenerateGUID(true)
    unnamed.ZIndexBehavior = Enum.ZIndexBehavior.Global
    unnamed.Parent = CoreGui

    -- VAPE V4 STYLE: Top Bar Container (Horizontal, minimal, sleek)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.BackgroundColor3 = Theme.Topbar
    topBar.BorderSizePixel = 0
    topBar.Position = UDim2.new(0.5, -250, 0, 10) -- Centered top
    topBar.Size = UDim2.new(0, 500, 0, 35) -- Vape style: thin horizontal bar
    topBar.Parent = unnamed

    local topBarUICorner = Instance.new("UICorner")
    topBarUICorner.CornerRadius = UDim.new(0, 3)
    topBarUICorner.Parent = topBar

    local topBarUIStroke = Instance.new("UIStroke")
    topBarUIStroke.Color = Theme.MainUIStroke
    topBarUIStroke.Thickness = 1
    topBarUIStroke.Parent = topBar

    -- Vape Logo/Title (Left side)
    local vapeTitle = Instance.new("TextLabel")
    vapeTitle.Name = "VapeTitle"
    vapeTitle.Font = Enum.Font.GothamBold
    vapeTitle.Text = Info.Text
    vapeTitle.TextColor3 = Theme.Highlight or Theme.SliderInner
    vapeTitle.TextSize = 14
    vapeTitle.TextXAlignment = Enum.TextXAlignment.Left
    vapeTitle.BackgroundTransparency = 1
    vapeTitle.Position = UDim2.new(0, 10, 0, 0)
    vapeTitle.Size = UDim2.new(0, 100, 1, 0)
    vapeTitle.Parent = topBar

    -- Container for category buttons (Vape style: horizontal list)
    local categoriesContainer = Instance.new("Frame")
    categoriesContainer.Name = "CategoriesContainer"
    categoriesContainer.BackgroundTransparency = 1
    categoriesContainer.Position = UDim2.new(0, 120, 0, 0)
    categoriesContainer.Size = UDim2.new(1, -230, 1, 0)
    categoriesContainer.Parent = topBar

    local categoriesLayout = Instance.new("UIListLayout")
    categoriesLayout.FillDirection = Enum.FillDirection.Horizontal
    categoriesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    categoriesLayout.Padding = UDim.new(0, 2)
    categoriesLayout.Parent = categoriesContainer

    -- Right side controls (Search, Settings, etc)
    local rightControls = Instance.new("Frame")
    rightControls.Name = "RightControls"
    rightControls.BackgroundTransparency = 1
    rightControls.Position = UDim2.new(1, -100, 0, 0)
    rightControls.Size = UDim2.new(0, 90, 1, 0)
    rightControls.Parent = topBar

    -- Close/Minimize buttons (Vape style: X and -)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Theme.ItemText
    closeButton.TextSize = 12
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Parent = topBar

    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 66, 66)}):Play()
    end)
    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.1), {TextColor3 = Theme.ItemText}):Play()
    end)
    closeButton.MouseButton1Click:Connect(function()
        unnamed:Destroy()
    end)

    -- Main content area (where modules appear)
    local mainContent = Instance.new("Frame")
    mainContent.Name = "MainContent"
    mainContent.BackgroundColor3 = Theme.Main
    mainContent.BorderSizePixel = 0
    mainContent.Position = UDim2.new(0.5, -250, 0, 50)
    mainContent.Size = UDim2.new(0, 500, 0, 400)
    mainContent.ClipsDescendants = true
    mainContent.Visible = false -- Hidden until category selected
    mainContent.Parent = unnamed

    local mainContentUICorner = Instance.new("UICorner")
    mainContentUICorner.CornerRadius = UDim.new(0, 3)
    mainContentUICorner.Parent = mainContent

    local mainContentUIStroke = Instance.new("UIStroke")
    mainContentUIStroke.Color = Theme.MainUIStroke
    mainContentUIStroke.Thickness = 1
    mainContentUIStroke.Parent = mainContent

    -- Module list container (Left side of main content)
    local moduleList = Instance.new("ScrollingFrame")
    moduleList.Name = "ModuleList"
    moduleList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    moduleList.CanvasSize = UDim2.new()
    moduleList.ScrollBarThickness = 2
    moduleList.ScrollBarImageColor3 = Theme.Highlight or Theme.SliderInner
    moduleList.BackgroundColor3 = Theme.TabContainer
    moduleList.BorderSizePixel = 0
    moduleList.Position = UDim2.new(0, 0, 0, 0)
    moduleList.Size = UDim2.new(0, 150, 1, 0)
    moduleList.Parent = mainContent

    local moduleListLayout = Instance.new("UIListLayout")
    moduleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    moduleListLayout.Parent = moduleList

    local moduleListPadding = Instance.new("UIPadding")
    moduleListPadding.PaddingLeft = UDim.new(0, 5)
    moduleListPadding.PaddingTop = UDim.new(0, 5)
    moduleListPadding.PaddingBottom = UDim.new(0, 5)
    moduleListPadding.Parent = moduleList

    -- Settings panel (Right side, shows when module selected)
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Name = "SettingsPanel"
    settingsPanel.BackgroundColor3 = Theme.SectionFrame
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Position = UDim2.new(0, 150, 0, 0)
    settingsPanel.Size = UDim2.new(1, -150, 1, 0)
    settingsPanel.Parent = mainContent

    local settingsPanelPadding = Instance.new("UIPadding")
    settingsPanelPadding.PaddingLeft = UDim.new(0, 10)
    settingsPanelPadding.PaddingTop = UDim.new(0, 10)
    settingsPanelPadding.PaddingRight = UDim.new(0, 10)
    settingsPanelPadding.PaddingBottom = UDim.new(0, 10)
    settingsPanelPadding.Parent = settingsPanel

    -- ============================================
    -- VAPE V4 DROPDOWN SYSTEM (Top Bar Style)
    -- ============================================

    function window:Category(Info)
        Info.Text = Info.Text or "Category"
        Info.Modules = Info.Modules or {} -- Pre-defined modules list

        local categoryTable = {}
        local isOpen = false
        local dropdownFrame = nil

        -- Category Button (Top bar style)
        local categoryButton = Instance.new("TextButton")
        categoryButton.Name = Info.Text .. "Button"
        categoryButton.Font = Enum.Font.GothamBold
        categoryButton.Text = Info.Text
        categoryButton.TextColor3 = Theme.TabText
        categoryButton.TextSize = 12
        categoryButton.BackgroundColor3 = Theme.TabFrame
        categoryButton.BorderSizePixel = 0
        categoryButton.Size = UDim2.new(0, 80, 0, 25)
        categoryButton.LayoutOrder = #Dropdowns + 1
        categoryButton.Parent = categoriesContainer

        local buttonUICorner = Instance.new("UICorner")
        buttonUICorner.CornerRadius = UDim.new(0, 2)
        buttonUICorner.Parent = categoryButton

        local buttonUIStroke = Instance.new("UIStroke")
        buttonUIStroke.Color = Theme.TabUIStroke
        buttonUIStroke.Thickness = 1
        buttonUIStroke.Parent = categoryButton

        -- VAPE STYLE: Dropdown appears BELOW the top bar
        dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = Info.Text .. "Dropdown"
        dropdownFrame.BackgroundColor3 = Theme.Main
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.Position = UDim2.new(0, categoryButton.AbsolutePosition.X, 0, 45)
        dropdownFrame.Size = UDim2.new(0, 200, 0, 0) -- Starts collapsed
        dropdownFrame.ClipsDescendants = true
        dropdownFrame.Visible = false
        dropdownFrame.ZIndex = 10
        dropdownFrame.Parent = unnamed

        local dropdownUICorner = Instance.new("UICorner")
        dropdownUICorner.CornerRadius = UDim.new(0, 3)
        dropdownUICorner.Parent = dropdownFrame

        local dropdownUIStroke = Instance.new("UIStroke")
        dropdownUIStroke.Color = Theme.MainUIStroke
        dropdownUIStroke.Thickness = 1
        dropdownUIStroke.Parent = dropdownFrame

        -- Module list inside dropdown
        local dropdownList = Instance.new("ScrollingFrame")
        dropdownList.Name = "DropdownList"
        dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
        dropdownList.CanvasSize = UDim2.new()
        dropdownList.ScrollBarThickness = 2
        dropdownList.ScrollBarImageColor3 = Theme.Highlight or Theme.SliderInner
        dropdownList.BackgroundTransparency = 1
        dropdownList.BorderSizePixel = 0
        dropdownList.Position = UDim2.new(0, 5, 0, 5)
        dropdownList.Size = UDim2.new(1, -10, 1, -10)
        dropdownList.Parent = dropdownFrame

        local dropdownListLayout = Instance.new("UIListLayout")
        dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownListLayout.Padding = UDim.new(0, 2)
        dropdownListLayout.Parent = dropdownList

        -- Close other dropdowns when opening
        local function closeOthers()
            for _, cat in pairs(Dropdowns) do
                if cat ~= categoryTable and cat.IsOpen then
                    cat:Close()
                end
            end
        end

        -- Toggle dropdown
        function categoryTable:Toggle()
            isOpen = not isOpen
            
            if isOpen then
                closeOthers()
                dropdownFrame.Visible = true
                mainContent.Visible = true
                
                -- Animate opening (Vape style: smooth height expand)
                local contentHeight = math.min(#Info.Modules * 28 + 10, 300)
                TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Size = UDim2.new(0, 200, 0, contentHeight)}):Play()
                
                -- Highlight button
                TweenService:Create(categoryButton, TweenInfo.new(0.15), 
                    {BackgroundColor3 = Theme.SelectedTabFrame, TextColor3 = Theme.Highlight or Theme.SliderInner}):Play()
                TweenService:Create(buttonUIStroke, TweenInfo.new(0.15), 
                    {Color = Theme.HighlightUIStroke or Theme.ItemUIStrokeSelected}):Play()
            else
                -- Animate closing
                TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Size = UDim2.new(0, 200, 0, 0)}):Play()
                
                -- Reset button
                TweenService:Create(categoryButton, TweenInfo.new(0.15), 
                    {BackgroundColor3 = Theme.TabFrame, TextColor3 = Theme.TabText}):Play()
                TweenService:Create(buttonUIStroke, TweenInfo.new(0.15), 
                    {Color = Theme.TabUIStroke}):Play()
                
                task.delay(0.2, function()
                    if not isOpen then
                        dropdownFrame.Visible = false
                    end
                end)
            end
        end

        function categoryTable:Close()
            if isOpen then
                isOpen = false
                TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Size = UDim2.new(0, 200, 0, 0)}):Play()
                TweenService:Create(categoryButton, TweenInfo.new(0.15), 
                    {BackgroundColor3 = Theme.TabFrame, TextColor3 = Theme.TabText}):Play()
                TweenService:Create(buttonUIStroke, TweenInfo.new(0.15), 
                    {Color = Theme.TabUIStroke}):Play()
                
                task.delay(0.2, function()
                    if not isOpen then
                        dropdownFrame.Visible = false
                    end
                end)
            end
        end

        function categoryTable:IsOpen()
            return isOpen
        end

        -- Add modules to dropdown
        for _, moduleName in ipairs(Info.Modules) do
            local moduleButton = Instance.new("TextButton")
            moduleButton.Name = moduleName
            moduleButton.Font = Enum.Font.Gotham
            moduleButton.Text = moduleName
            moduleButton.TextColor3 = Theme.ItemText
            moduleButton.TextSize = 12
            moduleButton.TextXAlignment = Enum.TextXAlignment.Left
            moduleButton.BackgroundColor3 = Theme.ItemFrame
            moduleButton.BorderSizePixel = 0
            moduleButton.Size = UDim2.new(1, 0, 0, 26)
            moduleButton.Parent = dropdownList

            local moduleButtonCorner = Instance.new("UICorner")
            moduleButtonCorner.CornerRadius = UDim.new(0, 2)
            moduleButtonCorner.Parent = moduleButton

            -- Hover effects
            moduleButton.MouseEnter:Connect(function()
                TweenService:Create(moduleButton, TweenInfo.new(0.1), 
                    {BackgroundColor3 = Theme.HoverItemFrame, TextColor3 = Theme.Highlight or Theme.SliderInner}):Play()
            end)

            moduleButton.MouseLeave:Connect(function()
                TweenService:Create(moduleButton, TweenInfo.new(0.1), 
                    {BackgroundColor3 = Theme.ItemFrame, TextColor3 = Theme.ItemText}):Play()
            end)

            -- Click to enable/disable (Vape style: toggle modules)
            moduleButton.MouseButton1Click:Connect(function()
                -- Toggle logic here - would add to main module list
                print("Toggled:", moduleName)
            end)
        end

        -- Click handling
        categoryButton.MouseButton1Click:Connect(function()
            categoryTable:Toggle()
        end)

        -- Hover effect for category button
        categoryButton.MouseEnter:Connect(function()
            if not isOpen then
                TweenService:Create(categoryButton, TweenInfo.new(0.1), 
                    {BackgroundColor3 = Theme.HoverTabFrame}):Play()
            end
        end)

        categoryButton.MouseLeave:Connect(function()
            if not isOpen then
                TweenService:Create(categoryButton, TweenInfo.new(0.1), 
                    {BackgroundColor3 = Theme.TabFrame}):Play()
            end
        end)

        table.insert(Dropdowns, categoryTable)
        return categoryTable
    end

    -- Close dropdowns when clicking outside
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            for _, cat in pairs(Dropdowns) do
                if cat:IsOpen() then
                    local dropdown = cat.DropdownFrame
                    if dropdown then
                        local pos = dropdown.AbsolutePosition
                        local size = dropdown.AbsoluteSize
                        if mousePos.X < pos.X or mousePos.X > pos.X + size.X or 
                           mousePos.Y < pos.Y or mousePos.Y > pos.Y + size.Y then
                            -- Check if clicked on button
                            local btnPos = cat.Button.AbsolutePosition
                            local btnSize = cat.Button.AbsoluteSize
                            if mousePos.X < btnPos.X or mousePos.X > btnPos.X + btnSize.X or 
                               mousePos.Y < btnPos.Y or mousePos.Y > btnPos.Y + btnSize.Y then
                                cat:Close()
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ============================================
    -- VAPE V4 STYLE: Dropdown Component (For Settings)
    -- ============================================

    function window:Dropdown(Info)
        Info.Text = Info.Text or "Dropdown"
        Info.Options = Info.Options or {}
        Info.Default = Info.Default or nil
        Info.Flag = Info.Flag or nil
        Info.Callback = Info.Callback or function() end

        local dropdownTable = {}
        local isOpen = false
        local selected = Info.Default

        -- Container (Vape style: minimal, full width)
        local container = Instance.new("Frame")
        container.Name = "DropdownContainer"
        container.BackgroundTransparency = 1
        container.Size = UDim2.new(1, 0, 0, 30)
        
        -- Main button (looks like input field)
        local mainButton = Instance.new("TextButton")
        mainButton.Name = "DropdownButton"
        mainButton.Font = Enum.Font.Gotham
        mainButton.Text = selected or Info.Text
        mainButton.TextColor3 = selected and Theme.ItemText or Theme.InputPlaceHolder
        mainButton.TextSize = 12
        mainButton.TextXAlignment = Enum.TextXAlignment.Left
        mainButton.BackgroundColor3 = Theme.ItemFrame
        mainButton.BorderSizePixel = 0
        mainButton.Position = UDim2.new(0, 0, 0, 0)
        mainButton.Size = UDim2.new(1, 0, 0, 30)
        mainButton.Parent = container

        local mainButtonCorner = Instance.new("UICorner")
        mainButtonCorner.CornerRadius = UDim.new(0, 2)
        mainButtonCorner.Parent = mainButton

        local mainButtonStroke = Instance.new("UIStroke")
        mainButtonStroke.Color = Theme.ItemUIStroke
        mainButtonStroke.Thickness = 1
        mainButtonStroke.Parent = mainButton

        -- Arrow icon (Vape style: simple chevron)
        local arrowIcon = Instance.new("ImageLabel")
        arrowIcon.Name = "Arrow"
        arrowIcon.Image = getcustomasset("Unnamed/Chevron.png")
        arrowIcon.ImageColor3 = Theme.DropdownIcon or Theme.ItemText
        arrowIcon.BackgroundTransparency = 1
        arrowIcon.Position = UDim2.new(1, -25, 0.5, -8)
        arrowIcon.Size = UDim2.new(0, 16, 0, 16)
        arrowIcon.Rotation = 0
        arrowIcon.Parent = mainButton

        -- Options container (Vape style: overlay dropdown)
        local optionsFrame = Instance.new("Frame")
        optionsFrame.Name = "OptionsFrame"
        optionsFrame.BackgroundColor3 = Theme.Main
        optionsFrame.BorderSizePixel = 0
        optionsFrame.Position = UDim2.new(0, 0, 0, 32)
        optionsFrame.Size = UDim2.new(1, 0, 0, 0)
        optionsFrame.ClipsDescendants = true
        optionsFrame.Visible = false
        optionsFrame.ZIndex = 5
        optionsFrame.Parent = container

        local optionsFrameCorner = Instance.new("UICorner")
        optionsFrameCorner.CornerRadius = UDim.new(0, 2)
        optionsFrameCorner.Parent = optionsFrame

        local optionsFrameStroke = Instance.new("UIStroke")
        optionsFrameStroke.Color = Theme.ItemUIStroke
        optionsFrameStroke.Thickness = 1
        optionsFrameStroke.Parent = optionsFrame

        local optionsList = Instance.new("ScrollingFrame")
        optionsList.Name = "OptionsList"
        optionsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
        optionsList.CanvasSize = UDim2.new()
        optionsList.ScrollBarThickness = 2
        optionsList.ScrollBarImageColor3 = Theme.Highlight or Theme.SliderInner
        optionsList.BackgroundTransparency = 1
        optionsList.BorderSizePixel = 0
        optionsList.Position = UDim2.new(0, 5, 0, 5)
        optionsList.Size = UDim2.new(1, -10, 1, -10)
        optionsList.ZIndex = 5
        optionsList.Parent = optionsFrame

        local optionsListLayout = Instance.new("UIListLayout")
        optionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optionsListLayout.Padding = UDim.new(0, 2)
        optionsListLayout.Parent = optionsList

        -- Toggle function
        function dropdownTable:Toggle()
            isOpen = not isOpen
            
            if isOpen then
                optionsFrame.Visible = true
                local height = math.min(#Info.Options * 28 + 10, 200)
                
                TweenService:Create(optionsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Size = UDim2.new(1, 0, 0, height)}):Play()
                TweenService:Create(arrowIcon, TweenInfo.new(0.2), {Rotation = 180}):Play()
                TweenService:Create(mainButtonStroke, TweenInfo.new(0.15), 
                    {Color = Theme.ItemUIStrokeSelected}):Play()
            else
                TweenService:Create(optionsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                    {Size = UDim2.new(1, 0, 0, 0)}):Play()
                TweenService:Create(arrowIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                TweenService:Create(mainButtonStroke, TweenInfo.new(0.15), 
                    {Color = Theme.ItemUIStroke}):Play()
                
                task.delay(0.2, function()
                    if not isOpen then
                        optionsFrame.Visible = false
                    end
                end)
            end
        end

        -- Add options
        for _, option in ipairs(Info.Options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.Font = Enum.Font.Gotham
            optionBtn.Text = option
            optionBtn.TextColor3 = Theme.ItemText
            optionBtn.TextSize = 12
            optionBtn.TextXAlignment = Enum.TextXAlignment.Left
            optionBtn.BackgroundColor3 = Theme.ItemFrame
            optionBtn.BorderSizePixel = 0
            optionBtn.Size = UDim2.new(1, 0, 0, 26)
            optionBtn.ZIndex = 5
            optionBtn.Parent = optionsList

            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 2)
            optionCorner.Parent = optionBtn

            -- Selection indicator (Vape style: left accent bar)
            local accentBar = Instance.new("Frame")
            accentBar.Name = "Accent"
            accentBar.BackgroundColor3 = Theme.Highlight or Theme.SliderInner
            accentBar.BorderSizePixel = 0
            accentBar.Size = UDim2.new(0, 2, 0, 0)
            accentBar.Position = UDim2.new(0, 0, 0.5, 0)
            accentBar.AnchorPoint = Vector2.new(0, 0.5)
            accentBar.ZIndex = 5
            accentBar.Parent = optionBtn

            -- Hover
            optionBtn.MouseEnter:Connect(function()
                if selected ~= option then
                    TweenService:Create(optionBtn, TweenInfo.new(0.1), 
                        {BackgroundColor3 = Theme.HoverItemFrame}):Play()
                end
            end)

            optionBtn.MouseLeave:Connect(function()
                if selected ~= option then
                    TweenService:Create(optionBtn, TweenInfo.new(0.1), 
                        {BackgroundColor3 = Theme.ItemFrame}):Play()
                end
            end)

            -- Select
            optionBtn.MouseButton1Click:Connect(function()
                selected = option
                mainButton.Text = option
                mainButton.TextColor3 = Theme.ItemText
                
                -- Update visuals
                for _, child in pairs(optionsList:GetChildren()) do
                    if child:IsA("TextButton") then
                        local isSel = child.Name == option
                        TweenService:Create(child, TweenInfo.new(0.15), 
                            {BackgroundColor3 = isSel and Theme.HoverItemFrame or Theme.ItemFrame}):Play()
                        TweenService:Create(child.Accent, TweenInfo.new(0.15), 
                            {Size = isSel and UDim2.new(0, 2, 0, 16) or UDim2.new(0, 2, 0, 0)}):Play()
                        TweenService:Create(child, TweenInfo.new(0.15), 
                            {TextColor3 = isSel and (Theme.Highlight or Theme.SliderInner) or Theme.ItemText}):Play()
                    end
                end

                if Info.Flag then
                    library.Flags[Info.Flag] = option
                end
                task.spawn(Info.Callback, option)
                dropdownTable:Toggle()
            end)

            -- Set initial
            if option == selected then
                accentBar.Size = UDim2.new(0, 2, 0, 16)
                optionBtn.TextColor3 = Theme.Highlight or Theme.SliderInner
                optionBtn.BackgroundColor3 = Theme.HoverItemFrame
            end
        end

        -- Click handling
        mainButton.MouseButton1Click:Connect(function()
            dropdownTable:Toggle()
        end)

        mainButton.MouseEnter:Connect(function()
            if not isOpen then
                TweenService:Create(mainButton, TweenInfo.new(0.1), 
                    {BackgroundColor3 = Theme.HoverItemFrame}):Play()
            end
        end)

        mainButton.MouseLeave:Connect(function()
            if not isOpen then
                TweenService:Create(mainButton, TweenInfo.new(0.1), 
                    {BackgroundColor3 = Theme.ItemFrame}):Play()
            end
        end)

        -- Methods
        function dropdownTable:Set(value)
            for _, child in pairs(optionsList:GetChildren()) do
                if child:IsA("TextButton") and child.Name == value then
                    child.MouseButton1Click:Fire()
                    return
                end
            end
        end

        function dropdownTable:Get()
            return selected
        end

        function dropdownTable:Refresh(newOptions, keepSelection)
            -- Clear existing
            for _, child in pairs(optionsList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            Info.Options = newOptions
            
            -- Re-add
            for _, option in ipairs(newOptions) do
                -- (Same creation code as above, simplified for refresh)
                -- ... add option ...
            end
            
            if not keepSelection then
                selected = nil
                mainButton.Text = Info.Text
                mainButton.TextColor3 = Theme.InputPlaceHolder
            end
        end

        return dropdownTable, container
    end

    return window
end
