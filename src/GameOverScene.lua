require "Cocos2d"
require "Cocos2dConstants"

require "SystemConst"

local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()
local listener

local GameOverScene = class("GameOverScene",function()
    return cc.Scene:create()
end)

function GameOverScene.create(score)
    local scene = GameOverScene.new(score)
    scene:addChild(scene:createLayer())
    return scene
end

function GameOverScene:ctor(score)

    self.score = score

    --场景生命周期事件处理
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "enterTransitionFinish" then
            self:onEnterTransitionFinish()
        elseif event == "exit" then
            self:onExit()
        elseif event == "exitTransitionStart" then
            self:onExitTransitionStart()
        elseif event == "cleanup" then
            self:cleanup()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

-- create layer
function GameOverScene:createLayer()
    cclog("GameOverScene init")
    local layer = cc.Layer:create()
    --local layColor = cc.LayerColor:create(ccc4(255, 255, 255, 255))
    --layer:addChild(layColor)
    --layer:setColor(cc.c3b(255, 255, 255))
    --local layer = CCLayerColor:create(ccc4(0, 0, 255, 255))  

    --添加背景地图.
    local bg = cc.TMXTiledMap:create("map/blue_bg.tmx")
    layer:addChild(bg)

    --放置发光粒子背景
    local ps = cc.ParticleSystemQuad:create("particle/light.plist")
    ps:setPosition(cc.p(size.width/2, size.height/2  - 100))
    layer:addChild(ps)

    local top = cc.Sprite:createWithSpriteFrameName("gameover.page.png")
    --锚点在左下角
    top:setAnchorPoint(cc.p(0,0))
    top:setScale(0.8)
    top:setPosition(cc.p(45, size.height - top:getContentSize().height * 0.8))
    layer:addChild(top)

    local defaults = cc.UserDefault:getInstance()
    local highScore = defaults:getIntegerForKey(HIGHSCORE_KEY, 0)
    if highScore < self.score then
        highScore = self.score
        defaults:setIntegerForKey(HIGHSCORE_KEY,highScore)
    end
    
    -- 插入自己的排名
    local yourRank = 11
    for i = 10, 1, -1 do
        local score = defaults:getIntegerForKey(tostring(i), 0)
        if self.score > score then
            yourRank = i
        end
    end 
    for i = 10, yourRank + 1, -1 do
        local score = defaults:getIntegerForKey(tostring(i - 1), 0)
        defaults:setIntegerForKey(tostring(i), score)
    end
    defaults:setIntegerForKey(tostring(yourRank), self.score)

    local lblHighScore = cc.Label:createWithTTF("总分：", "fonts/hanyi.ttf", 30)
    lblHighScore:setAnchorPoint(cc.p(0,0))
    --lblHighScore:setColor(cc.c3b(255, 0, 0))
    lblHighScore:setColor(cc.c3b(75,255,255))
    local topX,topY = top:getPosition()
    lblHighScore:setPosition(cc.p(90 , topY - 30))
    layer:addChild(lblHighScore)

    local text = string.format("%i", self.score)
    local lblScore = cc.Label:createWithTTF(text, "fonts/hanyi.ttf", 29)
    --lblScore:setColor(cc.c3b(75,255,255))
    lblScore:setAnchorPoint(cc.p(0,0))
    local lblHighScoreX,lblHighScoreY = lblHighScore:getPosition()
    lblScore:setPosition(cc.p(lblHighScoreX + 80, lblHighScoreY))
    layer:addChild(lblScore)
    
    -----------------
    
    local sprite1 = cc.Sprite:createWithSpriteFrameName(EnemyName.Enemy_2)
    sprite1:setPosition(cc.p(40, lblHighScoreY - 40))
    sprite1:setScale(0.5)
    layer:addChild(sprite1)
    
    local hitNum1 = cc.Label:createWithTTF(gHitEnemy2Num, "fonts/hanyi.ttf", 24)
    --lblScore:setColor(cc.c3b(75,255,255))
    local sprite1X, sprite1Y = sprite1:getPosition()
    hitNum1:setPosition(cc.p(sprite1X + 60, sprite1Y))
    layer:addChild(hitNum1)   
    
    ----------------- 
   
    local sprite2 = cc.Sprite:createWithSpriteFrameName(EnemyName.Enemy_1)
    sprite2:setPosition(cc.p(40, sprite1Y - 60))
    sprite2:setScale(0.5)
    layer:addChild(sprite2)

    local hitNum2 = cc.Label:createWithTTF(gHitEnemy1Num, "fonts/hanyi.ttf", 24)
    --lblScore:setColor(cc.c3b(75,255,255))
    local sprite2X, sprite2Y = sprite2:getPosition()
    hitNum2:setPosition(cc.p(sprite2X + 60, sprite2Y))
    layer:addChild(hitNum2) 
    
    ----------------- 

    local sprite3 = cc.Sprite:createWithSpriteFrameName(EnemyName.Enemy_Stone)
    sprite3:setPosition(cc.p(200, sprite1Y))
    sprite3:setScale(0.5)
    layer:addChild(sprite3)

    local hitNum3 = cc.Label:createWithTTF(gHitStoneNum, "fonts/hanyi.ttf", 24)
    --lblScore:setColor(cc.c3b(75,255,255))
    local sprite3X, sprite3Y = sprite3:getPosition()
    hitNum3:setPosition(cc.p(sprite3X + 60, sprite3Y))
    layer:addChild(hitNum3) 
    
    ----------------- 

    local sprite4 = cc.Sprite:createWithSpriteFrameName(EnemyName.Enemy_Planet)
    sprite4:setPosition(cc.p(200, sprite3Y - 60))
    sprite4:setScale(0.5)
    layer:addChild(sprite4)

    local hitNum4 = cc.Label:createWithTTF(gHitPlanetNum, "fonts/hanyi.ttf", 24)
    --lblScore:setColor(cc.c3b(75,255,255))
    local sprite4X, sprite4Y = sprite4:getPosition()
    hitNum4:setPosition(cc.p(sprite4X + 60, sprite4Y))
    layer:addChild(hitNum4) 
    
    
        
--    local text2 = cc.Label:createWithTTF("Tap the Screen to Play", "fonts/hanyi.ttf", 24)
--    text2:setAnchorPoint(cc.p(0,0))
--    local lblScoreX,lblScoreY = lblScore:getPosition()
--    text2:setPosition(cc.p(lblScoreX - 10, lblScoreY - 45))
--    layer:addChild(text2)
    
    

    --接触事件回调函数
    local function touchBegan(touch, event)
        --播放音效
        if defaults:getBoolForKey(SOUND_KEY)  then
            AudioEngine.playEffect(sound_1)
        end
        cc.Director:getInstance():popScene()
        return false
    end

    --注册 触摸事件监听器
    listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    -- EVENT_TOUCH_BEGAN事件回调函数
    listener:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN)

    -- 添加 触摸事件监听器
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    return layer
end


function GameOverScene:onEnter()
    cclog("GameOverScene onEnter")
end

function GameOverScene:onEnterTransitionFinish()
    cclog("GameOverScene onEnterTransitionFinish")
end

function GameOverScene:onExit()
    cclog("GameOverScene onExit")
    if nil ~= listener then
        cc.Director:getInstance():getEventDispatcher():removeEventListener(listener)
    end
end

function GameOverScene:onExitTransitionStart()
    cclog("GameOverScene onExitTransitionStart")
end

function GameOverScene:cleanup()
    cclog("GameOverScene cleanup")
end


return GameOverScene

