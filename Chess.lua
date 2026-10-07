server.hasIntroSkip = true
server.hasPoisonDisabled = true

function spawnCharacter(charName, x, y)
    local characterData = lookup(16, charName)
    local character = createObject(characterData)
    character:setPosition(x, y, 0)
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

function giveStatusEffect(char,effect)
    return char:addStatusEffectSelf(lookup(117, effect),AttackOrigin.UNKNOWN)
end

function useSkill(char,skill)
    char:useSkill(lookup(20, skill),char.x,char.y,true)
end

function subtileToTile(subtileCord)
    return math.floor(subtileCord/300)
end

function tileToSubtile(tileCord)
    return tileCord*300+150
end

function hasUsedPin(player)
    return player.emoteUsedTick +1 == server.tick
end

function getTileCentreCord(cord)
    return math.floor(cord/300)*300+150
end

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

function tickToSecond(tick)
    return tick*20
end

function secondToTick(second)
    return second/20
end

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

local function getName(character)

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
        return NAME_MAP[name] or name
    end

    return "UNKNOWN"
end

function getDistance(x1, y1, x2, y2)
    return math.sqrt(
        (x2 - x1)^2 +
        (y2 - y1)^2
    )
end

CHESS_PIECES = {
    pawn = "Enrager",
    rook = "CrossBomber",
    knight = "Painter",
    bishop = "Bulletstorm",
    queen = "Geisha",
    king = "Samurai"
}

processedProjectiles = {}

function getChessTileCentre(x, y)
    local bx = math.floor((x - 900) / 600 + 0.5)
    local by = math.floor((y - 2700) / 600 + 0.5)

    if bx < 0 or bx > 7 or by < 0 or by > 7 then
        return nil
    end

    return 900 + bx * 600, 2700 + by * 600
end


function chessToBlock(x, y)
    local bx = math.floor((x - 900) / 600 + 0.5)
    local by = math.floor((y - 2700) / 600 + 0.5)

    if bx < 0 or bx > 7 or by < 0 or by > 7 then
        return nil
    end

    return bx, by
end


function chessToWorld(bx, by)
    if bx < 0 or bx > 7 or by < 0 or by > 7 then
        return nil
    end

    return 900 + bx * 600, 2700 + by * 600
end


-- =========================================================
-- CHESS SETUP
-- =========================================================

whitePieces = {}
blackPieces = {}
chessSetupDone = false
playerOnTurn = 0

local WHITE = "white"
local BLACK = "black"

-- Standard chess starting positions.
--
-- Board coordinates:
--   by = 0  -> black back rank
--   by = 1  -> black pawns
--   by = 6  -> white pawns
--   by = 7  -> white back rank
--
-- bx = 0..7 -> a..h

local backRank = {
    "rook",
    "knight",
    "bishop",
    "queen",
    "king",
    "bishop",
    "knight",
    "rook"
}


-- Tracks the chess type ("pawn", "rook", ...) for every piece object,
-- so we know how it's allowed to move.
pieceTypes = {}

-- Tracks whether a piece has ever moved, needed for the pawn's
-- two-square opening move.
pieceHasMoved = {}

function spawnChessPiece(pieceType, color, bx, by)
    local characterName = CHESS_PIECES[pieceType]

    if characterName == nil then
        return nil
    end

    local x, y = chessToWorld(bx, by)

    if x == nil or y == nil then
        return nil
    end

    local piece = spawnCharacter(characterName, x, y)

    if piece == nil then
        return nil
    end

    -- Every chess piece starts invulnerable.
    giveStatusEffect(piece, "Invulnerable")

    pieceTypes[piece] = pieceType
    pieceHasMoved[piece] = false

    if color == WHITE then
        table.insert(whitePieces, piece)
    else
        table.insert(blackPieces, piece)
    end

    return piece
end


-- How many starting pieces to spawn per tick. Spawning is a real
-- engine cost (lookup + createObject + addObject per piece), so
-- spawning all 32 starting pieces in a single tick can blow the
-- 15ms tick budget on its own. Spread across ticks instead - see
-- stepSetupChessField, called from tick().
SETUP_PIECES_PER_TICK = 4

-- Queue of {type, color, bx, by} specs still waiting to be spawned
-- by stepSetupChessField. nil until setup starts.
chessSetupQueue = nil

-- Builds the full list of starting-position piece specs, in the
-- same order the old single-tick setupChessField used to spawn
-- them (black back rank, black pawns, white pawns, white back
-- rank).
function buildChessSetupQueue()
    local queue = {}

    for bx = 0, 7 do
        table.insert(queue, { type = backRank[bx + 1], color = BLACK, bx = bx, by = 0 })
    end

    for bx = 0, 7 do
        table.insert(queue, { type = "pawn", color = BLACK, bx = bx, by = 1 })
    end

    for bx = 0, 7 do
        table.insert(queue, { type = "pawn", color = WHITE, bx = bx, by = 6 })
    end

    for bx = 0, 7 do
        table.insert(queue, { type = backRank[bx + 1], color = WHITE, bx = bx, by = 7 })
    end

    return queue
end

-- Spawns up to `budget` more starting pieces, continuing from
-- wherever the last call left off. Call once per tick from tick();
-- safe to call with no setup in progress (including after setup is
-- already done).
function stepSetupChessField(budget)
    if chessSetupDone then
        return
    end

    if chessSetupQueue == nil then
        whitePieces = {}
        blackPieces = {}
        chessSetupQueue = buildChessSetupQueue()
    end

    local spawnsLeft = budget

    while spawnsLeft > 0 and #chessSetupQueue > 0 do
        local spec = table.remove(chessSetupQueue, 1)
        spawnChessPiece(spec.type, spec.color, spec.bx, spec.by)
        spawnsLeft = spawnsLeft - 1
    end

    if #chessSetupQueue == 0 then
        chessSetupDone = true
    end
end


-- =========================================================
-- CHESS TICK EFFECTS
-- =========================================================

