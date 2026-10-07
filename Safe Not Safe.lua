local CONFIG = {
DETECTION_RANGE = 2600,
DODGE_CORRIDOR = 480,
DODGE_SPEED = 220,
EMERGENCY_DODGE_SPEED = 380,
MAX_EVADE_SPEED = 450,
RETURN_SPEED = 0.08,
PEACE_TICKS_BEFORE_RETURN = 10,
DESTROY_WALLS = true,
MAX_SPRAYS = 1,
SPRAY_CHANCE = 45,
SPRAY_COOLDOWN_TICKS = 35,
MIN_DODGES_BEFORE_TAUNT = 3,
DODGES_FOR_ULTI = 9,
ULTI_DAMAGE = 50000,
SPIN_TICKS_ON_DODGE = 22,
SPIN_RADIUS = 70,
SPIN_SPEED_DEG = 85,
MELEE_SWING_RANGE = 1350,
MELEE_DODGE_SPEED = 240,
MELEE_PERSIST_TICKS = 3,
SWARM_DEFENSE_RANGE = 850,
SWARM_DEFENSE_COOLDOWN_TICKS = 40,
JUMP_DURATION_TICKS = 14,
JUMP_DISTANCE = 1400,
JUMP_PEAK_Z = 1800,
JUMP_COOLDOWN_TICKS = 18,
WALL_MARGIN = 1200
}

local proxyData = lookup(16, "ShotgunGirl")
local shellyUltiData = lookup(20, "ShotgunGirlUlti")
local sprayItemData = lookup(18, "Spray")
local tauntData = lookup(117, "SkaterGadgetJumpTaunt") or lookup(117, "PercenterGadgetCharm")
local stalkerInvisData = lookup(117, "StalkerUltiInvisible")
local weaponOrigin = AttackOrigin and AttackOrigin.WEAPON
local ultiOrigin = AttackOrigin and AttackOrigin.ULTI or weaponOrigin
local unknownOrigin = AttackOrigin and AttackOrigin.UNKNOWN

local function applyProxyInvisibility(p)
    if p == nil or not p:isAlive() then return end
    pcall(function()
        p:setInvisibility(1000000, 0)
    end)
    pcall(function()
        p:gainShield(1000000, 100)
    end)
    if stalkerInvisData ~= nil then
        pcall(function()
            p:addStatusEffectSelf(stalkerInvisData, unknownOrigin or AttackOrigin.UNKNOWN)
        end)
    end
end

local SPRAY_INDICES = {214, 5}

local cachedPlayer = nil
local activeSafe = nil
local proxyObj = nil
local proxyParkTick = 0
local anchorX = nil
local anchorY = nil
local lastDangerTick = 0
local lastDodgeSide = 1
local lastSprayTick = 0
local dodgedBurst = false
local dodgeCount = 0
local spinTicks = 0
local spinAngle = 0
local projHistory = {}
local charHistory = {}
local activeSpray = nil
local lastBreakTileX = -999
local lastBreakTileY = -999
local jumpState = nil
local lastJumpTick = 0
local meleeEvadeTicksLeft = 0
local meleeEvadeDirX = 0
local meleeEvadeDirY = 0
local lastSwarmDefenseTick = 0
local activeUltiBurstTick = 0
local activeUltiVictims = {}
local lastSafeHp = nil

local THROWER_PROJECTILES = {
TntDudeProjectile = true,
TntDudeUltiProjectile = true,
TntDudeOverchargedClusterProjectile = true,
TntDudeOverchargedUltiProjectile = true,
BarkeepProjectile = true,
BarkeepUltiProjectile = true,
BarkeepHealingProjectile = true,
BarkeepOverchargedUltiProjectile = true,
ClusterBombProjectile = true,
ClusterBombProjectile2 = true,
ClusterBombSummonProjectile = true,
ClusterBombOverchargedSummonProjectile = true,
CrossBomberProjectile = true,
CrossBomberUltiProjectile = true,
OverchargedCrossBomberUltiProjectile = true,
TwinsThrowerProjectile = true,
TwinsUltiProjectile = true,
BoneThrowerProjectile = true,
BoneThrowerUltiProjectile = true,
WallyProjectile = true,
WallyUltiProjectile = true,
WallySecondaryProjectile = true,
VoodooProjectileEarth = true,
VoodooProjectileForest = true,
VoodooProjectileWater = true,
VoodooProjectileAll = true,
VoodooUltiProjectile = true,
FuryProjectile = true,
FuryProjectileCrit = true,
PainterProjectile = true,
PainterUltiProjectile = true,
Painter002Projectile = true,
Painter002UltiProjectile = true,
Painter003Projectile = true,
Painter003UltiProjectile = true,
Painter004Projectile = true,
Painter004UltiProjectile = true,
Painter005Projectile = true,
Painter005UltiProjectile = true
}

local THROWER_CACHE = {}

