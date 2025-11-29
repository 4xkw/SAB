--[[

  esp anti desync by linse with:

  Esp Box
  Esp Skeleton
  Esp Tools
  Desync Status Red to Desynced and White to Non Desynced

]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}


local function GetServerPosition(part)

    local success, serverPos = pcall(function()
    
        return part.Position
        
    end)
    
    return success and serverPos or part.Position
    
end


local function CreateESP(player)

    if player == LocalPlayer then return end
    
    local esp = {
    
        Lines = {},
        Outlines = {},
        SkeletonLines = {},
        SkeletonOutlines = {},
        ToolText = nil,
        Player = player,
        LastServerPos = nil,
        LastClientPos = nil
        
    }
    
    for i = 1, 4 do
    
        local outline = Drawing.new("Line")
        outline.Visible = false
        outline.Color = Color3.new(0, 0, 0)
        outline.Thickness = 3
        outline.Transparency = 1
        outline.From = Vector2.new(0, 0)
        outline.To = Vector2.new(0, 0)
        esp.Outlines[i] = outline
        
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.new(1, 1, 1)
        line.Thickness = 1
        line.Transparency = 1
        line.From = Vector2.new(0, 0)
        line.To = Vector2.new(0, 0)
        esp.Lines[i] = line
        
    end
    
    for i = 1, 10 do
    
        local skeletonOutline = Drawing.new("Line")
        skeletonOutline.Visible = false
        skeletonOutline.Color = Color3.new(0, 0, 0)
        skeletonOutline.Thickness = 3
        skeletonOutline.Transparency = 1
        skeletonOutline.From = Vector2.new(0, 0)
        skeletonOutline.To = Vector2.new(0, 0)
        esp.SkeletonOutlines[i] = skeletonOutline
        
        local skeletonLine = Drawing.new("Line")
        skeletonLine.Visible = false
        skeletonLine.Color = Color3.new(1, 1, 1)
        skeletonLine.Thickness = 1
        skeletonLine.Transparency = 1
        skeletonLine.From = Vector2.new(0, 0)
        skeletonLine.To = Vector2.new(0, 0)
        esp.SkeletonLines[i] = skeletonLine
        
    end
    
    local toolText = Drawing.new("Text")
    toolText.Visible = false
    toolText.Color = Color3.new(1, 1, 1)
    toolText.OutlineColor = Color3.new(0, 0, 0)
    toolText.Outline = true
    toolText.Center = true
    toolText.Size = 16
    toolText.Font = 2
    toolText.Text = ""
    toolText.Transparency = 1
    esp.ToolText = toolText
    
    ESPObjects[player] = esp
    
end


local function RemoveESP(player)

    local esp = ESPObjects[player]
    
    if not esp then return end
    
    for _, line in next, esp.Lines do
    
        line:Remove()
        
    end
    
    for _, outline in next, esp.Outlines do
    
        outline:Remove()
        
    end
    
    for _, line in next, esp.SkeletonLines do
    
        line:Remove()
        
    end
    
    for _, outline in next, esp.SkeletonOutlines do
    
        outline:Remove()
        
    end
    
    if esp.ToolText then
    
        esp.ToolText:Remove()
        
    end
    
    ESPObjects[player] = nil
    
end


local function GetEquippedTool(character)

    for _, item in next, character:GetChildren() do
    
        if item:IsA("Tool") then
        
            return item.Name
            
        end
        
    end
    
    return nil
    
end


