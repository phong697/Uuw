-- phongdz - Ultimate Chilli-Integrated Hub (V2026 Edition)
-- Target: Steal an Egg (Game ID: 10563114921)
-- Verified Loader Link: loadstring(game:HttpGet("https://githubusercontent.com"))()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "phongdz - Chilli Premium Hub",
   LoadingTitle = "Loading phongdz Hub Elite...",
   LoadingSubtitle = "by phongdz",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "phongdz_config",
      FileName = "phongdz_chilli_v2026"
   },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Từ điển đa ngôn ngữ (VN/EN) đồng bộ hóa hệ thống Chilli Hub
local Lang = {
   Current = "VN",
   Text = {
      VN = {
         tab_lang = "Ngôn Ngữ", tab_farm = "Auto Farm Trứng", tab_train = "Auto Train", tab_chilli = "Chilli Hub Core",
         tab_upgrade = "Xây Căn Cứ & Bán", tab_server = "Quản Lý Server", tab_vis = "Đồ Họa & Tiện Ích",
         drop_lang = "Chọn Ngôn Ngữ", toggle_steal = "Trộm Trứng VIP (To & Đột Biến Nhất)", toggle_treadmill = "Auto Chạy Máy (Tốc Độ)",
         toggle_hatch = "Tự Động Mở Trứng", toggle_rift = "Ưu Tiên Trứng Cổng Nứt (Rift Eggs First)",
         toggle_collide = "Xóa Bỏ Va Chạm (Anti-Collide Body)", toggle_anticrash = "Chống Kẹt Game / Anti-Kick",
         toggle_sell = "Tự Động Bán Trứng (Auto Sell)", toggle_base = "Tự Động Xây/Nâng Cấp Căn Cứ", 
         toggle_esp = "Bật ESP Nhìn Xuyên Tường Trứng", toggle_antiafk = "Bật Chống Treo Máy (Anti-AFK)", 
         btn_rejoin = "Tham Gia Lại Server", btn_hop = "Tìm Server Ít Người", slider_speed = "Vận Tốc Safe Tween",
         warn_title = "⚠️ CẢNH BÁO GRAPHICS!", warn_desc = "Chế độ này sẽ xóa sạch tài nguyên mây trời, đổ bóng, texture để tăng tối đa FPS khi treo máy.",
         notif_title = "Hệ Thống", notif_lang = "Đã đổi sang Tiếng Việt!"
      },
      EN = {
         tab_lang = "Language", tab_farm = "Auto Farm Eggs", tab_train = "Auto Train", tab_chilli = "Chilli Core Features",
         tab_upgrade = "Base & Economy", tab_server = "Server Manager", tab_vis = "Visuals & Protect",
         drop_lang = "Select Language", toggle_steal = "Steal High-Value Eggs (Giant/Mutated)", toggle_treadmill = "Auto Train Treadmill",
         toggle_hatch = "Auto Hatch Eggs", toggle_rift = "Prioritize Rift Event Eggs First",
         toggle_collide = "Disable Body Collisions (NoClip)", toggle_anticrash = "Optimize Performance (Anti-Crash)",
         toggle_sell = "Auto Sell Eggs to Base", toggle_base = "Auto Upgrade Base & Plots", 
         toggle_esp = "Enable Egg ESP (Chams)", toggle_antiafk = "Enable Anti-AFK (No Disconnect)", 
         btn_rejoin = "Rejoin Server", btn_hop = "Server Hop (Low Players)", slider_speed = "Safe Tween Velocity",
         warn_title = "⚠️ GRAPHICS WARNING!", warn_desc = "This will delete all environmental skies, textures, and shading to reach maximum FPS boost.",
         notif_title = "System", notif_lang = "Language changed to English!"
      }
   }
}

