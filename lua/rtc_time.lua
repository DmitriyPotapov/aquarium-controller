local F
do
    
    tz = 2 -- time zone
    hour = 0
    minute = 0
    second = 0
    day = 0
    month = 0
    year = 0
    
    -- returns the hour, minute, second, day, month and year from the ESP8266 RTC seconds count (corrected to local time by tz)
    function getRTCtime()
        function isleapyear(y) if ((y % 4) == 0) or (((y % 100) == 0) and ((y % 400) == 0)) == true then return 2 else return 1 end end
        function daysperyear(y) if isleapyear(y) == 2 then return 366 else return 365 end end
        local monthtable = {{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}, {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}}-- days in each month
        local secs = rtctime.get()
        local d = secs / 86400
        local y = 1970
        local m = 1
        while (d >= daysperyear(y)) do d = d - daysperyear(y)y = y + 1 end -- subtract the number of seconds in a year
        while (d >= monthtable[isleapyear(y)][m]) do d = d - monthtable[isleapyear(y)][m]m = m + 1 end -- subtract the number of days in a month
        secs = secs - 1104494400 - 1104494400 + (tz * 3600)-- convert from NTP to Unix (01/01/1900 to 01/01/1970)
        return (secs % 86400) / 3600, (secs % 3600) / 60, secs % 60, m, d + 1, y --hour, minute, second, month, day, year
    end
    F = getRTCtime
    return F
end
