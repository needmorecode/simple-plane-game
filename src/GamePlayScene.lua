require "Cocos2d"
require "Cocos2dConstants"

require "SystemConst"
require "Global"

--主游戏层
local mainLayer

local Enemy = require("Sprite.Enemy")
local Fighter = require("Sprite.Fighter")
local Bullet = require("Sprite.Bullet")
local Item = require("Sprite.Item")

local schedulerId = nil
local scheduler = cc.Director:getInstance():getScheduler()

local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local touchFighterlistener
local contactListener

local fighter
--暂停菜单
local menu

--分数
local score = 0
--记录0~999分数
local scorePlaceholder = 0
--炸弹数量
local bombNum = 0
--子弹id
local bulletId = 1

local GamePlayScene = class("GamePlayScene",function()
    local scene = cc.Scene:createWithPhysics()
    --scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    --0,0不受到重力的影响
    scene:getPhysicsWorld():setGravity(cc.p(0,0))

    return scene
end)

function GamePlayScene.create()
    local scene = GamePlayScene.new()

    return scene
end

function GamePlayScene:ctor()
    cclog("GamePlayScene init")

    self:addChild(self:createInitBGLayer())
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

-- create 背景层
function GamePlayScene:createInitBGLayer()
    cclog("背景层初始化")
    local bgLayer = cc.Layer:create()

    local bg = cc.TMXTiledMap:create("map/blue_bg.tmx")
    bgLayer:addChild(bg,0,GameSceneNodeTag.BatchBackground)

    --放置发光粒子背景
    local ps = cc.ParticleSystemQuad:create("particle/light.plist")
    ps:setPosition(cc.p(size.width / 2, size.height / 2))
    bgLayer:addChild(ps,0,GameSceneNodeTag.BatchBackground)

--    --添加背景精灵1.
--    local sprite1 = cc.Sprite:createWithSpriteFrameName("gameplay.bg.sprite-1.png")
--    sprite1:setPosition(cc.p(-50, -50))
--    bgLayer:addChild(sprite1,0,GameSceneNodeTag.BatchBackground)
--
--    local ac1 = cc.MoveBy:create(20, cc.p(500, 600))
--    local ac2 = ac1:reverse()
--    local as1 = cc.Sequence:create(ac1, ac2)
--    sprite1:runAction(cc.RepeatForever:create(cc.EaseSineInOut:create(as1)))
--
--    --添加背景精灵2.
--    local sprite2 = cc.Sprite:createWithSpriteFrameName("gameplay.bg.sprite-2.png")
--    sprite2:setPosition(cc.p(size.width, 0))
--    bgLayer:addChild(sprite2,0,GameSceneNodeTag.BatchBackground)
--
--    local ac3 = cc.MoveBy:create(10, cc.p(-500, 600))
--    local ac4 = ac3:reverse()
--    local as2 = cc.Sequence:create(ac3, ac4)
--    sprite2:runAction(cc.RepeatForever:create(cc.EaseExponentialInOut:create(as2)))

    return bgLayer
end

-- create mainLayer
function GamePlayScene:createLayer() 

    mainLayer = cc.Layer:create()

