repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local damageRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Weapon"):WaitForChild("Damage")
local enemiesFolder = workspace:WaitForChild("Enemies")
local timeOfDay = ReplicatedStorage:WaitForChild("GameInfo"):WaitForChild("TimeOfDay")

local LocalPlayer = Players.LocalPlayer
local weaponName = "Katana"

-- 🔥 estado toggle
getgenv().AUTO_ATTACK = not getgenv().AUTO_ATTACK

-- 🔥 guardar último rango usado
getgenv().LAST_RANGE = getgenv().LAST_RANGE or 50
getgenv().RANGE = getgenv().RANGE or getgenv().LAST_RANGE

-- si cambias RANGE desde afuera, se guarda automáticamente
task.spawn(function()
    while true do
        task.wait(0.2)
        if getgenv().RANGE and getgenv().RANGE > 0 then
            getgenv().LAST_RANGE = getgenv().RANGE
        end
    end
end)

-- loop principal
if getgenv().AUTO_ATTACK then
    getgenv().AUTO_ATTACK_LOOP = task.spawn(function()
        while getgenv().AUTO_ATTACK do
            task.wait(0.1)

            local range = getgenv().RANGE

            if not range or range <= 0 then
                continue
            end

            -- día = no atacar
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

else
    -- apagar loop
    getgenv().AUTO_ATTACK = false
end
