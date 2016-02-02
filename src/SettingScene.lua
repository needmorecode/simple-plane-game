require "Cocos2d"
require "Cocos2dConstants"

require "SystemConst"

local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local SettingScene = class("SettingScene",function()
    return cc.Scene:create()
end)

function SettingScene.create()
    local scene = SettingScene.new()
    scene:addChild(scene:createLayer())
    return scene
end

function SettingScene:ctor()

end

-- create layer
function SettingScene:createLayer()
    cclog("SettingScene init")
    local layer = cc.Layer:create()

    local bg = cc.TMXTiledMap:create("map/red_bg.tmx")
    layer:addChild(bg)

    local top = cc.Sprite:createWithSpriteFrameName("setting.page.png")
    top:setPosition(cc.p(size.width/2, size.height - top:getContentSize().height /2))
    layer:addChild(top)

    local function menuSoundToggleCallback(sender)

        if defaults:getBoolForKey(SOUND_KEY, false) then
            defaults:setBoolForKey(SOUND_KEY, false)
        else
            defaults:setBoolForKey(SOUND_KEY, true)
            AudioEngine.playEffect(sound_1)
        end
    end

    --音效.
    local soundOnSprite  = cc.Sprite:createWithSpriteFrameName("check-on.png")
    local soundOffSprite  = cc.Sprite:createWithSpriteFrameName("check-off.png")
    local soundOnMenuItem = cc.MenuItemSprite:create(soundOnSprite, soundOnSprite)
    local soundOffMenuItem = cc.MenuItemSprite:create(soundOffSprite, soundOffSprite)
    local soundToggleMenuItem = cc.MenuItemToggle:create(soundOnMenuItem, soundOffMenuItem)
    soundToggleMenuItem:registerScriptTapHandler(menuSoundToggleCallback)

    local function menuMusicToggleCallback(tag, sender)
        if  defaults:getBoolForKey(MUSIC_KEY, false) then
            defaults:setBoolForKey(MUSIC_KEY, false)
            AudioEngine.stopMusic()
        else
            defaults:setBoolForKey(MUSIC_KEY, true)
            AudioEngine.playMusic(bg_music_2, true)
        end
        if defaults:getBoolForKey(SOUND_KEY) then
            AudioEngine.playEffect(sound_1)
        end
    end
    --音乐.
    local musicOnSprite  = cc.Sprite:createWithSpriteFrameName("check-on.png")
    local musicOffSprite  = cc.Sprite:createWithSpriteFrameName("check-off.png")
    local musicOnMenuItem = cc.MenuItemSprite:create(musicOnSprite, musicOnSprite)
    local musicOffMenuItem = cc.MenuItemSprite:create(musicOffSprite, musicOffSprite)
    local musicToggleMenuItem = cc.MenuItemToggle:create(musicOnMenuItem, musicOffMenuItem)
    musicToggleMenuItem:registerScriptTapHandler(menuMusicToggleCallback)

    local  menu = cc.Menu:create(soundToggleMenuItem, musicToggleMenuItem)
    menu:setPosition(cc.p(size.width / 2 + 70, size.height /2 + 60))
    menu:alignItemsVerticallyWithPadding(12)
    layer:addChild(menu, 1)

    --Ok菜单事件处理
    local function menuOkCallback(sender)
        cc.Director:getInstance():popScene()
        if defaults:getBoolForKey(SOUND_KEY) then
            AudioEngine.playEffect(sound_1)
        end
    end
    --Ok菜单
    local okNormal = cc.Sprite:createWithSpriteFrameName("button.ok.png")
    local okSelected = cc.Sprite:createWithSpriteFrameName("button.ok-on.png")
    local okMenuItem = cc.MenuItemSprite:create(okNormal, okSelected)
    okMenuItem:registerScriptTapHandler(menuOkCallback)

    local okMenu = cc.Menu:create(okMenuItem)
    okMenu:setPosition(cc.p(190, 50))
    layer:addChild(okMenu)

    --设置音效和音乐选中状态
    if  defaults:getBoolForKey(MUSIC_KEY, false) then
        musicToggleMenuItem:setSelectedIndex(0)
    else
        musicToggleMenuItem:setSelectedIndex(1)
    end
    if  defaults:getBoolForKey(SOUND_KEY, false) then
        soundToggleMenuItem:setSelectedIndex(0)
    else
        soundToggleMenuItem:setSelectedIndex(1)
    end

    return layer
end

return SettingScene

