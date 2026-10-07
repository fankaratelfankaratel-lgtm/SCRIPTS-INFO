server.hasIntroSkip = true

local traitNames = { 
    "Shelly1",
    "Shelly2",
    "Shelly3"
}

function tick()
    for i = 0, (server.playersCount - 1) do
        local p = server:getClientInfo(i)
        if p ~= nil then
            local char = server.objectManager:getObject(p.objectId)
            p.ultiCharge = p.maxUltiCharge
            p.overchargeCharge = p.maxOverchargeCharge
            if char ~= nil then
                for _, tName in ipairs(traitNames) do
                   char.traits:add(lookup(108, tName)) 
                end
            end
        end
    end
end