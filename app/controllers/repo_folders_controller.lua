--[[
    repository folder controller
]]
local _C = commonlib.inherit(Dove.Controller.Base, "Controller.RepoFolder")

_C.before_each("load_repo")

function _C:load_repo()
    self.repo = Model.Repository:new():init(self.params["repo_id"])
    repo:tree()
end

function _C:create()
    self.repo:add_node(self.params["folder_path"])
end

function _C:delete()
    self.repo:delete_node(self.params["id"])
end

function _C:move()
    self.repo:move_node(self.params["id"], self.params["dist_path"])
end