--    --添加陨石1.
--    local stone1 = Enemy.create(EnemyTypes.Enemy_Stone)
--    mainLayer:addChild(stone1, 10 , GameSceneNodeTag.Enemy)
--
--    --添加行星.
--    local planet = Enemy.create(EnemyTypes.Enemy_Planet)
--    mainLayer:addChild(planet, 10 , GameSceneNodeTag.Enemy)
--
--    --添加敌机1.
--    local enemyFighter1 = Enemy.create(EnemyTypes.Enemy_1)
--    mainLayer:addChild(enemyFighter1, 10 , GameSceneNodeTag.Enemy)
--
--    --添加敌机2.
--    local enemyFighter2 = Enemy.create(EnemyTypes.Enemy_2)
--    mainLayer:addChild(enemyFighter2, 10 , GameSceneNodeTag.Enemy)

    --开始游戏调度
    local function update(delta)
    
        gGameLastTime = gGameLastTime + delta
        
        -- 随机一个敌机2出来
        local randomNum = math.random(1, 10000)
        if (randomNum <= Enemy_initialAppearProb.Enemy_2 * (1 + Enemy_appear_increase_rate * gGameLastTime)) then
            local enemyFighter2 = Enemy.create(EnemyTypes.Enemy_2)
            mainLayer:addChild(enemyFighter2, 10 , GameSceneNodeTag.Enemy)
        end
        
        -- 随机一个陨石1出来
        if (randomNum <= Enemy_initialAppearProb.Enemy_Stone * (1 + Enemy_appear_increase_rate * gGameLastTime)) then
            local stone1 = Enemy.create(EnemyTypes.Enemy_Stone)
            mainLayer:addChild(stone1, 10 , GameSceneNodeTag.Enemy)
        end
        
        -- 随机一个敌机1出来
        if (randomNum <= Enemy_initialAppearProb.Enemy_1 * (1 + Enemy_appear_increase_rate * gGameLastTime)) then
            local enemyFighter1 = Enemy.create(EnemyTypes.Enemy_1)
            mainLayer:addChild(enemyFighter1, 10 , GameSceneNodeTag.Enemy)
        end
        
        -- 随机一个行星出来
        if (randomNum <= Enemy_initialAppearProb.Enemy_Planet * (1 + Enemy_appear_increase_rate * gGameLastTime)) then
            local planet = Enemy.create(EnemyTypes.Enemy_Planet)
            mainLayer:addChild(planet, 10 , GameSceneNodeTag.Enemy)
        end
        
        -- 扣除初始无敌cd
        fighter.initCd = fighter.initCd - delta
        
    end
    
    mainLayer:scheduleUpdateWithPriorityLua(update, 0)

    fighter = Fighter.create("gameplay.fighter.png")
    fighter:setPos(cc.p(size.width / 2, 70))
    --fighter.multiLeftTime = 0
    mainLayer:addChild(fighter, 10, GameSceneNodeTag.Fighter)


    --开始游戏调度
    local function shootBullet(delta)
    
