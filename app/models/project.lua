local _M = commonlib.inherit(Dove.Model.Base, "Model.Project")
local GitService = commonlib.gettable("Service.Git")
local json_encode = commonlib.Json.Encode
local json_decode = commonlib.Json.Decode

local function project_prefix(id)
    if tonumber(id) then
        return "project-id:" .. tostring(id)
    else
        return "project:" .. id
    end
end

local function load_and_cache_project(id)
    local project_data = GitService.client("GITLAB").load_project(id)
    APP.redis_client:set(project_prefix(project_data.id), json_encode(project_data))
    APP.redis_client:set(project_prefix(project_data.path_with_namespace), project_data.id)
    return project_data
end

local function find_project(id)
    local project_data
    local real_id = id
    if not tonumber(id) then
        real_id = APP.redis_client:get(project_prefix(id))
    end

    if real_id then
        project_data = APP.redis_client:get(project_prefix(real_id))
        if project_data then project_data = json_decode(project_data) end
    end

    if not project_data then
        project_data = load_and_cache_project(real_id or id)
    end

    return project_data
end

function _M:ctor()
end

function _M:init(key)
    self:init_by_table(find_project(key))
    return self
end

function _M:init_by_table(t)
    for key, value in pairs(t) do
        self[key] = value
    end
end

-- The ID or URL-encoded path of the project
-- 222 or gitlab_www_chenqh/keepworkHey
function _M.find(id)
    return _M:new():init(id)
end