-- How many pieces get their aura status effect (re)applied per
-- tick. applyChessEffects used to hit every piece (up to 32) every
-- single tick, forever - unlike the one-off setup spawn above, this
-- cost recurs on every tick for the whole game, so it needs to stay
-- spread rather than just chunked once. Instead we round-robin
-- through all pieces via chessEffectCursor, refreshing a batch each
-- tick; at 20 ticks/second and a budget of 8, every piece still
-- gets refreshed at least every 4 ticks (0.2s), which is well
-- within any status effect's duration.
CHESS_EFFECT_CHECKS_PER_TICK = 8

-- Index into this tick's combined white+black piece list of the
-- next piece due for a refresh. Wraps back to 1 once it runs past
-- the end.
chessEffectCursor = 1

function applyChessEffects(budget)
    local combined = {}

    for _, piece in ipairs(whitePieces) do
        if piece ~= nil then
            table.insert(combined, { piece = piece, effect = "RollerFireIce" })
        end
    end

    for _, piece in ipairs(blackPieces) do
        if piece ~= nil then
            -- table.insert(combined, { piece = piece, effect = "RollerFire" })
        end
    end

    local total = #combined

    if total == 0 then
        return
    end

    if chessEffectCursor > total then
        chessEffectCursor = 1
    end

    -- Never process the same piece twice in one tick, even if the
    -- budget is larger than the current piece count.
    local iterations = math.min(budget, total)

    for _ = 1, iterations do
        local entry = combined[chessEffectCursor]
        giveStatusEffect(entry.piece, entry.effect)

        chessEffectCursor = chessEffectCursor + 1

        if chessEffectCursor > total then
            chessEffectCursor = 1
        end
    end
end

function getChessPieceAt(x, y)
    local bx, by = chessToBlock(x, y)

    if bx == nil or by == nil then
        return nil
    end

    for _, piece in ipairs(whitePieces) do
        if piece ~= nil then
            local px, py = chessToBlock(piece.x, piece.y)

            if px == bx and py == by then
                return piece
            end
        end
    end

    for _, piece in ipairs(blackPieces) do
        if piece ~= nil then
            local px, py = chessToBlock(piece.x, piece.y)

            if px == bx and py == by then
                return piece
            end
        end
    end

    return nil
end


player1 = server:getClientInfo(0)
player2 = server:getClientInfo(1)

pieceSelected = nil

-- =========================================================
-- GAME TICK
-- =========================================================

-- =========================================================
-- CHESS STATE
-- =========================================================

playerOnTurn = 0

-- The currently selected piece for each player.
selectedPieces = {
    [0] = nil,
    [1] = nil
}

-- Set to true once the game has ended by checkmate or stalemate;
-- no further moves are accepted after that.
gameOver = false

-- Set for a player while they are choosing a promotion piece for a
-- pawn that just reached the far rank. See startPawnPromotion().
pendingPromotions = {
    [0] = nil,
    [1] = nil
}

-- Set right after a pawn's two-square opening move, describing the
-- one capture that's available en passant on the very next move.
-- Fields: pawn (the piece that jumped), color (its side), captureBx/
-- captureBy (the empty square a capturing pawn moves onto). Cleared
-- after every move unless that move itself is a new two-square jump.
-- See updateEnPassantTarget() / getCapturedPieceForMove().
enPassantTarget = nil


function isWhitePiece(piece)
    if piece == nil then
        return false
    end

    for _, p in ipairs(whitePieces) do
        if p == piece then
            return true
        end
    end

    return false
end


function isBlackPiece(piece)
    if piece == nil then
        return false
    end

    for _, p in ipairs(blackPieces) do
        if p == piece then
            return true
        end
    end

    return false
end


function isPlayerPiece(piece, player)
    if player == 0 then
        return isWhitePiece(piece)
    elseif player == 1 then
        return isBlackPiece(piece)
    end

    return false
end


function removeChessPiece(piece)
    if piece == nil then
        return
    end

    -- Remove it from the appropriate piece list.
    for i, p in ipairs(whitePieces) do
        if p == piece then
            table.remove(whitePieces, i)
            break
        end
    end

    for i, p in ipairs(blackPieces) do
        if p == piece then
            table.remove(blackPieces, i)
            break
        end
    end

    -- Put defeated piece outside the board.
    piece:teleport(1, 1, nil, nil, 0, 0)

    -- Drop any in-flight move check for it - it's been sent off the
    -- board on purpose, so checkStuckMoves must not "correct" that
    -- by teleporting it back to wherever it was headed before being
    -- captured.
    pendingMoveChecks[piece] = nil
end


-- Returns whatever piece "occupies" square (bx, by), accounting for
-- an optional hypothetical move described by `sim` (a table with
-- movingPiece, fromBx, fromBy, toBx, toBy, captured). Passing sim =
-- nil just returns the real board state via getChessPieceAt.
function virtualOccupant(bx, by, sim)
    if sim ~= nil then
        if bx == sim.toBx and by == sim.toBy then
            return sim.movingPiece
        end

        if bx == sim.fromBx and by == sim.fromBy then
            return nil
        end
    end

    local wx, wy = chessToWorld(bx, by)

    if wx == nil then
        return nil
    end

    local occupant = getChessPieceAt(wx, wy)

    if sim ~= nil and occupant == sim.captured then
        return nil
    end

    return occupant
end

-- Returns true if every square strictly between (fromBx, fromBy) and
-- (toBx, toBy) is empty. Assumes the two squares lie on a straight
-- line or diagonal (only meaningful for rook/bishop/queen moves).
-- An optional `sim` simulates a hypothetical move already being in
-- effect (used to test for check without actually moving anything).
function isPathClear(fromBx, fromBy, toBx, toBy, sim)
    local dx = toBx - fromBx
    local dy = toBy - fromBy

    local stepX = 0
    if dx > 0 then stepX = 1 elseif dx < 0 then stepX = -1 end

    local stepY = 0
    if dy > 0 then stepY = 1 elseif dy < 0 then stepY = -1 end

    local x, y = fromBx + stepX, fromBy + stepY

    while x ~= toBx or y ~= toBy do
        if virtualOccupant(x, y, sim) ~= nil then
            return false
        end

        x = x + stepX
        y = y + stepY
    end

    return true
end

