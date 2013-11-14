
local EventProtocol = require("framework.api.EventProtocol")
local scheduler     = require("framework.scheduler")

local Player = class("Player", function()
    return display.newLayer()
end)

local GRAVITY                 = -200
local PLAYER_MASS             = 100
local PLAYER_RADIUS           = 46
local PLAYER_FRAME_WIDTH      = 105
local PLAYER_HALF_FRAME_WIDTH = PLAYER_FRAME_WIDTH / 2
local PLAYER_FRAME_HEIGHT     = 95
Player.PLAYER_SPEED           = 3
Player.PLAYER_COLLISION_TYPE  = 1

function Player:ctor(currentWorld)
    EventProtocol.extend(self)

    -- create touch layer
    self:addTouchEventListener(function(event, x, y)
        return self:onTouch(event, x, y)
    end)
    self:setNodeEventEnabled(true)

    self.sprite = nil

    -- create batch node
    self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE_FILENAME)
    self:addChild(self.batch)

    self.world = currentWorld
end

function Player:getPlayer()
    return self.sprite
end

function Player:createSprite(x, y)
    -- add sprite to scene
    local texturePlayer = CCTextureCache:sharedTextureCache():addImage("dog.png")
    local rect = CCRect(0, 0, PLAYER_FRAME_WIDTH, PLAYER_FRAME_HEIGHT)
    local frame0 = CCSpriteFrame:createWithTexture(texturePlayer, rect)
    rect = CCRect(PLAYER_FRAME_WIDTH, 0, PLAYER_FRAME_WIDTH, PLAYER_FRAME_HEIGHT)
    local frame1 = CCSpriteFrame:createWithTexture(texturePlayer, rect)
    local animFrames = CCArray:create()
    animFrames:addObject(frame0)
    animFrames:addObject(frame1)
    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.5)

    local spritePlayer = CCSprite:createWithSpriteFrame(frame0)
    transition.playAnimationForever(spritePlayer, animation)

    -- moving player at every frame
    self.tickDirection = 1
    local rightWall = CCRect(display.right, 0, 10, display.height)
    local leftWall = CCRect(display.left - 10, 0, 10, display.height)
    local function tick()
        if not self.sprite then return end
        if self.isPaused then return end
        if rightWall:containsPoint(ccp(x + PLAYER_HALF_FRAME_WIDTH / 2, y)) or
            leftWall:containsPoint(ccp(x - PLAYER_HALF_FRAME_WIDTH / 2, y)) then
            self.tickDirection = self.tickDirection * -1
        end
        x = x + self.PLAYER_SPEED * self.tickDirection

        self.spriteBody:setPositionX(x)
        self.sprite:setPositionX(x)
    end
    self.tickScheduler = scheduler.scheduleUpdateGlobal(tick)

    -- create body
    self.spriteBody = self.world:createCircleBody(PLAYER_MASS, PLAYER_RADIUS)
    -- binding sprite to body
    self.spriteBody:bind(spritePlayer)
    -- set body position
    self.spriteBody:setPosition(x, y)
    self.spriteBody:setCollisionType(self.PLAYER_COLLISION_TYPE)

    return spritePlayer
end

function Player:climb(playerX, playerY, dist)
    self.climbing = true
    self.isPaused = true
    self.spriteBody:unbind()
    playerY = playerY + dist
    self.sprite:runAction(transition.sequence({
        CCMoveTo:create(dist / 300, CCPoint(playerX, playerY)),
        CCCallFunc:create(function() self.isPaused = false end),
        CCJumpTo:create(0.5, CCPoint(playerX, playerY + 70), 100, 1),
        CCCallFunc:create(function()
            local x, y = self.sprite:getPosition()
            self.spriteBody:setPosition(x, y)
            self.spriteBody:bind(self.sprite)
            self.climbing = false
        end),
    }))
end

function Player:onTouch(event, x, y)
    if event == "began" then
        if self.sprite == nil then
            self.sprite = self:createSprite(x, y)
            self:addChild(self.sprite)
        end
    end
end

function Player:removeAll()
    self:setTouchEnabled(false)
    transition.stopTarget(self.sprite)
    self.sprite = nil
    self:removeAllEventListeners()
    if self.tickScheduler then
        scheduler.unscheduleGlobal(self.tickScheduler)
    end
end

function Player:onEnter()
    self:setTouchEnabled(true)
end

function Player:onExit()
    self:removeAll()
end

return Player
