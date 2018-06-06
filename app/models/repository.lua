--[[
Repository model

A repository model must have a repo id, which must match the id in the git service.
Currently we store repos and repo permissions in keepwork core api server, the client should get repo id before call the git gateway.
]]
local _M = commonlib.inherit(Dove.Model.Base, "Model.Repository")
local StringHelper = commonlib.gettable("Dove.Utils.StringHelper")
local GitService = commonlib.gettable("Service.Git")

_M.db_name = "repository"

local json_encode = commonlib.Json.Encode
local json_decode = commonlib.Json.Decode
local string_gsub = string.gsub

local NODE_PREFIX = "node:"

local function add_node_prefix(repo_path, path)
    return NODE_PREFIX .. repo_path .. ":" .. path
end

local function remove_node_prefix(path)
    local arr = StringHelper.split(path, "[^:]+")
    return arr[#arr]
end

local function is_folder(path)
    return not path.match("^[^.]+") -- not **.**
end

function _M:ctor()
end

function _M:init(repo_id, root_path)
    self.repo_id = repo_id
    self.project = Model.Project:new():init(self.repo_id)
    self.root_path = root_path or "/"
    self.repo_path = self.project.data.path_with_namespace
    return self
end

function _M:load_tree()
    -- always load all
    return GitService.client("GITLAB").load_tree(self.repo_id)
end

function _M:load_relative_cached_nodes()
    local node_keys = APP.redis_client:keys(add_node_prefix(self.repo_path, self.root_path .. "*"))
    if #node_keys == 0 then
        return nil
    end

    local nodes = {}
    for _, key in pairs(node_keys) do
        nodes[remove_node_prefix(key)] = json_decode(APP.redis_client:get(key))
    end
    return nodes
end

function _M:cache_all_node(tree)
    for _, node in pairs(tree) do
        node.synchronized = true
        APP.redis_client:set(add_node_prefix(self.repo_path, node.path), json_encode(node))
    end
end

function _M:load_and_cache_tree()
    local tree = self:load_tree()
    self:cache_all_node(tree)
    self.cached_tree = self:load_relative_cached_nodes()
end

function _M:load_tree_from_cache()
    self.cached_tree = self:load_relative_cached_nodes()
    if (self.cached_tree) then
        return
    end
    self:load_and_cache_tree()
end

function _M:tree(force_refresh)
    if force_refresh then
        self:load_and_cache_tree()
    elseif not self.cached_tree then
        self:load_tree_from_cache()
    end
    return self.cached_tree
end

function _M:add_node(path)
    -- TODO
end

function _M:delete_node(path)
    -- TODO
end

function _M:move_node(path)
    -- TODO
end
