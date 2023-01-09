local commands = require("commands")

local utils = {}

function utils.read_stat_file(file)
    local content = ""
    local f = io.open(file, "r")
    if f then
        io.input(f)
        content = io.read()
        io.close(f)
    end
    return content
end

function utils.get_and_paste_bookmark(mon, font, nb, nf, sb, sf)
    local paste = ""
    local outP = assert(io.popen(commands.open_bookmarks(mon, font, nb, nf, sb ,sf), "r"))
    paste = outP:read("l")
    outP:close()

    if paste ~= nil then
        os.execute(commands.type(paste))
    end
end

function utils.get_audio_sink_mute()
    local outP = assert(io.popen(commands.get_mute(), "r"))
    local output = outP:read("l")
    outP:close()
    if output == "no" then
        return false
    else
        return true
    end
end

function utils.get_audio_sink_volume()
    local outP = assert(io.popen(commands.get_volume(), "r"))
    local output = outP:read("l")
    outP:close()
    return output
end

function utils.get_screen_brightness()
    local outP = assert(io.popen(commands.get_brightness(), "r"))
    local output = outP:read("l")
    outP:close()
    return output
end

return utils
