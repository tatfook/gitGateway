--[[
    git page controller
]]
local _C = commonlib.inherit(Dove.Controller.Base, "Controller.Page")
_C.resource_name = "page"

function _C:show()
    local page = Model.Page:new():init(self.params["id"])
    return page:content()
end
