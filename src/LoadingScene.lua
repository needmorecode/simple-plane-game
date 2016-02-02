require "Cocos2d"
require "Cocos2dConstants"
require "AudioEngine"

require "SystemConst"

local size = cc.Director:getInstance():getWinSize()
local frameCache = cc.SpriteFrameCache:getInstance()
local textureCache = cc.Director:getInstance():getTextureCache()

local LoadingScene = class("LoadingScene",function()
    return cc.Scene:create()
end)

function LoadingScene.create()
    local scene = LoadingScene.new()
    scene:addChild(scene:createLayer())
    return scene
end


function LoadingScene:ctor()
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
function LoadingScene:createLayer()
    cclog("LoadingScene init")
    local layer = cc.Layer:create()

    frameCache:addSpriteFramesWithFile(loading_texture_plist)
    local bg = cc.TMXTiledMap:create("map/red_bg.tmx")
    layer:addChild(bg)

    local logo =  cc.Sprite:createWithSpriteFrameName("logo.png")
    layer:addChild(logo)
    logo:setPosition(cc.p(size.width/2, size.height/2))

    local sprite =  cc.Sprite:createWithSpriteFrameName("loding4.png")
    layer:addChild(sprite)
    local logoX,logoY = logo:getPosition()
    sprite:setPosition(cc.p(logoX, logoY - 130))

    ------------------动画开始----------------------
    local animation = cc.Animation:create()
    for i=1,4 do
        local frameName = string.format("loding%d.png",i)
        cclog("frameName = %s", frameName)
        local spriteFrame = frameCache:getSpriteFrameByName(frameName)
        animation:addSpriteFrame(spriteFrame)
    end

    animation:setDelayPerUnit(0.5)              --设置两个帧播放时间
    animation:setRestoreOriginalFrame(true)     --动画执行后还原初始状态

    local action = cc.Animate:create(animation)
    sprite:runAction(cc.RepeatForever:create(action))
    --------------------动画结束------------------

    local function loadingTextureCallBack(texture)

        frameCache:addSpriteFramesWithFile(texture_plist)
        cclog("loading textrue ok.")

        --初始化 音乐
        AudioEngine.preloadMusic(bg_music_1)
        AudioEngine.preloadMusic(bg_music_2)
        --初始化 音效
        AudioEngine.preloadEffect(sound_1)
        AudioEngine.preloadEffect(sound_2)

        local HomeScene = require("HomeScene")
        local scene = HomeScene.create()
        cc.Director:getInstance():pushScene(scene)

    end

    textureCache:addImageAsync(texture_res,loadingTextureCallBack)

    return layer
end

function LoadingScene:onEnter()
    cclog("LoadingScene onEnter")
end

function LoadingScene:onEnterTransitionFinish()
    cclog("LoadingScene onEnterTransitionFinish")
end

function LoadingScene:onExit()
    cclog("LoadingScene onExit")
end

function LoadingScene:onExitTransitionStart()
    cclog("LoadingScene onExitTransitionStart")
    --AudioEngine.stopMusic()
end

function LoadingScene:cleanup()
    cclog("LoadingScene cleanup")
end

return LoadingScene