-- If moving `piece` (a king) from (fromBx, fromBy) to (toBx, toBy)
-- matches a legal castling move - king and rook both unmoved, empty
-- squares between them - returns a table describing the rook's side
-- of the move. Otherwise returns nil. Does not check whether the
-- king is in, passes through, or lands in check; that's handled
-- separately in isLegalChessMove, since it needs the fuller board
-- context.
function getCastlingMove(piece, fromBx, fromBy, toBx, toBy)
    if pieceHasMoved[piece] then
        return nil
    end

    local color = isWhitePiece(piece) and WHITE or BLACK
    local homeRow = (color == WHITE) and 7 or 0

    if fromBy ~= homeRow or fromBx ~= 4 then
        return nil
    end

    local rookFromBx, rookToBx

    if toBx > fromBx then
        rookFromBx, rookToBx = 7, 5
    else
        rookFromBx, rookToBx = 0, 3
    end

    local rookWx, rookWy = chessToWorld(rookFromBx, homeRow)

    if rookWx == nil then
        return nil
    end

    local rook = getChessPieceAt(rookWx, rookWy)

    if rook == nil or pieceTypes[rook] ~= "rook" or pieceHasMoved[rook] then
        return nil
    end

    if color == WHITE and not isWhitePiece(rook) then
        return nil
    end

    if color == BLACK and not isBlackPiece(rook) then
        return nil
    end

    -- Every square between the king and the rook must be empty.
    local minBx = math.min(fromBx, rookFromBx) + 1
    local maxBx = math.max(fromBx, rookFromBx) - 1

    for bx = minBx, maxBx do
        local wx, wy = chessToWorld(bx, homeRow)

        if wx == nil or getChessPieceAt(wx, wy) ~= nil then
            return nil
        end
    end

    return {
        rook = rook,
        rookFromBx = rookFromBx,
        rookToBx = rookToBx,
        rookRow = homeRow
    }
end

-- Checks whether moving `piece` from (fromBx, fromBy) to (toBx, toBy)
-- follows the standard movement rules for its piece type.
-- `target` is whatever piece (if any) already sits on the destination
-- square; it has already been confirmed to not be an allied piece.
-- This only checks the piece's own movement pattern; it does not
-- check whether the move leaves the mover's own king in check (see
-- isLegalChessMove below for that).
function isLegalPieceMovement(piece, fromBx, fromBy, toBx, toBy, target)
    local pieceType = pieceTypes[piece]

    if pieceType == nil then
        return false
    end

    -- Must actually move somewhere.
    if fromBx == toBx and fromBy == toBy then
        return false
    end

    local dx = toBx - fromBx
    local dy = toBy - fromBy
    local absDx = math.abs(dx)
    local absDy = math.abs(dy)

    if pieceType == "pawn" then
        -- White starts at by = 6 and advances toward by = 0.
        -- Black starts at by = 1 and advances toward by = 7.
        local isWhite = isWhitePiece(piece)
        local direction = isWhite and -1 or 1
        local startRow = isWhite and 6 or 1

        if dx == 0 then
            -- Straight moves can never capture.
            if target ~= nil then
                return false
            end

            if dy == direction then
                return true
            end

            if dy == 2 * direction and fromBy == startRow then
                local midBx, midBy = fromBx, fromBy + direction
                local mx, my = chessToWorld(midBx, midBy)
                return mx ~= nil and getChessPieceAt(mx, my) == nil
            end

            return false
        elseif absDx == 1 and dy == direction then
            -- Diagonal moves are only legal when capturing.
            return target ~= nil
        end

        return false

    elseif pieceType == "rook" then
        if (dx == 0) ~= (dy == 0) then
            return isPathClear(fromBx, fromBy, toBx, toBy)
        end
        return false

    elseif pieceType == "bishop" then
        if absDx == absDy then
            return isPathClear(fromBx, fromBy, toBx, toBy)
        end
        return false

    elseif pieceType == "queen" then
        if dx == 0 or dy == 0 or absDx == absDy then
            return isPathClear(fromBx, fromBy, toBx, toBy)
        end
        return false

    elseif pieceType == "knight" then
        return (absDx == 1 and absDy == 2) or (absDx == 2 and absDy == 1)

    elseif pieceType == "king" then
        if absDx <= 1 and absDy <= 1 then
            return true
        end

        -- A 2-square horizontal hop is only legal as castling.
        if absDy == 0 and absDx == 2 then
            return getCastlingMove(piece, fromBx, fromBy, toBx, toBy) ~= nil
        end

        return false
    end

    return false
end


-- Like isLegalPieceMovement, but for attack purposes: pawns "attack"
-- diagonally whether or not the square is actually occupied, and no
-- other piece-vs-target restriction applies. `sim`, if given,
-- simulates a hypothetical move already being in effect.
function canPieceAttackSquare(piece, fromBx, fromBy, toBx, toBy, sim)
    local pieceType = pieceTypes[piece]

    if pieceType == nil then
        return false
    end

    if fromBx == toBx and fromBy == toBy then
        return false
    end

    local dx = toBx - fromBx
    local dy = toBy - fromBy
    local absDx = math.abs(dx)
    local absDy = math.abs(dy)

    if pieceType == "pawn" then
        local isWhite = isWhitePiece(piece)
        local direction = isWhite and -1 or 1
        return absDx == 1 and dy == direction

    elseif pieceType == "knight" then
        return (absDx == 1 and absDy == 2) or (absDx == 2 and absDy == 1)

    elseif pieceType == "king" then
        return absDx <= 1 and absDy <= 1

    elseif pieceType == "rook" then
        if (dx == 0) ~= (dy == 0) then
            return isPathClear(fromBx, fromBy, toBx, toBy, sim)
        end
        return false

    elseif pieceType == "bishop" then
        if absDx == absDy then
            return isPathClear(fromBx, fromBy, toBx, toBy, sim)
        end
        return false

    elseif pieceType == "queen" then
        if dx == 0 or dy == 0 or absDx == absDy then
            return isPathClear(fromBx, fromBy, toBx, toBy, sim)
        end
        return false
    end

    return false
end

