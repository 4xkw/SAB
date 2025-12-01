local plr = game.Players.LocalPlayer

plr:SetAttribute("Stealing", false)

plr.AttributeChanged:Connect(function(attr)
    
    if attr == "Stealing" then
      
        plr:SetAttribute("Stealing", false)
      
    end
    
end)