-- Khởi tạo phân trang theo đúng cấu trúc tệp nạp
local LangTab = Window:CreateTab(Lang.Text[Lang.Current].tab_lang, 4483362458)
local FarmTab = Window:CreateTab(Lang.Text[Lang.Current].tab_farm, 4483362458)
local TrainTab = Window:CreateTab(Lang.Text[Lang.Current].tab_train, 4483362458)
local ChilliTab = Window:CreateTab(Lang.Text[Lang.Current].tab_chilli, 4483362458)
local UpgradeTab = Window:CreateTab(Lang.Text[Lang.Current].tab_upgrade, 4483362458)
local ServerTab = Window:CreateTab(Lang.Text[Lang.Current].tab_server, 4483362458)
local VisTab = Window:CreateTab(Lang.Text[Lang.Current].tab_vis, 4483362458)

-- Biến trạng thái cấu hình
local _G = getgenv and getgenv() or _G
_G.AutoSteal, _G.AutoTreadmill, _G.AutoHatch, _G.PrioritizeRift = false, false, false, false
_G.AntiCollide, _G.AntiCrash, _G.AutoSell, _G.AutoBase = false, false, false, false
_G.EggESP, _G.AntiAFK = false, false
_G.SelectedEggType, _G.TweenSpeed = "CommonEgg", 45

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local Elements = {}

-- Bộ lọc chấm điểm trứng mở rộng dựa trên lõi mã của Chilli Hub
local function GetAdvancedEggValue(egg)
    local score = 1
    local name = egg.Name:lower()
    
    if _G.PrioritizeRift and (name:find("rift") or egg:GetAttribute("Rift")) then
        return 99999
    end
    
    if name:find("cherry") or name:find("cosmic") or name:find("divine") or name:find("eternal") then score = score + 50
    elseif name:find("event") or name:find("mythic") then score = score + 30
    elseif name:find("legendary") then score = score + 20
    elseif name:find("epic") then score = score + 10
    elseif name:find("rare") then score = score + 5 end
    
    if name:find("rainbow") or egg:GetAttribute("Rainbow") then score = score * 3.5
    elseif name:find("parasite") or egg:GetAttribute("Parasite") then score = score * 3.0
    elseif name:find("golden") or egg:GetAttribute("Golden") then score = score * 2.5 end
    if name:find("giant") or name:find("large") or (egg:IsA("BasePart") and egg.Size.Magnitude > 8) then score = score * 2.0 end
    return score
end

local function SafeMoveTo(targetCFrame)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    task.wait(math.random(10, 25) / 100)
end

-- ==================== TRANG 1: NGÔN NGỮ ====================
Elements.LangDropdown = LangTab:CreateDropdown({
   Name = Lang.Text[Lang.Current].drop_lang, Options = {"Tiếng Việt (VN)", "English (EN)"}, CurrentOption = {"Tiếng Việt (VN)"}, MultipleOptions = false,
   Callback = function(Option)
      Lang.Current = (Option == "Tiếng Việt (VN)") and "VN" or "EN"
      local text = Lang.Text[Lang.Current]
      
      -- Sửa lỗi: Cập nhật tiêu đề chữ thời gian thực
      LangTab:SetTitle(text.tab_lang)
      FarmTab:SetTitle(text.tab_farm)
      TrainTab:SetTitle(text.tab_train)
      ChilliTab:SetTitle(text.tab_chilli)
      UpgradeTab:SetTitle(text.tab_upgrade)
      ServerTab:SetTitle(text.tab_server)
      VisTab:SetTitle(text.tab_vis)
      
      if Elements.StealToggle then Elements.StealToggle:SetTitle(text.toggle_steal) end
      if Elements.TreadmillToggle then Elements.TreadmillToggle:SetTitle(text.toggle_treadmill) end
      if Elements.RiftToggle then Elements.RiftToggle:SetTitle(text.toggle_rift) end
      if Elements.CollideToggle then Elements.CollideToggle:SetTitle(text.toggle_collide) end
      if Elements.CrashToggle then Elements.CrashToggle:SetTitle(text.toggle_anticrash) end
      if Elements.SellToggle then Elements.SellToggle:SetTitle(text.toggle_sell) end
   end,
})

