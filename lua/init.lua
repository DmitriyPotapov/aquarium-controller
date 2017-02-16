--Startup file--
startupFile = "startup.lua"
abort = false



function initStartup()
    print('Init Startup')
    abort = false
    print("Wait 10 seconds please, or press ENTER to abort startup")
    uart.on('data', '\r', function()
        abort = true uart.on('data')
    end, 0)
    tmr.alarm(0, 10000, 0, startup)
end

function startup()
    if abort == true then
        print('Startup aborted')
        return
    end
    l = file.list();
    
    print('List of LUA sctipts:\n' .. '----------------------------\n')
    for k, v in pairs(l) do
        print("--- Filename: " .. k .. ", Filesize: " .. v)
    end
    print('----------------------------\n')
    
    for k, v in pairs(l) do
        if k == startupFile then
            print("Found startup file: " .. startupFile)
            print("End of Init")
            dofile(startupFile)
        end
    end
end
tmr.alarm(0, 1000, 0, initStartup)
