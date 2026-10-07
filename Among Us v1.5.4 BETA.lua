-- server.hasIntroSkip = true
server.hasPoisonDisabled = true

-- log("This script is currently broken. Don't use it. Script will now crash on purpose.")
-- log("Until it's fixed, you can use v1.4.5. When this script is called v1.5.2, it's fixed.")
-- server:crash()


HOST_IMP = false

-- How many players should be made Impostors.

IMPOSTOR_COUNT = 2

--------------------------------------------------
-- SPAWNING
--------------------------------------------------

function spawnCharacter(charName, x, y, cachedData)
    local characterData = cachedData or lookup(16, charName)
    local character = createObject(characterData)
    character:setPosition(x, y, 0)
    character:increaseMaxHitPoints(1000000,false)
    server.objectManager:addObject(character)
    return character
end

function spawnItem(itemName, x, y)
    local itemData = lookup(18, itemName)
    local item = createObject(itemData)
    item:setPosition(x, y, 0)
    server.objectManager:addObject(item)
    return item
end

function placeTile(dynamicCode, x, y)
    if server.map:getTile(x, y) ~= nil then
        server.map:setDynamicTile(
            lookup(27, dynamicCode),
            x,
            y,
            owner
        )
    end
end


--------------------------------------------------
-- COORDINATES
--------------------------------------------------

function subtileToTile(subtileCord)
    return math.floor(subtileCord / 300)
end

function tileToSubtile(tileCord)
    return tileCord * 300 + 150
end

function getTileCentreCord(cord)
    return math.floor(cord / 300) * 300 + 150
end


--------------------------------------------------
-- EMERGENCY BUTTON
--------------------------------------------------

EMERGENCY_BUTTON_TILE_X = 33
EMERGENCY_BUTTON_TILE_Y = 20

EMERGENCY_BUTTON_X = tileToSubtile(EMERGENCY_BUTTON_TILE_X)
EMERGENCY_BUTTON_Y = tileToSubtile(EMERGENCY_BUTTON_TILE_Y)

EMERGENCY_BUTTON_RANGE = 300


--------------------------------------------------
-- OVERCHARGE
--------------------------------------------------

overchargeReset = {}

function enableOverchargeButton(p)
    local i = p.index

    if overchargeReset[i] == nil then
        overchargeReset[i] = false
    end

    if overchargeReset[i] then
        p.overchargeCharge = p.maxOverchargeCharge
        overchargeReset[i] = false
        return
    end

    if p.overchargeCharge < p.maxOverchargeCharge
        and p.overchargeCharge > 0 then

        p.overchargeCharge = 0
        overchargeReset[i] = true

    elseif p.overchargeCharge == 0 then

        p.overchargeCharge = p.maxOverchargeCharge
    end
end

function overchargeButtonPressed(p)
    return overchargeReset[p.index] == true
end

for i = 0, (server.playersCount - 1) do
    local p = server:getClientInfo(i)
    overchargeReset[i] = false
end


--------------------------------------------------
-- TIME
--------------------------------------------------

function tickToSecond(tick)
    return tick * 20
end

function secondToTick(second)
    return second / 20
end


--------------------------------------------------
-- CHARACTER HELPERS
--------------------------------------------------
NAME_MAP = {
   ShotgunGirl = "Shelly",
   Gunslinger = "Colt",
   BullDude = "Bull",
   RocketGirl = "Brock",
   TrickshotDude = "Rico",
   Cactus = "Spike",
   Barkeep = "Barley",
   Mechanic = "Jessie",
   Shaman = "Nita",
   TntDude = "Dynamike",
   Luchador = "El Primo",
   Undertaker = "Mortis",
   Crow = "Crow",
   DeadMariachi = "Poco",
   BowDude = "Bo",
   Sniper = "Piper",
   MinigunDude = "Pam",
   BlackHole = "Tara",
   BarrelBot = "Darryl",
   ArtilleryDude = "Penny",
   HammerDude = "Frank",
   HookDude = "Gene",
   ClusterBombDude = "Tick",
   Ninja = "Leon",
   Rosa = "Rosa",
   Whirlwind = "Carl",
   Baseball = "Bibi",
   Arcade = "8bit",
   Sandstorm = "Sandy",
   BeeSniper = "Bea",
   Mummy = "Emz",
   SpawnerDude = "Mr. P",
   Speedy = "Max",
   Driller = "Jacky",
   Blower = "Gale",
   Controller = "Nani",
   Wally = "Sprout",
   PowerLeveler = "Surge",
   Percenter = "Colette",
   FireDude = "Amber",
   IceDude = "Lou",
   SnakeOil = "Byron",
   Enrager = "Edgar",
   Ruffs = "Ruffs",
   Roller = "Stu",
   ElectroSniper = "Belle",
   StickyBomb = "Squeak",
   CrossBomber = "Grom",
   RopeDude = "Buzz",
   AssaultShotgun = "Griff",
   Knight = "Ash",
   MechaDude = "Meg",
   Duplicator = "Lola",
   KickerDude = "Fang",
   Flea = "Eve",
   JetpackGirl = "Janet",
   CannonGirl = "Bonnie",
   Silencer = "Otis",
   WeaponThrower = "Sam",
   SoulCollector = "Gus",
   ShieldTank = "Buster",
   Jester = "Chester",
   DoorMan = "Gray",
   Beamer = "Mandy",
   Splitter = "R-T",
   Puppeteer = "Willow",
   Maisie = "Maisie",
   FishTank = "Hank",
   Duelist = "Cordelius",
   Reviver = "Doug",
   Cooker = "Pearl",
   Conductor = "Chuck",
   Cocooner = "Charlie",
   Leaper = "Mico",
   Attacher = "Kit",
   Twins = "Larry",
   AxeJuggler = "Melody",
   InsectMan = "Angelo",
   DragonRider = "Draco",
   Ambusher = "Lily",
   Painter = "Berry",
   Crab = "Clancy",
   Digger = "Moe",
   Samurai = "Kenji",
   Ghost = "Shade",
   Voodoo = "Juju",
   Meeple = "Meeple",
   Skater = "Ollie",
   Morningstar = "Lumi",
   Chronomancer = "Finx",
   Alternator = "Jae-Yong",
   Geisha = "Kaze",
   Stalker = "Alli",
   Domain = "Trunk",
   Dancer = "Mina",
   Fury = "Ziggy",
   Bulletstorm = "Pierce",
   Daredevil = "Gigi",
   Mender = "Glowbert",
   Shadowdemon = "Sirius",
   Redirecter = "Najia",
   Gladiator = "Damian",
   MagicalGirl = "Starr Nova",
   Rock = "Bolt",
   KatanaKid = "Nori",
   FutureGirl = "Wendy",
   Attractor = "Cosmo",
   Stacker = "Vince",
   MechaDudeBig = "Meg",
   CannonGirlSmall = "Bonnie",
   Godzilla = "Godzilla",
   DiggerDrill = "Moe",
   GeishaTransformed = "Kaze",
   SuperNovaCactus = "Starr Patrol Spike",
   SuperNovaBeeSniper = "Starr Patrol Bea",
   SuperNovaFireDude = "Starr Patrol Amber",
   SuperNovaVoodoo = "Starr Patrol Juju",
   SuperNovaMagicalGirl = "Starr Patrol Starr Nova",
   Lightyear ="Laser Buzz Lightyear",
   LightyearSword = "Sword Buzz Lightyear",
   LightyearWing = "Wing Buzz Lightyear"
}

local function getName(character, playerIndex)

    if character == nil
        or character.data == nil
    then
        return "UNKNOWN"
    end

    local ok, name =
        pcall(function()
            return character.data:getName()
        end)

    if ok then

        local mapped = NAME_MAP[name]

        -- If this player is one of several playing the
        -- same character, append their distinguishing
        -- color suffix (see DUPLICATE CHARACTER HANDLING).

        if playerIndex ~= nil
            and playerNameSuffix[playerIndex] ~= nil
        then

            return mapped .. playerNameSuffix[playerIndex]
        end

        return mapped
    end

    return "UNKNOWN"
end


function getDistance(x1, y1, x2, y2)
    return math.sqrt(
        (x2 - x1)^2 +
        (y2 - y1)^2
    )