-- ==================== TRANG 2: AUTO FARM TRỨNG GIÁ TRỊ CAO ====================
Elements.StealToggle = FarmTab:CreateToggle({
   Name = Lang.Text[Lang.Current].toggle_steal, CurrentValue = false,
   Callback = function(Value)
      _G.AutoSteal = Value
      if Value then
          task.spawn(function()
              while _G.AutoSteal do
                  local eggList = {}
                  for _, obj in ipairs(workspace:GetDescendants()) do
                      if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj:GetAttribute("Egg")) then
                          table.insert(eggList, {Instance = obj, Value = GetAdvancedEggValue(obj)})
                      end
                  end
                  table.sort(eggList, function(a, b) return a.Value > b.Value end)
                  for _, eggData in ipairs(eggList) do
                      if not _G.AutoSteal then break end
                      if eggData.Instance and eggData.Instance.Parent then SafeMoveTo(eggData.Instance.CFrame + Vector3.new(0, 1.5, 0)) end
                  end
                  task.wait(0.4)
              end
          end)
      end
   end,
})

FarmTab:CreateSlider({
   Name = Lang.Text[Lang.Current].slider_speed, Min = 20, Max = 150, CurrentValue = 45,
   Callback = function(Value) _G.TweenSpeed = Value end,
})

-- ==================== TRANG 3: AUTO TRAIN ====================
Elements.TreadmillToggle = TrainTab:CreateToggle({
   Name = Lang.Text[Lang.Current].toggle_treadmill, CurrentValue = false,
   Callback = function(Value)
      _G.AutoTreadmill = Value
      if Value then
          task.spawn(function()
              while _G.AutoTreadmill do
                  local localBase = workspace:FindFirstChild("Bases") and workspace.Bases:FindFirstChild(LocalPlayer.Name)
                  local treadmill = localBase and localBase:FindFirstChild("Treadmill") or workspace:FindFirstChild("Treadmill", true)
                  local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                  if root and treadmill then
                      root.CFrame = treadmill:IsA("Model") and treadmill:GetPivot() or treadmill.CFrame
                      local trainRemote = game:GetService("ReplicatedStorage"):FindFirstChild("TrainRemote", true) or game:GetService("ReplicatedStorage"):FindFirstChild("TreadmillRemote", true)
                      if trainRemote and trainRemote:IsA("RemoteEvent") then trainRemote:FireServer() end
                  end
                  task.wait(0.05)
              end
          end)
      end
   end,
})

-- ==================== TRANG 4: CHILLI HUB CORE FEATURES ====================
Elements.RiftToggle = ChilliTab:CreateToggle({
Name = Lang.Text[Lang.Current].toggle_rift, CurrentValue = false,
Callback = function(Value) _G.PrioritizeRift = Value end,
})
Elements.CollideToggle = ChilliTab:CreateToggle({
Name = Lang.Text[Lang.Current].toggle_collide, CurrentValue = false,
Callback = function(Value)
_G.AntiCollide = Value
task.spawn(function()
while _G.AntiCollide do
local char = LocalPlayer.Character
if char then
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then part.CanCollide = false end
end
end
task.wait(0.1)
end
end)
end,
})
Elements.CrashToggle = ChilliTab:CreateToggle({
Name = Lang.Text[Lang.Current].toggle_anticrash, CurrentValue = false,
Callback = function(Value)
_G.AntiCrash = Value
if Value then game:GetService("RunService"):Set3dRenderingEnabled(false) else game:GetService("RunService"):Set3dRenderingEnabled(true) end
end,
})
-- ==================== TRANG 5: XÂY CĂN CỨ & TỰ ĐỘNG KINH TẾ ====================
Elements.SellToggle = UpgradeTab:CreateToggle({
Name = Lang.Text[Lang.Current].toggle_sell, CurrentValue = false,
Callback = function(Value)
_G.AutoSell = Value
if Value then
task.spawn(function()
while _G.AutoSell do
local sellPart = workspace:FindFirstChild("SellArea") or workspace:FindFirstChild("Sell", true)
if sellPart then
local currentCFrame = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.CFrame
SafeMoveTo(sellPart:IsA("Model") and sellPart:GetPivot() or sellPart.CFrame)
task.wait(0.2)
if currentCFrame then SafeMoveTo(currentCFrame) end
end
task.wait(4.0)
end
end)
end
end,
})