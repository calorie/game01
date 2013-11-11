
local EventProtocol = require("framework.api.EventProtocol")

local Ladder = class("Ladder", function()
    return display.newXTLayer()
end)

function Ladder:ctor()
    EventProtocol.extend(self)

    -- create touch layer
    self:addTouchEventListener(function(event, x, y)
        return self:onTouch(event, x, y)
    end)
    self:setNodeEventEnabled(true)
end

function Ladder:onSwipeGesture(x, y, direction, distance, speed)
    if direction == "up" then
        local ladder = CCSprite:create("ladder_block.png")
        local ladderHeight = ladder:getCascadeBoundingBox().size.height
        local startDistance = distance - ladderHeight / 2
        for i = 0, math.floor(startDistance / ladderHeight) do
            ladder = CCSprite:create("ladder_block.png")
            ladder:setPosition(x, y - startDistance + ladderHeight * i)
            self:addChild(ladder)
        end
    end
end

function Ladder:onTouchBegan(event, x, y)
    self.super:onTouchBegan(event, x, y)
end

function Ladder:onTouch(event, x, y)
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

function Ladder:onEnter()
    self:setTouchEnabled(true)
end

function Ladder:onExit()
    self:removeAllEventListeners()
end

return Ladder