end


--------------------------------------------------
-- IMPOSTOR
--------------------------------------------------

-- [playerIndex] = true if that player is an Impostor.
-- Used everywhere else to test roles.

impostorIds = {}

-- Ordered list of Impostor playerIndexes.

impostorList = {}

-- [playerIndex] = ClientInfo, for each Impostor.

impostors = {}

-- [playerIndex] = character object, for each Impostor.

impChars = {}

do
    local availableIds = {}

    for i = 0, (server.playersCount - 1) do
        table.insert(availableIds, i)
    end

    local count =
        math.min(IMPOSTOR_COUNT, server.playersCount)

    -- For testing to make the host an impostor

    if HOST_IMP then

        impostorIds[0] = true
        table.insert(impostorList, 0)

        for idx = 1, #availableIds do

            if availableIds[idx] == 0 then

                table.remove(availableIds, idx)
                break
            end
        end
    end

    while #impostorList < count
        and #availableIds > 0
    do

        local randIdx =
            server:getRandomInt(0, #availableIds - 1) + 1

        local playerId = availableIds[randIdx]

        table.remove(availableIds, randIdx)

        if not impostorIds[playerId] then

            impostorIds[playerId] = true
            table.insert(impostorList, playerId)
        end
    end

    for i = 1, #impostorList do

        local id = impostorList[i]
        local p = server:getClientInfo(id)

        impostors[id] = p

        impChars[id] =
            server.objectManager:getObject(
                p.objectId
            )
    end
end

-- Whether a given playerIndex is an Impostor.

function isImpostor(i)
    return impostorIds[i] == true
end

-- One Impostor's character, used as a generic damage
-- source/attacker for effects that don't belong to a
-- specific player (hiding bodies, killing vote covers,
-- dealing game-end damage).

primaryImpChar = impChars[impostorList[1]]


-- Alive-player counters backing countAliveImpostors() /
-- countAliveCrewmates(). Updated incrementally wherever a
-- player is marked dead (kill or ejection), rather than
-- rescanned from scratch every time those functions (and
-- therefore checkGameEnd(), called on every kill) run.

aliveImpostorCount = #impostorList
aliveCrewmateCount = server.playersCount - #impostorList


--------------------------------------------------
-- KILL COOLDOWN
--------------------------------------------------

-- [impostorPlayerIndex] = ticks remaining before that
-- Impostor can kill again.

killCooldowns = {}

-- [impostorPlayerIndex] = true for the tick that
-- Impostor has already killed on (prevents killing more
-- than one Crewmate per tick).

hasKilledThisTick = {}

for k = 1, #impostorList do

    local id = impostorList[k]
    local imp = impostors[id]

    imp.ultiCharge = imp.maxUltiCharge * 0.99

    killCooldowns[id] = 150
    hasKilledThisTick[id] = false
end


-- Kill cooldown (in ticks) every Impostor is given after a
-- meeting ends, and after a kill.

KILL_COOLDOWN_TICKS = 300

-- Resets every Impostor's kill cooldown back to the full
-- KILL_COOLDOWN_TICKS. Called when a meeting finishes.

function resetKillCooldowns()

    for k = 1, #impostorList do
        killCooldowns[impostorList[k]] = KILL_COOLDOWN_TICKS
    end
end


--------------------------------------------------
-- GAME STATE
--------------------------------------------------

isInit = false


--------------------------------------------------
-- GAME END
--------------------------------------------------

-- true once the game has been won by either side.
-- Used to make sure a win condition only fires once.

gameEnded = false

-- How long to wait, after the winner is decided, before
-- server:debugFinishBattle() is actually called.

GAME_END_DELAY_TICKS = 60

-- Ticks remaining until debugFinishBattle() is called.
-- 0 means "not counting down".

gameEndTimer = 0

-- The team to report to debugFinishBattle() once
-- gameEndTimer reaches 0.

gameEndWinnerTeam = nil


--------------------------------------------------
-- BODIES
--------------------------------------------------

-- Each body contains:
--
-- {
--     object = the body object,
--     playerId = the player who died
-- }

bodies = {}


--------------------------------------------------
-- MEETINGS
--------------------------------------------------

TICKS_PER_SECOND = 20

MEETING_DISCUSSION_TICKS = 30 * TICKS_PER_SECOND
MEETING_VOTING_TICKS     = 45 * TICKS_PER_SECOND

-- GhostIncorporeal (from setInvisibility/status effect)
-- lasts 120 ticks. We stop excluding the voter from
-- teleportation 3 ticks before that, at tick 117, and
-- resolve their vote at that point.

MEETING_VOTE_EFFECT_TICKS = 120
MEETING_VOTE_RESOLVE_TICK = 117

-- How close (in the same units as getDistance) a voter
-- needs to be to another player's start position to be
-- considered "standing on" them.

MEETING_VOTE_DISTANCE = 300

-- Seconds remaining at which to log a reminder.
-- The initial announcement (30 / 45) is logged separately.

MEETING_DISCUSSION_LOG_SECONDS = { 20, 10 }
MEETING_VOTING_LOG_SECONDS     = { 30, 15, 10, 5 }


--------------------------------------------------
-- MEETING COOLDOWN
--
-- After a meeting ends, the emergency button is locked
-- out for this long before another meeting can be
-- called. While cooling down, standing near the button
-- shows the remaining cooldown as a charge that fills
-- up (rather than snapping straight to full) the closer
-- the cooldown gets to finishing.
--------------------------------------------------

MEETING_COOLDOWN_TICKS = 15 * TICKS_PER_SECOND

-- Ticks remaining before the emergency button works
-- again. Starts at 0 so it's available immediately.

meetingCooldown = 0


-- true while a meeting (discussion or voting) is happening

meetingActive = false

-- "discussion" or "voting"

meetingPhase = nil

-- ticks remaining in the current phase

meetingTimer = 0

-- [playerIndex] = { x = ..., y = ... }
-- Everyone is teleported back to this spot every tick,
-- except while they are actively casting a vote.

meetingStartPositions = {}

-- [voterIndex] = targetIndex or "skip"
-- Only set once the voter's vote has been resolved.
-- A voter who never pressed the hyper button has no
-- entry at all, and their vote does not count.

meetingVotes = {}

-- [voterIndex] = true once the hyper button has been
-- used this meeting. Prevents voting more than once.

meetingHasVoted = {}

-- [voterIndex] = ticks elapsed since that player
-- activated their vote. nil if not currently voting.

meetingVotingPlayers = {}

-- [voterIndex] = the CactusCover character spawned at
-- that player's position when they activated their
-- vote, marking where they were standing. Killed once
-- their vote window (meetingVotingPlayers[i]) resolves.

meetingVoteCovers = {}


--------------------------------------------------
-- EJECTION (POST-VOTING)
--
-- Everything that used to happen inside endVoting() in
-- a single tick - teleporting everyone back, tallying,
-- logging every player's vote count, ejecting, and
-- cleanup - is spread across several ticks instead, to
-- avoid one huge tick right after a meeting ends.
--------------------------------------------------

-- How many players to log a vote count for per tick.
-- Keeps any one tick from looping + logging for the
-- whole lobby at once.

EJECT_LOG_PLAYERS_PER_TICK = 3

-- nil outside of the post-voting sequence. Otherwise one
-- of: "teleport", "log", "resolve", "cleanup".

meetingEjectStep = nil

-- Next playerIndex to log a vote count for.

meetingLogIndex = 0

-- [playerIndex] = number of votes. Built once, during
-- the "teleport" step, then read during "log"/"resolve".

meetingVoteCount = {}

meetingSkipCount = 0

-- Running "who has the most votes so far" state, updated
-- incrementally as meetingLogIndex advances, instead of
-- with one extra full loop in "resolve".

meetingHighest = 0
meetingHighestPlayer = nil
meetingTie = false

-- Next playerIndex to clean up a leftover vote cover for.

meetingCleanupIndex = 0


--------------------------------------------------
-- STATUS EFFECT CODES
--
-- lookup(117, ...) is looked up once here for every
-- fixed status effect name used throughout the script,
-- instead of being called again each time the effect is
-- applied (several of these are applied every tick, to
-- every dead/duplicate player).
--------------------------------------------------

STATUS_INVULNERABLE = lookup(117, "Invulnerable")
STATUS_GHOST_INCORPOREAL = lookup(117, "GhostIncorporeal")
STATUS_DEAD_SILENCE = lookup(117, "DeadMariachiBuddySp2Silence")

-- Cached once so a kill does not repeat this lookup() call
-- every time a body needs to be spawned.
BODY_CHARACTER_DATA = lookup(16, "SplitterLegs")

--------------------------------------------------
-- TEXT COLORS
--------------------------------------------------

function colorText(str, color)
    return "<c" .. color .. ">" .. str .. "</c>"
end

--------------------------------------------------
-- DEAD PLAYER TRACKING
--------------------------------------------------

-- true = player is dead
-- false/nil = player is alive

deadPlayers = {}

-- [playerIndex] = { ghost = effect, silence = effect },
-- the GhostIncorporeal and DeadMariachiBuddySp2Silence
-- status effect instances given to that player exactly
-- once, at the moment they died. nil if that player
-- isn't dead.

deadPlayerEffects = {}

-- Both of the above effects only last 120 ticks
-- natively, so rather than reapplying them (which would
-- give the player a second copy of each), their
-- existing instances just have their remaining duration
-- topped up via :addTicks() every 100 ticks, so they
-- never expire.

deadPlayerEffectTimer = 0

-- Ticks since duplicate-character status effects were
-- last topped up. See DUPLICATE CHARACTER HANDLING.

duplicateStatusTimer = 0


--------------------------------------------------
-- ULTI TRACKING
--------------------------------------------------

-- Stores the ulti charge from the previous tick.
--
-- This is used to detect when a player actually
-- used their ulti.

previousUltiCharge = {}

-- [playerIndex] = { x = ..., y = ... }
-- Captured once, right when the match starts, so
-- meetings can teleport everyone back to their spawn
-- point rather than wherever they were reported at.

matchSpawnPositions = {}


--------------------------------------------------
-- INVULNERABILITY
--------------------------------------------------

-- [playerIndex] = the Invulnerable status effect
-- instance applied to that player at match start.
-- Kept around so it can be cancel()'d right before
-- that player is dealt lethal damage at game end.

invulnerableEffects = {}

for i = 0, (server.playersCount - 1) do

    local p =
        server:getClientInfo(i)

    previousUltiCharge[i] =
        p.maxUltiCharge

    deadPlayers[i] = false

    matchSpawnPositions[i] = {
        x = p.x,
        y = p.y
    }

    local char =
        server.objectManager:getObject(
            p.objectId
        )

    if char ~= nil then

        invulnerableEffects[i] =
            char:addStatusEffectSelf(
                STATUS_INVULNERABLE,
                AttackOrigin.UNKNOWN
            )
    end
end


--------------------------------------------------
-- DUPLICATE CHARACTER HANDLING
--
-- When more than one player picks the same character,
-- the first (lowest playerIndex) is left completely
-- normal. Each further player picking that character
-- gets a distinguishing status effect, given once at
-- match start and topped up via :addTicks() every
-- DUPLICATE_STATUS_INTERVAL_TICKS ticks so it never
-- expires - plus a colored suffix on their displayed
-- name.
--
-- Only the first 4 "extra" players of a given character
-- (2nd through 5th overall) get a variant; a 6th+ player
-- on the same character is left as-is.
--------------------------------------------------

DUPLICATE_STATUS_INTERVAL_TICKS = 100

-- Each variant's status effect code is looked up once
-- here, rather than by name every time it's reapplied.

DUPLICATE_VARIANTS = {
    { suffix = " " .. colorText("(White)", "ffffff"),  status = lookup(117, "RollerFireIce") },
    { suffix = " " .. colorText("(Purple)", "8d00a6"), status = lookup(117, "MenderStarPowerAllyDamageBuff") },
    { suffix = " " .. colorText("(Green)", "1aff00"),  status = lookup(117, "PuppeteerPoison") },
    { suffix = " " .. colorText("(Orange)", "ffcc00"), status = lookup(117, "RollerFire") }
}

-- [playerIndex] = suffix string (e.g. " (White)") to
-- append to that player's displayed name. nil if that
-- player isn't a duplicate.

playerNameSuffix = {}

-- [playerIndex] = looked-up status effect code (from a
-- DUPLICATE_VARIANTS entry). nil if that player isn't a
-- duplicate.

playerDuplicateStatus = {}

-- [playerIndex] = the status effect instance given to
-- that player once, at match start (see below). Topped
-- up via :addTicks() by refreshDuplicateCharacterStatus()
-- so it never expires. nil if that player isn't a
-- duplicate.

playerDuplicateEffect = {}

do
    -- [rawCharacterName] = how many players so far have
    -- been seen playing that character.

    local characterCounts = {}

    for i = 0, (server.playersCount - 1) do

        local p =
            server:getClientInfo(i)

        local char =
            server.objectManager:getObject(
                p.objectId
            )

        local ok, rawName =
            pcall(function()
                return char.data:getName()
            end)

        if ok and rawName ~= nil then

            local seen =
                (characterCounts[rawName] or 0) + 1

            characterCounts[rawName] = seen

            -- seen == 1 is the first player with this
            -- character, and stays normal (no variant).

            local variant = DUPLICATE_VARIANTS[seen - 1]

            if variant ~= nil then

                playerNameSuffix[i] = variant.suffix
                playerDuplicateStatus[i] = variant.status

                if char ~= nil then

                    playerDuplicateEffect[i] =
                        char:addStatusEffectSelf(
                            variant.status,
                            AttackOrigin.UNKNOWN
                        )

                    playerDuplicateEffect[i]:addTicks(9999999)
                end
            end
        end
    end
end


--------------------------------------------------
-- INTRO HIDING
--
-- While the intro is playing, no one should be able to
-- tell who is Crewmate and who is Impostor. Crewmates are
-- made invisible, stunned, and huddled together at one
-- spot; Impostors are gathered (visible to each other, so
-- they learn their teammates) at a different spot, well
-- away from the Crewmates.
--
-- INTRO_REVEAL_DELAY_TICKS after the intro finishes,
-- everyone is teleported back to their real spawn point
-- and the hiding invisibility/stun is removed - all
-- within the same tick, so no one can infer a role from
-- the timing of anyone's reappearance.
--------------------------------------------------

INTRO_CREWMATE_HIDE_TILE_X = 1
INTRO_CREWMATE_HIDE_TILE_Y = 2

INTRO_IMPOSTOR_HIDE_TILE_X = 57
INTRO_IMPOSTOR_HIDE_TILE_Y = 2

INTRO_CREWMATE_HIDE_X = tileToSubtile(INTRO_CREWMATE_HIDE_TILE_X)
INTRO_CREWMATE_HIDE_Y = tileToSubtile(INTRO_CREWMATE_HIDE_TILE_Y)

INTRO_IMPOSTOR_HIDE_X = tileToSubtile(INTRO_IMPOSTOR_HIDE_TILE_X)
INTRO_IMPOSTOR_HIDE_Y = tileToSubtile(INTRO_IMPOSTOR_HIDE_TILE_Y)

-- Long enough to comfortably outlast the intro; ended
-- manually (set back to 0) at reveal time instead of
-- being allowed to expire on its own.

INTRO_HIDE_EFFECT_TICKS = 100000000

INTRO_REVEAL_DELAY_TICKS = 3 * TICKS_PER_SECOND

-- Ticks elapsed since the intro finished. Only counted
-- up until the reveal has happened once.

introRevealTimer = 0

-- true once everyone has been teleported back and
-- revealed.

introRevealDone = false

for i = 0, (server.playersCount - 1) do

    local p =
        server:getClientInfo(i)

    local char =
        server.objectManager:getObject(
            p.objectId
        )

    if char ~= nil then

        if isImpostor(i) then

            char:teleport(
                INTRO_IMPOSTOR_HIDE_X,
                INTRO_IMPOSTOR_HIDE_Y,
                nil,
                nil,
                0,
                0
            )

        else

            char:teleport(
                INTRO_CREWMATE_HIDE_X,
                INTRO_CREWMATE_HIDE_Y,
                nil,
                nil,
                0,
                0
            )

            char:setInvisibility(
                INTRO_HIDE_EFFECT_TICKS,
                -1
            )

            char:setStun(
                INTRO_HIDE_EFFECT_TICKS,
                true,
                false,
                true
            )
        end
    end
end


--------------------------------------------------
-- REFRESH DEAD PLAYER STATUS
--
-- Dead players are only ever given the GhostIncorporeal
-- and DeadMariachiBuddySp2Silence effects once, right
-- when they died (see KILL PLAYER / KILL THE EJECTED
-- PLAYER). This just tops up the remaining duration on
-- those same two effect instances so they never expire,
-- instead of giving the player fresh copies of them.
--------------------------------------------------

function refreshDeadPlayerStatus()

    for i = 0, (server.playersCount - 1) do

        local effects = deadPlayerEffects[i]

        if effects ~= nil then

            if effects.ghost ~= nil then
                effects.ghost:addTicks(9999999)
            end

            if effects.silence ~= nil then
                effects.silence:addTicks(9999999)
            end
        end
    end
end


--------------------------------------------------
-- REFRESH DUPLICATE CHARACTER STATUS
--
-- Tops up the remaining duration on each duplicate
-- player's distinguishing status effect instance (given
-- once, at match start) so it never expires, instead of
-- giving them a fresh copy of it. Dead players are
-- skipped - their GhostIncorporeal and
-- DeadMariachiBuddySp2Silence effects are handled
-- separately by refreshDeadPlayerStatus().
--------------------------------------------------