--        bulletId = bulletId + 1
--        if fighter == nil or fighter.multiLeftTime == nil then
--            print("")
--        end
--        if fighter.multiLeftTime > 0 then
--            fighter.multiLeftTime = fighter.multiLeftTime - delta
--        else    
--            if bulletId % Multi_shoot_ratio ~= 0 then
--                return
--            end
--        end

        if fighter.multiLeftTime > 0 then
            fighter.multiLeftTime = fighter.multiLeftTime - delta
        end
        
        if  nil ~= fighter and fighter:isVisible() then
            if fighter.multiLeftTime <= 0 then
                local bullet = Bullet.create("gameplay.bullet.png")
                mainLayer:addChild(bullet, 0, GameSceneNodeTag.Bullet)
                bullet:shootBulletFromFighter(fighter, 0)
            else
                local bullet1 = Bullet.create("gameplay.bullet.png")
                mainLayer:addChild(bullet1, 0, GameSceneNodeTag.Bullet)
                bullet1:shootBulletFromFighter(fighter, -1)
                
                local bullet2 = Bullet.create("gameplay.bullet.png")
                mainLayer:addChild(bullet2, 0, GameSceneNodeTag.Bullet)
                bullet2:shootBulletFromFighter(fighter, 1)
            end
        end

    end

    --接触事件回调函数
    local function onContactBegin(contact)
        --cclog("onContactBegin")
        local spriteA = contact:getShapeA():getBody():getNode()
        local spriteB = contact:getShapeB():getBody():getNode()

        local enemy1 = nil
        ----------------------------检测 飞机与敌人的碰撞 start----------------------------------
        cclog("A = %d  ------------ B = %d", spriteA:getTag(), spriteB:getTag())

        if  spriteA:getTag() == GameSceneNodeTag.Fighter
            and spriteB:getTag() == GameSceneNodeTag.Enemy then
            enemy1 = spriteB
        end
        if  spriteA:getTag() == GameSceneNodeTag.Enemy
            and spriteB:getTag() == GameSceneNodeTag.Fighter  then
            enemy1 = spriteA
        end

        if  nil ~= enemy1 and fighter.initCd <= 0  then --发生碰撞
            self:handleFighterCollidingWithEnemy(enemy1)
            return false
        end
        --------------------------检测 飞机与敌人的碰撞 end-----------------------------------

        --------------------------检测 炮弹与敌人的碰撞 start--------------------------------
        local enemy2 = nil
        if  spriteA:getTag() == GameSceneNodeTag.Bullet
            and  spriteB:getTag() == GameSceneNodeTag.Enemy then
            --不可见的炮弹不发生碰撞
            if   spriteA:isVisible() == false then
                return false
            end
            --使得炮弹消失
            spriteA:setVisible(false)
            enemy2 = spriteB
        end

        if  spriteA:getTag() == GameSceneNodeTag.Enemy
            and spriteB:getTag() == GameSceneNodeTag.Bullet then
            --不可见的炮弹不发生碰撞
            if  spriteB:isVisible() == false then
                return false
            end
            --使得炮弹消失
            spriteB:setVisible(false)
            enemy2 = spriteA
        end

        if nil ~= enemy2  then--发生碰撞
            self:handleBulletCollidingWithEnemy(enemy2)
            return false
        end
        ------------------------检测 炮弹与敌人的碰撞 end-----------------------------------
        
        
        --------------------------检测 玩家与道具的碰撞 start--------------------------------
        local item = nil
        if (spriteA:getTag() == GameSceneNodeTag.Fighter or spriteB:getTag() == GameSceneNodeTag.Fighter) and spriteA:getTag() ~= GameSceneNodeTag.Bullet and spriteB:getTag() ~= GameSceneNodeTag.Bullet then
            print("")
        end
        if spriteA:getTag() == GameSceneNodeTag.Item 
            and spriteB:getTag() == GameSceneNodeTag.Fighter then
            item = spriteA
        end
        if spriteB:getTag() == GameSceneNodeTag.Item 
            and spriteA:getTag() == GameSceneNodeTag.Fighter then
            item = spriteB
        end
        if nil ~= item then
            self:handleFighterCollidingWithItem(item)
            return false
        end
        ------------------------检测 玩家与道具的碰撞 end-----------------------------------
        
        
        
        return false
    end


    --接触事件回调函数
    local function touchBegan(touch, event)
        --cclog("touchBegan")
        return true
    end

    --接触事件回调函数
    local function touchMoved(touch, event)
        --cclog("touchMoved")
        -- 获取事件所绑定的 node
        local node = event:getCurrentTarget()

        local currentPosX, currentPosY = node:getPosition()
        local diff = touch:getDelta()
        -- 移动当前按钮精灵的坐标位置
        node:setPos(cc.p(currentPosX + diff.x, currentPosY + diff.y))
    end

    --返回主页菜单回调函数
    local function menuBackCallback(sender)
        cclog("menuBackCallback")
        cc.Director:getInstance():popScene()
        if defaults:getBoolForKey(SOUND_KEY)  then
            AudioEngine.playEffect(sound_1)
        end
    end
    --继续菜单回调函数
    local function menuResumeCallback(sender)

        cclog("menuResumeCallback")
        if defaults:getBoolForKey(SOUND_KEY)  then
            AudioEngine.playEffect(sound_1)
        end

        mainLayer:resume()
        schedulerId = nil
        schedulerId = scheduler:scheduleScriptFunc(shootBullet, Bullet_shoot_rate / Multi_shoot_ratio, false)

        --layer子节点继续
        local pChildren = mainLayer:getChildren()
        for i = 1, #pChildren, 1 do
            local  child = pChildren[i]
            child:resume()
        end
        mainLayer:removeChild(menu)
    end

    --暂停菜单回调函数
    local function menuPauseCallback(sender)
        cclog("menuPauseCallback")
        if defaults:getBoolForKey(SOUND_KEY)  then
            AudioEngine.playEffect(sound_1)
        end

        --暂停当前层中的node
        mainLayer:pause()
        if (schedulerId ~= nil) then
            scheduler:unscheduleScriptEntry(schedulerId)
        end

        --layer子节点暂停
        local pChildren = mainLayer:getChildren()
        for i = 1, #pChildren, 1 do
            local  child = pChildren[i]
            child:pause()
        end

        --返回主菜单
        local backNormal = cc.Sprite:createWithSpriteFrameName("button.back.png")
        local backSelected = cc.Sprite:createWithSpriteFrameName("button.back-on.png")
        local backMenuItem = cc.MenuItemSprite:create(backNormal, backSelected)
        backMenuItem:registerScriptTapHandler(menuBackCallback)

        --继续游戏菜单
        local resumeNormal = cc.Sprite:createWithSpriteFrameName("button.resume.png")
        local resumeSelected = cc.Sprite:createWithSpriteFrameName("button.resume-on.png")
        local resumeMenuItem = cc.MenuItemSprite:create(resumeNormal, resumeSelected)
        resumeMenuItem:registerScriptTapHandler(menuResumeCallback)

        menu = cc.Menu:create(backMenuItem,resumeMenuItem)
        menu:alignItemsVertically()
        menu:setPosition(cc.p(size.width / 2, size.height / 2))

        mainLayer:addChild(menu,50,1000)

    end

    -- 创建一个事件监听器 OneByOne 为单点触摸
    touchFighterlistener = cc.EventListenerTouchOneByOne:create()
    -- 设置是否吞没事件，在 onTouchBegan 方法返回 true 时吞没
    touchFighterlistener:setSwallowTouches(true)
    -- EVENT_TOUCH_BEGAN事件回调函数
    touchFighterlistener:registerScriptHandler(touchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    -- EVENT_TOUCH_MOVED事件回调函数
    touchFighterlistener:registerScriptHandler(touchMoved,cc.Handler.EVENT_TOUCH_MOVED )

    -- 创建一个接触事件监听器
    contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    -- 添加监听器
    eventDispatcher:addEventListenerWithSceneGraphPriority(touchFighterlistener, fighter)
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, mainLayer)

    --初始化暂停按钮.
    local pauseSprite = cc.Sprite:createWithSpriteFrameName("button.pause.png")
    local pauseMenuItem = cc.MenuItemSprite:create(pauseSprite, pauseSprite)
    pauseMenuItem:registerScriptTapHandler(menuPauseCallback)

    local pauseMenu = cc.Menu:create(pauseMenuItem)
    pauseMenu:setPosition(cc.p(30, size.height - 28))

    mainLayer:addChild(pauseMenu,300,999)

    --每0.2秒调用shootBullet函数发射1发炮弹
    schedulerId = scheduler:scheduleScriptFunc(shootBullet, Bullet_shoot_rate / Multi_shoot_ratio, false)

    --分数
    score = 0
    --记录0~999分数
    scorePlaceholder = 0

    --在状态栏中设置玩家的生命值
    self:updateStatusBarFighter()
    --在状态栏中显示得分
    self:updateStatusBarScore()
    --在状态栏中显示炸弹数
    self:updateStatusBarBombNum()


    return mainLayer