local function isThrowerProjectile(proj)
    if proj == nil or proj.data == nil then return false end
    local name = proj.data:getName()
    local cached = THROWER_CACHE[name]
    if cached ~= nil then return cached end

    if THROWER_PROJECTILES[name] then
        THROWER_CACHE[name] = true
        return true
    end
    local lname = name:lower()
    local res = (lname:find("tntdude") or lname:find("mike") or
       lname:find("barkeep") or lname:find("barley") or
       lname:find("clusterbomb") or lname:find("tick") or
       lname:find("crossbomber") or lname:find("grom") or
       lname:find("twinsthrower") or lname:find("twins") or lname:find("larry") or lname:find("lawrie") or
       lname:find("bonethrower") or lname:find("willow") or
       lname:find("wally") or lname:find("sprout") or
       lname:find("voodoo") or lname:find("juju") or
       lname:find("fury") or lname:find("ziggy") or lname:find("painter") or lname:find("berry")) ~= nil
    THROWER_CACHE[name] = res
    return res
end

local function clampToMap(x, y)
    local margin = 350
    local maxX = (server.map and server.map.absSizeX or 18000) - margin
    local maxY = (server.map and server.map.absSizeY or 18000) - margin
    return math.max(margin, math.min(maxX, x)), math.max(margin, math.min(maxY, y))
end

local function getBorderClearance(x, y)
    local mapW = (server.map and server.map.absSizeX) or 18000
    local mapH = (server.map and server.map.absSizeY) or 18000
    return math.min(x, mapW - x, y, mapH - y)
end

local function isNearCorner(x, y, margin)
    local mapW = (server.map and server.map.absSizeX) or 18000
    local mapH = (server.map and server.map.absSizeY) or 18000
    local nearX = (x < margin) or (x > mapW - margin)
    local nearY = (y < margin) or (y > mapH - margin)
    return nearX and nearY
end

local HAZARD_RADIUS_CACHE = {}
local function getHazardRadius(area)
    if area == nil or area.data == nil then return 600 end
    local name = area.data:getName()
    local cached = HAZARD_RADIUS_CACHE[name]
    if cached ~= nil then return cached end

    local lname = name:lower()
    local r = 600
    if lname:find("painter") then
        if lname:find("mutant") then r = 375 else r = 500 end
    elseif lname:find("barkeep") or lname:find("barley") then
        if lname:find("slow") then r = 1000 else r = 600 end
    elseif lname:find("cactus") then
        r = 800
    elseif lname:find("fury") then
        r = 1500
    elseif lname:find("voodoo") then
        r = 600
    elseif lname:find("burn") or lname:find("fire") then
        r = 450
    end
    HAZARD_RADIUS_CACHE[name] = r
    return r
end

local HARMFUL_NAME_CACHE = {}
local function isHarmfulAreaName(name)
    local cached = HARMFUL_NAME_CACHE[name]
    if cached ~= nil then return cached end

    local lname = name:lower()
    if lname:find("heal") and not (lname:find("hotanddot") or lname:find("healanddamage")) then
        HARMFUL_NAME_CACHE[name] = false
        return false
    end
    if lname:find("totem") or lname:find("speed") or lname:find("invis") then
        HARMFUL_NAME_CACHE[name] = false
        return false
    end
    local res = (lname:find("painter") or lname:find("barkeep") or lname:find("barley") or
       lname:find("cactus") or lname:find("voodoo") or lname:find("fury") or
       lname:find("burn") or lname:find("fire") or lname:find("poison") or
       lname:find("insectman") or lname:find("slow") or lname:find("slippery") or
       lname:find("stasis") or lname:find("puddle") or lname:find("trap") or
       lname:find("digger") or lname:find("mine")) ~= nil
    HARMFUL_NAME_CACHE[name] = res
    return res
end

local function isHarmfulArea(area, safe)
    if area == nil or not area:isAlive() then return false end
    local isEnemy = false
    if area.team ~= -1 then
        if safe ~= nil and area.team ~= safe.team then
            isEnemy = true
        end
    else
        if area.index ~= nil and area.index ~= -1 then
            local owner = server:getClientInfo(area.index)
            if owner ~= nil and safe ~= nil and owner:getAttackTeam() ~= safe.team then
                isEnemy = true
            end
        else
            isEnemy = true
        end
    end
    if not isEnemy then return false end
    if area.data == nil then return false end
    return isHarmfulAreaName(area.data:getName())
end

local currentTickHazards = nil
local currentTickHazardsTick = -1

local function getActiveHarmfulAreas(safe)
    if currentTickHazardsTick == server.tick and currentTickHazards ~= nil then
        return currentTickHazards
    end
    currentTickHazards = {}
    currentTickHazardsTick = server.tick
    if server.objectManager ~= nil and server.objectManager.getAreaEffects ~= nil then
        for _, area in server.objectManager:getAreaEffects() do
            if area:isAlive() and isHarmfulArea(area, safe) then
                table.insert(currentTickHazards, area)
            end
        end
    end
    return currentTickHazards
end

local function isPointInHazard(px, py, safe, margin)
    local hazards = getActiveHarmfulAreas(safe)
    if #hazards == 0 then
        return false
    end
    local m = margin or 280
    for _, area in ipairs(hazards) do
        if area:isAlive() then
            local dx = px - area.x
            local dy = py - area.y
            local r = getHazardRadius(area) + m
            if (dx * dx + dy * dy) < (r * r) then
                return true
            end
        end
    end
    return false
end

local function checkCharAttacking(char)
    local weapon = char:getWeaponSkill()
    if weapon ~= nil and weapon.activeTicksLeft ~= nil and weapon.activeTicksLeft > 0 then return true end
    local ulti = char:getUltiSkill()
    if ulti ~= nil and ulti.activeTicksLeft ~= nil and ulti.activeTicksLeft > 0 then return true end
    return false
