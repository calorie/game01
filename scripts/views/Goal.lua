
local EventProtocol = require("framework.api.EventProtocol")

local Goal = class("Goal", function()
    return display.newLayer()
end)

function Goal:ctor()
    EventProtocol.extend(self)

    self.sprite = display.newSprite("#Title.png", display.right - 150, display.top - 50)
    self.sprite:setScale(0.5)
    self:addChild(self.sprite)

    self:addEventListener("LEVEL_COMPLETED", handler(self, self.onLevelCompleted))
end

function Goal:getGoal()
    return self.sprite
end

function Goal:onLevelCompleted()
    audio.playEffect(GAME_SFX.levelCompleted)

    local dialog = display.newSprite("#LevelCompletedDialogBg.png")
    dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    self:addChild(dialog)

    transition.moveTo(dialog, {time = 0.7, y = display.top - dialog:getContentSize().height / 2 - 40, easing = "BOUNCEOUT"})
end

function Goal:removeAll()
    transition.stopTarget(self.sprite)
    self:removeAllEventListeners()
end

function Goal:onExit()
    self:removeAll()
end

return Goal
