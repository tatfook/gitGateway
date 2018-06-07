--[[
    git file controller
]]
local _C = commonlib.inherit(Dove.Controller.Base, "Controller.File")
_C.resource_name = "file"

function _C:show()
    local file = Model.File:new():init(self.params["id"])
    return file:content()
end
