repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local damageRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Weapon"):WaitForChild("Damage")
local enemiesFolder = workspace:WaitForChild("Enemies")
local timeOfDay = ReplicatedStorage:WaitForChild("GameInfo"):WaitForChild("TimeOfDay")

local LocalPlayer = Players.LocalPlayer
local weaponName = "Katana"

-- 🔥 evitar duplicar toggle si ya existe
if getgenv().AUTO_ATTACK_LOADED then
    return
end
getgenv().AUTO_ATTACK_LOADED = true

-- estado toggle
getgenv().AUTO_ATTACK = false

-- rango
getgenv().RANGE = getgenv().RANGE or 50

-- loop único
task.spawn(function()
    while true do
        task.wait(0.1)

        if not getgenv().AUTO_ATTACK then
            continue
        end

        local range = getgenv().RANGE

        if not range or range <= 0 then
            continue
        end

        if timeOfDay.Value == "Day" then
            continue
        end

        local char = LocalPlayer.Character
        if not char then continue end

        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end

        for _, npc in pairs(enemiesFolder:GetChildren()) do
            local humanoid = npc:FindFirstChildOfClass("Humanoid")
            local root = npc:FindFirstChild("HumanoidRootPart")

            if humanoid and root and humanoid.Health > 0 then
                local distance = (root.Position - myRoot.Position).Magnitude

                if distance <= range then
                    damageRemote:FireServer(
                        humanoid,
                        weaponName,
                        root.Position
                    )
                end
            end
        end
    end
end)