end

function GamePlayScene:onEnter()
    cclog("GamePlayScene onEnter")
    gGameLastTime = 0
    gHitEnemy1Num = 0
    gHitEnemy2Num = 0
    gHitStoneNum = 0
    gHitPlanetNum = 0
    self:addChild(self:createLayer())

end

--处理玩家与敌人的碰撞检测
function GamePlayScene:handleFighterCollidingWithEnemy(enemy)

    self:removeChildByTag(GameSceneNodeTag.ExplosionParticleSystem)

    local explosion = cc.ParticleSystemQuad:create("particle/explosion.plist")
    explosion:setPosition(fighter:getPosition())
    self:addChild(explosion, 2, GameSceneNodeTag.ExplosionParticleSystem)
    if  defaults:getBoolForKey(SOUND_KEY)  then
        AudioEngine.playEffect(sound_2)
    end
    --设置敌人消失
    enemy:setVisible(false)
    enemy:unscheduleUpdate()
    enemy:removeFromParent()

    --设置玩家消失
    fighter.hitPoints = fighter.hitPoints - 1
    --cclog("fighter hitPoints = %d",fighter.hitPoints)
    self:updateStatusBarFighter()
    --游戏结束
    if fighter.hitPoints <=0 then
        cclog("GameOver")
        local GameOverScene = require("GameOverScene")
        local scene = GameOverScene.create(score)
        local tsc = cc.TransitionFade:create(1.0, scene)
        cc.Director:getInstance():pushScene(tsc)
    else
        fighter:setPosition(cc.p(size.width /2, 70))
        local ac1 = cc.Show:create()
        local ac2 = cc.FadeIn:create(1.0)
        local seq = cc.Sequence:create(ac1,ac2)
        fighter.initCd = Fighter_initCd
        fighter:runAction(seq)
    end
end

-- 飞机与道具的碰撞检测
function GamePlayScene:handleFighterCollidingWithItem(item)

    if  defaults:getBoolForKey(SOUND_KEY)  then
        AudioEngine.playEffect(sound_1)
    end
    
    if item.itemType == ItemTypes.Item_Bomb then
        bombNum = bombNum + 1
        --cclog("fighter hitPoints = %d",fighter.hitPoints)
        self:updateStatusBarBombNum()
    else
        fighter.multiLeftTime = Multi_shoot_time
    end
    
    --设置道具消失
    item:setVisible(false)
    item:removeFromParent()
