local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ProximityPromptService = game:GetService("ProximityPromptService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local SetPlayerBlockListRemote = game:GetService("RobloxReplicatedStorage").SetPlayerBlockList

local autoStealEnabled: boolean = true

local function CanBlock(): boolean

    local count: number = 0

    for index, player in Players:GetPlayers() do

        count += 1

    end

    return count == 2

end

local function GetOtherPlayers(): {Player}

    local list: {Player} = {}

    for index, player in Players:GetPlayers() do

        if player ~= LocalPlayer then

            table.insert(list, player)

        end

    end

    return list

end

local function AutoConfirmBlockPrompt(): ()

    task.spawn(function()

        task.wait(0.2)
        
        local success: boolean, err: string? = pcall(function()

            local BlockingModalScreen = CoreGui:WaitForChild("BlockingModalScreen", 3)
            local ConfirmButton = BlockingModalScreen.BlockingModalContainer.BlockingModalContainerWrapper.BlockingModal.AlertModal.AlertContents.Footer.Buttons["3"]
            
            if ConfirmButton then

                task.wait(0.05)

                pcall(function()

                    ConfirmButton.Activated:Fire()

                end)

                pcall(function()

                    for index, connection in getconnections(ConfirmButton.Activated) do

                        connection:Fire()

                    end

                end)

                pcall(function()

                    for index, connection in getconnections(ConfirmButton.MouseButton1Down) do

                        connection:Fire()

                    end

                end)

                pcall(function()

                    for index, connection in getconnections(ConfirmButton.MouseButton1Up) do

                        connection:Fire()

                    end

                end)

            end

        end)
        
        if not success then

        end

    end)

end

local function TryBlock(): ()

    if not CanBlock() then return end
    local otherPlayers: {Player} = GetOtherPlayers()
    
    for index, player in otherPlayers do

        local success: boolean, err: string? = pcall(function()

            StarterGui:SetCore("PromptBlockPlayer", player)
            SetPlayerBlockListRemote:FireServer(otherPlayers)
            AutoConfirmBlockPrompt()

        end)

        if not success then

        end

    end

end

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt: ProximityPrompt)

    if not autoStealEnabled then return end

    if prompt:GetAttribute("State") ~= "Steal" then return end
    
    task.spawn(function()

        task.wait(1.6)
        TryBlock()

    end)

end)
