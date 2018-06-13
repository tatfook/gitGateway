--------------------------------------------------------------
-- send message by:

-- local topic = 'test'
-- APP.kafka_producer:send({
--     topic = topic,
--     partition = 0,
--     payload = 'test message',
--     key = 'test key'
-- })
--------------------------------------------------------------

require 'rdkafka/kafka'

local default_producer_options = {["statistics.interval.ms"] = "1000"}
local default_topic_options = {["auto.commit.enable"] = "true"}
local event_callbacks = {}

function event_callbacks.delivery_cb(payload)
    print(format('%s : %s', 'Delivery Callback ', payload))
end

function event_callbacks.stat_cb(status)
    -- print(format('%s : %s', 'Status Callback', status))
end

function event_callbacks.error_cb(err_numb, reason)
    print(format('%s : %s  %s', 'Error Callback ', err_numb, reason))
end

-- function event_callbacks.log_cb(level, fac, buf)
-- end

local function parse_kafka_config_from_env()
    local brokers = {}
    local topics = {}
    for k, v in pairs(ENV) do
        -- variable from .env started with 'KAFKA_BROKER'
        if (k:match("^KAFKA_BROKER")) then
            brokers[#brokers + 1] = v
        end
        -- variable from .env started with 'KAFKA_TOPIC'
        if (k:match("^KAFKA_TOPIC")) then
            topics[#topics + 1] = v
        end
    end

    return {
        brokers = brokers,
        topics = topics,
    }
end

local kafka_config = parse_kafka_config_from_env()

local function bind_producer()
    local producer = Kafka.Producer:new():init(
        kafka_config.brokers,
        event_callbacks,
        default_producer_options
    )
    APP.kafka_producer = producer
end

local function bind_topics()
    for i, topic_name in ipairs(kafka_config.topics) do
        APP.kafka_producer:bind_topic(
            topic_name, default_topic_options)
    end
    APP.kafka_topics = APP.kafka_producer.topics
end

local function bind_kafka()
    bind_producer()
    bind_topics()
    APP.kafka_producer:start_poll_loop(50)
end

xpcall(
    function()
        bind_kafka()
    end,
    function(e)
        print(e)
    end
)
