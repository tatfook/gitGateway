local redis = require 'redis-npl/redis'

xpcall(
    function() APP.redis_client = redis.connect(ENV['REDIS_SERVER'], ENV['REDIS_PORT']) end,
    function(e) print(e) end
)
