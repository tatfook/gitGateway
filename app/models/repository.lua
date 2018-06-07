--[[
Repository model

A repository model must have a repo id, which must match the id in the git service.
Currently we store repos and repo permissions in keepwork core api server, the client should get repo id before call the git gateway.
]]
local _M = commonlib.inherit(Dove.Model.Base, "Model.Repository")
local GitService = commonlib.gettable("Service.Git")
local Node = commonlib.gettable("Model.Node")

_M.db_name = "repository"

local string_gsub = string.gsub
local table_insert = table.insert

function _M:ctor()
end

function _M:init(repo_id, root_path)
    self.repo_id = repo_id
    self.project = Model.Project.find(self.repo_id)
    self.root_path = root_path or "/"
    self.repo_path = self.project.path_with_namespace
    return self
end

function _M:to_json()
    local json_data = {}
    for _, node in ipairs(self:tree()) do
        table_insert(json_data, node:to_json())
    end
    return json_data
end

function _M:load_tree()
    -- Always load all data. Pls fix it when we can find a way to do the lazy loading.
    return GitService.client("GITLAB").load_tree(self.repo_id)
end

function _M:load_relative_cached_nodes()
    local node_keys = APP.redis_client:keys(Node.add_node_prefix(self.repo_path, self.root_path .. "*"))
    if #node_keys == 0 then
        return nil
    end

    local nodes = {}
    for _, key in pairs(node_keys) do
        local node = Node:new():init_by_key(self, key)
        table_insert(nodes, node)
    end
    return nodes
end

function _M:cache_tree_data(tree)
    for _, node_data in pairs(tree) do
        Node.cache(self, node_data)
    end
end

function _M:load_and_cache_tree()
    self:cache_tree_data(self:load_tree())
    self.nodes = self:load_relative_cached_nodes()
end

function _M:load_tree_from_cache()
    self.nodes = self:load_relative_cached_nodes()
    if not self.nodes then
        self:load_and_cache_tree()
    end
end

function _M:tree(force_refresh)
    if force_refresh then
        self:load_and_cache_tree()
    elseif not self.nodes then
        self:load_tree_from_cache()
    end
    return self.nodes
end

function _M:add_node(path)
    if NodeHelper.is_folder(path) then
        self:add_folder(path)
    else
        self:add_file(path)
    end
end

function _M:have_node(path)
    return self.tree()[path] ~= nil
end

function _M:check_parent_node(path)
    local parent_node = NodeHelper.parent_node(path)
    if parent_node and not self:have_node(parent_node) then
        return false
    end
    return true
end

function _M:delete_node(path)
end

function _M:move_node(path)
end

function _M:add_folder(path)
    if not self:check_parent_node(path) then
        return false, "invalid parent node"
    end
    if self:have_node(path) then
        return false, "already existed"
    end
    self:add_file(path .. "/.gitignore")
end

function _M:delete_folder(path)
    -- delete all files in t
end

function _M:move_folder(path)
end

function _M:add_file(path)
    if not self:check_parent_node(path) then
        return false, "invalid parent node"
    end
    if self:have_node(path) then
        return false, "already existed"
    end
    -- TODO Add file
end

function _M:delete_file(path)
    -- TODO
end

function _M:move_file(path)
    -- TODO
end
