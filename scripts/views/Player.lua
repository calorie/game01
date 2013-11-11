
local EventProtocol = require("framework.api.EventProtocol")
local scheduler = require("framework.scheduler")

local Player = class("Player", function()
    return display.newLayer()
end)
Player.player = nil

local GRAVITY         = -200
local PLAYER_MASS     = 100
local PLAYER_RADIUS   = 46
local COIN_FRICTION   = 0.8
local COIN_ELASTICITY = 0.8
local WALL_THICKNESS  = 64
local WALL_FRICTION   = 1.0
local WALL_ELASTICITY = 0
local PLAYER_FRAME_WIDTH = 105
local PLAYER_FRAME_HEIGHT = 95

function Player:ctor()
    EventProtocol.extend(self)

    -- create touch layer
    self:addTouchEventListener(function(event, x, y)
        return self:onTouch(event, x, y)
    end)
    self:setNodeEventEnabled(true)

    -- create batch node
    self.batch = display.newBatchNode(GAME_TEXTURE_IMAGE_FILENAME)
    self:addChild(self.batch)

    -- create physics world
    self.world = CCPhysicsWorld:create(0, GRAVITY)
    -- add world to scene
    self:addChild(self.world)

    local bottomWallSprite = display.newSprite("#AdBar.png")
    self.batch:addChild(bottomWallSprite)
    local bottomWallBody = self.world:createBoxBody(0, display.width, WALL_THICKNESS)
    bottomWallBody:setFriction(WALL_FRICTION)
    bottomWallBody:setElasticity(WALL_ELASTICITY)
    bottomWallBody:bind(bottomWallSprite)
    bottomWallBody:setPosition(display.cx, display.bottom + WALL_THICKNESS / 2)
end

function Player:createPlayer(x, y)
    -- add sprite to scene
    local texturePlayer = CCTextureCache:sharedTextureCache():addImage("dog.png")
    local rect = CCRectMake(0, 0, PLAYER_FRAME_WIDTH, PLAYER_FRAME_HEIGHT)
    local frame0 = CCSpriteFrame:createWithTexture(texturePlayer, rect)
    rect = CCRectMake(PLAYER_FRAME_WIDTH, 0, PLAYER_FRAME_WIDTH, PLAYER_FRAME_HEIGHT)
    local frame1 = CCSpriteFrame:createWithTexture(texturePlayer, rect)

    local spritePlayer = CCSprite:createWithSpriteFrame(frame0)

    local animFrames = CCArray:create()

    animFrames:addObject(frame0)
    animFrames:addObject(frame1)

    local animation = CCAnimation:createWithSpriteFrames(animFrames, 0.5)
    local animate = CCAnimate:create(animation)
    spritePlayer:runAction(CCRepeatForever:create(animate))

    -- moving player at every frame
    local direction = 1
    local function tick()
        if not Player.player then return end
        if Player.player.isPaused then return end
        if x > display.width or x < 0 then
          direction = direction * -1
        end
        x = x + 3 * direction

        Player.player:setPositionX(x)
    end

    scheduler.scheduleUpdateGlobal(tick)

    -- create body
    local playerBody = self.world:createCircleBody(PLAYER_MASS, PLAYER_RADIUS)
    -- playerBody:setFriction(COIN_FRICTION)
    -- playerBody:setElasticity(COIN_ELASTICITY)
    -- binding sprite to body
    playerBody:bind(spritePlayer)
    -- set body position
    playerBody:setPosition(x, y)

    return spritePlayer
end

function Player:onTouch(event, x, y)
    if event == "began" then
        if Player.player == nil then
            Player.player = self:createPlayer(x, y)
            self:addChild(Player.player)
        end
    end
end

function Player:onEnter()
    self:setTouchEnabled(true)
    self.world:start()
end

function Player:onExit()
    Player.player = nil
    self:removeAllEventListeners()
end

return Player
