
local EventProtocol = require("framework.api.EventProtocol")

local Wall = class("Wall", function()
    return display.newXTLayer()
end)

Wall.WALL_COLLISION_TYPE = 2
local WALL_THICKNESS     = 64
local WALL_FRICTION      = 1.0
local WALL_ELASTICITY    = 0

function Wall:ctor(currentWorld)
    EventProtocol.extend(self)
    self:setNodeEventEnabled(true)

    self.world = currentWorld
    self.walls = {}
    self:bottomWall()
end

function Wall:staticWall(x, y, width, height)
    if height == nil then height = WALL_THICKNESS end

    local sprite = display.newSprite("#AdBar.png")
    sprite:setPosition(CCPoint(x, y))
    sprite:setScaleX(width / sprite:getContentSize().width)
    sprite:setScaleY(height / sprite:getContentSize().height)

    local wallBody = self.world:createBoxBody(0, width, height)
    wallBody:setFriction(WALL_FRICTION)
    wallBody:setElasticity(WALL_ELASTICITY)
    wallBody:bind(sprite)
    wallBody:setPosition(x, y)
    wallBody:setCollisionType(self.WALL_COLLISION_TYPE)
    self.world:addBody(wallBody)

    self:addChild(sprite)
    return sprite
end

function Wall:bottomWall()
    self:staticWall(display.cx, display.bottom + WALL_THICKNESS / 2, display.width, WALL_THICKNESS)
end

function Wall:topWall()
    self:staticWall(display.cx, display.top + WALL_THICKNESS / 2, display.width, WALL_THICKNESS)
end

function Wall:level(levelWalls)
    -- TODO batch
    for i, wall in pairs(levelWalls) do
        local sprite = self:staticWall(wall.x, wall.y, wall.width, wall.height)
        self:setWall(sprite)
    end
end
function Wall:createWall(x, y, direction, distance, ladders)
    local ladderHeight
    local ladderWidth
    local collidedLadderX
    local cy, width = y, distance
    local cx
    if direction == "left" then
        cx = x + distance / 2
    elseif direction == "right" then
        cx = x - distance / 2
    end
    for i, ladder in pairs(ladders) do
        for j, ladderBlock in pairs(ladder) do
            if ladderHeight == nil or ladderWidth == nil then
                ladderHeight = ladderBlock:getContentSize().height
                ladderWidth = ladderBlock:getContentSize().width
            end
            local lx, ly = ladderBlock:getPosition()

            -- collision with ladder
            if direction == "left" then
                local startX = x + distance
                if lx < x or lx > startX then break end
                if startX > lx - ladderWidth / 2 and startX < lx + ladderWidth / 2 then return end
                if y > ly - ladderHeight / 2 and y < ly + ladderHeight / 2 then
                    if collidedLadderX == nil or lx > collidedLadderX then
                        width = startX - lx - ladderWidth / 2
                        cx = startX - width / 2
                        collidedLadderX = lx
                    end
                    break
                end
            elseif direction == "right" then
                local startX = x - distance
                if lx > x or lx < startX then break end
                if startX > lx - ladderWidth / 2 and startX < lx + ladderWidth / 2 then return end
                if y > ly - ladderHeight / 2 and y < ly + ladderHeight / 2 then
                    if collidedLadderX == nil or lx < collidedLadderX then
                        width = lx - startX - ladderWidth / 2
                        cx = startX + width / 2
                        collidedLadderX = lx
                    end
                    break
                end
            end
        end
    end
    local sprite = self:staticWall(cx, cy, width, WALL_THICKNESS / 2)
    self:setWall(sprite)
end

function Wall:setWall(wall)
    table.insert(self.walls, wall)
end

function Wall:getWalls()
    return self.walls
end

function Wall:onEnter()
    self:setTouchEnabled(true)
end

function Wall:onExit()
    self:removeAll()
end

function Wall:removeAll()
    self:setTouchEnabled(false)
    self:removeAllEventListeners()
end

return Wall
