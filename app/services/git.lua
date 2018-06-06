
local _M = commonlib.gettable("Service.Git")
local GitlabService = commonlib.gettable("Service.Gitlab")

function _M.client(source_type)
    if source_type == 'GITLAB' then
        return GitlabService
    end
end
