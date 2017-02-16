local getTime = dofile('rtc_time.lua')
   hour, minute, second, month, day, year = getTime()
    if year > 2000 then
        if (math.floor(hour) == cfg.onHour and math.floor(minute) == cfg.onMin) then
            gpio.write(cfg.relay2Pin, 0)
            cfg.relay2State = 0
            writeConfig(configFile, cfg)
        elseif (math.floor(hour) == cfg.offHour and math.floor(minute) == cfg.offMin) then
            gpio.write(cfg.relay2Pin, 1)
            cfg.relay2State = 1
            writeConfig(configFile, cfg)
        end
    end
getTime = nil
