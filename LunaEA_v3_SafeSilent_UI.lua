
-- LunaSoft_v4_AirHub_Integrated.lua

--// AirHub Modules
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/Modules/Aimbot.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/Modules/Wall%20Hack.lua"))()

--// Подключение UI и инициализация
local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Aimbot, WallHack = getgenv().AirHub.Aimbot, getgenv().AirHub.WallHack

-- Настройка простого окна
local MainFrame = Library:CreateWindow({
    Name = "LunaSoft AirHub",
    Themeable = {
        Info = "Aimbot + WallHack (ESP) by Exunys & LunaSoft",
        Credit = false
    }
})

local tab = MainFrame:CreateTab({ Name = "Main" })
local section = tab:CreateSection({ Name = "Features" })

section:AddToggle({
    Name = "Aimbot",
    Value = Aimbot.Settings.Enabled,
    Callback = function(val) Aimbot.Settings.Enabled = val end
})

section:AddToggle({
    Name = "ESP",
    Value = WallHack.Settings.Enabled,
    Callback = function(val) WallHack.Settings.Enabled = val end
})

-- Уведомление о запуске
game.StarterGui:SetCore("SendNotification", {
    Title = "LunaSoft x AirHub",
    Text = "Cheat successfully injected.",
    Duration = 5
})