end

function GamePlayScene:handleEnemyDie(enemy)
    --爆炸和音效
    local node = mainLayer:getChildByTag(GameSceneNodeTag.ExplosionParticleSystem)
    if nil ~= node  then
        self:removeChild(node)
    end
    local explosion = cc.ParticleSystemQuad:create("particle/explosion.plist")
    explosion:setPosition(enemy:getPosition())
    self:addChild(explosion, 2, GameSceneNodeTag.ExplosionParticleSystem)
    if defaults:getBoolForKey(SOUND_KEY)  then
        AudioEngine.playEffect(sound_2)
    end

    if enemy.enemyType == EnemyTypes.Enemy_Stone then
        score = EnemyScores.Enemy_Stone + score
        scorePlaceholder =  EnemyScores.Enemy_Stone + scorePlaceholder
        gHitStoneNum = gHitStoneNum + 1
    elseif enemy.enemyType ==  EnemyTypes.Enemy_1 then
        score = EnemyScores.Enemy_1 + score
        scorePlaceholder =  EnemyScores.Enemy_1 + scorePlaceholder
        gHitEnemy1Num = gHitEnemy1Num + 1
    elseif enemy.enemyType ==  EnemyTypes.Enemy_2 then
        score = EnemyScores.Enemy_2 + score
        scorePlaceholder =  EnemyScores.Enemy_2 + scorePlaceholder
        gHitEnemy2Num = gHitEnemy2Num + 1
    else
        score = EnemyScores.Enemy_Planet + score
        scorePlaceholder =  EnemyScores.Enemy_Planet + scorePlaceholder
        gHitPlanetNum = gHitPlanetNum + 1
    end

    --每次获得1000分数，生命值 加一，scorePlaceholder恢复0.
    if  scorePlaceholder >= 1000 then
        fighter.hitPoints = fighter.hitPoints + 1
        self:updateStatusBarFighter()
        scorePlaceholder = scorePlaceholder - 1000
    end

    self:updateStatusBarScore()


    -- 若消灭了行星，则一定几率出现道具
    if enemy.enemyType == EnemyTypes.Enemy_Planet then
        local random = math.random(1,10)
        if (random <= 2) then
            -- 出现炸弹   
            local sprite1 = Item.create(ItemTypes.Item_Bomb, enemy)
            mainLayer:addChild(sprite1, 10 , GameSceneNodeTag.Item)

        elseif (random <= 4) then
            -- 出现双倍火力
            local sprite2 = Item.create(ItemTypes.Item_Multi, enemy)
            mainLayer:addChild(sprite2, 10 , GameSceneNodeTag.Item)

        end
    end

    --设置敌人消失
    enemy:setVisible(false)
    enemy:unscheduleUpdate()
    enemy:removeFromParent()
end

--炮弹与敌人的碰撞检测
function GamePlayScene:handleBulletCollidingWithEnemy(enemy)

    enemy.hitPoints = enemy.hitPoints - 1

    if  enemy.hitPoints <= 0 then
        self:handleEnemyDie(enemy)
        --enemy:spawn()
    end
end

--在状态栏中显示得分
function GamePlayScene:updateStatusBarScore()

    mainLayer:removeChildByTag(GameSceneNodeTag.StatusBarScore)

    if score <0 then
        score = 0
    end

    local strScore = string.format("%d", score)
    local lblScore = cc.Label:createWithTTF(strScore, "fonts/hanyi.ttf", 18)

    lblScore:setPosition(cc.p(size.width / 2, size.height - 28))
    mainLayer:addChild(lblScore, 20, GameSceneNodeTag.StatusBarScore)

end

--在状态栏中显示炸弹数量
function GamePlayScene:updateStatusBarBombNum()

   local function menuBombCallback(sender)
        cclog("menuBombCallback")
        
        if bombNum <= 0 then
            return
        end
        
        if defaults:getBoolForKey(SOUND_KEY)  then
            AudioEngine.playEffect(sound_1)
        end
        
        bombNum = bombNum - 1
        self:updateStatusBarBombNum()
        
        -- 消灭地图上所有敌人
        local pChildren = mainLayer:getChildren()
        for i = 1, #pChildren, 1 do
            local  child = pChildren[i]
            if child:getTag() == GameSceneNodeTag.Enemy then
                self:handleEnemyDie(child)
