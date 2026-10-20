local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
if not Player then return end

local PlayerGui = Player:WaitForChild("PlayerGui")

local OLD = PlayerGui:FindFirstChild("r3xsenseUI")
if OLD then OLD:Destroy() end

local Theme = {
    Background = Color3.fromRGB(22, 22, 25),
    Panel = Color3.fromRGB(28, 28, 32),
    Sidebar = Color3.fromRGB(25, 25, 29),
    Element = Color3.fromRGB(35, 35, 40),
    Hover = Color3.fromRGB(44, 44, 50),
    Accent = Color3.fromRGB(120, 160, 190),
    Text = Color3.fromRGB(225, 225, 230),
    Muted = Color3.fromRGB(145, 145, 155),
    Border = Color3.fromRGB(52, 52, 59),
}

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for key, value in pairs(properties or {}) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4)
    }, parent)
end

local function Stroke(parent, color)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = 1
    }, parent)
end

local function Label(parent, text, size, position, fontSize)
    return Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        Size = size,
        Position = position,
        Font = Enum.Font.Gotham,
        TextSize = fontSize or 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local Gui = Create("ScreenGui", {
    Name = "r3xsenseUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

local Main = Create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(650, 440),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, Gui)

Corner(Main, 5)
Stroke(Main)

local Scale = Create("UIScale", {
    Scale = 1
}, Main)

local function UpdateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local viewport = camera.ViewportSize
    Scale.Scale = math.min(
        1,
        viewport.X / 680,
        viewport.Y / 470
    )
end

UpdateScale()

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(UpdateScale)
end


local Top = Create("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, Main)

local Title = Label(
    Top,
    "r3xsense",
    UDim2.new(0.5, 0, 1, 0),
    UDim2.fromOffset(12, 0),
    14
)

Title.Font = Enum.Font.GothamBold

local Version = Label(
    Top,
    "v1.0.0",
    UDim2.fromOffset(55, 34),
    UDim2.new(1, -65, 0, 0),
    10
)

Version.TextColor3 = Theme.Muted
Version.TextXAlignment = Enum.TextXAlignment.Right

Create("Frame", {
    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),
    BackgroundColor3 = Theme.Border,
    BorderSizePixel = 0
}, Top)


local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(0, 35),
    Size = UDim2.new(0, 135, 1, -35),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0
}, Main)

local SidePadding = Create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8)
}, Sidebar)

local SideLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, Sidebar)

local Content = Create("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(136, 35),
    Size = UDim2.new(1, -136, 1, -35),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, Main)


local Subbar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, Content)

local SubTitle = Label(
    Subbar,
    "GENERAL",
    UDim2.new(1, -20, 1, 0),
    UDim2.fromOffset(12, 0),
    11
)

SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextColor3 = Theme.Accent


local PageHolder = Create("Frame", {
    Position = UDim2.fromOffset(0, 35),
    Size = UDim2.new(1, 0, 1, -35),
    BackgroundTransparency = 1,
    ClipsDescendants = true
}, Content)

local Pages = {}
local NavButtons = {}
local CurrentTab

local function CreatePage(name)
    local page = Create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false
    }, PageHolder)

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    }, page)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    Pages[name] = page
    return page
end

local function SelectTab(name)
    if not Pages[name] then return end

    CurrentTab = name

    for tabName, page in pairs(Pages) do
        page.Visible = tabName == name
    end

    for tabName, button in pairs(NavButtons) do
        local selected = tabName == name

        button.BackgroundColor3 = selected
            and Theme.Hover
            or Theme.Sidebar

        button.TextColor3 = selected
            and Theme.Accent
            or Theme.Muted
    end

    SubTitle.Text = string.upper(name)
end

local function CreateTab(name, order)
    local button = Create("TextButton", {
        Name = name .. "Button",
        Size = UDim2.new(1, 0, 0, 31),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order
    }, Sidebar)

    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 9)
    }, button)

    Corner(button, 3)

    button.Activated:Connect(function()
        SelectTab(name)
    end)

    NavButtons[name] = button
    return CreatePage(name)
end

local function CreateSection(parent, title)
    local section = Create("Frame", {
        Name = title .. "Section",
        Size = UDim2.new(1, -2, 0, 40),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0
    }, parent)

    Corner(section, 4)
    Stroke(section)

    Create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 29),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left
    }, section)

    local body = Create("Frame", {
        Position = UDim2.fromOffset(8, 30),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, section)

    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, body)

    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 9)
    }, body)

    return body
end

local function CreateToggle(parent, text, default, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundTransparency = 1
    }, parent)

    Label(
        row,
        text,
        UDim2.new(1, -55, 1, 0),
        UDim2.new(),
        11
    ).TextColor3 = Theme.Text

    local enabled = default == true

    local button = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(34, 16),
        BackgroundColor3 = enabled
            and Theme.Accent
            or Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, row)

    Corner(button, 3)

    local indicator = Create("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = enabled
            and UDim2.new(1, -13, 0.5, -5)
            or UDim2.fromOffset(3, 3),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0
    }, button)

    Corner(indicator, 2)

    button.Activated:Connect(function()
        enabled = not enabled

        TweenService:Create(
            button,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 = enabled
                    and Theme.Accent
                    or Theme.Element
            }
        ):Play()

        indicator.Position = enabled
            and UDim2.new(1, -13, 0.5, -5)
            or UDim2.fromOffset(3, 3)

        if callback then
            callback(enabled)
        end
    end)

    return {
        Set = function(value)
            enabled = value == true
            button.BackgroundColor3 = enabled
                and Theme.Accent
                or Theme.Element
        end,

        Get = function()
            return enabled
        end
    }
