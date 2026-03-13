--// Startup Notification
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "faeiana.exe",
        Text = "Execution started.",
        Duration = 3
    })
end)

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local CurrentCamera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Config
local Config = {
    MasterLock = false,
    MasterSpeed = true,

    LockActive = false,
    SpeedActive = false,

    MouseLockKey = Enum.KeyCode.C,
    WalkSpeedKey = Enum.KeyCode.V,
    ToggleGUIKey = Enum.KeyCode.F4,

    UseRightClick = false,
    ActivationType = "Toggle",

    Smoothness = 0.71,
    Prediction = 0.250,
    LeftOffset = 2.34,
    UpOffset = -10.53,
    HitPart = 'HumanoidRootPart',
    WalkSpeedValue = 300,

    HipHeightEnabled = false,
    HipHeightValue = 2,

    HitboxEnabled = false,
    HitboxSize = 2,
}

--// GUI Setup
local ImGui = loadstring(game:HttpGet('https://github.com/depthso/Roblox-ImGUI/raw/main/ImGui.lua'))()

local Window = ImGui:CreateWindow({
    Title = 'FAEIANAS LEGIT SETS <3',
    Size = UDim2.fromOffset(400, 480),
    Position = UDim2.fromScale(0.5, 0.2),
})

--// Main Flamelock Tab
local MouseTab = Window:CreateTab({ Name = 'cam' })

MouseTab:Checkbox({
    Label = 'Enable ',
    Value = Config.MasterLock,
    Callback = function(_, v)
        Config.MasterLock = v
        Config.LockActive = false
    end,
})

MouseTab:Combo({
    Label = 'Activation Type',
    Items = {"Toggle", "Hold"},
    Value = Config.ActivationType,
    Callback = function(_, v)
        Config.ActivationType = v
        Config.LockActive = false
    end,
})

MouseTab:Slider({
    Label = 'Smoothness', MinValue = 0, MaxValue = 1,
    Value = Config.Smoothness, Callback = function(_, v) Config.Smoothness = v end,
})

--// Movement Tab
local MoveTab = Window:CreateTab({ Name = 'movement' })
MoveTab:Checkbox({
    Label = 'Enable Speed ',
    Value = Config.MasterSpeed,
    Callback = function(_, v)
        Config.MasterSpeed = v
        Config.SpeedActive = false
    end,
})
MoveTab:Slider({
    Label = 'Speed Value', MinValue = 16, MaxValue = 500,
    Value = Config.WalkSpeedValue, Callback = function(_, v) Config.WalkSpeedValue = v end,
})

--// Hip Height Tab
local HipTab = Window:CreateTab({ Name = 'hip height' })

HipTab:Checkbox({
    Label = 'Enable HipHeight',
    Value = Config.HipHeightEnabled,
    Callback = function(_, v)
        Config.HipHeightEnabled = v
    end,
})

HipTab:Slider({
    Label = 'HipHeight (-10 to 10)',
    MinValue = -10,
    MaxValue = 10,
    Value = Config.HipHeightValue,
    Callback = function(_, v)
        Config.HipHeightValue = v
    end,
})

--// HITBOX EXPANDER TAB
local HitboxTab = Window:CreateTab({ Name = 'hbe' })

HitboxTab:Checkbox({
    Label = 'Enable Hitbox Expander',
    Value = Config.HitboxEnabled,
    Callback = function(_, v)
        Config.HitboxEnabled = v
        if v then
            _G.HeadSize = Config.HitboxSize
            _G.HitboxTransparencyValue = 1
            _G.HitboxColor = "Really black"
        else
            _G.HeadSize = 0
        end
    end,
})

HitboxTab:Slider({
    Label = 'Hitbox Size',
    MinValue = 0,
    MaxValue = 10,
    Value = Config.HitboxSize,
    Callback = function(_, v)
        Config.HitboxSize = v
        if Config.HitboxEnabled then
            _G.HeadSize = v
        end
    end,
})

--// Settings Tab
local SettingsTab = Window:CreateTab({ Name = 'settings' })

