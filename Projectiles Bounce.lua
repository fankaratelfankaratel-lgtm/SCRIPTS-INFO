local TraitData1 = lookup(108, "Sprout2")
local TraitData2 = lookup(108, "Lily3")
local TraitData3 = lookup(108, "R_Ruff_Bounce_L_2")

local registered = 0
function tick()
     for _, char in server.objectManager:getCharacters() do
       if char.id > registered then
        char.traits:add(TraitData1)
        char.traits:add(TraitData2)
        char.traits:add(TraitData3)
        registered = char.id
       end
     end
end