end

local function isCharacterAttacking(char)
    local ok, res = pcall(checkCharAttacking, char)
    return ok and res
end

local function evaluateDodgeSide(safe, perpX, perpY, step, avgPerp)
    local testDist = math.max(step * 3, 600)

    local c1X = safe.x + perpX * testDist
    local c1Y = safe.y + perpY * testDist

    local c2X = safe.x - perpX * testDist
    local c2Y = safe.y - perpY * testDist

    local h1 = isPointInHazard(c1X, c1Y, safe, 200)
    local h2 = isPointInHazard(c2X, c2Y, safe, 200)
    if h1 and not h2 then
        return -1
    elseif h2 and not h1 then
        return 1
    end

    local clear1 = getBorderClearance(c1X, c1Y)
    local clear2 = getBorderClearance(c2X, c2Y)

    local corner1 = isNearCorner(c1X, c1Y, CONFIG.WALL_MARGIN)
    local corner2 = isNearCorner(c2X, c2Y, CONFIG.WALL_MARGIN)

    if corner1 and not corner2 then
        return -1
    elseif corner2 and not corner1 then
        return 1
    end

    if clear1 < CONFIG.WALL_MARGIN and clear2 > clear1 + 300 then
        return -1
    elseif clear2 < CONFIG.WALL_MARGIN and clear1 > clear2 + 300 then
        return 1
    end

    if server.map ~= nil then
        local t1X, t1Y = math.floor(c1X / 300), math.floor(c1Y / 300)
        local t2X, t2Y = math.floor(c2X / 300), math.floor(c2Y / 300)
        if t1X >= 0 and t1X < server.map.tileSizeX and t1Y >= 0 and t1Y < server.map.tileSizeY and
           t2X >= 0 and t2X < server.map.tileSizeX and t2Y >= 0 and t2Y < server.map.tileSizeY then
            local tile1 = server.map:getTile(t1X, t1Y)
            local tile2 = server.map:getTile(t2X, t2Y)
            local blocked1 = tile1 ~= nil and tile1.data ~= nil and tile1.data:getName() ~= "Open"
            local blocked2 = tile2 ~= nil and tile2.data ~= nil and tile2.data:getName() ~= "Open"
            if blocked1 and not blocked2 then
                return -1
            elseif blocked2 and not blocked1 then
                return 1
            end
        end
    end

    if math.abs(avgPerp) > 15 then
        return (avgPerp > 0) and 1 or -1
    end

    return (lastDodgeSide ~= 0) and lastDodgeSide or 1
end

local function isEnemyTarget(char, safe)
    if char == nil or not char:isAlive() or char.id == safe.id then return false end
    if proxyObj ~= nil and char.id == proxyObj.id then return false end
    if char.team == safe.team then return false end
    local name = char.data and char.data:getName()
    if name == "Safe" or name == "SafeKatanaKingdom" or name == "SafeVoxel" or name == "SafeDeepsea" then
        return false
    end
    return true
end

local function findPlayer()
    for _, char in server.objectManager:getCharacters() do
        if char:isAlive() and not char.isBot and (proxyObj == nil or char.id ~= proxyObj.id) then
            return char
        end
    end

    for _, char in server.objectManager:getCharacters() do
        if char:isAlive() and (proxyObj == nil or char.id ~= proxyObj.id) then
            local name = char.data and char.data:getName()
            if name ~= "Safe" and name ~= "SafeKatanaKingdom" and name ~= "SafeVoxel" and name ~= "SafeDeepsea" then
                return char
            end
        end
    end

    return nil
end

local function findNearestEnemy(safe)
    local nearest = nil
    local minDistSq = 999999999

    for _, char in server.objectManager:getCharacters() do
        if isEnemyTarget(char, safe) then
            local dx = char.x - safe.x
            local dy = char.y - safe.y
            local distSq = dx * dx + dy * dy
            if distSq < minDistSq then
                minDistSq = distSq
                nearest = char
            end
        end
    end

    return nearest
end

local function getSafe(player)
    if activeSafe ~= nil and activeSafe:isAlive() then
        return activeSafe
    end

    local enemySafe = nil
    local anySafe = nil

    for _, char in server.objectManager:getCharacters() do
        if char:isAlive() then
            local name = char.data:getName()
            if name == "Safe" or name == "SafeKatanaKingdom" or name == "SafeVoxel" or name == "SafeDeepsea" then
                anySafe = char
                if player ~= nil and char.team ~= player.team then
                    enemySafe = char
                    break
                end
            end
        end
    end

    local chosen = enemySafe or anySafe
    if chosen ~= nil then
        activeSafe = chosen
        anchorX = chosen.x
        anchorY = chosen.y
        return activeSafe
    end

    return nil
end

local function getProxy(safe)
    if proxyObj ~= nil and proxyObj:isAlive() then
        return proxyObj
    end

    if proxyData == nil then
        return nil
    end

    local p = createObject(proxyData)
    if p ~= nil then
        local safeTeam = (safe and safe.team) or 1
        p:setIndex(-1, safeTeam)
        p:setPosition(200, 200, 0)
        server.objectManager:addObject(p)
        applyProxyInvisibility(p)
        p:stopMovement()
        proxyObj = p
        return proxyObj
    end

    return nil