--                -- TODO
--                --爆炸和音效
--                local node = mainLayer:getChildByTag(GameSceneNodeTag.ExplosionParticleSystem)
--                if nil ~= node  then
--                    self:removeChild(node)
--                end
--                local explosion = cc.ParticleSystemQuad:create("particle/explosion.plist")
--                explosion:setPosition(child:getPosition())
--                self:addChild(explosion, 2, GameSceneNodeTag.ExplosionParticleSystem)
--
--                --设置敌人消失
--                child:setVisible(false)
--                child:unscheduleUpdate()
--                child:removeFromParent()        
            end
            --child:resume()
        end
        -- 播放爆炸音效
        if defaults:getBoolForKey(SOUND_KEY)  then
            AudioEngine.playEffect(sound_2)
        end
   end

    --先移除上次的精灵
    mainLayer:removeChildByTag(GameSceneNodeTag.StatusBarBombNode)

    local fg = cc.Sprite:createWithSpriteFrameName("gameplay.bg.sprite-1.png")
    --fg:setPosition(cc.p(size.width - 60, 28))
    fg:setScale(0.5)
    --mainLayer:addChild(fg,20,GameSceneNodeTag.StatusBarBombNode)
    
    --local listener1 = cc.EventListenerTouchOneByOne:create()
    --listener1:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    local bombMenuItem = cc.MenuItemSprite:create(fg, fg)
    bombMenuItem:registerScriptTapHandler(menuBombCallback)

    local bombMenu = cc.Menu:create(bombMenuItem)
    bombMenu:setPosition(cc.p(size.width - 60, 40))

    mainLayer:addChild(bombMenu, 300, GameSceneNodeTag.StatusBarBombNode)

    mainLayer:removeChildByTag(GameSceneNodeTag.StatusBarBombNum)


    if bombNum < 0 then
        bombNum = 0
    end
    local bombNumStr = string.format("x %d", bombNum)
    local lblLife = cc.Label:createWithTTF(bombNumStr, "fonts/hanyi.ttf", 18)
    local fgX,fgY = bombMenu:getPosition()
    lblLife:setPosition(cc.p(fgX + 15, fgY - 15))
    mainLayer:addChild(lblLife, 20, GameSceneNodeTag.StatusBarBombNum)

end

--在状态栏中设置玩家的生命值
function GamePlayScene:updateStatusBarFighter()

    --先移除上次的精灵
    mainLayer:removeChildByTag(GameSceneNodeTag.StatusBarFighterNode)

    local fg = cc.Sprite:createWithSpriteFrameName("gameplay.life.png")
    fg:setPosition(cc.p(size.width - 60, size.height - 28))
    mainLayer:addChild(fg,20,GameSceneNodeTag.StatusBarFighterNode)

    --添加生命值 x 5
    mainLayer:removeChildByTag(GameSceneNodeTag.StatusBarLifeNode)


    if fighter.hitPoints < 0 then
        fighter.hitPoints = 0
    end
    local life = string.format("x %d", fighter.hitPoints)
    local lblLife = cc.Label:createWithTTF(life, "fonts/hanyi.ttf", 18)
    local fgX,fgY = fg:getPosition()
    lblLife:setPosition(cc.p(fgX + 30, fgY))
    mainLayer:addChild(lblLife, 20, GameSceneNodeTag.StatusBarLifeNode)

end


function GamePlayScene:onEnterTransitionFinish()
    cclog("GamePlayScene onEnterTransitionFinish")
    if defaults:getBoolForKey(MUSIC_KEY) then
        AudioEngine.playMusic(bg_music_2, true)
    end
end

function GamePlayScene:onExit()

    cclog("GamePlayScene onExit")
    --停止游戏调度
    if (schedulerId ~= nil) then
        scheduler:unscheduleScriptEntry(schedulerId)
    end
    --注销事件监听器.
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if nil ~= touchFighterlistener then
        eventDispatcher:removeEventListener(touchFighterlistener)
    end
    if nil ~= contactListener then
        eventDispatcher:removeEventListener(contactListener)
    end

    --删除layer节点以及其子节点
    mainLayer:removeAllChildren()
    mainLayer:removeFromParent()
    mainLayer = nil

end

function GamePlayScene:onExitTransitionStart()
    cclog("GamePlayScene onExitTransitionStart")
end

function GamePlayScene:cleanup()
    cclog("GamePlayScene cleanup")
end

return GamePlayScene
 
