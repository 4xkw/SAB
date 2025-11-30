local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local RagdollEvent = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Ragdoll"):WaitForChild("Ragdoll")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local CombatService = Net:RemoteEvent("CombatService/ApplyImpulse")

local function Protect(Character)
    local Humanoid = Character:WaitForChild("Humanoid")
    local RootPart = Character:WaitForChild("HumanoidRootPart")

    RagdollEvent.OnClientEvent:Connect(function(_, _)
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        Humanoid:Move(Vector3.zero, false)
    end)

    task.spawn(function()
        while Character.Parent do
            task.wait(0.1)
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("Motor6D") and v.Enabled == false then
                    v.Enabled = true
                end
            end
        end
    end)

    Humanoid.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Physics then
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)

    local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local Controls = require(PlayerScripts:WaitForChild("PlayerModule")):GetControls()

    task.spawn(function()
        while Character.Parent do
            task.wait(1)
            Controls:Enable()
        end
    end)

    CombatService.OnClientEvent:Connect(function(...)
        if RootPart and RootPart.Parent then
            RootPart.Anchored = true
            task.delay(0.5, function()
                if RootPart and RootPart.Parent then
                    RootPart.Anchored = false
                end
            end)
        end
    end)
end

if LocalPlayer.Character then
    Protect(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Protect(char)
end)