function refreshDuplicateCharacterStatus()

    for i = 0, (server.playersCount - 1) do

        local effect = playerDuplicateEffect[i]

        if effect ~= nil and not deadPlayers[i] then
            effect:addTicks(9999999)
        end
    end
end


--------------------------------------------------
-- GAME END HELPERS
--------------------------------------------------

-- Cancels a player's Invulnerable status effect, if
-- they still have one.

function cancelInvulnerability(p)

    if p == nil then
        return
    end

    local invulnerable =
        invulnerableEffects[p.index]

    if invulnerable ~= nil then

        invulnerable:cancel()

        invulnerableEffects[p.index] = nil
    end
end


-- Every Crewmate (non-Impostor) playerIndex, dead or
-- alive.

function getAllCrewmateIndices()

    local list = {}

    for i = 0, (server.playersCount - 1) do

        if not isImpostor(i) then
            table.insert(list, i)
        end
    end

    return list
end


-- Every Impostor playerIndex, dead or alive.

function getAllImpostorIndices()

    local list = {}

    for i = 1, #impostorList do
        table.insert(list, impostorList[i])
    end

    return list
end


-- How many Impostors are still alive.

function countAliveImpostors()
    -- O(1): aliveImpostorCount is maintained incrementally
    -- wherever a player is marked dead, instead of rescanning
    -- every Impostor here on every call.
    return aliveImpostorCount