-- Finds the board square of `color`'s king, accounting for `sim` if
-- the king itself is the piece being hypothetically moved.
function findKingSquare(color, sim)
    local list = (color == WHITE) and whitePieces or blackPieces

    for _, piece in ipairs(list) do
        if pieceTypes[piece] == "king" then
            if sim ~= nil and piece == sim.movingPiece then
                return sim.toBx, sim.toBy
            end

            return chessToBlock(piece.x, piece.y)
        end
    end

    return nil, nil
end

-- Returns `color`'s king piece object, or nil if it can't be found.
function findKingPiece(color)
    local list = (color == WHITE) and whitePieces or blackPieces

    for _, piece in ipairs(list) do
        if piece ~= nil and pieceTypes[piece] == "king" then
            return piece
        end
    end

    return nil
end

-- Returns true if any piece of `byColor` attacks square (bx, by).
function isSquareAttacked(bx, by, byColor, sim)
    local list = (byColor == WHITE) and whitePieces or blackPieces

    for _, piece in ipairs(list) do
        if piece ~= nil and (sim == nil or piece ~= sim.captured) then
            local pbx, pby = chessToBlock(piece.x, piece.y)

            if pbx ~= nil and canPieceAttackSquare(piece, pbx, pby, bx, by, sim) then
                return true
            end
        end
    end

    return false
end

-- Is `color`'s king currently in check?
function isKingInCheck(color, sim)
    local kbx, kby = findKingSquare(color, sim)

    if kbx == nil then
        return false
    end

    local opponentColor = (color == WHITE) and BLACK or WHITE

    return isSquareAttacked(kbx, kby, opponentColor, sim)
end

-- Tracks the "in check" status effect currently applied to each
-- color's king, if any: the effect object (so it can be :cancel()'d),
-- which king piece it's on, and the tick it's due to expire. See
-- updateCheckEffects / clearCheckEffect.
kingCheckEffects = {
    [WHITE] = nil,
    [BLACK] = nil
}

-- How long (in ticks) the check status effect lasts before it needs
-- refreshing to keep showing while the king is still in check.
CHECK_EFFECT_DURATION = 20

-- Removes `color`'s king-in-check status effect, if one is currently
-- active.
function clearCheckEffect(color)
    local state = kingCheckEffects[color]

    if state ~= nil then
        if state.effect ~= nil then
            state.effect:cancel()
        end

        kingCheckEffects[color] = nil
    end
end

-- Keeps each king's "in check" status effect in sync with the
-- current board state: applies it the moment that side's king is put
-- in check, refreshes it just before it would run out while the
-- check is still ongoing, and removes it again once the king is no
-- longer in check. Call once per tick.
function updateCheckEffects()
    for _, color in ipairs({ WHITE, BLACK }) do
        local king = findKingPiece(color)

        if king == nil or not isKingInCheck(color, nil) then
            clearCheckEffect(color)
        else
            local state = kingCheckEffects[color]

            if state == nil or state.piece ~= king or server.tick >= state.expiresAtTick then
                if state ~= nil and state.effect ~= nil then
                    state.effect:cancel()
                end

                kingCheckEffects[color] = {
                    effect = giveStatusEffect(king, "MorningstarSuperRoot"),
                    piece = king,
                    expiresAtTick = server.tick + CHECK_EFFECT_DURATION
                }
            end
        end
    end
end

-- Would moving `piece` from (fromBx, fromBy) to (toBx, toBy) leave
-- its own side's king in check?
function wouldMoveLeaveKingInCheck(piece, fromBx, fromBy, toBx, toBy, target)
    local color = isWhitePiece(piece) and WHITE or BLACK

    local sim = {
        movingPiece = piece,
        fromBx = fromBx,
        fromBy = fromBy,
        toBx = toBx,
        toBy = toBy,
        captured = target
    }

    return isKingInCheck(color, sim)
end

-- Full legality check used for actually making a move: the piece's
-- movement pattern must be valid, AND the move must not leave the
-- mover's own king in check.
function isLegalChessMove(piece, fromBx, fromBy, toBx, toBy, target)
    if not isLegalPieceMovement(piece, fromBx, fromBy, toBx, toBy, target) then
        return false
    end

    -- Castling has extra requirements beyond the normal king move:
    -- the king may not castle out of, through, or into check.
    if pieceTypes[piece] == "king" and fromBy == toBy and math.abs(toBx - fromBx) == 2 then
        local color = isWhitePiece(piece) and WHITE or BLACK
        local opponentColor = (color == WHITE) and BLACK or WHITE

        if isKingInCheck(color, nil) then
            return false
        end

        local transitBx = fromBx + (toBx > fromBx and 1 or -1)

        if isSquareAttacked(transitBx, fromBy, opponentColor, nil) then
            return false
        end
    end

    if wouldMoveLeaveKingInCheck(piece, fromBx, fromBy, toBx, toBy, target) then
        return false
    end

    return true
end

-- Works out which piece (if any) would be captured by moving `piece`
-- to (toBx, toBy), given whatever already sits on the destination
-- square (`destinationOccupant`). This is normally just the
-- destination occupant, but also recognises an en passant capture,
-- where the captured pawn sits on a different square.
function getCapturedPieceForMove(piece, fromBx, fromBy, toBx, toBy, destinationOccupant)
    if destinationOccupant ~= nil then
        return destinationOccupant
    end

    if pieceTypes[piece] ~= "pawn" or enPassantTarget == nil then
        return nil
    end

    if toBx ~= enPassantTarget.captureBx or toBy ~= enPassantTarget.captureBy then
        return nil
    end

    local color = isWhitePiece(piece) and WHITE or BLACK

    if color == enPassantTarget.color then
        return nil
    end

    return enPassantTarget.pawn
end

-- Called once a move has actually been made, to set up the en
-- passant capture it makes available (if it was a pawn's two-square
-- opening move), or clear any old one otherwise - the right to
-- capture en passant only lasts for the very next move.
function updateEnPassantTarget(piece, fromBx, fromBy, toBx, toBy)
    enPassantTarget = nil

    if pieceTypes[piece] ~= "pawn" or fromBx ~= toBx then
        return
    end

    local dy = toBy - fromBy

    if math.abs(dy) ~= 2 then
        return
    end

    enPassantTarget = {
        pawn = piece,
        color = isWhitePiece(piece) and WHITE or BLACK,
        captureBx = toBx,
        captureBy = fromBy + dy / 2
    }
