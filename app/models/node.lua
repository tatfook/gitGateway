--[[
    repository tree node
]]
local _M = commonlib.inherit(Dove.Model.Base, "Model.Node")
local StringHelper = commonlib.gettable("Dove.Utils.StringHelper")

local json_encode = commonlib.Json.Encode
local json_decode = commonlib.Json.Decode
local string_gsub = string.gsub
local table_concat = table.concat

local NODE_PREFIX = "node:"

function _M:ctor()
end

function _M:init()
    return self
end

function _M:init_by_table(repo, t)

end

function _M:init_by_key(repo, key)
    self.key = key
    self.repo = repo
    self:load()
    return self
end

function _M:to_json()
    return self.info
end

function _M:json_info()
    return json_encode(self.info)
end

function _M:load()
    self.info = json_decode(APP.redis_client:get(self.key))
    self.path = self.info.path
    self.is_folder = _M.is_folder(self.path)
end

function _M:cache()
    APP.redis_client:set(_M.add_node_prefix(self.repo.repo_path, self.path), json_encode(self.info))
end

function _M.add_node_prefix(repo_path, path)
    return NODE_PREFIX .. repo_path .. ":" .. path
end

function _M.remove_node_prefix(path)
    local segments = StringHelper.split(path, ":")
    return segments[#segments]
end

function _M.is_folder(path)
    return not path:match("^[^.]+") -- not **.**
end

function _M.parent_node(path)
    local segments = StringHelper.split(path, "/")
    if #segments > 1 then
        table_concat(segments, "/", 1, #segments - 1)
    end
end

function _M.cache(repo, node_info)
    node_info.synchronized = true
    APP.redis_client:set(_M.add_node_prefix(repo.repo_path, node_info.path), json_encode(node_info))
end