end


-- How many crewmates (non-Impostor players) are
-- still alive.

function countAliveCrewmates()
    -- O(1): see countAliveImpostors() above.
    return aliveCrewmateCount
end


-- Ends the game: instead of killing every player off,
-- the winner is decided immediately here, but the actual
-- server:debugFinishBattle(winner.team) call is delayed
-- by GAME_END_DELAY_TICKS ticks (see tick()), using the
-- first playerIndex in winningIndices (the first
-- Impostor or Crewmate, whichever side won) to look up
-- the winning team.

function triggerGameEnd(winningIndices, message)

    if gameEnded then
        return
    end

    gameEnded = true

    log(message)

    local winner =
        server:getClientInfo(winningIndices[1])

    if winner ~= nil then
        gameEndWinnerTeam = winner.team
    end

    gameEndTimer = GAME_END_DELAY_TICKS
end


-- The Impostors win once the alive Crewmates no longer
-- outnumber the alive Impostors (e.g. 2 Impostors vs 2
-- Crewmates left).

function triggerImpostorWin()

    triggerGameEnd(
        getAllImpostorIndices(),
        "Game over! The " .. colorText("Impostors", "ff0000") .. " win."
    )
end


-- The Crewmates win once every Impostor has been
-- ejected.

function triggerCrewWin()

    triggerGameEnd(
        getAllCrewmateIndices(),
        "Game over! The " .. colorText("Crewmates","1aff00") .. " win."
    )
end


-- Checks both win conditions. Safe to call after any
-- Impostor or Crewmate death (kill or ejection).

function checkGameEnd()

    if gameEnded then
        return
    end

    if countAliveImpostors() <= 0 then

        triggerCrewWin()
        return
    end

    if countAliveCrewmates() <= countAliveImpostors() then

        triggerImpostorWin()
    end
end


--------------------------------------------------
-- FIND NEAREST BODY
--------------------------------------------------

function getNearestBody(player)

    local nearestBody = nil
    local nearestDistance = nil

    for i = 1, #bodies do

        local bodyInfo = bodies[i]
        local body = bodyInfo.object

        if body ~= nil then

            local distance =
                getDistance(
                    player.x,
                    player.y,
                    body.x,
                    body.y
                )

            if nearestDistance == nil
                or distance < nearestDistance
            then

                nearestDistance = distance
                nearestBody = bodyInfo
            end
        end
    end

    return nearestBody, nearestDistance
end


--------------------------------------------------
-- LOG DEAD PLAYERS
--
-- Lists everyone whose body hasn't been reported yet
-- (i.e. anyone who has died since the last meeting).
--------------------------------------------------

function logDeadPlayers()

    local deadPlayersList = {}

    for i = 1, #bodies do

        local deadInfo = bodies[i]

        local deadP =
            server:getClientInfo(
                deadInfo.playerId
            )

        if deadP ~= nil then

            local deadC =
                server.objectManager:getObject(
                    deadP.objectId
                )

            if deadC ~= nil then

                table.insert(
                    deadPlayersList,
                    getName(deadC, deadInfo.playerId)
                )
            end
        end
    end


    log(
        "Dead players: "
        .. table.concat(
            deadPlayersList,
            ", "
        )
    )
end


--------------------------------------------------
-- HIDE ALL BODIES
--------------------------------------------------

function hideAllBodies()

    for i = 1, #bodies do

        local body =
            bodies[i].object

        if body ~= nil then

            body:takeDamage(primaryImpChar.index, 100000000, 0, nil, nil, true, false, primaryImpChar.x, primaryImpChar.y, nil, false, AttackOrigin.UNKNOWN, false, false, false, 0)
        end
    end

    bodies = {}
end


--------------------------------------------------
-- REPORT BODY
--------------------------------------------------

function reportBody(reporter, bodyInfo)

    -- Dead players cannot report.
    --
    -- This is an additional safety check in case
    -- reportBody() is ever called directly.

    if deadPlayers[reporter.index] then
        return
    end


    local reporterChar =
        server.objectManager:getObject(
            reporter.objectId
        )

    local deadPlayer =
        server:getClientInfo(
            bodyInfo.playerId
        )

    local deadChar = nil

    if deadPlayer ~= nil then

        deadChar =
            server.objectManager:getObject(
                deadPlayer.objectId
            )
    end


    --------------------------------------------------
    -- REPORTER FOUND BODY
    --------------------------------------------------

    if reporterChar ~= nil
        and deadChar ~= nil
    then

        log(
            getName(reporterChar, reporter.index)
            .. " found "
            .. getName(deadChar, bodyInfo.playerId)
            .. "'s dead body."
        )
    end


    --------------------------------------------------
    -- DEAD PLAYERS
    --------------------------------------------------

    logDeadPlayers()


    --------------------------------------------------
    -- HIDE ALL BODIES
    --------------------------------------------------

    hideAllBodies()


    --------------------------------------------------
    -- START MEETING
    --------------------------------------------------

    startMeeting()
end


--------------------------------------------------
-- EMERGENCY BUTTON
--------------------------------------------------

