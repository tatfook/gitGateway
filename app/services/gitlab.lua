
NPL.load("(gl)script/ide/System/os/HttpClient.lua")
local HttpHelper = commonlib.gettable("Dove.Utils.HttpHelper")
local _M = commonlib.gettable("Service.Gitlab")

local GIT_API = ENV["GIT_API_URL"]
local PRIVATE_TOKEN = ENV["GIT_ADMIN_TOKEN"]
local DEFAULT_PAGE_SIZE = 100000

function _M.load_tree(project_id, root_path, page_size, recursive)
    local tree_api_url =
        format(
        "%s/projects/%s/repository/tree?path=%s&per_page=%s&recursive=%s",
        GIT_API,
        project_id,
        HttpHelper.encode_uri_component(root_path or "/"),
        page_size or DEFAULT_PAGE_SIZE,
        tostring(recursive or true)
    )
    local headers = {["private-token"] = PRIVATE_TOKEN}
    local code, msg, data = HttpClient:get(tree_api_url, {headers = headers})
    if code == 200 then
        return data
    else
        error("failed to load tree via api: " .. tree_api_url)
    end
end

function _M.project_serializer(project)
    return {
        id = project.id,
        visibility = project.visibility,
        name = project.name,
        path = project.path,
        path_with_namespace = project.path_with_namespace,
        owner = project.owner,
        namespace = project.namespace
    }
end

function _M.load_project(project_id)
    local project_api_url =
        format(
        "%s/projects/%s",
        GIT_API,
        project_id
    )
    local headers = {["private-token"] = PRIVATE_TOKEN}
    local code, msg, data = HttpClient:get(project_api_url, {headers = headers})
    if code == 200 then
        return _M.project_serializer(data)
    else
        error("failed to load tree via api: " .. project_api_url)
    end
end