end

-- Same as isLegalChessMove, but also works out the destination's
-- occupant and rejects moves onto one's own piece, mirroring the
-- checks moveChessPiece does. Used for scanning every possible move
-- when looking for checkmate/stalemate.
function isLegalMoveAvailable(piece, fromBx, fromBy, toBx, toBy)
    local wx, wy = chessToWorld(toBx, toBy)

    if wx == nil then
        return false
    end

    local target = getChessPieceAt(wx, wy)

    if target ~= nil then
        if isWhitePiece(piece) and isWhitePiece(target) then
            return false
        end

        if isBlackPiece(piece) and isBlackPiece(target) then
            return false
        end
    end

    local capturedPiece = getCapturedPieceForMove(piece, fromBx, fromBy, toBx, toBy, target)

    return isLegalChessMove(piece, fromBx, fromBy, toBx, toBy, capturedPiece)
end

-- How many isLegalMoveAvailable checks to run per tick while
-- looking for checkmate/stalemate. Keeps any one tick cheap even
-- though the full scan (pieces x 64 squares) can be a few hundred
-- checks; only degenerate near-mate positions ever need the full
-- scan; most ticks exit after just a few checks because a legal
-- move is found immediately.
EVAL_CHECKS_PER_TICK = 8

-- Currently running checkmate/stalemate scan, or nil if idle.
-- See startEvaluateGameState / stepEvaluateGameState.
evalJob = nil

-- Begins an incremental scan for whether `color` has any legal move
-- anywhere on the board. Input is blocked (see selectChessField)
-- while a scan is running.
function startEvaluateGameState(color)
    local list = (color == WHITE) and whitePieces or blackPieces
    local pieces = {}

    for _, piece in ipairs(list) do
        if piece ~= nil then
            local fromBx, fromBy = chessToBlock(piece.x, piece.y)

            if fromBx ~= nil then
                table.insert(pieces, { piece = piece, fromBx = fromBx, fromBy = fromBy })
            end
        end
    end

    evalJob = {
        color = color,
        -- Whether the king is in check is cheap to compute up front
        -- (one square vs. up to 16 attackers), unlike the full move
        -- scan below, so it doesn't need to be spread out too.
        inCheck = isKingInCheck(color, nil),
        pieces = pieces,
        pieceIndex = 1,
        toBx = 0,
        toBy = 0,
        hasMove = false
    }
end

-- Runs up to `budget` more legality checks of the current scan.
-- Call once per tick; safe to call with no scan running.
function stepEvaluateGameState(budget)
    if evalJob == nil then
        return
    end

    local job = evalJob
    local checksLeft = budget

    while checksLeft > 0 do
        local entry = job.pieces[job.pieceIndex]

        if entry == nil then
            -- Every piece/destination pair has been checked with no
            -- legal move found.
            break
        end

        if isLegalMoveAvailable(entry.piece, entry.fromBx, entry.fromBy, job.toBx, job.toBy) then
            job.hasMove = true
            break
        end

        -- Advance to the next destination square, then the next
        -- piece once all 64 squares have been tried.
        job.toBy = job.toBy + 1

        if job.toBy > 7 then
            job.toBy = 0
            job.toBx = job.toBx + 1

            if job.toBx > 7 then
                job.toBx = 0
                job.pieceIndex = job.pieceIndex + 1
            end
        end

        checksLeft = checksLeft - 1
    end

    -- Finished either because a move was found, or because there
    -- was nothing left to check.
    if job.hasMove or job.pieces[job.pieceIndex] == nil then
        finishEvaluateGameState(job)
        evalJob = nil
    end
end

-- Announces check, checkmate, or stalemate once a scan has finished,
-- and sets gameOver to stop further moves once the game is decided.
-- Ends the round by dealing lethal damage to every connected
-- player's character.
function endGame()
    for i = 0, (server.playersCount - 1) do
        local p = server:getClientInfo(i)

        if p ~= nil then
            local char = server.objectManager:getObject(p.objectId)

            if char ~= nil then
                char:takeDamage(0, 1000000, 0, nil, nil, true, false, 0, 0, nil, false, AttackOrigin.UNKNOWN, false, false, false, 0)
            end
        end
    end
end

function finishEvaluateGameState(job)
    local color = job.color
    local inCheck = job.inCheck
    local hasMove = job.hasMove

    if inCheck and not hasMove then
        gameOver = true

        local winnerColor = (color == WHITE) and BLACK or WHITE

        log("Checkmate! " .. capitalize(winnerColor) .. " wins!")
    elseif not inCheck and not hasMove then
        gameOver = true

        log("Stalemate! The game is a draw.")
    elseif inCheck then
        log(capitalize(color) .. " is in check!")
    end
end


-- Pieces move at 1000 units per second (the speed passed to
-- moveTo). The two conversion helpers above (tickToSecond /
-- secondToTick) put the tick rate at 20 ticks per second, so a move
-- takes distance / MOVE_UNITS_PER_TICK ticks to arrive.
MOVE_UNITS_PER_SECOND = 1000
TICKS_PER_SECOND = 20
MOVE_UNITS_PER_TICK = MOVE_UNITS_PER_SECOND / TICKS_PER_SECOND

-- Extra ticks of slack on top of the expected travel time, to
-- absorb ordinary rounding/scheduling jitter before a move that
-- hasn't arrived gets treated as stuck.
MOVE_CHECK_SLACK_TICKS = 5

-- How close (in world units) a piece needs to have gotten to its
-- destination to count as "arrived" rather than stuck.
MOVE_ARRIVAL_TOLERANCE = 10

-- Tracks pieces currently mid-move, keyed by piece, so a move that
-- never actually arrives - most likely because something (like a
-- status effect) blocked it partway - can be caught and corrected.
-- Each entry holds the intended destination and the tick by which
-- the move should have finished. See moveChessPieceTo /
-- checkStuckMoves.
pendingMoveChecks = {}

