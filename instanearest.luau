wait(5)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

local isEnabled: boolean = true
local targetName: string? = nil
local activePrompt: ProximityPrompt? = nil
local spamThread: thread? = nil
local fireConnection: RBXScriptConnection? = nil
local connections: {RBXScriptConnection | {Disconnect: () -> ()}} = {}

local function ParseNumber(text: string?): number

    if not text then return 0 end

    local cleaned: string = text:gsub('[%$%s,]', '')
    local numStr, suffix = cleaned:match('([%d%.]+)(%a*)')

    if not numStr then return 0 end

    local base: number = tonumber(numStr) or 0

    local multipliers: {[string]: number} = {

        K = 1e3,
        M = 1e6,
        B = 1e9,
        T = 1e12,
        Qa = 1e15,
        Qi = 1e18,
        Sx = 1e21,
        Sp = 1e24,
        Oc = 1e27,
        No = 1e30,
        Dc = 1e33

    }

    if suffix and suffix ~= "" then

        local multiplier: number? = multipliers[suffix]

        return multiplier and (base * multiplier) or base

    end

    return base

end

local function PromptHandle(prompt: ProximityPrompt, duration: number?): ()

    duration = duration or 0.399

    prompt:InputHoldBegin()

    task.wait(duration)

    prompt:InputHoldEnd()
end

local function TargetFind(): ()

    local highestValue: number = -math.huge
    local bestName: string? = nil

    for _, plot in Workspace.Plots:GetChildren() do

        for _, obj in plot:GetDescendants() do

            if obj:IsA("TextLabel") and obj.Name == "Generation" then

                local label = obj.Parent:FindFirstChild("DisplayName")

                if label then

                    local name: string = label.Text
                    local value: number = ParseNumber(obj.Text)

                    if value > highestValue then

                        highestValue = value
                        bestName = name

                    end

                end

            end

        end

    end

    if bestName and bestName ~= targetName then

        targetName = bestName
        activePrompt = nil

    end

end

local function CleanupTasks(): ()

    if spamThread then

        task.cancel(spamThread)
        spamThread = nil

    end

    if fireConnection then

        if typeof(fireConnection) == "RBXScriptConnection" then

            fireConnection:Disconnect()

        else

            task.cancel(fireConnection)

        end

        fireConnection = nil

    end

end

local function Init(): ()

    if #connections > 0 then return end

    local promptConn: RBXScriptConnection = ProximityPromptService.PromptShown:Connect(function(prompt: ProximityPrompt)

        if not isEnabled then return end
        if not targetName or prompt.ObjectText ~= targetName then return end

        if prompt:GetAttribute("State") ~= "Steal" then return end

        prompt.Style = Enum.ProximityPromptStyle.Custom
        prompt.MaxActivationDistance = 10000
        prompt.RequiresLineOfSight = false

        activePrompt = prompt
        PromptHandle(prompt, 0.399)

        CleanupTasks()

        fireConnection = RunService.Heartbeat:Connect(function()

            if isEnabled and prompt.Parent then

                prompt.Style = Enum.ProximityPromptStyle.Custom
                fireproximityprompt(prompt)

            end

        end)

        spamThread = task.spawn(function()

            while isEnabled and prompt.Parent do

                task.wait(0.899)

                if isEnabled and prompt.Parent then

                    PromptHandle(prompt, 0.399)

                end

            end

        end)

    end)

    local scanLoop: thread = task.spawn(function()

        while isEnabled do

            task.wait(0.6)

            if targetName and not activePrompt then

                for _, obj in Workspace:GetDescendants() do

                    if obj:IsA("ProximityPrompt")

                        and obj.ObjectText == targetName
                        and obj:GetAttribute("State") == "Steal" then

                        obj.MaxActivationDistance = 10000
                        obj.RequiresLineOfSight = false

                        PromptHandle(obj, 0.399)

                        break

                    end
                end
            end
        end
    end)

    local updateLoop: thread = task.spawn(function()

        while isEnabled do

            TargetFind()
            task.wait(2)

        end

    end)

    local propertyLoop: thread = task.spawn(function()

        while isEnabled do

            for _, obj in Workspace:GetDescendants() do

                if obj:IsA("ProximityPrompt")

                    and obj:GetAttribute("State") == "Steal" then

                    if targetName and obj.ObjectText == targetName then

                        obj.MaxActivationDistance = 10000
                        obj.RequiresLineOfSight = false
                        obj.Style = Enum.ProximityPromptStyle.Custom

                    else

                        obj.MaxActivationDistance = 0
                        obj.RequiresLineOfSight = true

                    end

                end

            end

            task.wait()

        end

    end)

    local charConn: RBXScriptConnection = LocalPlayer.CharacterAdded:Connect(function()

        if isEnabled then

            TargetFind()

        end

    end)

    table.insert(connections, promptConn)
    table.insert(connections, charConn)
    table.insert(connections, {Disconnect = function() task.cancel(scanLoop) end})
    table.insert(connections, {Disconnect = function() task.cancel(updateLoop) end})
    table.insert(connections, {Disconnect = function() task.cancel(propertyLoop) end})

    TargetFind()

end

Init()