function callEmergencyMeeting(reporter)

    -- Dead players cannot call an emergency meeting.
    --
    -- This is an additional safety check in case
    -- callEmergencyMeeting() is ever called directly.

    if deadPlayers[reporter.index] then
        return
    end


    local reporterChar =
        server.objectManager:getObject(
            reporter.objectId
        )


    --------------------------------------------------
    -- REPORTER CALLED THE MEETING
    --------------------------------------------------

    if reporterChar ~= nil then

        log(
            getName(reporterChar, reporter.index)
            .. " called an emergency meeting."
        )
    end


    --------------------------------------------------
    -- DEAD PLAYERS
    --------------------------------------------------

    logDeadPlayers()


    --------------------------------------------------
    -- HIDE ALL BODIES
    --------------------------------------------------

    hideAllBodies()


    --------------------------------------------------
    -- START MEETING
    --------------------------------------------------

    startMeeting()
end


--------------------------------------------------
-- START MEETING
--------------------------------------------------

function startMeeting()

    meetingActive = true
    meetingPhase = "discussion"
    meetingTimer = MEETING_DISCUSSION_TICKS

    meetingStartPositions = {}
    meetingVotes = {}
    meetingHasVoted = {}
    meetingVotingPlayers = {}
    meetingVoteCovers = {}


    --------------------------------------------------
    -- USE MATCH SPAWN POINTS AS START LOCATIONS
    --------------------------------------------------

    for i = 0, (server.playersCount - 1) do

        local pos = matchSpawnPositions[i]

        if pos ~= nil then

            meetingStartPositions[i] = {
                x = pos.x,
                y = pos.y
            }
        end
    end


    log("Discussion time. 30 seconds remaining")
end


--------------------------------------------------
-- START VOTING
--------------------------------------------------

function startVoting()

    meetingPhase = "voting"
    meetingTimer = MEETING_VOTING_TICKS

    log("Voting time. 45 seconds remaining")
    log("Press " .. colorText("hyper", "8d00a6") .. " button to vote, and walk to the player you want to vote on within 6 seconds.")
    log("Stand inside the person you want to vote out.")
    log("Stand far from the other players to skip")
end


--------------------------------------------------
-- IS ANYONE MID-VOTE
--------------------------------------------------

function anyVoteInProgress()

    for i = 0, (server.playersCount - 1) do

        if meetingVotingPlayers[i] ~= nil then
            return true
        end
    end

    return false
end


--------------------------------------------------
-- HAS EVERYONE VOTED
--
-- Dead players cannot vote, so they don't count.
--------------------------------------------------

function allPlayersVoted()

    for i = 0, (server.playersCount - 1) do

        if not deadPlayers[i]
            and not meetingHasVoted[i]
        then

            return false
        end
    end

    return true
end


--------------------------------------------------
-- KILL A VOTE COVER
--
-- Deals lethal damage to (and clears the reference to)
-- the CactusCover marking a voter's position, once it's
-- no longer needed.
--------------------------------------------------

function killVoteCover(i)

    local cover = meetingVoteCovers[i]

    if cover ~= nil then

        cover:takeDamage(primaryImpChar.index, 100000000, 0, nil, nil, true, false, primaryImpChar.x, primaryImpChar.y, nil, false, AttackOrigin.UNKNOWN, false, false, false, 0)

        meetingVoteCovers[i] = nil
    end
end


--------------------------------------------------
-- ACTIVATE A VOTE
--
-- Called the tick a player presses the hyper button
-- during the voting phase.
--------------------------------------------------

function activateVote(i, p)

    meetingHasVoted[i] = true
    meetingVotingPlayers[i] = 0

    local char =
        server.objectManager:getObject(
            p.objectId
        )

    if char ~= nil then

        char:setInvisibility(
            MEETING_VOTE_EFFECT_TICKS,
            -1
        )

        char:addStatusEffectSelf(
            STATUS_GHOST_INCORPOREAL,
            AttackOrigin.UNKNOWN
        )
    end


    --------------------------------------------------
    -- SPAWN A COVER TO MARK THIS VOTER'S LOCATION
    --------------------------------------------------

    meetingVoteCovers[i] =
        spawnCharacter(
            "CactusCover",
            p.x,
            p.y
        )
end


--------------------------------------------------
-- RESOLVE A VOTE
--
-- Called once a voter's window reaches
-- MEETING_VOTE_RESOLVE_TICK. Looks at where they are
-- currently standing and compares it against every
-- (still alive) player's saved start position.
--------------------------------------------------

function resolveVote(i)

    local p =
        server:getClientInfo(i)

    if p == nil then
        meetingVotes[i] = "skip"
        killVoteCover(i)
        return
    end

    local target = nil
    local targetDistance = nil

    for j = 0, (server.playersCount - 1) do

        if not deadPlayers[j] then

            local pos = meetingStartPositions[j]

            if pos ~= nil then

                local distance =
                    getDistance(
                        p.x,
                        p.y,
                        pos.x,
                        pos.y
                    )

                if distance < MEETING_VOTE_DISTANCE
                    and (targetDistance == nil
                        or distance < targetDistance)
                then

                    target = j
                    targetDistance = distance
                end
            end
        end
    end

    if target ~= nil then
        meetingVotes[i] = target
    else
        meetingVotes[i] = "skip"
    end

    killVoteCover(i)
end

--------------------------------------------------
-- END VOTING / EJECTION
--
-- This used to be one function that teleported
-- everyone, tallied, logged every player's vote count,
-- ejected, and cleaned up, all in the single tick voting
-- ended - a big spike right after a meeting. It's now
-- spread across several ticks via meetingEjectStep;
-- startEjection() only kicks the sequence off, and
-- updateEjection() (called from updateMeeting() every
-- tick) does one small piece of it per tick.
--------------------------------------------------

function startEjection()

    meetingPhase = "ejecting"
    meetingEjectStep = "teleport"

    meetingLogIndex = 0
    meetingVoteCount = {}
    meetingSkipCount = 0

    meetingHighest = 0
    meetingHighestPlayer = nil
    meetingTie = false

    meetingCleanupIndex = 0
end


--------------------------------------------------
-- EJECT STEP: TELEPORT + TALLY
--
-- The per-tick teleport loop in updateMeeting() skips
-- whoever is still mid-vote. If the last pending vote
-- resolves on the same tick voting ends, that voter
-- would never get teleported back to their start
-- position, and could still be standing wherever they
-- walked to cast their vote once their vote
-- invisibility runs out a few ticks later. No vote can
-- still be in progress once this runs, so it's safe to
-- teleport everyone back in one final pass. Tallying the
-- (already-resolved) votes here is just arithmetic on
-- small tables, so it's cheap enough to share this tick
-- with the teleport loop.
--------------------------------------------------

function ejectStepTeleport()

    for i = 0, (server.playersCount - 1) do

        local pos = meetingStartPositions[i]

        if pos ~= nil then

            local p =
                server:getClientInfo(i)

            if p ~= nil then

                local char =
                    server.objectManager:getObject(
                        p.objectId
                    )

                if char ~= nil then

                    char:teleport(
                        pos.x,
                        pos.y,
                        nil,
                        nil,
                        0,
                        0
                    )
                end
            end
        end

        meetingVoteCount[i] = 0
    end

    for voter, target in pairs(meetingVotes) do

        if target == "skip" then

            meetingSkipCount =
                meetingSkipCount + 1

        else

            meetingVoteCount[target] =
                meetingVoteCount[target] + 1
        end
    end

    meetingHighest = meetingSkipCount

    log("Votes:")

    meetingEjectStep = "log"
end


--------------------------------------------------
-- EJECT STEP: LOG RESULTS
--
-- Logs a handful of players' vote counts per tick
-- (rather than the whole lobby at once), and updates the
-- running "who has the most votes" state as it goes so
-- there's no separate full loop needed afterwards.
--------------------------------------------------

function ejectStepLog()

    local processed = 0

    while meetingLogIndex < server.playersCount
        and processed < EJECT_LOG_PLAYERS_PER_TICK
    do

        local i = meetingLogIndex

        local p =
            server:getClientInfo(i)

        local char = nil

        if p ~= nil then
            char =
                server.objectManager:getObject(
                    p.objectId
                )
        end

        local votes = meetingVoteCount[i]

        log(
            getName(char, i)
            .. ": "
            .. votes
            .. " votes"
        )


        --------------------------------------------------
        -- SKIP ACTS AS THE BASELINE. IF A PLAYER TIES THE
        -- CURRENT HIGHEST (INCLUDING SKIP), OR TWO PLAYERS
        -- TIE EACH OTHER, IT'S A DRAW.
        --------------------------------------------------

        if votes > meetingHighest then

            meetingHighest = votes
            meetingHighestPlayer = i
            meetingTie = false

        elseif votes == meetingHighest
            and votes > 0
        then

            meetingTie = true
        end

        meetingLogIndex = meetingLogIndex + 1
        processed = processed + 1
    end

    if meetingLogIndex >= server.playersCount then

        log("Skip: " .. meetingSkipCount .. " votes")

        meetingEjectStep = "resolve"
    end
