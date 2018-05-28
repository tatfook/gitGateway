local redis = require 'redis-npl/redis'
local redis_config = APP.config.custom.redis

if (redis_config) then
    xpcall(
        function() APP.redis_client = redis.connect(redis_config.server, redis_config.port) end,
        function(e) print(e) end
    )
end
