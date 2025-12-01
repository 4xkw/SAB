local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local function respawn(plr: Player) : ()

    local char = plr.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")

    if hum then

        hum:ChangeState(Enum.HumanoidStateType.Dead)

    end

    if char then

        char:ClearAllChildren()

    end

    local newChar = Instance.new("Model")
    newChar.Parent = Workspace
    plr.Character = newChar

    task.wait()

    plr.Character = char

    newChar:Destroy()

end

if LocalPlayer then

    respawn(LocalPlayer)

end