end


--------------------------------------------------
-- EJECT STEP: RESOLVE
--
-- Acts on the tally built up over the "teleport"/"log"
-- steps. Only touches the single ejected player (if
-- any), so this is cheap enough for one tick.
--------------------------------------------------

function ejectStepResolve()

    if meetingHighestPlayer == nil or meetingTie then

        log("No one was ejected.")

    else

        local highestPlayer = meetingHighestPlayer

        local ejectedP =
            server:getClientInfo(highestPlayer)

        local ejectedChar = nil

        if ejectedP ~= nil then
            ejectedChar =
                server.objectManager:getObject(
                    ejectedP.objectId
                )
        end

        if ejectedChar ~= nil then

            log(
                getName(ejectedChar, highestPlayer)
                .. " was ejected."
            )


            --------------------------------------------------
            -- KILL THE EJECTED PLAYER
            --------------------------------------------------

            ejectedChar:setInvisibility(
                10000000,
                -1
            )

            deadPlayerEffects[highestPlayer] = {
                ghost =
                    ejectedChar:addStatusEffectSelf(
                        STATUS_GHOST_INCORPOREAL,
                        AttackOrigin.UNKNOWN
                    ),
                silence =
                    ejectedChar:addStatusEffectSelf(
                        STATUS_DEAD_SILENCE,
                        AttackOrigin.UNKNOWN
                    )
            }

            deadPlayerEffects[highestPlayer].silence:addTicks(99999999)

            deadPlayers[highestPlayer] = true

            if isImpostor(highestPlayer) then
                aliveImpostorCount = aliveImpostorCount - 1
            else
                aliveCrewmateCount = aliveCrewmateCount - 1
            end


            --------------------------------------------------
            -- ANNOUNCE ROLE
            --
            -- With a single Impostor, ejecting them ends
            -- the mystery, so there's nothing left to
            -- "remaining" about. With multiple Impostors,
            -- also report how many are still alive.
            --------------------------------------------------

            if isImpostor(highestPlayer) then

                if #impostorList == 1 then

                    log(
                        getName(ejectedChar, highestPlayer)
                        .. " was the Impostor."
                    )

                else

                    log(
                        getName(ejectedChar, highestPlayer)
                        .. " was an Impostor."
                    )

                    log(
                        countAliveImpostors()
                        .. " Impostors remaining."
                    )
                end

            else

                log(
                    getName(ejectedChar, highestPlayer)
                    .. " was not an Impostor."
                )

                log(
                    countAliveImpostors()
                    .. " Impostors remaining."
                )
            end


            --------------------------------------------------
            -- CHECK FOR GAME END
            --
            -- Handles both win conditions: all Impostors
            -- ejected, or the alive Crewmates no longer
            -- outnumbering the alive Impostors.
            --------------------------------------------------

            checkGameEnd()
        end
    end

    meetingCleanupIndex = 0
    meetingEjectStep = "cleanup"
end


--------------------------------------------------
-- EJECT STEP: CLEAN UP ANY LEFTOVER VOTE COVERS
--
-- Normally every cover is already killed by
-- resolveVote(), so this is just a safety net - but it's
-- still chunked per tick to stay consistent with the
-- rest of the sequence.
--------------------------------------------------

function ejectStepCleanup()

    local processed = 0

    while meetingCleanupIndex < server.playersCount
        and processed < EJECT_LOG_PLAYERS_PER_TICK
    do

        killVoteCover(meetingCleanupIndex)

        meetingCleanupIndex = meetingCleanupIndex + 1
        processed = processed + 1
    end

    if meetingCleanupIndex >= server.playersCount then

        --------------------------------------------------
        -- RESET MEETING STATE
        --------------------------------------------------

        meetingActive = false
        meetingPhase = nil
        meetingTimer = 0
        meetingEjectStep = nil

        meetingStartPositions = {}
        meetingVotes = {}
        meetingHasVoted = {}
        meetingVotingPlayers = {}
        meetingVoteCovers = {}


        --------------------------------------------------
        -- START MEETING COOLDOWN
        --------------------------------------------------

        meetingCooldown = MEETING_COOLDOWN_TICKS


        --------------------------------------------------
        -- RESET KILL COOLDOWNS
        --------------------------------------------------

        resetKillCooldowns()
    end
end


--------------------------------------------------
-- EJECT DISPATCH
--
-- Called every tick while meetingPhase == "ejecting".
-- Does exactly one step's worth of work.
--------------------------------------------------

function updateEjection()

    if meetingEjectStep == "teleport" then
        ejectStepTeleport()

    elseif meetingEjectStep == "log" then
        ejectStepLog()

    elseif meetingEjectStep == "resolve" then
        ejectStepResolve()

    elseif meetingEjectStep == "cleanup" then
        ejectStepCleanup()
    end
end


--------------------------------------------------
-- UPDATE MEETING
--
-- Called every tick. Handles teleporting everyone back
-- to their start point, advancing active vote windows,
-- and moving between discussion / voting / ejection.
--------------------------------------------------

function updateMeeting()

    if not meetingActive then
        return
    end


    --------------------------------------------------
    -- EJECTION (POST-VOTING)
    --
    -- Once voting has ended, everyone has already been
    -- teleported back and no vote window can still be
    -- open, so none of the discussion/voting-phase work
    -- below applies any more - just advance the ejection
    -- sequence one step and stop.
    --------------------------------------------------

    if meetingPhase == "ejecting" then

        updateEjection()
        return
    end


    --------------------------------------------------
    -- TELEPORT EVERYONE TO THEIR START POINT
    --
    -- Skip anyone currently mid-vote so they're free to
    -- walk to the player they want to vote on.
    --------------------------------------------------

    for i = 0, (server.playersCount - 1) do

        if meetingVotingPlayers[i] == nil then

            local pos = meetingStartPositions[i]

            if pos ~= nil then

                local p =
                    server:getClientInfo(i)

                if p ~= nil then

                    local char =
                        server.objectManager:getObject(
                            p.objectId
                        )

                    if char ~= nil then

                        char:teleport(
                            pos.x,
                            pos.y,
                            nil,
                            nil,
                            0,
                            0
                        )
                    end
                end
            end
        end
    end


    --------------------------------------------------
    -- ADVANCE ACTIVE VOTE WINDOWS
    --------------------------------------------------

    for i = 0, (server.playersCount - 1) do

        if meetingVotingPlayers[i] ~= nil then

            meetingVotingPlayers[i] =
                meetingVotingPlayers[i] + 1

            if meetingVotingPlayers[i]
                == MEETING_VOTE_RESOLVE_TICK
            then

                resolveVote(i)

                -- Vote time is over: resume teleporting
                -- this player every frame.

                meetingVotingPlayers[i] = nil
            end
        end
    end


    --------------------------------------------------
    -- DISCUSSION PHASE
    --------------------------------------------------

    if meetingPhase == "discussion" then

        meetingTimer = meetingTimer - 1

        if meetingTimer % TICKS_PER_SECOND == 0 then

            local secondsLeft =
                meetingTimer / TICKS_PER_SECOND

            for j = 1, #MEETING_DISCUSSION_LOG_SECONDS do

                if secondsLeft
                    == MEETING_DISCUSSION_LOG_SECONDS[j]
                then

                    log(
                        secondsLeft
                        .. " seconds remaining"
                    )
                end
            end
        end

        if meetingTimer <= 0 then
            startVoting()
        end

        return
    end


    --------------------------------------------------
    -- VOTING PHASE
    --------------------------------------------------

    if meetingPhase == "voting" then

        --------------------------------------------------
        -- CHECK FOR VOTE BUTTON PRESSES
        --
        -- Ghosts (dead players) cannot vote, and each
        -- player can only vote once per meeting.
        --------------------------------------------------

        for i = 0, (server.playersCount - 1) do

            if not deadPlayers[i]
                and not meetingHasVoted[i]
                and meetingVotingPlayers[i] == nil
            then

                local p =
                    server:getClientInfo(i)

                if p ~= nil
                    and overchargeButtonPressed(p)
                then

                    activateVote(i, p)
                end
            end
        end


        meetingTimer = meetingTimer - 1

        if meetingTimer % TICKS_PER_SECOND == 0 then

            local secondsLeft =
                meetingTimer / TICKS_PER_SECOND

            for j = 1, #MEETING_VOTING_LOG_SECONDS do

                if secondsLeft
                    == MEETING_VOTING_LOG_SECONDS[j]
                then

                    log(
                        secondsLeft
                        .. " seconds remaining"
                    )
                end
            end
        end


        --------------------------------------------------
        -- END VOTING
        --
        -- Ends when time runs out, or early once every
        -- alive player has voted. Either way, we still
        -- wait for any in-progress vote windows to finish
        -- before moving on to the ejection.
        --------------------------------------------------

        if (meetingTimer <= 0 or allPlayersVoted())
            and not anyVoteInProgress()
        then

            startEjection()
        end

        return
    end
