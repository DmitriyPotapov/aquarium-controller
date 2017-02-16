
timer = require('timer')
cfg = {}
configFile = "config.json"
function readConfig(fileName)
    local configVar = {}
    if file.exists(fileName) then
        print('Config file exists.')
    else
        print('Error config file not exists!')
        return
    end
    if file.open(fileName) then
        print('Read config from ' .. fileName)
        configJson = file.read()
        decodeOk, configVar = pcall(cjson.decode, configJson)
        if decodeOk then
            print('Config read sucess.')
            return configVar
        else
            print("Failed to read config!")
            return nil
        end
        file.close()
    end
end
function writeConfig(fileName, configVar)
    if file.exists(fileName) then
        --print('Config file exists.')
        else
        print('Error config file not exists!')
        return false
    end
    encodeOk, configJson = pcall(cjson.encode, configVar)
    if encodeOk then
        file.remove(fileName)
        file.open(fileName, "w+")
        file.write(configJson)
        configJson = nil
        file.close()
        return true
    else
        print("Failed to encode config!")
        return false
    end
end


cfg = readConfig(configFile)
gpio.mode(cfg.relay1Pin, gpio.OUTPUT)
gpio.mode(cfg.relay2Pin, gpio.OUTPUT)
gpio.mode(cfg.intLedPin, gpio.OUTPUT)
gpio.write(cfg.relay1Pin, cfg.relay1State);
gpio.write(cfg.relay2Pin, cfg.relay2State);
pwm.setup(cfg.intLedPin, 400, cfg.pwmDuty)
pwm.start(cfg.intLedPin)
blinkCount = 0
while blinkCount < 6 do
    gpio.write(cfg.intLedPin, gpio.LOW)
    tmr.delay(100 * 1000)
    gpio.write(cfg.intLedPin, gpio.HIGH)
    tmr.delay(100 * 1000)
    blinkCount = blinkCount + 1
end


function onwifconnected()
    if (wifi.sta.status() == 5 and wifi.sta.getip() ~= nil) then
        print("Connected to wifi as:" .. wifi.sta.getip())
        sntp.sync("0.pool.ntp.org")
        dofile("mqtt.lc")
    else
        print('WiFi not connected, wait 5 sec.')
        timer.setTimeout(function()
            if (wifi.sta.status() == 3 or wifi.sta.status() == 0) then
                print('Wifi AP not found, setup WiFi started')
                enduser_setup.manual(true)
                enduser_setup.start(function()
                --node.restart() 
                end,
                    function(err, str)
                        print("enduser_setup: Error #" .. err .. ": " .. str)
                        --node.restart()
                    end
            );
            end end, 5000)
    end
end
onwifconnected()
timer.setInterval(function()
    if (wifi.sta.status() == 5) then
        sntp.sync("0.pool.ntp.org")
    end
end, 900000)
