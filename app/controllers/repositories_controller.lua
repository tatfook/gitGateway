local _C = commonlib.inherit(Dove.Controller.Base, "Controller.Repository")
_C.resource_name = "repository"

function _C:show()
    local repo = Model.Repository:new():init(self.params["id"], self.params["root_path"])
    return repo:tree()
end
