local _M = commonlib.inherit(Dove.Model.Base, "Model.Page")

function _M:ctor()
end

function _M:init(path)
    self.path = path
    return self
end

function _M:load_page()
    -- TODO
    return "TODO"
end

function _M:load_cached_page_data()
    self.cached_data = APP.redis_client:get(self.path)
    if not self.cached_data then
        self.cached_data = self:load_page()
        APP.redis_client:set(self.path, self.cached_data)
    end
    return self.cached_data
end

function _M:content()
    if not self.cached_data then
        self:load_cached_page_data()
    end
    return self.cached_data
end
