---
--常量文件
--
--

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

--UserDefault中保存音效播放状态键
SOUND_KEY = "sound_key"
--UserDefault中保存背景音效播放状态键
MUSIC_KEY = "music_key"
--UserDefault中保存最高记录键
HIGHSCORE_KEY = "highscore_key"

--本地iOS平台
if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
    --声音
    bg_music_1  =   "sound/home_bg.aifc"
    bg_music_2  =  "sound/game_bg.aifc"
    sound_1   =  "sound/Blip.caf"
    sound_2   =  "sound/Explosion.caf"
    effectExplosion = "sound/Explosion.caf"

    --LostRoutes  Texture资源
    texture_res = 'texture/LostRoutes_Texture.pvr.gz'
    --LostRoutes Texture plist
    texture_plist = 'texture/LostRoutes_Texture_pvr.plist'
    --loading  Texture资源
    loading_texture_res = 'texture/loading_texture.pvr.gz'
    --loading Texture plist
    loading_texture_plist = 'texture/loading_texture_pvr.plist'

    --其它平台包括Web和Android等
else
    --声音
    bg_music_1   =  "sound/home_bg.mp3"
    bg_music_2  =  "sound/game_bg.mp3"
    sound_1  =   "sound/Blip.wav"
    sound_2   =  "sound/Explosion.wav"
    effectExplosion = "sound/Explosion.wav"
    --LostRoutes  Texture资源
    texture_res = 'texture/LostRoutes_Texture.png'
    --LostRoutes Texture plist
    texture_plist = 'texture/LostRoutes_Texture.plist'
    --loading  Texture资源
    loading_texture_res = 'texture/loading_texture.png'
    --loading Texture plist
    loading_texture_plist = 'texture/loading_texture.plist'

end

-- Home菜单操作标识
HomeMenuActionTypes = {
    MenuItemStart = 100,
    MenuItemSetting = 101,
    MenuItemHelp =  102
}

--定义敌人类型
EnemyTypes = {
    Enemy_Stone =  0,--陨石
    Enemy_1 =  1,--敌机1
    Enemy_2 =  2,--敌机2
    Enemy_Planet =  3 --行星
}

--道具类型
ItemTypes = {
    Item_Bomb = 0,  --炸弹
    Item_Double = 1 --双倍火力
}

--定义敌人名称 也是敌人精灵帧的名字
EnemyName = {
    Enemy_Stone =  "gameplay.stone1.png",
    Enemy_1 =  "gameplay.enemy-1.png",
    Enemy_2 =  "gameplay.enemy-2.png",
    Enemy_Planet =  "gameplay.enemy.planet.png"
}

--游戏场景中使用的标签常量
GameSceneNodeTag = {
    StatusBarFighterNode =  301,
    StatusBarLifeNode =  302,
    StatusBarScore =  303,
    StatusBarBombNum = 304,
    StatusBarBombNode = 305,
    BatchBackground =  800,
    Fighter =  900,
    ExplosionParticleSystem =  802,
    Bullet =  803,
    Enemy =  804,
    Item = 805,
}

--精灵速度常量
Sprite_Velocity = {
    Enemy_Stone =  cc.p(0, -80),
    Enemy_1 =  cc.p(0, -50),
    Enemy_2 =  cc.p(0, -100),
    Enemy_Planet =  cc.p(0, -30),
    Bullet =  cc.p(0, 200)
}

--分值
EnemyScores = {
    Enemy_Stone = 10,
    Enemy_1 = 15,
    Enemy_2 = 5,
    Enemy_Planet = 20
}

--敌人初始生命值
Enemy_initialHitPoints = {
    Enemy_Stone = 5,
    Enemy_1 = 10,
    Enemy_2 = 1,
    Enemy_Planet = 15
}

--我方飞机生命数
Fighter_hitPoints = 3

--我方飞机初始无敌状态时间
Fighter_initCd = 3

--敌人飞行速度变化率(每秒增加)
Enemy_velocity_increase_rate = 0.01

--敌人出现概率变化率（每秒增加）
Enemy_appear_increase_rate = 0.01

--敌人初始出现概率
Enemy_initialAppearProb = {
    Enemy_Stone = 50,
    Enemy_1 = 20,
    Enemy_2 = 200,
    Enemy_Planet = 10
}

-- 子弹发射频率
Bullet_shoot_rate = 0.2

-- 多倍火力时间
Multi_shoot_time = 10
-- 4倍火力
Multi_shoot_ratio = 1