-- Commands `piece` to move to (destX, destY) exactly like moveTo,
-- but also remembers the destination and a deadline so
-- checkStuckMoves can notice if the move never actually completed
-- and teleport the piece into place as a fallback.
function moveChessPieceTo(piece, destX, destY)
    local distance = getDistance(piece.x, piece.y, destX, destY)

    piece:moveTo(destX, destY, true, 1000, false, false)

    local travelTicks = math.ceil(distance / MOVE_UNITS_PER_TICK)

    pendingMoveChecks[piece] = {
        destX = destX,
        destY = destY,
        deadlineTick = server.tick + travelTicks + MOVE_CHECK_SLACK_TICKS
    }
end

-- Checks every move started by moveChessPieceTo whose deadline has
-- passed. If the piece never actually got close to its destination -
-- e.g. it got stuck rooted mid-move - teleports it straight there so
-- the visible board can't desync from what the game logic thinks
-- happened (and so it doesn't sit somewhere it can be captured while
-- game logic believes it already escaped). Call once per tick.
function checkStuckMoves()
    for piece, check in pairs(pendingMoveChecks) do
        if server.tick >= check.deadlineTick then
            local distance = getDistance(piece.x, piece.y, check.destX, check.destY)

            if distance > MOVE_ARRIVAL_TOLERANCE then
                piece:teleport(check.destX, check.destY, nil, nil, 0, 0)
            end

            pendingMoveChecks[piece] = nil
        end
    end
end

function moveChessPiece(piece, x, y)
    if piece == nil then
        return false
    end

    local tileX, tileY = getChessTileCentre(x, y)

    if tileX == nil or tileY == nil then
        return false
    end

    local fromBx, fromBy = chessToBlock(piece.x, piece.y)
    local toBx, toBy = chessToBlock(tileX, tileY)

    if fromBx == nil or toBx == nil then
        return false
    end

    -- Check whether another piece occupies the destination.
    local target = getChessPieceAt(tileX, tileY)

    if target ~= nil and target ~= piece then

        -- Do not allow capturing your own piece.
        if isWhitePiece(piece) and isWhitePiece(target) then
            return false
        end

        if isBlackPiece(piece) and isBlackPiece(target) then
            return false
        end
    else
        -- Moving onto your own square, or onto itself, is not a move.
        target = nil
    end

    -- Work out what's actually captured by this move - normally
    -- just `target`, but an en passant capture takes a pawn that
    -- isn't standing on the destination square. Must be computed
    -- against the CURRENT en passant target, before it's updated
    -- below for the next move.
    local capturedPiece = getCapturedPieceForMove(piece, fromBx, fromBy, toBx, toBy, target)

    -- If this is a castling move, work out the rook's side of it now
    -- too, so it can be executed alongside the king once the whole
    -- move is confirmed legal.
    local castling = nil

    if pieceTypes[piece] == "king" and fromBy == toBy and math.abs(toBx - fromBx) == 2 then
        castling = getCastlingMove(piece, fromBx, fromBy, toBx, toBy)
    end

    -- Reject moves that don't follow the piece's movement rules.
    if not isLegalChessMove(piece, fromBx, fromBy, toBx, toBy, capturedPiece) then
        return false
    end

    -- The move is confirmed legal, so it's about to actually happen -
    -- remove the mover's "in check" status effect now rather than
    -- waiting for the next tick's updateCheckEffects. (A legal move
    -- always gets the mover's own king out of check, so this is safe
    -- to do unconditionally.)
    clearCheckEffect(isWhitePiece(piece) and WHITE or BLACK)

    if capturedPiece ~= nil then
        -- Defeat the captured piece.
        removeChessPiece(capturedPiece)
    end

    -- Move the selected piece to the centre of the square.
    moveChessPieceTo(piece, tileX, tileY)

    pieceHasMoved[piece] = true

    if castling ~= nil then
        local rookWx, rookWy = chessToWorld(castling.rookToBx, castling.rookRow)

        moveChessPieceTo(castling.rook, rookWx, rookWy)

        pieceHasMoved[castling.rook] = true
    end

    updateEnPassantTarget(piece, fromBx, fromBy, toBx, toBy)

    return true
end


function capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

function getPieceColorName(piece)
    if isWhitePiece(piece) then
        return "White"
    elseif isBlackPiece(piece) then
        return "Black"
    end

    return "Unknown"
end

function getPieceTypeName(piece)
    local pieceType = pieceTypes[piece]

    if pieceType == nil then
        return "Unknown"
    end

    return capitalize(pieceType)
end

-- Converts board coordinates to standard algebraic notation, e.g.
-- bx = 4, by = 3 -> "e5".
function toChessNotation(bx, by)
    if bx == nil or by == nil then
        return "?"
    end

    return string.char(97 + bx) .. tostring(8 - by)
end


-- =========================================================
-- PAWN PROMOTION
-- =========================================================

-- The four promotion choices, shown as a column at I3-I6 next to
-- the board (rank 3 at the bottom, rank 6 at the top).
PROMOTION_SLOTS = {
    { rank = 3, pieceType = "queen" },
    { rank = 4, pieceType = "rook" },
    { rank = 5, pieceType = "bishop" },
    { rank = 6, pieceType = "knight" }
}

-- World coordinates for the promotion slot at the given rank (3-6),
-- always in column "I" (one column to the right of the board).
function promotionSlotWorld(rank)
    local bx = 8
    local by = 8 - rank

    return 900 + bx * 600, 2700 + by * 600
end

-- Returns the rank (3-6) of the promotion slot at world position
-- (x, y), or nil if that position isn't one of the four slots.
function getPromotionSlotAt(x, y)
    local bx = math.floor((x - 900) / 600 + 0.5)
    local by = math.floor((y - 2700) / 600 + 0.5)

    if bx ~= 8 then
        return nil
    end

    local rank = 8 - by

    if rank < 3 or rank > 6 then
        return nil
    end

    return rank
end

-- Whether `piece` landing on row `by` counts as reaching the far
-- end of the board for its colour.
function isPromotionRank(piece, by)
    if isWhitePiece(piece) then
        return by == 0
    elseif isBlackPiece(piece) then
        return by == 7
    end

    return false
end

