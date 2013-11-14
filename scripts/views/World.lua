
local EventProtocol = require("framework.api.EventProtocol")
local scheduler     = require("framework.scheduler")
local Player        = require("..views.Player")
local Ladder        = require("..views.Ladder")
local Goal          = require("..views.Goal")
local Wall          = require("..views.Wall")
local Enemy         = require("..views.Enemy")

local World = class("World", function()
    return display.newXTLayer()
end)

local GRAVITY          = -200
local IS_WORLD_CREATED = false

function World:ctor(levelData)
    EventProtocol.extend(self)

    self.levelData = levelData

    self.physicsWorld = CCPhysicsWorld:create(0, GRAVITY)
    self:addChild(self.physicsWorld)
    -- debug
    self.worldDebug = self.physicsWorld:createDebugNode()
    self:addChild(self.worldDebug)

    self.wallLayer = Wall.new(self.physicsWorld)
    self:addChild(self.wallLayer)

    self.playerLayer = Player.new(self.physicsWorld)
    self:addChild(self.playerLayer)

    self:setNodeEventEnabled(true)
    self:addTouchEventListener(function(event, x, y)
        return self:onTouch(event, x, y)
    end)

    self.physicsWorld:addCollisionScriptListener(
        handler(self, self.onCollisionListenerPlayerAndWall),
        Player.PLAYER_COLLISION_TYPE,
        Wall.WALL_COLLISION_TYPE)
    self.physicsWorld:addCollisionScriptListener(
        handler(self, self.onCollisionListenerPlayerAndEnemy),
        Player.PLAYER_COLLISION_TYPE,
        Enemy.ENEMY_COLLISION_TYPE)
    self.physicsWorld:addCollisionScriptListener(
        handler(self, self.onCollisionListenerWallAndEnemy),
        Wall.WALL_COLLISION_TYPE,
        Enemy.ENEMY_COLLISION_TYPE)
end

function World:onCollisionListenerPlayerAndWall(eventType, event)
    if eventType == "begin" then
        if not IS_WORLD_CREATED then
            self:addLayers()
            self:addEventListeners()
            self:addSchedulers()
            self:addLevels()
            IS_WORLD_CREATED = true
        end
    end
    return true
end

function World:onCollisionListenerPlayerAndEnemy(eventType, event)
    if eventType == "begin" then
        if not self.playerLayer.climbing then
            self:gameOver()
        end
    end
    return true
end

function World:onCollisionListenerWallAndEnemy(eventType, event)
    if eventType == "separate" then
        local direction = event:getBody2().tickDirection
        event:getBody2().tickDirection = direction * -1
    end
    return true
end

function World:removeAllLayers()
    self.playerLayer:removeAll()
    self.ladderLayer:removeAll()
    self.goalLayer:removeAll()
    self.wallLayer:removeAll()
    self.enemyLayer:removeAll()
    self:removeAll()
end

function World:gameOver()
    self:removeAllLayers()
end

function World:addLayers()
    self.ladderLayer = Ladder.new(self.physicsWorld)
    self:addChild(self.ladderLayer)

    self.enemyLayer = Enemy.new(self.physicsWorld, self.levelData)
    self:addChild(self.enemyLayer)

    self.goalLayer = Goal.new()
    self.goal = self.goalLayer:getGoal()
    self:addChild(self.goalLayer)
end

function World:addEventListeners()
end

function World:addSchedulers()
    local function collisions()
        self.player = self.playerLayer:getPlayer()
        if self.player == nil then return end
        local playerX, playerY = self.player:getPosition()
        self:collisionPlayerAndLadder(playerX, playerY)
        self:collisionPlayerAndGoal(playerX, playerY)
    end
    self.collisionsScheduler = scheduler.scheduleUpdateGlobal(collisions)
end

function World:addLevels()
    self.wallLayer:level(self.levelData.walls)
end

function World:collisionPlayerAndLadder(playerX, playerY)
    if self.ladderLayer == nil then return end
    if self.playerLayer.climbing then return end
    self.ladders = self.ladderLayer:getLadders()
    if self.ladders == nil or next(self.ladders) == nil then return end
    for i, ladder in pairs(self.ladders) do
        for j, ladderBlock in pairs(ladder) do
            local ladderBlockRect = ladderBlock:getBoundingBox()
            local ladderBlockX = ladderBlockRect.origin.x
            local ladderBlockWidth = ladderBlockRect.size.width
            if playerX < ladderBlockX - ladderBlockWidth or
                playerX > ladderBlockX + ladderBlockWidth then
                break
            end
            local playerRect = self.player:getBoundingBox()
            if ladderBlockRect:containsPoint(CCPoint(playerX - self.playerLayer.tickDirection * ladderBlockWidth / 2, playerY)) then
                local dist = ladderBlockRect.size.height * (#ladder - j + 1)
                self.playerLayer:climb(playerX, playerY, dist)
                break
            end
        end
        if self.playerLayer.climbing then break end
    end
end

function World:collisionPlayerAndGoal(playerX, playerY)
    if self.goalLayer == nil then return end
    local goalRect = self.goal:getBoundingBox()
    if goalRect:containsPoint(CCPoint(playerX, playerY)) then
        self.goalLayer:dispatchEvent({name = "LEVEL_COMPLETED"})
        self:removeAllLayers()
    end
end

function World:onTouch(event, x, y)
    if event == "began" then
        self:onTouchBegan(event, x, y)
        return true
    elseif event == "moved" then
        self:onTouchMoved(event, x, y)
    elseif event == "ended" then
        self:onTouchEnded(event, x, y)
    else
    end
end

function World:onSwipeGesture(x, y, direction, distance, speed)
    if not IS_WORLD_CREATED then return end
    if direction == "right" then
        self.wallLayer:createWall(x, y, direction, distance, self.ladderLayer:getLadders())
    elseif direction == "left" then
        self.wallLayer:createWall(x, y, direction, distance, self.ladderLayer:getLadders())
    elseif direction == "up" then
        self.ladderLayer:createLadder(x, y, distance, self.wallLayer:getWalls())
    end
end

function World:onEnter()
    self:setTouchEnabled(true)
    self.physicsWorld:start()
end

function World:onExit()
    self:removeAll()
end

function World:removeAll()
    IS_WORLD_CREATED = false
    self:setTouchEnabled(false)
    self:removeAllEventListeners()
    self.physicsWorld:stop()
    if self.collisionsScheduler then
        scheduler.unscheduleGlobal(self.collisionsScheduler)
    end
end

return World
