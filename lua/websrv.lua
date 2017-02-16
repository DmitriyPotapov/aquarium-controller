srv = net.createServer(net.TCP)
print('Start an HTTP server')
srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
            --print("HTTP request: "..request)
            local response = "HTTP/1.1 200 OK\nContent-Type: text/html\nRefresh: 5\nAccess-Control-Allow-Origin:*\n\n";
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
            if (method == nil) then
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
            end
            local _GET = {}
            if (vars ~= nil) then
                for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                    _GET[k] = v
                end
            end
            
            if (_GET.temp == "1") then
                local ds18 = require("ds18b20")
                local temp = ds18.getTemperature(cfg.ds18b20Pin, 1);
                if (temp ~= nil) then
                    response = response .. string.format("%.2f", temp)
                else
                    response = response .. string.format("%.2f", -271)
                end
                ds18 = nil
                ds18b20 = nil
                package.loaded["ds18b20"] = nil
                temp = nil
            
            elseif (_GET.temp == "2") then
                local ds18 = require("ds18b20")
                local temp = ds18.getTemperature(cfg.ds18b20Pin, 2)
                if (temp ~= nil) then
                    response = response .. string.format("%.2f", temp)
                else
                    response = response .. string.format("%.2f", -271)
                end
                ds18 = nil
                ds18b20 = nil
                package.loaded["ds18b20"] = nil
                temp = nil
            elseif (_GET.temp == "all") then
                local ds18 = require("ds18b20")
                local t1 = ds18.getTemperature(cfg.ds18b20Pin, 1)
                local t2 = ds18.getTemperature(cfg.ds18b20Pin, 2)
                if (t1 ~= nil and t2 ~= nil) then
                    response = response .. string.format('{"t1": %.2f, "t2": %.2f}', t1, t2)
                elseif (t1 ~= nil and t1 == nil) then
                    response = response .. string.format('{"t1": %.2f, "t2": %.2f}', t1, -271)
                elseif (t2 ~= nil and t1 == nil) then
                    response = response .. string.format('{"t1": %.2f, "t2": %.2f}', -271, t2)
                else
                    response = response .. string.format('{"t1": %.2f, "t2": %.2f}', -271, -271)
                end
                ds18 = nil
                ds18b20 = nil
                package.loaded["ds18b20"] = nil
                t1 = nil
                t2 = nil
            elseif (_GET.setpwm ~= nil) then
                pwm.setduty(cfg.intLedPin, _GET.setpwm)
            elseif (_GET.relay == "1") then
                gpio.write(cfg.relay1Pin, _GET.state);
            elseif (_GET.relay == "2") then
                gpio.write(cfg.relay2Pin, _GET.state);
            elseif (_GET.uptime == "get") then
                response = response .. string.format('%.2f', tmr.time() / 60)
            end
            response = response
            client:send(response);
            client:close();
            collectgarbage();
    end)
end)