-- Spawns the 4 promotion options next to the board and marks the
-- player as awaiting a promotion choice.
function startPawnPromotion(player, pawn, bx, by)
    local color = isWhitePiece(pawn) and WHITE or BLACK
    local options = {}

    for _, slot in ipairs(PROMOTION_SLOTS) do
        local sx, sy = promotionSlotWorld(slot.rank)
        local optionPiece = spawnCharacter(CHESS_PIECES[slot.pieceType], sx, sy)

        if optionPiece ~= nil then
            giveStatusEffect(optionPiece, "Invulnerable")

            options[slot.rank] = {
                piece = optionPiece,
                pieceType = slot.pieceType
            }
        end
    end

    pendingPromotions[player] = {
        pawn = pawn,
        bx = bx,
        by = by,
        color = color,
        options = options
    }

    log(getPieceColorName(pawn) .. " promoting Pawn - choose a piece")
end

-- Handles a click while a promotion is pending: picks the chosen
-- piece, brings it onto the board, and clears away the pawn and the
-- 3 unused options.
function resolvePawnPromotion(player, x, y)
    local promo = pendingPromotions[player]

    if promo == nil then
        return
    end

    local rank = getPromotionSlotAt(x, y)

    if rank == nil then
        return
    end

    local chosen = promo.options[rank]

    if chosen == nil then
        return
    end

    local boardX, boardY = chessToWorld(promo.bx, promo.by)

    -- Teleport the pawn away, just like a defeated piece.
    removeChessPiece(promo.pawn)
    pieceTypes[promo.pawn] = nil

    -- Bring the chosen piece onto the board in the pawn's place.
    chosen.piece:teleport(boardX, boardY, nil, nil, 0, 0)
    pieceTypes[chosen.piece] = chosen.pieceType
    pieceHasMoved[chosen.piece] = true

    if promo.color == WHITE then
        table.insert(whitePieces, chosen.piece)
    else
        table.insert(blackPieces, chosen.piece)
    end

    -- Teleport the 3 unused options away.
    for optionRank, option in pairs(promo.options) do
        if optionRank ~= rank then
            option.piece:teleport(1, 1, nil, nil, 0, 0)
            pieceTypes[option.piece] = nil
        end
    end

    pendingPromotions[player] = nil

    log(getPieceColorName(chosen.piece) .. " promoted Pawn to " .. capitalize(chosen.pieceType))

    -- The move is only now complete, so change turn.
    if playerOnTurn == 0 then
        playerOnTurn = 1
    else
        playerOnTurn = 0
    end

    local nextColor = (playerOnTurn == 0) and WHITE or BLACK
    startEvaluateGameState(nextColor)
end


-- Tracks the ConductorSign markers currently shown for each player's
-- selected piece, so they can be destroyed again on deselect, on
-- switching selection, or once a move is made.
moveMarkers = {
    [0] = {},
    [1] = {}
}

-- How many move-marker legality checks (each of which may spawn a
-- marker) to run per tick while building up the marker set for a
-- newly selected piece. Keeps any one tick cheap even for a queen,
-- which can have up to 27 legal destinations - see
-- stepSpawnMoveMarkers.
MARKER_CHECKS_PER_TICK = 8

-- Currently running marker-spawn job for each player, or nil while
-- idle. See spawnMoveMarkers / stepSpawnMoveMarkers.
markerJobs = {
    [0] = nil,
    [1] = nil
}

-- Destroys any ConductorSign markers currently shown for `player`,
-- clears the tracking table, and cancels any marker-spawn job still
-- in progress for them.
function clearMoveMarkers(player)
    for _, marker in ipairs(moveMarkers[player]) do
        if marker ~= nil then
            marker:destroy()
        end
    end

    moveMarkers[player] = {}
    markerJobs[player] = nil
end

-- Begins an incremental scan that will spawn a ConductorSign on every
-- tile `piece` can legally move to right now. The actual work is
-- spread across ticks by stepSpawnMoveMarkers (called from tick()),
-- so selecting a piece never does a full 64-square scan - and the
-- spawns it triggers - in a single tick.
function spawnMoveMarkers(player, piece)
    local fromBx, fromBy = chessToBlock(piece.x, piece.y)

    if fromBx == nil then
        return
    end

    markerJobs[player] = {
        piece = piece,
        fromBx = fromBx,
        fromBy = fromBy,
        toBx = 0,
        toBy = 0
    }
end

-- Runs up to `budget` more legality checks of the current
-- marker-spawn job for `player`, spawning a marker for each square
-- that turns out to be a legal destination. Call once per tick from
-- tick(); safe to call with no job running.
function stepSpawnMoveMarkers(player, budget)
    local job = markerJobs[player]

    if job == nil then
        return
    end

    local checksLeft = budget

    while checksLeft > 0 do
        if job.toBx > 7 then
            -- Every destination square has been checked.
            markerJobs[player] = nil
            return
        end

        if isLegalMoveAvailable(job.piece, job.fromBx, job.fromBy, job.toBx, job.toBy) then
            local wx, wy = chessToWorld(job.toBx, job.toBy)

            if wx ~= nil then
                local marker = spawnItem("ConductorSign", wx, wy)
                table.insert(moveMarkers[player], marker)
            end
        end

        job.toBy = job.toBy + 1

        if job.toBy > 7 then
            job.toBy = 0
            job.toBx = job.toBx + 1
        end

        checksLeft = checksLeft - 1
    end
end