end

local function breakWallsAround(x, y)
    if not CONFIG.DESTROY_WALLS or server.map == nil then return end

    local tx = math.floor(x / 300)
    local ty = math.floor(y / 300)

    if tx == lastBreakTileX and ty == lastBreakTileY then
        return
    end

    lastBreakTileX = tx
    lastBreakTileY = ty

    for dx = -1, 1 do
        for dy = -1, 1 do
            local cx = tx + dx
            local cy = ty + dy
            if cx >= 0 and cx < server.map.tileSizeX and cy >= 0 and cy < server.map.tileSizeY then
                local tile = server.map:getTile(cx, cy)
                if tile ~= nil and tile.data ~= nil then
                    local tName = tile.data:getName()
                    if tName ~= "Open" and tName ~= "" then
                        server.map:destructTile(cx, cy, true)
                    end
                end
            end
        end
    end
end

local function spawnTaunt(safe, forceClown)
    if not forceClown then
        if server.tick - lastSprayTick < CONFIG.SPRAY_COOLDOWN_TICKS then
            return
        end

        if server:getRandomInt(1, 101) > CONFIG.SPRAY_CHANCE then
            return
        end
    end

    lastSprayTick = server.tick
    spinTicks = forceClown and (CONFIG.SPIN_TICKS_ON_DODGE * 2) or CONFIG.SPIN_TICKS_ON_DODGE

    if tauntData ~= nil then
        pcall(function()
            safe:addStatusEffectSelf(tauntData, unknownOrigin or AttackOrigin.UNKNOWN)
        end)
    end

    pcall(function()
        if sprayItemData ~= nil then
            if activeSpray ~= nil and activeSpray:isAlive() then
                activeSpray:destroy()
                activeSpray = nil
            end

            local pickIndex = forceClown and 214 or SPRAY_INDICES[server:getRandomInt(1, #SPRAY_INDICES + 1)]
            local spray = createObject(sprayItemData)
            if spray ~= nil then
                spray.sprayDataIndex = pickIndex
                spray:setPosition(math.floor(safe.x), math.floor(safe.y), 0)
                server.objectManager:addObject(spray)
                activeSpray = spray
            end
        end
    end)
end

local function fireShellyUlti(safe, target)
    if target == nil or not target:isAlive() then return end

    local targetX = target.x
    local targetY = target.y

    local p = getProxy(safe)
    if p ~= nil and shellyUltiData ~= nil then
        pcall(function()
            p:setPosition(math.floor(safe.x), math.floor(safe.y), 0)
            applyProxyInvisibility(p)
            local ulti = p:getUltiSkill()
            if ulti ~= nil then
                ulti:charge(100)
            end
            p:useSkill(shellyUltiData, targetX, targetY, false)
            applyProxyInvisibility(p)
        end)
    end

    proxyParkTick = server.tick + 2
    activeUltiBurstTick = server.tick
    activeUltiVictims = {}

    spawnTaunt(safe, true)
end

local function updateThreatsAndGetEvasion(safe)
    local evadeX = 0
    local evadeY = 0
    local dangerCount = 0

    local threatCount = 0
    local sumDx = 0
    local sumDy = 0
    local sumPerp = 0
    local minForwardDist = 99999
    local minTicksToImpact = 999
    local hasFrankProj = false
    local firstThreatDx = 0
    local firstThreatDy = 0
    local throwerThreat = nil

    for _, proj in server.objectManager:getProjectiles() do
        local id = proj.id
        if proj:isAlive() and proj.finishState == 0 then
            local prev = projHistory[id]
            if prev ~= nil then
                local vx = proj.x - prev.x
                local vy = proj.y - prev.y
                prev.x = proj.x
                prev.y = proj.y
                prev.tick = server.tick
                local speed = math.sqrt(vx * vx + vy * vy)

                if speed > 10 then
                    local dx = vx / speed
                    local dy = vy / speed

                    local toSafeX = safe.x - proj.x
                    local toSafeY = safe.y - proj.y

                    local forwardDist = toSafeX * dx + toSafeY * dy

                    if forwardDist > 0 and forwardDist < CONFIG.DETECTION_RANGE then
                        local perpDist = toSafeX * dy - toSafeY * dx

                        local isLob = isThrowerProjectile(proj)
                        local isFrank = (proj.data ~= nil and (proj.data:getName():find("HammerDude") ~= nil))
                        local corridor = CONFIG.DODGE_CORRIDOR
                        if isLob then
                            corridor = corridor + 250
                        elseif isFrank then
                            corridor = corridor + 350
                        end

                        if math.abs(perpDist) < corridor then
                            threatCount = threatCount + 1
                            sumDx = sumDx + dx
                            sumDy = sumDy + dy
                            sumPerp = sumPerp + perpDist
                            if forwardDist < minForwardDist then
                                minForwardDist = forwardDist
                            end
                            local ticksToImpact = forwardDist / math.max(speed, 1)
                            if ticksToImpact < minTicksToImpact then
                                minTicksToImpact = ticksToImpact
                            end
                            if isFrank then hasFrankProj = true end
                            if threatCount == 1 then
                                firstThreatDx = dx
                                firstThreatDy = dy
                            end
                            if isLob and throwerThreat == nil then
                                throwerThreat = {
                                    dx = dx,
                                    dy = dy,
                                    perpDist = perpDist,
                                }
                            end
                        end
                    end
                end
            else
                projHistory[id] = { x = proj.x, y = proj.y, tick = server.tick }
            end
        else
            if projHistory[id] ~= nil then
                projHistory[id] = nil
            end
        end
    end

    if server.tick % 60 == 0 then
        for pid, pdata in pairs(projHistory) do
            if server.tick - pdata.tick > 2 then
                projHistory[pid] = nil
            end
        end
    end

    local hazardThreat = nil
    local hazardEvadeX = 0
    local hazardEvadeY = 0

    local harmfulAreas = getActiveHarmfulAreas(safe)
    for _, area in ipairs(harmfulAreas) do
        if area:isAlive() then
            local adx = safe.x - area.x
            local ady = safe.y - area.y
            local aDist = math.sqrt(adx * adx + ady * ady)
            local aRadius = getHazardRadius(area)
            local dangerDist = aRadius + 280

            if aDist < dangerDist then
                dangerCount = dangerCount + 1
                local normX = (aDist > 10) and (adx / aDist) or 1
                local normY = (aDist > 10) and (ady / aDist) or 0
                hazardEvadeX = hazardEvadeX + normX
                hazardEvadeY = hazardEvadeY + normY

                if hazardThreat == nil then
                    hazardThreat = {
                        dx = normX,
                        dy = normY,
                        dist = aDist,
                        radius = aRadius,
                        area = area
                    }
                end
            end
        end
    end

    local allChars = server.objectManager:getCharacters()

    local closeAoEThreat = nil
    for _, char in allChars do
        if isEnemyTarget(char, safe) then
            local cname = char.data and char.data:getName() or ""
            local isDrillerOrDoug = (cname == "Driller" or cname == "Reviver")
            local isFrank = (cname == "HammerDude")

            if isDrillerOrDoug or isFrank then
                if isCharacterAttacking(char) then
                    local dx = safe.x - char.x
                    local dy = safe.y - char.y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    local maxRange = isFrank and 2400 or 1250
                    if dist < maxRange and dist > 10 then
                        closeAoEThreat = {
                            dx = dx / dist,
                            dy = dy / dist,
                            dist = dist,
                            char = char
                        }
                        break
                    end
                end
            end
        end
    end

    local jumpTrigger = (throwerThreat ~= nil) or (closeAoEThreat ~= nil) or (hazardThreat ~= nil)
    if jumpTrigger and jumpState == nil and (server.tick - lastJumpTick > CONFIG.JUMP_COOLDOWN_TICKS) then
        lastJumpTick = server.tick
        dangerCount = dangerCount + 1
        lastDangerTick = server.tick

        local jumpDirX, jumpDirY
        if throwerThreat ~= nil then
            local perpX = throwerThreat.dy
            local perpY = -throwerThreat.dx
            local jumpSide = evaluateDodgeSide(safe, perpX, perpY, CONFIG.JUMP_DISTANCE, throwerThreat.perpDist)
            lastDodgeSide = jumpSide
            jumpDirX = perpX * jumpSide
            jumpDirY = perpY * jumpSide
        elseif closeAoEThreat ~= nil then
            jumpDirX = closeAoEThreat.dx
            jumpDirY = closeAoEThreat.dy
        else
            jumpDirX = hazardThreat.dx
            jumpDirY = hazardThreat.dy
        end

        local destX = safe.x + jumpDirX * CONFIG.JUMP_DISTANCE
        local destY = safe.y + jumpDirY * CONFIG.JUMP_DISTANCE
        destX, destY = clampToMap(destX, destY)

        if isPointInHazard(destX, destY, safe, 200) then
            local altX = safe.x - jumpDirX * CONFIG.JUMP_DISTANCE
            local altY = safe.y - jumpDirY * CONFIG.JUMP_DISTANCE
            altX, altY = clampToMap(altX, altY)
            if not isPointInHazard(altX, altY, safe, 200) then
                jumpDirX = -jumpDirX
                jumpDirY = -jumpDirY
                destX = altX
                destY = altY
            end
        end

        jumpState = {
            startTick = server.tick,
            totalTicks = CONFIG.JUMP_DURATION_TICKS,
            startX = safe.x,
            startY = safe.y,
            destX = destX,
            destY = destY,
            peakZ = CONFIG.JUMP_PEAK_Z,
        }


        if lastSafeHp ~= nil and safe.hitPoints < lastSafeHp then
            local lostHp = lastSafeHp - safe.hitPoints
            pcall(function()
                safe:takeHeal(0, lostHp, false, nil, unknownOrigin or AttackOrigin.UNKNOWN)
            end)
            pcall(function()
                safe.hitPoints = lastSafeHp
            end)
        end

        local initZ = math.floor(CONFIG.JUMP_PEAK_Z * 0.3)
        local initX = math.floor(safe.x + jumpDirX * (CONFIG.JUMP_DISTANCE * 0.1))
        local initY = math.floor(safe.y + jumpDirY * (CONFIG.JUMP_DISTANCE * 0.1))
        initX, initY = clampToMap(initX, initY)
        safe:setPosition(initX, initY, initZ)

        if tauntData ~= nil then
            pcall(function()
                safe:addStatusEffectSelf(tauntData, unknownOrigin or AttackOrigin.UNKNOWN)
            end)
        end

        return dangerCount, 0, 0
    end

    if threatCount > 0 then
        dangerCount = dangerCount + threatCount

        local avgDx = sumDx / threatCount
        local avgDy = sumDy / threatCount
        local avgLen = math.sqrt(avgDx * avgDx + avgDy * avgDy)
        if avgLen > 0.05 then
            avgDx = avgDx / avgLen
            avgDy = avgDy / avgLen
        else
            avgDx, avgDy = firstThreatDx, firstThreatDy
        end

        local avgPerp = sumPerp / threatCount
        local perpX = avgDy
        local perpY = -avgDx

        local urgency = math.max(0.8, 1.6 - (minForwardDist / CONFIG.DETECTION_RANGE))
        if minTicksToImpact <= 4 or minForwardDist < 900 or hasFrankProj then
            urgency = math.max(urgency, 1.8)
        end

        local step = CONFIG.DODGE_SPEED * urgency
        if minTicksToImpact <= 3 or hasFrankProj then
            step = math.max(step, CONFIG.EMERGENCY_DODGE_SPEED)
        end

        local isWideSpread = (threatCount >= 2) or hasFrankProj
        if isWideSpread then
            step = step * 1.4
        end

        local chosenSide = evaluateDodgeSide(safe, perpX, perpY, step, avgPerp)
        lastDodgeSide = chosenSide

        evadeX = evadeX + (perpX * chosenSide) * step
        evadeY = evadeY + (perpY * chosenSide) * step

        if isWideSpread then
            evadeX = evadeX + avgDx * (step * 0.35)
            evadeY = evadeY + avgDy * (step * 0.35)
        end
    end

    local meleeThreatActive = false
    local meleeRetreatX = 0
    local meleeRetreatY = 0
    local seenChars = {}

    for _, char in allChars do
        seenChars[char.id] = true
        if isEnemyTarget(char, safe) then
            local cid = char.id
            local cdx = safe.x - char.x
            local cdy = safe.y - char.y
            local dist = math.sqrt(cdx * cdx + cdy * cdy)

            local prevC = charHistory[cid]
            local cvx, cvy, cspeed = 0, 0, 0
            if prevC ~= nil then
                cvx = char.x - prevC.x
                cvy = char.y - prevC.y
                cspeed = math.sqrt(cvx * cvx + cvy * cvy)
                prevC.x = char.x
                prevC.y = char.y
            else
                charHistory[cid] = { x = char.x, y = char.y }
            end

            local cname = char.data and char.data:getName() or ""

            local isKnownCharger = (cname == "Undertaker" or cname == "Geisha" or cname == "Stalker" or cname == "BullDude" or cname == "KickerDude")
            local isChargingAtSafe = false
            if isKnownCharger and cspeed >= 85 and dist < 1800 and dist > 10 then
                local dotToSafe = (cdx * cvx + cdy * cvy) / (dist * cspeed)
                if dotToSafe > 0.5 then
                    isChargingAtSafe = true
                end
            end

            local isAttacking = isCharacterAttacking(char)

            local isFrankWindup = (cname == "HammerDude" and isAttacking and dist < 2500)

            local isMeleeSwing = (dist < CONFIG.MELEE_SWING_RANGE and dist > 10) and (isAttacking or isChargingAtSafe)

            if isFrankWindup or isMeleeSwing or isChargingAtSafe then
                meleeThreatActive = true
                dangerCount = dangerCount + 1

                local normX = (dist > 10) and (cdx / dist) or 1
                local normY = (dist > 10) and (cdy / dist) or 0

                if isFrankWindup then
                    normX, normY = -normY, normX
                    if evaluateDodgeSide(safe, normX, normY, CONFIG.MELEE_DODGE_SPEED, 0) < 0 then
                        normX, normY = -normX, -normY
                    end
                end

                meleeRetreatX = meleeRetreatX + normX
                meleeRetreatY = meleeRetreatY + normY
            end
        end
    end

    for id in pairs(charHistory) do
        if not seenChars[id] then
            charHistory[id] = nil
        end
    end

    if meleeThreatActive then
        local rLen = math.sqrt(meleeRetreatX * meleeRetreatX + meleeRetreatY * meleeRetreatY)
        if rLen > 0.05 then
            meleeRetreatX = meleeRetreatX / rLen
            meleeRetreatY = meleeRetreatY / rLen
        else
            meleeRetreatX = 1
            meleeRetreatY = 0
        end

        local mapW = (server.map and server.map.absSizeX) or 18000
        local mapH = (server.map and server.map.absSizeY) or 18000

        if safe.y < CONFIG.WALL_MARGIN and meleeRetreatY < -0.3 then
            meleeRetreatY = 0
            if math.abs(meleeRetreatX) > 0.02 then
                meleeRetreatX = (meleeRetreatX > 0) and 1 or -1
            else
                local side = evaluateDodgeSide(safe, 1, 0, 600, 0)
                lastDodgeSide = side
                meleeRetreatX = side
            end
        elseif safe.y > mapH - CONFIG.WALL_MARGIN and meleeRetreatY > 0.3 then
            meleeRetreatY = 0
            if math.abs(meleeRetreatX) > 0.02 then
                meleeRetreatX = (meleeRetreatX > 0) and 1 or -1
            else
                local side = evaluateDodgeSide(safe, 1, 0, 600, 0)
                lastDodgeSide = side
                meleeRetreatX = side
            end
        end

        if safe.x < CONFIG.WALL_MARGIN and meleeRetreatX < -0.3 then
            meleeRetreatX = 0
            if math.abs(meleeRetreatY) > 0.02 then
                meleeRetreatY = (meleeRetreatY > 0) and 1 or -1
            else
                local side = evaluateDodgeSide(safe, 0, 1, 600, 0)
                lastDodgeSide = side
                meleeRetreatY = side
            end
        elseif safe.x > mapW - CONFIG.WALL_MARGIN and meleeRetreatX > 0.3 then
            meleeRetreatX = 0
            if math.abs(meleeRetreatY) > 0.02 then
                meleeRetreatY = (meleeRetreatY > 0) and 1 or -1
            else
                local side = evaluateDodgeSide(safe, 0, 1, 600, 0)
                lastDodgeSide = side
                meleeRetreatY = side
            end
        end

        local fLen = math.sqrt(meleeRetreatX * meleeRetreatX + meleeRetreatY * meleeRetreatY)
        if fLen > 0.05 then
            meleeRetreatX = meleeRetreatX / fLen
            meleeRetreatY = meleeRetreatY / fLen
        end

        meleeEvadeTicksLeft = CONFIG.MELEE_PERSIST_TICKS
        meleeEvadeDirX = meleeRetreatX
        meleeEvadeDirY = meleeRetreatY

        evadeX = evadeX + meleeRetreatX * CONFIG.MELEE_DODGE_SPEED
        evadeY = evadeY + meleeRetreatY * CONFIG.MELEE_DODGE_SPEED
    elseif meleeEvadeTicksLeft > 0 then
        meleeEvadeTicksLeft = meleeEvadeTicksLeft - 1
        dangerCount = dangerCount + 1

        evadeX = evadeX + meleeEvadeDirX * (CONFIG.MELEE_DODGE_SPEED * 0.85)
        evadeY = evadeY + meleeEvadeDirY * (CONFIG.MELEE_DODGE_SPEED * 0.85)
    end

    if hazardThreat ~= nil then
        local hLen = math.sqrt(hazardEvadeX * hazardEvadeX + hazardEvadeY * hazardEvadeY)
        if hLen > 0.05 then
            hazardEvadeX = hazardEvadeX / hLen
            hazardEvadeY = hazardEvadeY / hLen
        else
            hazardEvadeX = hazardThreat.dx
            hazardEvadeY = hazardThreat.dy
        end
        evadeX = evadeX + hazardEvadeX * CONFIG.MAX_EVADE_SPEED
        evadeY = evadeY + hazardEvadeY * CONFIG.MAX_EVADE_SPEED
    end

    return dangerCount, evadeX, evadeY
end

function tick()
    if cachedPlayer == nil or not cachedPlayer:isAlive() then
        cachedPlayer = findPlayer()
        if cachedPlayer == nil then
            return
        end
    end

    local safe = activeSafe
    if safe == nil or not safe:isAlive() then
        safe = getSafe(cachedPlayer)
        if safe == nil then
            return
        end
        activeSafe = safe
    end

    if lastSafeHp == nil then
        lastSafeHp = safe.hitPoints
    end

    if anchorX == nil or anchorY == nil then
        anchorX = safe.x
        anchorY = safe.y
    end

    if jumpState ~= nil then
        local elapsed = server.tick - jumpState.startTick
        local total = jumpState.totalTicks

        if elapsed >= total then
            local destX = jumpState.destX
            local destY = jumpState.destY
            destX, destY = clampToMap(destX, destY)
            safe:setPosition(math.floor(destX), math.floor(destY), 0)
            breakWallsAround(destX, destY)

            if tauntData ~= nil then
                pcall(function()
                    safe:addStatusEffectSelf(tauntData, unknownOrigin or AttackOrigin.UNKNOWN)
                end)
            end

            dodgedBurst = true
            lastDangerTick = server.tick
            jumpState = nil
        else
            local p = elapsed / total
            local curX = jumpState.startX + (jumpState.destX - jumpState.startX) * p
            local curY = jumpState.startY + (jumpState.destY - jumpState.startY) * p
            local curZ = 4 * jumpState.peakZ * p * (1 - p)

            curX, curY = clampToMap(curX, curY)
            safe:setPosition(math.floor(curX), math.floor(curY), math.floor(curZ))
            breakWallsAround(curX, curY)
        end
        lastSafeHp = safe.hitPoints
        return
    end

    if proxyParkTick > 0 and server.tick >= proxyParkTick then
        proxyParkTick = 0
        if proxyObj ~= nil and proxyObj:isAlive() then
            proxyObj:setPosition(200, 200, 0)
            proxyObj:stopMovement()
            applyProxyInvisibility(proxyObj)
        end
    end

    if proxyObj ~= nil and proxyObj:isAlive() then
        proxyObj.hitPoints = proxyObj.maxHitPoints
    end

    if (server.tick - activeUltiBurstTick < 25) and (safe ~= nil and safe:isAlive()) then
        local allProjs = server.objectManager:getProjectiles()
        local allChars = nil
        for _, proj in allProjs do
            if proj:isAlive() and proj.data and proj.data:getName():find("ShotgunGirl") then
                if proj.finishState == 3 and proj.shotCharacter ~= nil then
                    local victim = proj.shotCharacter
                    if isEnemyTarget(victim, safe) and not activeUltiVictims[victim.id] then
                        activeUltiVictims[victim.id] = true
                        pcall(function()
                            local srcIdx = (victim.index ~= nil and victim.index >= 0) and victim.index or 0
                            victim:takeDamage(
                                srcIdx,
                                CONFIG.ULTI_DAMAGE,
                                0,
                                safe,
                                nil,
                                true,
                                true,
                                safe.x,
                                safe.y,
                                nil,
                                false,
                                ultiOrigin or AttackOrigin.UNKNOWN,
                                false,
                                true,
                                false,
                                0
                            )
                        end)
                    end
                end

                if allChars == nil then
                    allChars = server.objectManager:getCharacters()
                end

                for _, char in allChars do
                    if isEnemyTarget(char, safe) and not activeUltiVictims[char.id] and char:isAlive() then
                        local pdx = char.x - proj.x
                        local pdy = char.y - proj.y
                        if (pdx * pdx + pdy * pdy) < (220 * 220) then
                            activeUltiVictims[char.id] = true
                            pcall(function()
                                local srcIdx = (char.index ~= nil and char.index >= 0) and char.index or 0
                                char:takeDamage(
                                    srcIdx,
                                    CONFIG.ULTI_DAMAGE,
                                    0,
                                    safe,
                                    nil,
                                    true,
                                    true,
                                    safe.x,
                                    safe.y,
                                    nil,
                                    false,
                                    ultiOrigin or AttackOrigin.UNKNOWN,
                                    false,
                                    true,
                                    false,
                                    0
                                )
                            end)
                        end
                    end
                end
            end
        end
    end

    if (server.tick - lastSwarmDefenseTick > CONFIG.SWARM_DEFENSE_COOLDOWN_TICKS) and (jumpState == nil) then
        local swarmRangeSq = CONFIG.SWARM_DEFENSE_RANGE * CONFIG.SWARM_DEFENSE_RANGE
        for _, char in server.objectManager:getCharacters() do
            if isEnemyTarget(char, safe) then
                local cname = char.data and char.data:getName() or ""
                local isPet = cname:find("Pet") or cname:find("Spider")
                if isPet then
                    local ndx = char.x - safe.x
                    local ndy = char.y - safe.y
                    if (ndx * ndx + ndy * ndy) < swarmRangeSq then
                        lastSwarmDefenseTick = server.tick
                        fireShellyUlti(safe, char)
                        break
                    end
                end
            end
        end
    end

    local dangerCount, evadeX, evadeY = updateThreatsAndGetEvasion(safe)
    local curX, curY = safe.x, safe.y
    local newX = curX
    local newY = curY

    if dangerCount > 0 then
        lastDangerTick = server.tick
        dodgedBurst = true
        spinTicks = 0

        local totalEvade = math.sqrt(evadeX * evadeX + evadeY * evadeY)
        local maxSpeed = CONFIG.MAX_EVADE_SPEED
        if totalEvade > maxSpeed then
            local scale = maxSpeed / totalEvade
            evadeX = evadeX * scale
            evadeY = evadeY * scale
        end

        newX = curX + evadeX
        newY = curY + evadeY
    else
        if dodgedBurst then
            dodgedBurst = false
            dodgeCount = dodgeCount + 1

            if dodgeCount >= CONFIG.DODGES_FOR_ULTI then
                dodgeCount = 0
                local enemy = findNearestEnemy(safe)
                if enemy ~= nil then
                    fireShellyUlti(safe, enemy)
                else
                    spawnTaunt(safe, true)
                end
            elseif dodgeCount > CONFIG.MIN_DODGES_BEFORE_TAUNT then
                spawnTaunt(safe, false)
            end
        end

        if spinTicks > 0 then
            spinTicks = spinTicks - 1
            spinAngle = (spinAngle + CONFIG.SPIN_SPEED_DEG) % 360
            local spinRad = math.rad(spinAngle)
            newX = newX + math.cos(spinRad) * CONFIG.SPIN_RADIUS
            newY = newY + math.sin(spinRad) * CONFIG.SPIN_RADIUS
        elseif server.tick - lastDangerTick > CONFIG.PEACE_TICKS_BEFORE_RETURN then
            local targetX = curX + (anchorX - curX) * CONFIG.RETURN_SPEED
            local targetY = curY + (anchorY - curY) * CONFIG.RETURN_SPEED
            if not isPointInHazard(targetX, targetY, safe, 150) and not isPointInHazard(anchorX, anchorY, safe, 300) then
                newX = targetX
                newY = targetY
            end
        end
    end

    newX, newY = clampToMap(newX, newY)

    if math.abs(newX - curX) > 1 or math.abs(newY - curY) > 1 then
        safe:setPosition(math.floor(newX), math.floor(newY), 0)
        breakWallsAround(newX, newY)
    end

    lastSafeHp = safe.hitPoints
end