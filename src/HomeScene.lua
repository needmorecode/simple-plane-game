require "Cocos2d"
require "Cocos2dConstants"

require "SystemConst"

local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local HomeScene = class("HomeScene",function()
    return cc.Scene:create()
end)

function HomeScene.create()
    local scene = HomeScene.new()
    scene:addChild(scene:createLayer())
    return scene
end

function HomeScene:ctor()
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
function HomeScene:createLayer()
    cclog("HomeScene init")
    local layer = cc.Layer:create()

    local bg = cc.TMXTiledMap:create("map/red_bg.tmx")
    layer:addChild(bg)

    local top =  cc.Sprite:createWithSpriteFrameName("home-top.png")
    layer:addChild(top)
    top:setPosition(cc.p(size.width/2, size.height - top:getContentSize().height / 2))

    local buttom = cc.Sprite:createWithSpriteFrameName("home-end.png")
    buttom:setPosition(cc.p(size.width/2, buttom:getContentSize().height / 2))
    layer:addChild(buttom)

    local function menuItemCallback(tag, sender)
        --播放音效
        if defaults:getBoolForKey(SOUND_KEY) then
            AudioEngine.playEffect(sound_1)
        end

        if tag == HomeMenuActionTypes.MenuItemStart then
            local GamePlayScene = require("GamePlayScene")
            local scene = GamePlayScene.create()
            local ts = cc.TransitionCrossFade:create(1, scene)
            cc.Director:getInstance():pushScene(ts)
        elseif tag == HomeMenuActionTypes.MenuItemSetting then
            local SettingScene = require("SettingScene")
            local scene = SettingScene.create()
            local ts = cc.TransitionCrossFade:create(1, scene)
            cc.Director:getInstance():pushScene(ts)
        else
            local HelpScene = require("HelpScene")
            local scene = HelpScene.create()
            local ts = cc.TransitionCrossFade:create(1, scene)
            cc.Director:getInstance():pushScene(ts)
        end

    end

    -- 开始菜单
    local startSpriteNormal = cc.Sprite:createWithSpriteFrameName("button.start.png")
    local startSpriteSelected = cc.Sprite:createWithSpriteFrameName("button.start-on.png")
    local startMenuItem = cc.MenuItemSprite:create( startSpriteNormal,  startSpriteSelected)
    startMenuItem:registerScriptTapHandler(menuItemCallback)
    startMenuItem:setTag(HomeMenuActionTypes.MenuItemStart)

    -- 设置菜单
    local settingSpriteNormal = cc.Sprite:createWithSpriteFrameName("button.setting.png")
    local settingSpriteSelected = cc.Sprite:createWithSpriteFrameName("button.setting-on.png")
    local settingMenuItem = cc.MenuItemSprite:create( settingSpriteNormal, settingSpriteSelected)
    settingMenuItem:registerScriptTapHandler(menuItemCallback)
    settingMenuItem:setTag(HomeMenuActionTypes.MenuItemSetting)

    -- 帮助菜单
    local helppriteNormal = cc.Sprite:createWithSpriteFrameName("button.help.png")
    local helpSpriteSelected = cc.Sprite:createWithSpriteFrameName("button.help-on.png")
    local helpMenuItem = cc.MenuItemSprite:create(  helppriteNormal,  helpSpriteSelected)
    helpMenuItem:registerScriptTapHandler(menuItemCallback)
    helpMenuItem:setTag(HomeMenuActionTypes.MenuItemHelp)

    local mu = cc.Menu:create(startMenuItem, settingMenuItem, helpMenuItem)

    mu:setPosition(size.width/2, size.height/2)
    mu:alignItemsVerticallyWithPadding(12)
    layer:addChild(mu)

    return layer
end


function HomeScene:onEnter()
    cclog("HomeScene onEnter")
end

function HomeScene:onEnterTransitionFinish()
    cclog("HomeScene onEnterTransitionFinish")
    if defaults:getBoolForKey(MUSIC_KEY) then
        AudioEngine.playMusic(bg_music_1, true)
    end
end

function HomeScene:onExit()
    cclog("HomeScene onExit")
end

function HomeScene:onExitTransitionStart()
    cclog("HomeScene onExitTransitionStart")
end

function HomeScene:cleanup()
    cclog("HomeScene cleanup")
end


return HomeScene

