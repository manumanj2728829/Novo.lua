-- Carregando Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Tabela principal do ESP
local ESP = {
    Enabled = false,
    TextEnabled = true,
    SkeletonEnabled = true,
    SkeletonMaxDistance = 1000,
    Drawings = {
        Box = {},
        Text = {},
        Skeleton = {}
    }
}

-- Função de converter CFrame para Viewport
local function cframe_to_viewport(cframe)
    local pos, onScreen = Camera:WorldToViewportPoint(cframe.Position)
    return Vector2.new(pos.X, pos.Y), onScreen
end

-- Conexões do esqueleto padrão Roblox R15
local skeleton_connections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"RightLowerLeg", "RightFoot"}
}

-- Função de criar desenhos
local function create_esp(player)
    local drawings = {
        BoxOutline = Drawing.new("Square"),
        BoxInline = Drawing.new("Square"),
        Text = Drawing.new("Text"),
        Skeleton = {}
    }

    drawings.BoxOutline.Thickness = 3
    drawings.BoxInline.Thickness = 1
    drawings.Text.Size = 13
    drawings.Text.Center = true
    drawings.Text.Outline = true
    drawings.Text.Font = 2

    for i = 1, #skeleton_connections do
        local line = Drawing.new("Line")
        line.Thickness = 1
        drawings.Skeleton[i] = line
    end

    ESP.Drawings.Box[player] = drawings
end

-- Função de atualizar ESP
local function update_esp(player)
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local drawings = ESP.Drawings.Box[player]
    if not character or not hrp or not humanoid or humanoid.Health <= 0 then return end

    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then return end

    local size = Vector2.new(50, 100)
    local topLeft = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)

    -- Box
    drawings.BoxOutline.Position = topLeft - Vector2.new(1,1)
    drawings.BoxOutline.Size = size + Vector2.new(2,2)
    drawings.BoxOutline.Color = Color3.new(0,0,0)
    drawings.BoxOutline.Visible = ESP.Enabled

    drawings.BoxInline.Position = topLeft
    drawings.BoxInline.Size = size
    drawings.BoxInline.Color = Color3.new(1,0,0)
    drawings.BoxInline.Visible = ESP.Enabled

    -- Text
    drawings.Text.Text = player.Name
    drawings.Text.Position = Vector2.new(pos.X, topLeft.Y - 15)
    drawings.Text.Color = Color3.new(1,1,1)
    drawings.Text.Visible = ESP.TextEnabled

    -- Skeleton
    if ESP.SkeletonEnabled then
        local cache = {}
        for i, con in ipairs(skeleton_connections) do
            local partA = character:FindFirstChild(con[1])
            local partB = character:FindFirstChild(con[2])
            if partA and partB then
                local a = cache[partA] or Camera:WorldToViewportPoint(partA.Position)
                local b = cache[partB] or Camera:WorldToViewportPoint(partB.Position)
                cache[partA] = a
                cache[partB] = b
                local line = drawings.Skeleton[i]
                line.From = Vector2.new(a.X, a.Y)
                line.To = Vector2.new(b.X, b.Y)
                line.Color = Color3.new(0,1,0)
                line.Visible = true
            end
        end
    end
end

-- Loop principal do ESP
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESP.Drawings.Box[player] then
                create_esp(player)
            end
            update_esp(player)
        end
    end
end)

-- Interface com Rayfield
Rayfield:CreateWindow({
    Name = "ESP Completo",
    LoadingTitle = "ESP Loader",
    LoadingSubtitle = "By Nicolas",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ESP_Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Criando a aba e armazenando na variável 'ESP_Tab'
local ESP_Tab = Window:CreateTab({
    Name = "ESP Geral",
    Icon = "📦"
})

-- Criando os toggles dentro da aba
ESP_Tab:CreateToggle({
    Name = "Ativar Box ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESP.Enabled = Value
    end
})

ESP_Tab:CreateToggle({
    Name = "Ativar Text ESP",
    CurrentValue = true,
    Callback = function(Value)
        ESP.TextEnabled = Value
    end
})

ESP_Tab:CreateToggle({
    Name = "Ativar Skeleton ESP",
    CurrentValue = true,
    Callback = function(Value)
        ESP.SkeletonEnabled = Value
    end
})
