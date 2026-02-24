--// GlassUI.lua (LocalScript)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GlassUI = {}
GlassUI.__index = GlassUI

-- Utility
local function Tween(obj, props, time)
	return TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function Create(class, props)
	local inst = Instance.new(class)
	for i,v in pairs(props) do
		inst[i] = v
	end
	return inst
end

-- Main Constructor
function GlassUI:CreateWindow(title)

	local ScreenGui = Create("ScreenGui", {
		Name = "GlassUI",
		Parent = PlayerGui,
		ResetOnSpawn = false
	})

	-- Background Blur
	local Blur = Create("BlurEffect", {
		Size = 12,
		Parent = game:GetService("Lighting")
	})

	-- Main Window
	local Main = Create("Frame", {
		Parent = ScreenGui,
		Size = UDim2.fromOffset(650, 400),
		Position = UDim2.fromScale(0.5,0.5),
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundColor3 = Color3.fromRGB(20,20,25),
		BackgroundTransparency = 0.2
	})

	Create("UICorner", {
		Parent = Main,
		CornerRadius = UDim.new(0, 18)
	})

	Create("UIStroke", {
		Parent = Main,
		Color = Color3.fromRGB(255,255,255),
		Transparency = 0.85,
		Thickness = 1
	})

	-- Sidebar (Discord Style)
	local Sidebar = Create("Frame", {
		Parent = Main,
		Size = UDim2.fromOffset(140,400),
		BackgroundColor3 = Color3.fromRGB(15,15,18),
		BackgroundTransparency = 0.15
	})

	Create("UICorner", {
		Parent = Sidebar,
		CornerRadius = UDim.new(0, 18)
	})

	local SideLayout = Create("UIListLayout", {
		Parent = Sidebar,
		Padding = UDim.new(0,6),
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	})

	-- Content Area
	local Content = Create("Frame", {
		Parent = Main,
		Position = UDim2.fromOffset(150, 10),
		Size = UDim2.new(1,-160,1,-20),
		BackgroundTransparency = 1
	})

	local Tabs = {}

	function GlassUI:AddTab(name)
		local TabButton = Create("TextButton", {
			Parent = Sidebar,
			Size = UDim2.fromOffset(120, 36),
			Text = name,
			BackgroundColor3 = Color3.fromRGB(30,30,35),
			TextColor3 = Color3.new(1,1,1),
			BackgroundTransparency = 0.1
		})

		Create("UICorner", {
			Parent = TabButton,
			CornerRadius = UDim.new(0,12)
		})

		local TabFrame = Create("Frame", {
			Parent = Content,
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Visible = false
		})

		local Layout = Create("UIListLayout", {
			Parent = TabFrame,
			Padding = UDim.new(0,10)
		})

		Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

		Tabs[name] = TabFrame

		TabButton.MouseButton1Click:Connect(function()
			for _,tab in pairs(Tabs) do
				tab.Visible = false
			end
			TabFrame.Visible = true

			for _,btn in pairs(Sidebar:GetChildren()) do
				if btn:IsA("TextButton") then
					Tween(btn, {BackgroundColor3 = Color3.fromRGB(30,30,35)}, 0.15)
				end
			end

			Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(65,85,255)}, 0.15)
		end)

		if not next(Tabs) then
			TabFrame.Visible = true
		end

		local Elements = {}

		function Elements:AddButton(text, callback)
			local Btn = Create("TextButton", {
				Parent = TabFrame,
				Size = UDim2.fromOffset(360,40),
				Text = text,
				TextColor3 = Color3.new(1,1,1),
				BackgroundColor3 = Color3.fromRGB(40,40,50)
			})

			Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0,12)})

			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, {BackgroundColor3 = Color3.fromRGB(70,70,90)}, 0.1)
				task.wait(0.1)
				Tween(Btn, {BackgroundColor3 = Color3.fromRGB(40,40,50)}, 0.1)
				if callback then callback() end
			end)
		end

		function Elements:AddToggle(text, default, callback)
			local State = default or false

			local Btn = Create("TextButton", {
				Parent = TabFrame,
				Size = UDim2.fromOffset(360,40),
				Text = text,
				TextColor3 = Color3.new(1,1,1),
				BackgroundColor3 = State and Color3.fromRGB(65,85,255) or Color3.fromRGB(40,40,50)
			})

			Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0,12)})

			Btn.MouseButton1Click:Connect(function()
				State = not State
				Tween(Btn, {
					BackgroundColor3 = State and Color3.fromRGB(65,85,255) or Color3.fromRGB(40,40,50)
				}, 0.2)
				if callback then callback(State) end
			end)
		end

		function Elements:AddSlider(text, min, max, default, callback)
			local Value = default or min

			local Holder = Create("Frame", {
				Parent = TabFrame,
				Size = UDim2.fromOffset(360,50),
				BackgroundTransparency = 1
			})

			local Label = Create("TextLabel", {
				Parent = Holder,
				Size = UDim2.new(1,0,0,20),
				Text = text.." : "..Value,
				TextColor3 = Color3.new(1,1,1),
				BackgroundTransparency = 1
			})

			local Bar = Create("Frame", {
				Parent = Holder,
				Position = UDim2.fromOffset(0,25),
				Size = UDim2.fromOffset(360,15),
				BackgroundColor3 = Color3.fromRGB(40,40,50)
			})

			Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1,0)})

			local Fill = Create("Frame", {
				Parent = Bar,
				Size = UDim2.fromScale((Value-min)/(max-min),1),
				BackgroundColor3 = Color3.fromRGB(65,85,255)
			})

			Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1,0)})

			local Dragging = false

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if Dragging then
					local pct = math.clamp(
						(input.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,
						0,1
					)
					Value = math.floor(min + (max-min)*pct)
					Fill.Size = UDim2.fromScale(pct,1)
					Label.Text = text.." : "..Value
					if callback then callback(Value) end
				end
			end)
		end

		return Elements
	end

	return GlassUI
end

return GlassUI
