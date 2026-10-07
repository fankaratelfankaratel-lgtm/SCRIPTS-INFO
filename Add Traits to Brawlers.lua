server.hasIntroSkip = true

local traitNames = { --change these
    "Meg1_Transform",
    "Meg2_Transform"
}

function tick()
    for i = 0, (server.playersCount - 1) do
        local p = server:getClientInfo(i)
        if p ~= nil then
            local char = server.objectManager:getObject(p.objectId)
            if char ~= nil then
                for _, value in ipairs(traitNames) do
                   char.traits:add(lookup(108, value)) 
                end
            end
        end
    end
end