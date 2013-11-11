
local Levels = import("..data.Levels")
local Player = require("..views.Player")
local Ladder = require("..views.Ladder")

local PlayWallScene = class("PlayWallScene", function()
    return display.newScene("PlayWallScene")
end)

function PlayWallScene:ctor()
    local bg = display.newSprite("#PlayLevelSceneBg.png")
    -- make background sprite always align top
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg)

    self.player = Player.new()
    self:addChild(self.player)

    self.ladder = Ladder.new()
    self:addChild(self.ladder)

    -- create menu
    local backButton = ui.newImageMenuItem({
        image = "#BackButton.png",
        imageSelected = "#BackButtonSelected.png",
        x = display.cx,
        y = display.bottom + 30,
        sound = GAME_SFX.backButton,
        listener = function()
            game.enterMenuScene()
        end,
    })

    local menu = ui.newMenu({backButton})
    self:addChild(menu)
end

function PlayWallScene:onLevelCompleted()
    audio.playEffect(GAME_SFX.levelCompleted)

    local dialog = display.newSprite("#LevelCompletedDialogBg.png")
    dialog:setPosition(display.cx, display.top + dialog:getContentSize().height / 2 + 40)
    self:addChild(dialog)

    transition.moveTo(dialog, {time = 0.7, y = display.top - dialog:getContentSize().height / 2 - 40, easing = "BOUNCEOUT"})
end

function PlayWallScene:onEnter()
end

return PlayWallScene
