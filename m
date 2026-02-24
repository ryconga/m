function sectiontable:Dropdown(Info)
    Info.Text = Info.Text or "Dropdown"
    Info.Flag = Info.Flag or nil
    Info.Default = Info.Default or nil
    Info.List = Info.List or {}
    Info.Callback = Info.Callback or function() end
    Info.ChangeTextOnPick = Info.ChangeTextOnPick ~= false -- Default true for Vape style

    local insidedropdown = {}
    local Theme = Themes[library.Theme]

    -- Main dropdown container (Vape style: clean, minimal frame)
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.BackgroundTransparency = 1
    dropdown.Size = UDim2.new(0, 175, 0, 28)
    dropdown.Parent = itemContainer

    -- Dropdown frame with Vape-style subtle borders
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "DropdownFrame"
    dropdownFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    dropdownFrame.BackgroundColor3 = Theme.ItemFrame
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    dropdownFrame.Size = UDim2.new(0, 171, 0, 24)
    dropdownFrame.Parent = dropdown

    local dropdownUICorner = Instance.new("UICorner")
    dropdownUICorner.CornerRadius = UDim.new(0, 2)
    dropdownUICorner.Parent = dropdownFrame

    -- Vape-style subtle stroke
    local dropdownUIStroke = Instance.new("UIStroke")
    dropdownUIStroke.Name = "DropdownUIStroke"
    dropdownUIStroke.Color = Theme.ItemUIStroke
    dropdownUIStroke.Thickness = 1
    dropdownUIStroke.Parent = dropdownFrame

    -- Text label (left-aligned like Vape)
    local dropdownText = Instance.new("TextLabel")
    dropdownText.Name = "DropdownText"
    dropdownText.Font = Enum.Font.GothamBold
    dropdownText.Text = Info.Default or Info.Text
    dropdownText.TextColor3 = Theme.ItemText
    dropdownText.TextSize = 12
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.TextTruncate = Enum.TextTruncate.AtEnd
    dropdownText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Position = UDim2.new(0, 8, 0, 0)
    dropdownText.Size = UDim2.new(0, 140, 0, 24)
    dropdownText.Parent = dropdownFrame

    -- Vape-style chevron icon (rotates smoothly)
    local dropdownIcon = Instance.new("ImageLabel")
    dropdownIcon.Name = "DropdownIcon"
    dropdownIcon.Image = getcustomasset("Unnamed/Chevron.png")
    dropdownIcon.ImageColor3 = Theme.DropdownIcon or Theme.ItemText
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Position = UDim2.new(0, 152, 0, 4)
    dropdownIcon.Size = UDim2.new(0, 16, 0, 16)
    dropdownIcon.Rotation = 0 -- Vape style: starts pointing down
    dropdownIcon.Parent = dropdownFrame

    -- Click detection button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Font = Enum.Font.SourceSans
    dropdownButton.Text = ""
    dropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    dropdownButton.TextSize = 14
    dropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dropdownButton.BackgroundTransparency = 1
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Parent = dropdownFrame

    -- Options container (Vape style: appears below with smooth expand)
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.BackgroundColor3 = Theme.ContainerHolder or Theme.ItemFrame
    optionsContainer.BorderSizePixel = 0
    optionsContainer.ClipsDescendants = true
    optionsContainer.Position = UDim2.new(0, 2, 0, 26)
    optionsContainer.Size = UDim2.new(0, 171, 0, 0)
    optionsContainer.Visible = false
    optionsContainer.ZIndex = 5
    optionsContainer.Parent = dropdown

    local optionsUICorner = Instance.new("UICorner")
    optionsUICorner.CornerRadius = UDim.new(0, 2)
    optionsUICorner.Parent = optionsContainer

    local optionsUIStroke = Instance.new("UIStroke")
    optionsUIStroke.Color = Theme.ItemUIStroke
    optionsUIStroke.Thickness = 1
    optionsUIStroke.Parent = optionsContainer

    -- Scrolling frame for options (Vape style: max height with scroll)
    local optionsScrolling = Instance.new("ScrollingFrame")
    optionsScrolling.Name = "OptionsScrolling"
    optionsScrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsScrolling.CanvasSize = UDim2.new()
    optionsScrolling.ScrollBarThickness = 2
    optionsScrolling.ScrollBarImageColor3 = Theme.Highlight or Theme.SliderInner
    optionsScrolling.BackgroundTransparency = 1
    optionsScrolling.BorderSizePixel = 0
    optionsScrolling.Position = UDim2.new(0, 0, 0, 2)
    optionsScrolling.Size = UDim2.new(1, 0, 1, -4)
    optionsScrolling.ZIndex = 5
    optionsScrolling.Parent = optionsContainer

    local optionsListLayout = Instance.new("UIListLayout")
    optionsListLayout.Name = "OptionsListLayout"
    optionsListLayout.Padding = UDim.new(0, 1)
    optionsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsListLayout.Parent = optionsScrolling

    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingLeft = UDim.new(0, 4)
    optionsPadding.PaddingRight = UDim.new(0, 4)
    optionsPadding.PaddingTop = UDim.new(0, 2)
    optionsPadding.PaddingBottom = UDim.new(0, 2)
    optionsPadding.Parent = optionsScrolling

    -- State variables
    local isOpen = false
    local selectedValue = Info.Default
    local optionHeight = 22
    local maxVisibleOptions = 6
    local totalOptions = 0

    -- Vape-style hover effects
    dropdownFrame.MouseEnter:Connect(function()
        TweenService:Create(dropdownFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundColor3 = Theme.HoverItemFrame}):Play()
    end)

    dropdownFrame.MouseLeave:Connect(function()
        if not isOpen then
            TweenService:Create(dropdownFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {BackgroundColor3 = Theme.ItemFrame}):Play()
        end
    end)

    dropdownButton.MouseButton1Down:Connect(function()
        TweenService:Create(dropdownUIStroke, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Color = Theme.ItemUIStrokeSelected}):Play()
    end)

    dropdownButton.MouseButton1Up:Connect(function()
        if not isOpen then
            TweenService:Create(dropdownUIStroke, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Color = Theme.ItemUIStroke}):Play()
        end
    end)

    -- Toggle function with Vape-style smooth animation
    local function toggleDropdown()
        isOpen = not isOpen
        
        if isOpen then
            optionsContainer.Visible = true
            containerHolder.ClipsDescendants = false
            
            -- Calculate height based on options count
            local contentHeight = math.min(totalOptions * (optionHeight + 1) + 4, maxVisibleOptions * (optionHeight + 1) + 4)
            
            -- Animate opening (Vape style: smooth expand)
            TweenService:Create(dropdownIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Rotation = 180}):Play()
            TweenService:Create(optionsContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 171, 0, contentHeight)}):Play()
            TweenService:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, 28 + contentHeight + 2)}):Play()
            
            -- Update section sizing
            TweenService:Create(section, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, section.Size.Y.Offset + contentHeight + 2)}):Play()
            TweenService:Create(sectionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, sectionFrame.Size.Y.Offset + contentHeight + 2)}):Play()
            TweenService:Create(itemContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, itemContainer.Size.Y.Offset + contentHeight + 2)}):Play()
        else
            -- Animate closing
            TweenService:Create(dropdownIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Rotation = 0}):Play()
            TweenService:Create(optionsContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 171, 0, 0)}):Play()
            TweenService:Create(dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, 28)}):Play()
            
            -- Revert section sizing
            local currentHeight = optionsContainer.Size.Y.Offset
            TweenService:Create(section, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, section.Size.Y.Offset - currentHeight - 2)}):Play()
            TweenService:Create(sectionFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, sectionFrame.Size.Y.Offset - currentHeight - 2)}):Play()
            TweenService:Create(itemContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                {Size = UDim2.new(0, 175, 0, itemContainer.Size.Y.Offset - currentHeight - 2)}):Play()
            
            task.delay(0.2, function()
                if not isOpen then
                    optionsContainer.Visible = false
                    containerHolder.ClipsDescendants = true
                    dropdownFrame.BackgroundColor3 = Theme.ItemFrame
                end
            end)
        end
    end

    dropdownButton.MouseButton1Click:Connect(toggleDropdown)

    -- Add option function (Vape style: clean hover effects)
    function insidedropdown:Add(value)
        totalOptions = totalOptions + 1
        
        local optionFrame = Instance.new("Frame")
        optionFrame.Name = "Option_" .. tostring(totalOptions)
        optionFrame.BackgroundColor3 = Theme.ItemFrame
        optionFrame.BackgroundTransparency = 1 -- Start transparent for clean look
        optionFrame.BorderSizePixel = 0
        optionFrame.Size = UDim2.new(1, 0, 0, optionHeight)
        optionFrame.ZIndex = 5
        optionFrame.Parent = optionsScrolling

        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 2)
        optionCorner.Parent = optionFrame

        local optionText = Instance.new("TextLabel")
        optionText.Name = "OptionText"
        optionText.Font = Enum.Font.GothamBold
        optionText.Text = tostring(value)
        optionText.TextColor3 = Theme.ItemText
        optionText.TextSize = 11
        optionText.TextXAlignment = Enum.TextXAlignment.Left
        optionText.TextTruncate = Enum.TextTruncate.AtEnd
        optionText.BackgroundTransparency = 1
        optionText.Position = UDim2.new(0, 6, 0, 0)
        optionText.Size = UDim2.new(1, -12, 1, 0)
        optionText.ZIndex = 5
        optionText.Parent = optionFrame

        -- Selection indicator (Vape style: subtle left accent)
        local selectionIndicator = Instance.new("Frame")
        selectionIndicator.Name = "SelectionIndicator"
        selectionIndicator.BackgroundColor3 = Theme.Highlight or Theme.SliderInner
        selectionIndicator.BorderSizePixel = 0
        selectionIndicator.Size = UDim2.new(0, 2, 0, 0)
        selectionIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        selectionIndicator.AnchorPoint = Vector2.new(0, 0.5)
        selectionIndicator.ZIndex = 5
        selectionIndicator.Parent = optionFrame

        local optionButton = Instance.new("TextButton")
        optionButton.Name = "OptionButton"
        optionButton.Font = Enum.Font.SourceSans
        optionButton.Text = ""
        optionButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        optionButton.TextSize = 14
        optionButton.BackgroundTransparency = 1
        optionButton.Size = UDim2.new(1, 0, 1, 0)
        optionButton.ZIndex = 5
        optionButton.Parent = optionFrame

        -- Update selection visual
        local function updateSelection()
            local isSelected = (selectedValue == value)
            TweenService:Create(optionFrame, TweenInfo.new(0.15), 
                {BackgroundTransparency = isSelected and 0.8 or 1}):Play()
            TweenService:Create(optionText, TweenInfo.new(0.15), 
                {TextColor3 = isSelected and (Theme.Highlight or Theme.SliderInner) or Theme.ItemText}):Play()
            TweenService:Create(selectionIndicator, TweenInfo.new(0.15), 
                {Size = isSelected and UDim2.new(0, 2, 0, 14) or UDim2.new(0, 2, 0, 0)}):Play()
        end

        -- Hover effects (Vape style: subtle background)
        optionFrame.MouseEnter:Connect(function()
            if selectedValue ~= value then
                TweenService:Create(optionFrame, TweenInfo.new(0.15), 
                    {BackgroundTransparency = 0.9}):Play()
                TweenService:Create(optionText, TweenInfo.new(0.15), 
                    {TextColor3 = Theme.HoverItemFrame}):Play()
            end
        end)

        optionFrame.MouseLeave:Connect(function()
            if selectedValue ~= value then
                TweenService:Create(optionFrame, TweenInfo.new(0.15), 
                    {BackgroundTransparency = 1}):Play()
                TweenService:Create(optionText, TweenInfo.new(0.15), 
                    {TextColor3 = Theme.ItemText}):Play()
            end
        end)

        -- Click handling
        optionButton.MouseButton1Click:Connect(function()
            selectedValue = value
            
            -- Update all options visuals
            for _, child in pairs(optionsScrolling:GetChildren()) do
                if child:IsA("Frame") and child.Name:match("^Option_") then
                    local indicator = child:FindFirstChild("SelectionIndicator")
                    local text = child:FindFirstChild("OptionText")
                    if indicator and text then
                        local isSel = (child.Name == optionFrame.Name)
                        TweenService:Create(child, TweenInfo.new(0.15), 
                            {BackgroundTransparency = isSel and 0.8 or 1}):Play()
                        TweenService:Create(text, TweenInfo.new(0.15), 
                            {TextColor3 = isSel and (Theme.Highlight or Theme.SliderInner) or Theme.ItemText}):Play()
                        TweenService:Create(indicator, TweenInfo.new(0.15), 
                            {Size = isSel and UDim2.new(0, 2, 0, 14) or UDim2.new(0, 2, 0, 0)}):Play()
                    end
                end
            end

            -- Update main text if enabled
            if Info.ChangeTextOnPick then
                dropdownText.Text = tostring(value)
            end

            -- Callback
            if Info.Flag then
                library.Flags[Info.Flag] = value
            end
            task.spawn(Info.Callback, value)

            -- Close dropdown with delay (Vape style)
            task.delay(0.1, toggleDropdown)
        end)

        -- Set initial selection
        if Info.Default == value then
            updateSelection()
        end
    end

    -- Remove option function
    function insidedropdown:Remove(value)
        for _, child in pairs(optionsScrolling:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("OptionText") then
                if child.OptionText.Text == tostring(value) then
                    child:Destroy()
                    totalOptions = totalOptions - 1
                    
                    if isOpen then
                        local newHeight = math.min(totalOptions * (optionHeight + 1) + 4, maxVisibleOptions * (optionHeight + 1) + 4)
                        TweenService:Create(optionsContainer, TweenInfo.new(0.15), 
                            {Size = UDim2.new(0, 171, 0, newHeight)}):Play()
                    end
                    break
                end
            end
        end
    end

    -- Clear all options
    function insidedropdown:Clear()
        for _, child in pairs(optionsScrolling:GetChildren()) do
            if child:IsA("Frame") and child.Name:match("^Option_") then
                child:Destroy()
            end
        end
        totalOptions = 0
        if isOpen then
            toggleDropdown()
        end
    end

    -- Set value function
    function insidedropdown:Set(value)
        for _, child in pairs(optionsScrolling:GetChildren()) do
            if child:IsA("Frame") and child:FindFirstChild("OptionText") then
                if child.OptionText.Text == tostring(value) then
                    child.OptionButton.MouseButton1Click:Fire()
                    return
                end
            end
        end
    end

    -- Get value function
    function insidedropdown:Get()
        return selectedValue
    end

    -- Refresh function (rebuild from list)
    function insidedropdown:Refresh(newList, keepSelection)
        insidedropdown:Clear()
        for _, v in ipairs(newList) do
            insidedropdown:Add(v)
        end
        if not keepSelection then
            selectedValue = nil
            dropdownText.Text = Info.Text
        end
    end

    -- Initialize with provided list
    for _, v in ipairs(Info.List) do
        insidedropdown:Add(v)
    end

    -- Handle section closing/opening
    SectionOpened:GetPropertyChangedSignal("Value"):Connect(function()
        if isOpen then
            toggleDropdown()
        end
    end)

    return insidedropdown
end
