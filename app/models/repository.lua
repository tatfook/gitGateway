local _M = commonlib.inherit(Dove.Model.Base, "Model.Repository")

_M.db_name = "repository"

_M.before_create = {"load_repository"}

function _M:ctor()
end

function _M:load_repository()
    -- local tree_data = HttpClient.get()
end