end

local function CreateSlider(parent, title, min, max, initial, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1
    }, parent)

    local value = initial or min

    local label = Label(
        row,
        title .. "  " .. tostring(value),
        UDim2.new(1, 0, 0, 18),
        UDim2.new(),
        11
    )

    local bar = Create("Frame", {
        Position = UDim2.fromOffset(0, 27),
        Size = UDim2.new(1, 0, 0, 5),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0
    }, row)

    Corner(bar, 3)

    local ratio = math.clamp((value - min) / (max - min), 0, 1)

    local fill = Create("Frame", {
        Size = UDim2.new(ratio, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    }, bar)

    Corner(fill, 3)

    local dragging = false

    local function Update(input)
        local width = math.max(bar.AbsoluteSize.X, 1)
        local ratioNow = math.clamp(
            (input.Position.X - bar.AbsolutePosition.X) / width,
            0,
            1
        )

        value = math.floor(min + (max - min) * ratioNow + 0.5)
        fill.Size = UDim2.new(ratioNow, 0, 1, 0)
        label.Text = title .. "  " .. tostring(value)

        if callback then callback(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            Update(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function CreateColorRow(parent, title, initial)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundTransparency = 1
    }, parent)

    Label(
        row,
        title,
        UDim2.new(1, -45, 1, 0),
        UDim2.new(),
        11
    )

    local swatch = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(34, 17),
        BackgroundColor3 = initial or Theme.Accent,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, row)

    Corner(swatch, 3)
    Stroke(swatch)

    local colors = {
        Theme.Accent,
        Color3.fromRGB(120, 180, 145),
        Color3.fromRGB(180, 140, 190),
        Color3.fromRGB(210, 170, 100),
        Color3.fromRGB(210, 110, 110),
        Color3.fromRGB(100, 160, 210)
    }

    local index = 1

    swatch.Activated:Connect(function()
        index = index % #colors + 1
        swatch.BackgroundColor3 = colors[index]
    end)
end


local General = CreateTab("General", 1)
local GeneralSection = CreateSection(General, "Interface")

CreateToggle(GeneralSection, "Show notifications", true)
CreateToggle(GeneralSection, "Compact layout", false)
CreateToggle(GeneralSection, "Reduce animations", true)

CreateSlider(
    GeneralSection,
    "Interface scale",
    60,
    100,
    100,
    function(value)
        Scale.Scale = value / 100
    end
)


local Interface = CreateTab("Interface", 2)
local InterfaceSection = CreateSection(Interface, "Window")

CreateToggle(InterfaceSection, "Responsive sizing", true)
CreateToggle(InterfaceSection, "Rounded corners", true)
CreateToggle(InterfaceSection, "Show sidebar", true)

CreateSlider(
    InterfaceSection,
    "Window width",
    400,
    800,
    650,
    function(value)
        Main.Size = UDim2.fromOffset(value, Main.Size.Y.Offset)
    end
)


local Visuals = CreateTab("Visuals", 3)
local VisualSection = CreateSection(Visuals, "Display options")

CreateToggle(VisualSection, "Show status panel", true)
CreateToggle(VisualSection, "Show decorative indicators", false)
CreateToggle(VisualSection, "Use subtle transitions", true)


local Colors = CreateTab("Colors", 4)
local ColorSection = CreateSection(Colors, "Theme colors")

CreateColorRow(ColorSection, "Accent color", Theme.Accent)
CreateColorRow(ColorSection, "Background", Theme.Background)
CreateColorRow(ColorSection, "Panel", Theme.Panel)


local Configs = CreateTab("Configs", 5)
local ConfigSection = CreateSection(Configs, "Configuration")

CreateToggle(ConfigSection, "Remember interface settings", false)
CreateToggle(ConfigSection, "Restore default layout", false)

local ResetButton = Create("TextButton", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Theme.Element,
    BorderSizePixel = 0,
    Text = "Reset interface",
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Theme.Text
}, ConfigSection)

Corner(ResetButton, 3)

ResetButton.Activated:Connect(function()
    Scale.Scale = 1
    Main.Size = UDim2.fromOffset(650, 440)
    SelectTab("General")
end)


do
    local dragging = false
    local dragStart
    local startPosition
    local activeInput

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            activeInput = input
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input == activeInput
            or input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
            activeInput = nil
        end
    end)
end


local Close = Create("TextButton", {
    Name = "CloseButton",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -10, 0.5, 0),
    Size = UDim2.fromOffset(20, 20),
    BackgroundColor3 = Theme.Element,
    BorderSizePixel = 0,
    Text = "x",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Theme.Muted
}, Top)

Corner(Close, 3)

Close.Activated:Connect(function()
    Gui:Destroy()
end)


local Reopen = Create("TextButton", {
    Name = "ReopenButton",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -15, 1, -15),
    Size = UDim2.fromOffset(105, 38),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    Text = "Open r3xsense",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = Theme.Text,
    Visible = false
}, Gui)

Corner(Reopen, 4)
Stroke(Reopen)

Close.Activated:Connect(function()
    Reopen.Visible = true
end)

Reopen.Activated:Connect(function()
    Reopen.Visible = false
    Main.Visible = true
end)


local Minimize = Create("TextButton", {
    Name = "MinimizeButton",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -36, 0.5, 0),
    Size = UDim2.fromOffset(20, 20),
    BackgroundColor3 = Theme.Element,
    BorderSizePixel = 0,
    Text = "_",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Theme.Muted
}, Top)

Corner(Minimize, 3)

Minimize.Activated:Connect(function()
    Main.Visible = false
    Reopen.Visible = true
end)

SelectTab("General")

print("say less loaded")
