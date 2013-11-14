
local EventProtocol = require("framework.api.EventProtocol")

local Ladder = class("Ladder", function()
    return display.newXTLayer()
end)
Ladder.LADDER_HEIGHT         = 68
Ladder.LADDER_WIDTH          = 88
Ladder.LADDER_FRICTION       = 1.0
Ladder.LADDER_ELASTICITY     = 0
Ladder.LADDER_COLLISION_TYPE = 3

function Ladder:ctor(currentWorld)
    EventProtocol.extend(self)

    self.sprites = {}
    self.world = currentWorld

    self:setNodeEventEnabled(true)
end

function Ladder:getLadders()
    return self.sprites
end

function Ladder:createLadder(x, y, distance, walls)
    -- TODO batch
    local ladderHeight = self.LADDER_HEIGHT
    local ladderWidth = self.LADDER_WIDTH
    local startDistance = distance - ladderHeight / 2
    local loopNum = math.floor(startDistance / ladderHeight)
    local ladder = {}
    for i = 0, loopNum do
        local cx, cy = x, y - startDistance + ladderHeight * i
        local ladderBlock = display.newSprite("ladder_block.png")
        ladderBlock:setPosition(cx, cy)
        table.insert(ladder, ladderBlock)
        self:addChild(ladderBlock)
        -- local ladderBody = self.world:createBoxBody(0, ladderWidth / 2, ladderHeight)
        -- ladderBody:setPosition(cx, cy)
        -- ladderBody:setFriction(self.LADDER_FRICTION)
        -- ladderBody:setElasticity(self.LADDER_ELASTICITY)
        -- ladderBody:bind(ladderBlock)
        -- ladderBody:setCollisionType(self.LADDER_COLLISION_TYPE)
        -- self.world:addBody(ladderBody)
        local ladderBlockRect = ladderBlock:getBoundingBox()
        local isBreak = false
        for j, wall in pairs(walls) do
            local wallRect = wall:getBoundingBox()
            if CCRect.intersectsRect(wallRect, ladderBlockRect)  and
                not (i == 0 and y - startDistance > wallRect.origin.y) then
                isBreak = true
                break
            end
        end
        if isBreak then break end
    end
    table.insert(self.sprites, ladder)
end

function Ladder:removeAll()
    self:setTouchEnabled(false)
    self:removeAllEventListeners()
end

function Ladder:onEnter()
    self:setTouchEnabled(true)
end

function Ladder:onExit()
    self:removeAll()
end

return Ladder