end


--------------------------------------------------
-- UPDATE ULTI FROM BODY PROXIMITY
--------------------------------------------------

function updateBodyUlti(player)

    --------------------------------------------------
    -- DEAD PLAYERS CANNOT REPORT
    --------------------------------------------------

    if deadPlayers[player.index] then

        player.ultiCharge = 0

        return
    end


    local bodyInfo, distance =
        getNearestBody(player)


    --------------------------------------------------
    -- NEAR A BODY
    --------------------------------------------------

    if bodyInfo ~= nil
        and distance < 900
    then

        player.ultiCharge =
            player.maxUltiCharge

        return
    end


    --------------------------------------------------
    -- NEAR THE EMERGENCY BUTTON
    --------------------------------------------------

    local buttonDistance =
        getDistance(
            player.x,
            player.y,
            EMERGENCY_BUTTON_X,
            EMERGENCY_BUTTON_Y
        )

    if buttonDistance < EMERGENCY_BUTTON_RANGE then

        if meetingCooldown > 0 then

            -- Still on cooldown: fill the charge up
            -- gradually, the closer we get to being
            -- able to call another meeting.

            player.ultiCharge =
                player.maxUltiCharge
                * (MEETING_COOLDOWN_TICKS - meetingCooldown)
                / MEETING_COOLDOWN_TICKS

        else

            player.ultiCharge =
                player.maxUltiCharge
        end

        return
    end


    --------------------------------------------------
    -- NOT NEAR A BODY
    --------------------------------------------------

    if isImpostor(player.index) then

        -- An impostor's ulti normally represents
        -- their own kill cooldown.

        player.ultiCharge =
            player.maxUltiCharge
            * (killCooldowns[player.index] or 0)
            / 300

    else

        -- Normal players lose their report charge
        -- when they move away from all bodies.

        player.ultiCharge = 0
    end
end

--------------------------------------------------
-- RULES
--------------------------------------------------

log("Among Us v1.5.3")
log(" ")
log("Rules:")
log("Don't attack, not even as impostor or Ghost.")
log("Don't chat as ghost.")
log("Impostors spawn on a .. " .. colorText("red I", "ff0000") .. ", crewmates on a " .. colorText("green C", "0d4700"))
log(colorText("Hyper", "8d00a6") .. " button to kill as impostor.")
log(colorText("Super", "d4ad00") .. "charge shows kill cooldown.")
log("R-T's legs are the dead body.")
log("Use " .. colorText("super", "d4ad00") .. " to report a body or call a meeting.")

--------------------------------------------------
-- MAIN TICK
--------------------------------------------------

