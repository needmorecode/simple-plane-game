
require "Cocos2d"

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    local sharedFileUtils = cc.FileUtils:getInstance()
    local glview = cc.Director:getInstance():getOpenGLView()
    --glview:setFrameSize(640, 960)

    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")

    --屏幕大小
    local screenSize = glview:getFrameSize()
    --设计分辨率大小
    local designSize = cc.size(320,480)
    --资源大小
    local resourceSize = cc.size(640, 960)

    local searchPaths = sharedFileUtils:getSearchPaths()
    local resPrefix = "res/"
    if screenSize.height > 960 then
        designSize = cc.size(320, 568)
        table.insert(searchPaths, 1, resPrefix.."hd")
    else
        table.insert(searchPaths, 1, resPrefix.."hd")
    end
    sharedFileUtils:setSearchPaths(searchPaths)

    cc.Director:getInstance():setContentScaleFactor(resourceSize.width/designSize.width) --默认为1.0
    glview:setDesignResolutionSize(designSize.width, designSize.height, cc.ResolutionPolicy.EXACT_FIT)

    --create scene
    local scene = require("LoadingScene")
    local loadingScene = scene.create()

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(loadingScene)
    else
        cc.Director:getInstance():runWithScene(loadingScene)
    end

end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
