
require "socket"
local scheduler = require("framework.scheduler")

local XTLayer = class("XTLayer", CCLayerExtend)
XTLayer.__index = XTLayer

local _xtSwipeThreshold  = 10
local _xtSwipeTime       = 1000
local _xtLongTapTime     = 1000
local _xtTouchHasMoved   = false
local _xtTouchStartTime  = 0
local _xtTouchStartX     = 0
local _xtTouchStartY     = 0
local function fabs(n) return math.abs(n) end

function XTLayer:millisecondNow()
    return socket.gettime() * 1000
end

function XTLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, XTLayer)
    return target
end

function XTLayer:onTouchBegan(event, x, y)
    _xtTouchHasMoved = false
    _xtTouchStartTime = self:millisecondNow()
    _xtTouchStartX = x
    _xtTouchStartY = y
end

function XTLayer:onTouchMoved(event, x, y)
    _xtTouchHasMoved = true
end

function XTLayer:onTouchEnded(event, x, y)
    local endTime = self:millisecondNow()
    local deltaTime = endTime - _xtTouchStartTime
    local deltaX = x - _xtTouchStartX
    local deltaY = y - _xtTouchStartY
    local positiveDeltaX = fabs(deltaX)
    local positiveDeltaY = fabs(deltaY)

    local horizontalDistancePercentage = fabs((deltaX / display.width) * 100)
    local vertivalDistancePercentage = fabs((deltaY / display.height) * 100)
    local function isHorizontal()
        return positiveDeltaX > positiveDeltaY and horizontalDistancePercentage > _xtSwipeThreshold and deltaTime < _xtSwipeTime
    end
    local function isVertical()
        return positiveDeltaX < positiveDeltaY and vertivalDistancePercentage > _xtSwipeThreshold and deltaTime < _xtSwipeTime
    end
    local speed = 0
    if isHorizontal() then
        if deltaX < 0 then
            _xtTouchDirection = "left"
        elseif deltaX > 0 then
            _xtTouchDirection = "right"
        end
        speed = fabs(deltaX) / deltaTime
        self:onSwipeGesture(x, y, _xtTouchDirection, positiveDeltaX, speed)
    elseif isVertical() then
        if deltaY < 0 then
            _xtTouchDirection = "down"
        elseif deltaY > 0 then
            _xtTouchDirection = "up"
        end
        speed = fabs(deltaY) / deltaTime
        self:onSwipeGesture(x, y, _xtTouchDirection, positiveDeltaY, speed)
    elseif deltaTime >= _xtLongTapTime then
        self:onLongTapGesture(x, y, deltaTime)
    else
    end
end

function XTLayer:onTouch(event, x, y)
    if event == "began" then
        self:onTouchBegan(event, x, y)
    elseif event == "moved" then
        self:onTouchMoved(event, x, y)
    elseif event == "ended" then
        self:onTouchEnded(event, x, y)
    else
    end
end


function XTLayer:onSwipeGesture(x, y, direction, distance, speed)
end

function XTLayer:onLongTapGesture(x, y, deltaTime)
end

function display.newXTLayer()
    layer = XTLayer.extend(CCLayer:create())
    layer.super = XTLayer
    return layer
end