function tick()
    if not server:isIntroFinished() then
        return
    end

    --------------------------------------------------
    -- INTRO REVEAL
    --
    -- Keep everyone hidden/frozen for
    -- INTRO_REVEAL_DELAY_TICKS after the intro ends, then
    -- teleport everyone back to their real spawn and drop
    -- the hiding invisibility/stun, all in this one tick.
    -- The rest of the game does not start until this has
    -- happened.
    --------------------------------------------------

    if not introRevealDone then

        introRevealTimer = introRevealTimer + 1

        if introRevealTimer >= INTRO_REVEAL_DELAY_TICKS then

            introRevealDone = true

            for i = 0, (server.playersCount - 1) do

                local p =
                    server:getClientInfo(i)

                local pos =
                    matchSpawnPositions[i]

                if p ~= nil and pos ~= nil then

                    local char =
                        server.objectManager:getObject(
                            p.objectId
                        )

                    if char ~= nil then

                        char:teleport(
                            pos.x,
                            pos.y,
                            nil,
                            nil,
                            0,
                            0
                        )

                        if not isImpostor(i) then

                            -- NOTE: a duration of 0 here
                            -- was making the stun/invisibility
                            -- permanent instead of ending it -
                            -- this engine appears to treat 0
                            -- as a "never expires" sentinel,
                            -- the same way -1 is used as a
                            -- sentinel elsewhere. Passing a
                            -- tiny positive duration instead
                            -- overwrites the long hiding
                            -- duration with a normal, short
                            -- one that expires almost
                            -- immediately.

                            char:setInvisibility(2, -1)

                            char:setStun(
                                2,
                                true,
                                false,
                                true
                            )
                        end
                    end
                end

                --------------------------------------------------
                -- RESET ULTI BASELINE
                --
                -- previousUltiCharge was frozen at its
                -- script-load value the whole time we were
                -- returning early above (intro + this hidden
                -- window). Whatever actually happened to
                -- ultiCharge during that gap (passive regen,
                -- an unstunned Impostor pressing their ability
                -- button, etc.) would otherwise look exactly
                -- like "just used ulti" on the very first live
                -- tick below, and immediately fire a false
                -- report / emergency meeting. Resync it to the
                -- real current value now, right as gameplay
                -- actually starts.
                --------------------------------------------------

                if p ~= nil then
                    previousUltiCharge[i] = p.ultiCharge
                end
            end
        end

        return
    end

    --------------------------------------------------
    -- GAME END
    --
    -- The winner is decided immediately in
    -- triggerGameEnd(), but server:debugFinishBattle()
    -- isn't called until gameEndTimer counts down to 0,
    -- so there's a short delay before the battle actually
    -- ends.
    --------------------------------------------------

    if gameEnded then

        if gameEndTimer > 0 then

            gameEndTimer = gameEndTimer - 1

            if gameEndTimer == 0
                and gameEndWinnerTeam ~= nil
            then
                server:debugFinishBattle(gameEndWinnerTeam)
            end
        end

        return
    end

    --------------------------------------------------
    -- PER-TICK CLIENT/CHARACTER CACHE
    --
    -- server:getClientInfo(i) and server.objectManager:
    -- getObject(p.objectId) were each being called again from
    -- scratch in every single loop below (6+ times per player,
    -- per tick). Fetch both once per player here and reuse
    -- them for the rest of the tick instead.
    --------------------------------------------------

    local tickClients = {}
    local tickChars = {}

    for i = 0, (server.playersCount - 1) do

        local p = server:getClientInfo(i)
        tickClients[i] = p

        if p ~= nil then
            tickChars[i] =
                server.objectManager:getObject(p.objectId)
        end
    end


    --------------------------------------------------
    -- DRAIN WEAPON SKILL CHARGE
    --
    -- Every tick, force every player's weapon skill
    -- charge down by 100.
    --------------------------------------------------

    for i = 0, (server.playersCount - 1) do

        local p = tickClients[i]

        if p ~= nil then

            local char = tickChars[i]

            if char ~= nil then

                local skill = char:getWeaponSkill()

                if skill ~= nil then
                    skill:charge(-100)
                end
            end
        end
    end


    --------------------------------------------------
    -- MEETINGS
    --
    -- Handles teleporting, voting and ejection. Killing
    -- and reporting are disabled below while a meeting
    -- is active.
    --------------------------------------------------

    updateMeeting()


    --------------------------------------------------
    -- REFRESH DEAD PLAYER EFFECT
    --
    -- GhostIncorporeal lasts 120 ticks.
    -- Refresh it every 100 ticks so it cannot expire.
    --------------------------------------------------

    deadPlayerEffectTimer =
        deadPlayerEffectTimer + 1

    if deadPlayerEffectTimer >= 100 then

        deadPlayerEffectTimer = 0

        refreshDeadPlayerStatus()
    end


    --------------------------------------------------
    -- REFRESH DUPLICATE CHARACTER STATUS
    --
    -- Reapplies the distinguishing status effect for
    -- players who share a character with someone else,
    -- every DUPLICATE_STATUS_INTERVAL_TICKS ticks.
    --------------------------------------------------

    duplicateStatusTimer =
        duplicateStatusTimer + 1

    if duplicateStatusTimer >= DUPLICATE_STATUS_INTERVAL_TICKS then

        duplicateStatusTimer = 0

        refreshDuplicateCharacterStatus()
    end


    --------------------------------------------------
    -- SAVE CURRENT ULTI CHARGES
    --
    -- IMPORTANT:
    --
    -- We save these BEFORE changing anything.
    -- This allows us to detect an ulti use before
    -- body proximity restores the charge.
    --------------------------------------------------

    local currentUltiCharge = {}

    for i = 0, (server.playersCount - 1) do

        currentUltiCharge[i] =
            tickClients[i].ultiCharge
    end


    --------------------------------------------------
    -- CHECK FOR REPORTS
    --
    -- This happens BEFORE body proximity restores
    -- ulti charge.
    --
    -- Dead players are explicitly excluded.
    --
    -- This also works for the impostor.
    --------------------------------------------------

    local reported = {}

    if not meetingActive then

        for i = 0, (server.playersCount - 1) do

            local p = tickClients[i]

            local previous =
                previousUltiCharge[i]

            if previous == nil then
                previous =
                    p.maxUltiCharge
            end


            local ultiWasUsed =
                not deadPlayers[i]
                and previous >= p.maxUltiCharge
                and currentUltiCharge[i]
                    < p.maxUltiCharge

            -- getNearestBody() scans every unreported body,
            -- and getDistance() to the button is its own
            -- sqrt() call, so both are skipped entirely for
            -- the (overwhelming majority of) players whose
            -- ulti wasn't just used this tick. This used to
            -- run for every single player every single tick.

            local bodyInfo, distance = nil, nil
            local nearBody = false
            local nearButton = false

            if ultiWasUsed then

                bodyInfo, distance = getNearestBody(p)

                nearBody =
                    bodyInfo ~= nil
                    and distance < 900

                nearButton =
                    getDistance(
                        p.x,
                        p.y,
                        EMERGENCY_BUTTON_X,
                        EMERGENCY_BUTTON_Y
                    ) < EMERGENCY_BUTTON_RANGE
            end


            --------------------------------------------------
            -- ULTI WAS USED NEAR A BODY
            --------------------------------------------------

            if ultiWasUsed and nearBody then

                -- Temporarily restore the ulti so the
                -- report does not leave the player empty.

                p.ultiCharge =
                    p.maxUltiCharge

                reportBody(
                    p,
                    bodyInfo
                )

                reported[i] = true


            --------------------------------------------------
            -- ULTI WAS USED NEAR THE EMERGENCY BUTTON
            --------------------------------------------------

            elseif ultiWasUsed and nearButton and meetingCooldown == 0 then

                -- Temporarily restore the ulti so calling
                -- the meeting does not leave the player empty.

                p.ultiCharge =
                    p.maxUltiCharge

                callEmergencyMeeting(p)

                reported[i] = true
            end
        end
    end


    --------------------------------------------------
    -- UPDATE OVERCHARGE
    --
    -- This runs every tick regardless of meeting state,
    -- since the same "hyper" button is also used to
    -- cast a vote during a meeting.
    --------------------------------------------------

    for i = 0, (server.playersCount - 1) do

        enableOverchargeButton(tickClients[i])
    end


    --------------------------------------------------
    -- KILL COOLDOWN
    --------------------------------------------------

    for k = 1, #impostorList do

        local id = impostorList[k]

        if killCooldowns[id] > 0 then
            killCooldowns[id] =
                killCooldowns[id] - 1
        end

        hasKilledThisTick[id] = false
    end


    --------------------------------------------------
    -- MEETING COOLDOWN
    --------------------------------------------------

    if meetingCooldown > 0 then
        meetingCooldown =
            meetingCooldown - 1
    end


    --------------------------------------------------
    -- KILLING
    --
    -- Disabled while a meeting is happening.
    --------------------------------------------------

    if not meetingActive then

    for k = 1, #impostorList do

        local impId = impostorList[k]

        if not deadPlayers[impId] then

            local imp = impostors[impId]
            local impC = impChars[impId]

            if imp ~= nil and impC ~= nil
                and killCooldowns[impId] == 0
                and not hasKilledThisTick[impId]
                and overchargeButtonPressed(imp)
            then

                -- Only Crewmates are valid kill targets:
                -- this is what stops Impostors from
                -- killing each other.

                for i = 0, (server.playersCount - 1) do

                    if not isImpostor(i)
                        and not deadPlayers[i]
                    then

                        local p = tickClients[i]
                        local char = tickChars[i]

                        if char ~= nil
                            and getDistance(
                                p.x,
                                p.y,
                                imp.x,
                                imp.y
                            ) < 900
                        then

                            --------------------------------------------------
                            -- TELEPORT IMPOSTOR TO PLAYER
                            --------------------------------------------------

                            impC:teleport(
                                p.x,
                                p.y,
                                nil,
                                nil,
                                0,
                                0
                            )


                            --------------------------------------------------
                            -- KILL PLAYER
                            --------------------------------------------------

                            char:setInvisibility(
                                10000000,
                                -1
                            )

                            deadPlayerEffects[i] = {
                                ghost =
                                    char:addStatusEffectSelf(
                                        STATUS_GHOST_INCORPOREAL,
                                        AttackOrigin.UNKNOWN
                                    ),
                                silence =
                                    char:addStatusEffectSelf(
                                        STATUS_DEAD_SILENCE,
                                        AttackOrigin.UNKNOWN
                                    )
                            }

                            deadPlayerEffects[i].silence:addTicks(99999999)
                            --------------------------------------------------
                            -- MARK PLAYER AS DEAD
                            --------------------------------------------------

                            deadPlayers[i] = true
                            aliveCrewmateCount = aliveCrewmateCount - 1


                            --------------------------------------------------
                            -- CHECK FOR GAME END
                            --------------------------------------------------

                            checkGameEnd()


                            --------------------------------------------------
                            -- RESET KILL COOLDOWN
                            --------------------------------------------------

                            killCooldowns[impId] = KILL_COOLDOWN_TICKS

                            hasKilledThisTick[impId] = true


                            --------------------------------------------------
                            -- SPAWN BODY
                            --------------------------------------------------

                            local body =
                                spawnCharacter(
                                    "SplitterLegs",
                                    p.x,
                                    p.y,
                                    BODY_CHARACTER_DATA
                                )


                            --------------------------------------------------
                            -- SAVE BODY
                            --------------------------------------------------

                            table.insert(
                                bodies,
                                {
                                    object = body,
                                    playerId = i
                                }
                            )

                            -- This Impostor has killed this
                            -- tick; stop scanning for more
                            -- targets.

                            break
                        end
                    end
                end
            end
        end
    end

    end


    --------------------------------------------------
    -- UPDATE ULTI CHARGES
    --
    -- Do NOT overwrite a player who just reported.
    --------------------------------------------------

    for i = 0, (server.playersCount - 1) do

        if not reported[i] then

            updateBodyUlti(tickClients[i])
        end
    end


    --------------------------------------------------
    -- SAVE ULTI CHARGES FOR NEXT TICK
    --------------------------------------------------

    for i = 0, (server.playersCount - 1) do

        previousUltiCharge[i] =
            tickClients[i].ultiCharge
    end

    for _, item in server.objectManager:getItems() do
        if item ~= nil then
            item:destroy()
        end
    end
end