function selectChessField(player, x, y)
    log("Found a projectile")

    -- Ignore all input once the game has been decided.
    if gameOver then
        return
    end

    -- Ignore input while still scanning for checkmate/stalemate from
    -- the previous move (see stepEvaluateGameState).
    if evalJob ~= nil then
        return
    end

    -- If this player is choosing a promotion piece, this click picks
    -- from the options instead of doing a normal selection or move.
    if pendingPromotions[player] ~= nil then
        resolvePawnPromotion(player, x, y)
        return
    end

    local piece = selectedPieces[player]

    -- =============================================
    -- FIRST SELECTION
    -- =============================================

    if piece == nil then

        local selected = getChessPieceAt(x, y)

        if selected == nil then
            return
        end

        -- Player can only select their own pieces.
        if not isPlayerPiece(selected, player) then
            return
        end

        selectedPieces[player] = selected
        spawnMoveMarkers(player, selected)

        log(getPieceColorName(selected) .. " selected " .. getPieceTypeName(selected))

        return
    end


    -- =============================================
    -- SECOND SELECTION
    -- =============================================

    local clickedPiece = getChessPieceAt(x, y)

    -- Clicking the already-selected piece again deselects it.
    if clickedPiece == piece then
        clearMoveMarkers(player)
        selectedPieces[player] = nil
        log("Deselected piece")
        return
    end

    -- Clicking another of the player's own pieces switches the
    -- selection to that piece instead of attempting a move.
    if clickedPiece ~= nil and isPlayerPiece(clickedPiece, player) then
        clearMoveMarkers(player)
        selectedPieces[player] = clickedPiece
        spawnMoveMarkers(player, clickedPiece)
        log("Switched selection to another piece")
        return
    end

    local tileX, tileY = getChessTileCentre(x, y)
    local colorName = getPieceColorName(piece)
    local typeName = getPieceTypeName(piece)

    if moveChessPiece(piece, x, y) then

        -- Move was successful.
        clearMoveMarkers(player)
        selectedPieces[player] = nil

        local toBx, toBy = chessToBlock(tileX, tileY)
        log(colorName .. " moved " .. typeName .. " to " .. toChessNotation(toBx, toBy))

        if pieceTypes[piece] == "pawn" and isPromotionRank(piece, toBy) then
            -- Pawn reached the far rank: hold the turn until the
            -- player picks a promotion piece.
            startPawnPromotion(player, piece, toBx, toBy)
        else
            -- Change turn.
            if playerOnTurn == 0 then
                playerOnTurn = 1
            else
                playerOnTurn = 0
            end

            local nextColor = (playerOnTurn == 0) and WHITE or BLACK
            startEvaluateGameState(nextColor)
        end
    end
end


-- =========================================================
-- GAME TICK
-- =========================================================

processedProjectiles = {}

function getProjectileKey(proj)
    return tostring(proj.index) .. ":" ..
           tostring(proj.x) .. ":" ..
           tostring(proj.y)
end


function cleanupProcessedProjectiles()
    local activeProjectiles = {}

    for _, proj in server.objectManager:getProjectiles() do
        if proj.finishState == 1 then
            local key = getProjectileKey(proj)
            activeProjectiles[key] = true
        end
    end

    for key, _ in pairs(processedProjectiles) do
        if not activeProjectiles[key] then
            processedProjectiles[key] = nil
        end
    end
end


-- =========================================================
-- PLAY TIME LOGGING
-- =========================================================

TICKS_PER_MINUTE = TICKS_PER_SECOND * 60

-- Tick the game started on, set the first time updatePlayTimeLog
-- runs. nil until then.
gameStartTick = nil

-- How many whole minutes of play time have been logged so far, so
-- each minute mark is only logged once.
minutesPlayedLogged = 0

-- Logs a message once for every whole minute that passes since the
-- game started. Call once per tick from tick(); cheap (just integer
-- math) so no budgeting needed.
function updatePlayTimeLog()
    if gameStartTick == nil then
        gameStartTick = server.tick
    end

    local elapsedTicks = server.tick - gameStartTick
    local elapsedMinutes = math.floor(elapsedTicks / TICKS_PER_MINUTE)

    if elapsedMinutes > minutesPlayedLogged then
        minutesPlayedLogged = elapsedMinutes
        log(13 - minutesPlayedLogged .. " minute(s) left.")
    end
end

function tick()
    stepSetupChessField(SETUP_PIECES_PER_TICK)
    applyChessEffects(CHESS_EFFECT_CHECKS_PER_TICK)

    -- Once the game has been decided, keep ending it every tick - a
    -- single takeDamage call isn't reliably enough on its own.
    if gameOver then
        endGame()
        return
    end

    -- Log elapsed play time once per minute.
    updatePlayTimeLog()

    -- Spend a small, fixed budget continuing any in-progress
    -- checkmate/stalemate scan, instead of doing the whole scan in
    -- one go on the tick the move happened.
    stepEvaluateGameState(EVAL_CHECKS_PER_TICK)

    -- Same idea for move markers: spend a small, fixed budget per
    -- player continuing any in-progress marker-spawn job, instead of
    -- scanning all 64 squares (and spawning every marker) in one go
    -- on the tick a piece gets selected.
    stepSpawnMoveMarkers(0, MARKER_CHECKS_PER_TICK)
    stepSpawnMoveMarkers(1, MARKER_CHECKS_PER_TICK)

    -- Remove projectile keys that no longer exist.
    cleanupProcessedProjectiles()

    for _, proj in server.objectManager:getProjectiles() do

        if proj.finishState == 1 then

            local key = getProjectileKey(proj)

            -- Only process this projectile once.
            if not processedProjectiles[key] then

                processedProjectiles[key] = true

                if proj.index == player1.index
                    and playerOnTurn == 0
                then

                    selectChessField(
                        0,
                        proj.x,
                        proj.y
                    )

                elseif proj.index == player2.index
                    and playerOnTurn == 1
                then

                    selectChessField(
                        1,
                        proj.x,
                        proj.y
                    )

                end
            end
        end
    end

    -- Catch any move that never actually arrived (e.g. one that got
    -- blocked mid-move by a status effect) and teleport that piece
    -- into place. Done before updateCheckEffects so check status is
    -- always evaluated against the corrected, final position.
    checkStuckMoves()

    -- Keep each king's "in check" status effect up to date. Done
    -- LAST, after this tick's move (if any) has already been
    -- processed above, so a move that escapes check always has the
    -- final say for this tick: if updateCheckEffects ran first, a
    -- refresh landing on the very same tick as the escaping move
    -- could re-root the king moments before moveChessPiece tries to
    -- move it, swallowing the move and leaving the king stuck in
    -- check for the opponent to capture. Cheap enough to do in full
    -- every tick regardless - unlike the move scans above, it's just
    -- one attack check per piece, not per square.
    updateCheckEffects()
end