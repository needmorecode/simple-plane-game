require "Cocos2d"
require "Cocos2dConstants"

require "SystemConst"

require "Global"

local size = cc.Director:getInstance():getWinSize()
local defaults = cc.UserDefault:getInstance()

local Item = class("Item",function()
    return cc.Sprite:create()
end)

function Item.create(itemType, enemy)
    local sprite = Item.new(itemType, enemy)
    return sprite
end

function Item:ctor(itemType, enemy)
    local verts = nil
    local frameName = nil
    if itemType  == ItemTypes.Item_Bomb then
        frameName = "gameplay.bg.sprite-1.png"
        verts = {
            cc.p(1.25, 32.25),
            cc.p(36.75, -4.75),
            cc.p( 2.75, -31.75),
            cc.p(-35.75,-3.25)} 
    else
        frameName = "gameplay.bg.sprite-2.png"
        verts = {
            cc.p(1.25, 32.25),
            cc.p(36.75, -4.75),
            cc.p( 2.75, -31.75),
            cc.p(-35.75,-3.25)}
    end
   
    self:setSpriteFrame(frameName)
    self:setPosition(enemy:getPosition())
    self.itemType = itemType

    local body = cc.PhysicsBody:create()
    body:addShape(cc.PhysicsShapePolygon:create(verts))

    self:setPhysicsBody(body)
    body:setCategoryBitmask(0x01)         --0001
    body:setCollisionBitmask(0x02)        --0010
    body:setContactTestBitmask(0x01)      --0001

    self:setScale(0.5)

    if itemType  == ItemTypes.Item_Bomb then
        local ac1 = cc.MoveBy:create(20, cc.p(500, 600))
        local ac2 = ac1:reverse()
        local as1 = cc.Sequence:create(ac1, ac2)
        self:runAction(cc.RepeatForever:create(cc.EaseSineInOut:create(as1)))
    else
        local ac3 = cc.MoveBy:create(10, cc.p(-500, 600))
        local ac4 = ac3:reverse()
        local as2 = cc.Sequence:create(ac3, ac4)
        self:runAction(cc.RepeatForever:create(cc.EaseExponentialInOut:create(as2)))
    end
    
    -- 存活30秒
    self.liveTime = 30
  

    --开始游戏调度
    local function update(delta)

        self.liveTime = self.liveTime - delta
        
        if  self.liveTime <= 0  then
            self:unscheduleUpdate()
            self:removeFromParent()
        end
    end

    self:scheduleUpdateWithPriorityLua(update, 0)

    function onNodeEvent(tag)
        if tag == "exit" then
            --停止游戏调度
            self:unscheduleUpdate()
        end
    end
    self:registerScriptHandler(onNodeEvent)

end



return Item