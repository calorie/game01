
local Levels = {}
local levelsData = {}
local WALL_THICKNESS = 64 / 2

levelsData[1] = {
    walls = {
        {
            x = display.right - display.width / 4,
            y = display.cy,
            width = display.width / 2,
            height = WALL_THICKNESS
        }
    },
    enemies = {
        {
            x = display.cx + 50,
            y = display.cy + 100,
            speed = 1
        }
    }
}
levelsData[2] = {
    walls = {
        {
            x = display.left + display.width / 4,
            y = display.cy - display.height / 8,
            width = display.width / 2,
            height = WALL_THICKNESS
        },
        {
            x = display.right - display.width / 4,
            y = display.cy + display.height / 8,
            width = display.width / 2,
            height = WALL_THICKNESS
        }
    },
    enemies = {
        {
            x = display.cx + 50,
            y = display.cy + 150
        },
        {
            x = display.cx - 50,
            y = display.cy - 100
        }
    }
}
levelsData[3] = {
    walls = {
        {
            x = display.cx,
            y = display.cy,
            width = display.width,
            height = WALL_THICKNESS
        }
    },
    enemies = {
        {
            x = display.cx,
            y = display.cy + 50
        }
    }
}

function Levels.numLevels()
    return #levelsData
end

function Levels.get(levelIndex)
    assert(levelIndex >= 1 and levelIndex <= #levelsData, string.format("levelsData.get() - invalid levelIndex %s", tostring(levelIndex)))
    return clone(levelsData[levelIndex])
end

return Levels
