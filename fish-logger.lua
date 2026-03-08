-- Fix for nil value error

local FishLogger = {}

function FishLogger:start()
    -- Ensure LocalPlayer is valid
    local player = game.Players.LocalPlayer
    if not player then
        error("LocalPlayer is nil")
    end

    -- Start Logging Process
    pcall(function()
        -- Your logging logic here
    end)
end

-- Replace task.wait() with wait() to prevent errors
function FishLogger:wait()
    wait()
end

return FishLogger
