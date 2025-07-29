-- LunaSoft CounterBlox HVH v2

-- // SETTINGS
local config = {
    silentAim = true,
    triggerBot = true,
    autoFire = true,
    noRecoil = true,
    noSpread = true,
    bunnyHop = true,
    webhook = "https://discord.com/api/webhooks/1399596197110349824/zL9_TWQl8VyH5x2lsCDncsDRHAcagAGlpgLeTY409gy6NPI0vEpaao4o-W58PHlCkNow",
    glowColor = Color3.fromRGB(255, 105, 180)
}

-- // UI (простой пример)
local ui = Instance.new("ScreenGui", game.CoreGui)
ui.Name = "LunaSoftMenu"
local frame = Instance.new("Frame", ui)
frame.Position = UDim2.new(0.7, 0, 0.3, 0)
frame.Size = UDim2.new(0, 200, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "LunaSoft HVH"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 0.7, 0.9)
title.TextSize = 18

-- // Webhook
pcall(function()
    syn.request({
        Url = config.webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode({
            content = "**[LunaSoft HVH]** Cheat Injected into CounterBlox!",
            username = "LunaLogger"
        })
    })
end)

-- // Silent Aim
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local Mouse = lp:GetMouse()

local function getClosest()
    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Team ~= lp.Team and plr.Character and plr.Character:FindFirstChild("Head") then
            local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local diff = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(headPos.X, headPos.Y)).magnitude
                if diff < dist then
                    closest = plr
                    dist = diff
                end
            end
        end
    end
    return closest
end

local function fire()
    mouse1press()
    wait()
    mouse1release()
end

-- // Heartbeat Connection
game:GetService("RunService").Heartbeat:Connect(function()
    local target = getClosest()
    if target then
        if config.autoFire and config.triggerBot then
            fire()
        end
    end
end)

-- // BunnyHop
game:GetService("UserInputService").JumpRequest:Connect(function()
    if config.bunnyHop and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        if lp.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- // NoRecoil / NoSpread (patched via metatable hook)
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if method == "FireServer" and tostring(self):lower():find("shoot") then
        if config.noSpread then
            args[2] = CFrame.new(args[2].p) -- No random spread offset
        end
        if config.noRecoil then
            args[3] = Vector3.new(0, 0, 0) -- Remove recoil data
        end
        return old(self, unpack(args))
    end

    return old(self, ...)
end)
setreadonly(mt, true)
