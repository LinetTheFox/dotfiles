local files = {}

function files.battery_capacity(batN) 
    return string.format("/sys/class/power_supply/BAT%d/capacity", batN)
end

function files.ac_connected()
    return "/sys/class/power_supply/ACAD/online"
end

return files