
local World       = require("..views.World")
local WorldLevels = require("..data.WorldLevels")

local PlayWallScene = class("PlayWallScene", function()
    return display.newScene("PlayWallScene")
end)

function PlayWallScene:ctor(levelIndex)
    local bg = display.newSprite("#PlayLevelSceneBg.png")
    bg:setPosition(display.cx, display.top - bg:getContentSize().height / 2)
    self:addChild(bg)

    self.world = World.new(WorldLevels.get(levelIndex))
    self:addChild(self.world)

    -- create menu
    local backButton = ui.newImageMenuItem({
        image = "#BackButton.png",
        imageSelected = "#BackButtonSelected.png",
        x = display.cx,
        y = display.bottom + 30,
        sound = GAME_SFX.backButton,
        listener = function()
            game.enterChooseLevelScene()
        end,
    })
    local menu = ui.newMenu({backButton})
    self:addChild(menu)
end

return PlayWallScene
