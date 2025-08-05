-- Carrega Rayfield UI

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()



-- Serviços

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer



-- Tabelas para armazenar elementos

local PlayerBoxes = {}

local PlayerTracers = {}

local PlayerChams = {}



-- Funções de criação

local function CreateChams(target)

    if not target.Character then return end

    local highlight = Instance.new("Highlight")

    highlight.Adornee = target.Character

    highlight.Parent = target.Character

    highlight.FillColor = Color3.fromRGB(255, 0, 0)

    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

    highlight.FillTransparency = 0.5

    highlight.OutlineTransparency = 0

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    return highlight

end



local function CreateBox()

    local box = {

        TopLeft = Drawing.new("Line"),

        TopRight = Drawing.new("Line"),

        BottomLeft = Drawing.new("Line"),

        BottomRight = Drawing.new("Line"),

    }



    for _, line in pairs(box) do

        line.Color = Color3.fromRGB(255, 0, 0)

        line.Thickness = 2

        line.Transparency = 1

        line.Visible = false

    end



    return box

end



local function UpdateBox(box, position, size)

    local x, y = position.X, position.Y

    local w, h = size.X, size.Y



    box.TopLeft.From = Vector2.new(x - w / 2, y - h / 2)

    box.TopLeft.To = Vector2.new(x + w / 2, y - h / 2)



    box.TopRight.From = Vector2.new(x + w / 2, y - h / 2)

    box.TopRight.To = Vector2.new(x + w / 2, y + h / 2)



    box.BottomLeft.From = Vector2.new(x - w / 2, y - h / 2)

    box.BottomLeft.To = Vector2.new(x - w / 2, y + h / 2)



    box.BottomRight.From = Vector2.new(x - w / 2, y + h / 2)

    box.BottomRight.To = Vector2.new(x + w / 2, y + h / 2)



    for _, line in pairs(box) do

        line.Visible = true

    end

end



local function CreateTracer()

    local tracer = Drawing.new("Line")

    tracer.Color = Color3.fromRGB(255, 255, 255)

    tracer.Thickness = 1.5

    tracer.Transparency = 1

    tracer.Visible = false

    return tracer

end



local function UpdateTracer(tracer, targetPos, originPos)

    tracer.From = originPos

    tracer.To = targetPos

    tracer.Visible = true

end



-- Configurações

local ESPSettings = {

    Chams = false,

    Box = false,

    Tracer = false,

}



-- UI

local Window = Rayfield:CreateWindow({Name = "ESP Visuals - Rayfield", ConfigurationSaving = {Enabled = false}})

local Tab = Window:CreateTab("ESP", 4483362458)



Tab:CreateToggle({

    Name = "Chams",

    CurrentValue = false,

    Callback = function(Value)

        ESPSettings.Chams = Value

    end,

})



Tab:CreateToggle({

    Name = "Box ESP",

    CurrentValue = false,

    Callback = function(Value)

        ESPSettings.Box = Value

    end,

})



Tab:CreateToggle({

    Name = "Tracer ESP",

    CurrentValue = false,

    Callback = function(Value)

        ESPSettings.Tracer = Value

    end,

})



-- Atualização contínua

RunService.RenderStepped:Connect(function()

    for _, player in pairs(Players:GetPlayers()) do

        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then

            local root = player.Character.HumanoidRootPart

            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)



            -- Chams

            if ESPSettings.Chams and not PlayerChams[player] then

                PlayerChams[player] = CreateChams(player)

            elseif not ESPSettings.Chams and PlayerChams[player] then

                PlayerChams[player]:Destroy()

                PlayerChams[player] = nil

            end



            -- Box

            if ESPSettings.Box then

                if not PlayerBoxes[player] then

                    PlayerBoxes[player] = CreateBox()

                end

                if onScreen then

                    UpdateBox(PlayerBoxes[player], Vector2.new(pos.X, pos.Y), Vector2.new(60, 100))

                end

            elseif PlayerBoxes[player] then

                for _, line in pairs(PlayerBoxes[player]) do

                    line.Visible = false

                end

            end



            -- Tracer

            if ESPSettings.Tracer then

                if not PlayerTracers[player] then

                    PlayerTracers[player] = CreateTracer()

                end

                if onScreen then

                    UpdateTracer(PlayerTracers[player], Vector2.new(pos.X, pos.Y), Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y))

                end

            elseif PlayerTracers[player] then

                PlayerTracers[player].Visible = false

            end

        end

    end

end)