local function UpdateESP()

    for player, esp in next, ESPObjects do
    
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        
            for _, line in next, esp.Lines do
            
                line.Visible = false
                
            end
            
            for _, outline in next, esp.Outlines do
            
                outline.Visible = false
                
            end
            
            for _, line in next, esp.SkeletonLines do
            
                line.Visible = false
                
            end
            
            for _, outline in next, esp.SkeletonOutlines do
            
                outline.Visible = false
                
            end
            
            esp.ToolText.Visible = false
            
            continue
            
        end
        
        local character = player.Character
        local hrp = character.HumanoidRootPart
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        
        if not humanoid or humanoid.Health <= 0 then
        
            for _, line in next, esp.Lines do
            
                line.Visible = false
                
            end
            
            for _, outline in next, esp.Outlines do
            
                outline.Visible = false
                
            end
            
            for _, line in next, esp.SkeletonLines do
            
                line.Visible = false
                
            end
            
            for _, outline in next, esp.SkeletonOutlines do
            
                outline.Visible = false
                
            end
            
            esp.ToolText.Visible = false
            
            continue
            
        end
        
        local camera = workspace.CurrentCamera
        
        local serverPos = GetServerPosition(hrp)
        local clientPos = hrp.Position
        
        local isDesynced = false
        
        if esp.LastServerPos and esp.LastClientPos then
        
            local serverMoved = (serverPos - esp.LastServerPos).Magnitude > 0.5
            local clientMoved = (clientPos - esp.LastClientPos).Magnitude > 0.5
            
            if serverMoved and not clientMoved then
            
                isDesynced = true
                
            end
            
        end
        
        esp.LastServerPos = serverPos
        esp.LastClientPos = clientPos
        
        local espColor = isDesynced and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
        
        local minX, maxX = math.huge, -math.huge
        local minY, maxY = math.huge, -math.huge
        local allVisible = true
        
        for _, part in next, character:GetChildren() do
        
            if part:IsA("BasePart") then
            
                local partServerPos = GetServerPosition(part)
                
                local corners = {
                
                    CFrame.new(partServerPos) * CFrame.new(-part.Size.X/2, part.Size.Y/2, 0),
                    CFrame.new(partServerPos) * CFrame.new(part.Size.X/2, part.Size.Y/2, 0),
                    CFrame.new(partServerPos) * CFrame.new(-part.Size.X/2, -part.Size.Y/2, 0),
                    CFrame.new(partServerPos) * CFrame.new(part.Size.X/2, -part.Size.Y/2, 0)
                    
                }
                
                for _, corner in next, corners do
                
                    local screenPos, visible = camera:WorldToViewportPoint(corner.Position)
                    
                    if screenPos.Z < 0 then
                    
                        allVisible = false
                        break
                        
                    end
                    
                    minX = math.min(minX, screenPos.X)
                    maxX = math.max(maxX, screenPos.X)
                    minY = math.min(minY, screenPos.Y)
                    maxY = math.max(maxY, screenPos.Y)
                    
                end
                
                if not allVisible then
                
                    break
                    
                end
                
            end
            
        end
        
        if not allVisible then
        
            for _, line in next, esp.Lines do
            
                line.Visible = false
                
            end
            
            for _, outline in next, esp.Outlines do
            
                outline.Visible = false
                
            end
            
            for _, line in next, esp.SkeletonLines do
            
                line.Visible = false
                
            end
            
            for _, outline in next, esp.SkeletonOutlines do
            
                outline.Visible = false
                
            end
            
            esp.ToolText.Visible = false
            
            continue
            
        end
        
        local top = minY
        local bottom = maxY
        local left = minX
        local right = maxX
        
        esp.Outlines[1].From = Vector2.new(left, top)
        esp.Outlines[1].To = Vector2.new(right, top)
        esp.Lines[1].From = Vector2.new(left, top)
        esp.Lines[1].To = Vector2.new(right, top)
        esp.Lines[1].Color = espColor
        
        esp.Outlines[2].From = Vector2.new(right, top)
        esp.Outlines[2].To = Vector2.new(right, bottom)
        esp.Lines[2].From = Vector2.new(right, top)
        esp.Lines[2].To = Vector2.new(right, bottom)
        esp.Lines[2].Color = espColor
        
        esp.Outlines[3].From = Vector2.new(right, bottom)
        esp.Outlines[3].To = Vector2.new(left, bottom)
        esp.Lines[3].From = Vector2.new(right, bottom)
        esp.Lines[3].To = Vector2.new(left, bottom)
        esp.Lines[3].Color = espColor
        
        esp.Outlines[4].From = Vector2.new(left, bottom)
        esp.Outlines[4].To = Vector2.new(left, top)
        esp.Lines[4].From = Vector2.new(left, bottom)
        esp.Lines[4].To = Vector2.new(left, top)
        esp.Lines[4].Color = espColor
        
        for _, line in next, esp.Lines do
        
            line.Visible = true
            
        end
        
        for _, outline in next, esp.Outlines do
        
            outline.Visible = true
            
        end
        
        local equippedTool = GetEquippedTool(character)
        
        if equippedTool then
        
            local centerX = (left + right) / 2
            local textY = bottom + 5
            
            esp.ToolText.Text = equippedTool
            esp.ToolText.Position = Vector2.new(centerX, textY)
            esp.ToolText.Color = espColor
            esp.ToolText.Visible = true
            
        else
        
            esp.ToolText.Visible = false
            
        end
        
        local head = character:FindFirstChild("Head")
        local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        local lowerTorso = character:FindFirstChild("LowerTorso") or upperTorso
        local leftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
        local rightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
        local leftLowerArm = character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm")
        local rightLowerArm = character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm")
        local leftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
        local rightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
        local leftLowerLeg = character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg")
        local rightLowerLeg = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg")
        local leftFoot = character:FindFirstChild("LeftFoot") or leftLowerLeg
        local rightFoot = character:FindFirstChild("RightFoot") or rightLowerLeg
        
        if head and upperTorso and lowerTorso then
        
            local skeletonParts = {
            
                {head, upperTorso},
                {upperTorso, lowerTorso},
                {upperTorso, leftUpperArm},
                {upperTorso, rightUpperArm},
                {leftUpperArm, leftLowerArm},
                {rightUpperArm, rightLowerArm},
                {lowerTorso, leftUpperLeg},
                {lowerTorso, rightUpperLeg},
                {leftUpperLeg, leftLowerLeg},
                {rightUpperLeg, rightLowerLeg}
                
            }
            
            for i, parts in next, skeletonParts do
            
                if parts[1] and parts[2] then
                
                    local part1Pos = GetServerPosition(parts[1])
                    local part2Pos = GetServerPosition(parts[2])
                    
                    local screen1, visible1 = camera:WorldToViewportPoint(part1Pos)
                    local screen2, visible2 = camera:WorldToViewportPoint(part2Pos)
                    
                    if visible1 and visible2 and screen1.Z > 0 and screen2.Z > 0 then
                    
                        local from = Vector2.new(screen1.X, screen1.Y)
                        local to = Vector2.new(screen2.X, screen2.Y)
                        
                        esp.SkeletonOutlines[i].From = from
                        esp.SkeletonOutlines[i].To = to
                        esp.SkeletonOutlines[i].Visible = true
                        
                        esp.SkeletonLines[i].From = from
                        esp.SkeletonLines[i].To = to
                        esp.SkeletonLines[i].Color = espColor
                        esp.SkeletonLines[i].Visible = true
                        
                    else
                    
                        esp.SkeletonOutlines[i].Visible = false
                        esp.SkeletonLines[i].Visible = false
                        
                    end
                    
                else
                
                    esp.SkeletonOutlines[i].Visible = false
                    esp.SkeletonLines[i].Visible = false
                    
                end
                
            end
            
        else
        
            for _, line in next, esp.SkeletonLines do
            
                line.Visible = false
                
            end
            
            for _, outline in next, esp.SkeletonOutlines do
            
                outline.Visible = false
                
            end
            
        end
        
    end
    
end


for _, player in next, Players:GetPlayers() do

    CreateESP(player)
    
end


Players.PlayerAdded:Connect(function(player)

    CreateESP(player)
    
end)


Players.PlayerRemoving:Connect(function(player)

    RemoveESP(player)
    
end)


for _, player in next, Players:GetPlayers() do

    if player ~= LocalPlayer then
    
        player.CharacterAdded:Connect(function()
        
            task.wait(0.1)
            
            if ESPObjects[player] then
            
                RemoveESP(player)
                CreateESP(player)
                
            end
            
        end)
        
    end
    
end


RunService.RenderStepped:Connect(UpdateESP)
