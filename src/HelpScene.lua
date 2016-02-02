require "Cocos2d"
require "Cocos2dConstants"

require "SystemConst"

local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local HelpScene = class("HelpScene",function()
    return cc.Scene:create()
end)

function HelpScene.create()
    local scene = HelpScene.new()
    scene:addChild(scene:createLayer())
    return scene
end

function HelpScene:ctor()

end

-- create layer
function HelpScene:createLayer()
    cclog("HelpScene init")
    local layer = cc.Layer:create()

    local bg = cc.TMXTiledMap:create("map/red_bg.tmx")
    layer:addChild(bg)

    --local top = cc.Sprite:createWithSpriteFrameName("help.page.png")
    --top:setPosition(cc.p(size.width/2, size.height - top:getContentSize().height /2))
    --layer:addChild(top)
    
    local size = cc.Director:getInstance():getWinSize()
    
    local rankTitle = cc.Label:createWithTTF("高分榜", "fonts/hanyi.ttf", 30)
    rankTitle:setAnchorPoint(cc.p(0,0))
    rankTitle:setColor(cc.c3b(255, 0, 0))
    --rankTitle:setColor(cc.c3b(75,255,255))
    rankTitle:setPosition(cc.p(110 , size.height - 60))
    layer:addChild(rankTitle)
    
    local titleX, titleY = rankTitle:getPosition()
    local currY = titleY - 40
    
    for i = 1, 10 do
        local score = defaults:getIntegerForKey(tostring(i), 0)
        
        local text = string.format("%d", i)
        local lblScore = cc.Label:createWithTTF(text, "fonts/hanyi.ttf", 25)
        lblScore:setAnchorPoint(cc.p(0,0))
        lblScore:setPosition(cc.p(90, currY))
        lblScore:setColor(cc.c3b(255, 0, 0))
        layer:addChild(lblScore)
        
        text = string.format("%d", score)
        lblScore = cc.Label:createWithTTF(text, "fonts/hanyi.ttf", 25)
        lblScore:setAnchorPoint(cc.p(0,0))
        lblScore:setPosition(cc.p(160, currY))
        lblScore:setColor(cc.c3b(0, 0, 255))
        layer:addChild(lblScore)
        currY = currY - 30
    end 



    --Ok菜单事件处理
    local function menuOkCallback(sender)
        --播放音效
        if defaults:getBoolForKey(SOUND_KEY) then
            AudioEngine.playEffect(sound_1)
        end
        cc.Director:getInstance():popScene()
    end

    --Ok菜单
    local okNormal = cc.Sprite:createWithSpriteFrameName("button.ok.png")
    local okSelected = cc.Sprite:createWithSpriteFrameName("button.ok-on.png")
    local okMenuItem = cc.MenuItemSprite:create(okNormal, okSelected)
    okMenuItem:registerScriptTapHandler(menuOkCallback)

    local okMenu = cc.Menu:create(okMenuItem)
    okMenu:setPosition(cc.p(190, 50))
    layer:addChild(okMenu)

    return layer
end

return HelpScene

