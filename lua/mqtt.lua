local topics = {relayState = 1, pwmValue = 1, system = 1, thresholdTemp = 1, lightTimer = 1}
local topicName = {relayState = "relayState", pwmValue = "pwmValue", system = "system", thresholdTemp = "thresholdTemp", lightTimer = "lightTimer"}

mq = mqtt.Client(cfg.mqttClientId, 60, cfg.mqttUserName, cfg.mqttPassword)

mq:lwt("system", '{"client":"nodemcu-offine"}', 0, 0)
mq:on("offline", function(client)
   
end)

mq:connect(cfg.mqttServer, cfg.mqttWsPort, 0,
    function(client)
        print("[.lc] Connected to MQTT server " .. cfg.mqttServer)
        mq:subscribe(topics, function(client)
            print("Subscribe to topics :" .. cjson.encode(topics) .. " success.")
        end)
        mq:publish("system", '{"client":"nodemcu-online"}', 0, 0)
        sendTelemetry()
    end,
    function(client, reason)
        print("Connect to MQTT failed by reason: " .. reason)
    end)

function sendTelemetry()
    local ds18 = require("ds18b20")
    local t1 = ds18.getTemperature(cfg.ds18b20Pin, 1)
    local t2 = ds18.getTemperature(cfg.ds18b20Pin, 2)
    local payload = {}
    if (t1 ~= nil and t2 ~= nil) then
        payload.t1 = t1
        payload.t2 = t2
    elseif (t1 ~= nil and t1 == nil) then
        payload.t1 = t1
        payload.t2 = -271
    elseif (t2 ~= nil and t1 == nil) then
        payload.t1 = -271
        payload.t2 = t2
    else
        payload.t1 = -271
        payload.t2 = -271
    end
    if (t2 ~= nil and t2 < cfg.thresholdTemp) then
        gpio.write(cfg.relay1Pin, 0)
    elseif (t2 ~= nil and t2 > cfg.thresholdTemp) then
        gpio.write(cfg.relay1Pin, 1)
    end
    cfg.relay1State = gpio.read(cfg.relay1Pin)
    writeConfig(configFile, cfg)
    ds18 = nil
    ds18b20 = nil
    package.loaded["ds18b20"] = nil
    t1 = nil
    t2 = nil
    
    payload.uptime = string.format('%.2f', tmr.time() / 60)
    payload.heap = node.heap()
    payload.relay1State = cfg.relay1State
    payload.relay2State = cfg.relay2State
    payload.thresholdTemp = cfg.thresholdTemp
    payload.pwmDuty = cfg.pwmDuty
    payload.onHour = cfg.onHour
    payload.onMin = cfg.onMin
    payload.offHour = cfg.offHour
    payload.offMin = cfg.offMin
    payloadJson = cjson.encode(payload)
    mq:publish("telemetry", payloadJson, 0, 0)
    payload = nil
end

mq:on("message", function(client, topic, data)
    if data == nil then
        return
    end
    payload = cjson.decode(data)
    if (topic == topicName.relayState) then
        if (payload.relay == 1) then
            gpio.write(cfg.relay1Pin, payload.state);
            cfg.relay1State = gpio.read(cfg.relay1Pin)
            writeConfig(configFile, cfg)
        elseif (payload.relay == 2) then
            gpio.write(cfg.relay2Pin, payload.state);
            cfg.relay2State = gpio.read(cfg.relay2Pin)
            writeConfig(configFile, cfg)
        end
    elseif (topic == topicName.pwmValue) then
        pwm.setduty(cfg.intLedPin, payload.pwm)
        cfg.pwmDuty = payload.pwm
        writeConfig(configFile, cfg)
    elseif (topic == topicName.system) then
        if (payload.client == "webapp") then
            sendTelemetry()
        end
    elseif (topic == topicName.thresholdTemp) then
        cfg.thresholdTemp = payload.val
        writeConfig(configFile, cfg)
    elseif (topic == topicName.lightTimer) then
        cfg.onHour = payload.onHour
        cfg.onMin = payload.onMin
        cfg.offHour = payload.offHour
        cfg.offMin = payload.offMin
        writeConfig(configFile, cfg)
    end
end)




timer.setInterval(function()
    sendTelemetry()
    dofile('onofftimer.lua')
end, 20000)