SettingsTab:Label({ Text = "— Keybinds —" })

SettingsTab:Keybind({
    Label = 'Cam Key',
    Value = Config.MouseLockKey,
    Callback = function(_, v) Config.MouseLockKey = v end,
})

SettingsTab:Keybind({
    Label = 'Speed Toggle Key',
    Value = Config.WalkSpeedKey,
    Callback = function(_, v) Config.WalkSpeedKey = v end,
})

SettingsTab:Keybind({
    Label = 'Hide UI Key',
    Value = Config.ToggleGUIKey,
    Callback = function(_, v) Config.ToggleGUIKey = v end,
})

--// Target Logic
local target = nil
local function getClosestTarget()
    local closest, shortest = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Config.HitPart) then
            local part = plr.Character[Config.HitPart]
            local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < shortest then
                    closest = part
                    shortest = dist
                end
            end
        end
    end
    return closest
end

--// Input Handling
local function handleActivation(isInputBegin)
    if not Config.MasterLock then return end

    if Config.ActivationType == "Toggle" then
        if isInputBegin then
            Config.LockActive = not Config.LockActive
            target = Config.LockActive and getClosestTarget() or nil
        end
    elseif Config.ActivationType == "Hold" then
        Config.LockActive = isInputBegin
        target = isInputBegin and getClosestTarget() or nil
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    local isMouse = (input.UserInputType == Enum.UserInputType.MouseButton2 and Config.UseRightClick)
    local isKey = (input.KeyCode == Config.MouseLockKey and not Config.UseRightClick)

    if isMouse or isKey then
        handleActivation(true)
    elseif input.KeyCode == Config.WalkSpeedKey and Config.MasterSpeed then
        Config.SpeedActive = not Config.SpeedActive
    elseif input.KeyCode == Config.ToggleGUIKey then
        Window:SetVisible(not Window.Visible)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local isMouse = (input.UserInputType == Enum.UserInputType.MouseButton2 and Config.UseRightClick)
    local isKey = (input.KeyCode == Config.MouseLockKey and not Config.UseRightClick)

    if (isMouse or isKey) and Config.ActivationType == "Hold" then
        handleActivation(false)
    end
end)

--// Hitbox Script Loader
_G.HeadSize = Config.HitboxSize
_G.HitboxTransparencyValue = 1
_G.HitboxColor = "Really black"

loadstring(game:HttpGet("https://gist.githubusercontent.com/vejuxas/bdd5d826525d1ad5984b0d85557393ac/raw/98ba5cca53317dd3613f0c9d46283d916de4e33f/hitbox%20expander"))()

--------------------------------------------------------------------
-- ⭐ FIXED LOOPS (FINAL WORKING VERSION)
--------------------------------------------------------------------

--// CAM LOOP
RunService.RenderStepped:Connect(function()
    if Config.MasterLock and Config.LockActive and target and target.Parent then
        local targetPos = target.Position + (target.Velocity * Config.Prediction)
        local camRight = CurrentCamera.CFrame.RightVector
        local offsetVec = (camRight * Config.LeftOffset) + Vector3.new(0, Config.UpOffset, 0)
        local finalPos = targetPos + offsetVec
        local finalScreenPos, onScreen = CurrentCamera:WorldToViewportPoint(finalPos)

        if onScreen then
            local mousePos = UserInputService:GetMouseLocation()
            pcall(function()
                mousemoverel(
                    (finalScreenPos.X - mousePos.X) * Config.Smoothness,
                    (finalScreenPos.Y - mousePos.Y) * Config.Smoothness
                )
            end)
        end
    end
end)

--// SPEED LOOP (RenderStepped, isolated)
RunService.RenderStepped:Connect(function()
    if Config.MasterSpeed and Config.SpeedActive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Config.WalkSpeedValue
        end
    end
end)

--// HIPHEIGHT LOOP
RunService.RenderStepped:Connect(function()
    if Config.HipHeightEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.HipHeight = Config.HipHeightValue
        end
    end
end)
