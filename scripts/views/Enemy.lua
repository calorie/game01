
local EventProtocol = require("framework.api.EventProtocol")
local scheduler     = require("framework.scheduler")

local Enemy = class("Enemy", function()
    return display.newLayer()
end)

Enemy.ENEMY_SPEED          = 3
Enemy.ENEMY_COLLISION_TYPE = 4
local ENEMY_MASS           = 100
local ENEMY_RADIUS         = 46

function Enemy:ctor(currentWorld, levelData)
    EventProtocol.extend(self)
    self:setNodeEventEnabled(true)

    self.world = currentWorld
    self.tickSchedulers = {}

    self:createEnemy(levelData.enemies)
end

function Enemy:createEnemy(enemies)
    for i, enemy in pairs(enemies) do
        local x, y, speed = enemy.x, enemy.y, enemy.speed
        local sprite = display.newSprite("#Coin0001.png")
        sprite:setPosition(x, y)
        local spriteBody = self.world:createCircleBody(ENEMY_MASS, ENEMY_RADIUS)
        spriteBody:bind(sprite)
        spriteBody:setPosition(x, y)
        spriteBody:setCollisionType(self.ENEMY_COLLISION_TYPE)

        spriteBody.tickDirection = 1
        local function tick()
            if self.isPaused then return end
            if speed == nil then speed = self.ENEMY_SPEED end
            x = x + speed * spriteBody.tickDirection
            spriteBody:setPositionX(x)
            sprite:setPositionX(x)
        end
        local tickScheduler = scheduler.scheduleUpdateGlobal(tick)
        table.insert(self.tickSchedulers, tickScheduler)
        self:addChild(sprite)
    end
end

function Enemy:onEnter()
    self:setTouchEnabled(true)
end

function Enemy:onExit()
    self:removeAll()
end

function Enemy:removeAll()
    self:setTouchEnabled(false)
    self:removeAllEventListeners()
    for i, s in pairs(self.tickSchedulers) do
        if s ~= nil then scheduler.unscheduleGlobal(s) end
    end
end

return Enemy
