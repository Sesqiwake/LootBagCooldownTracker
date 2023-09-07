local addonName = "LootBag Cooldown Tracker"
local buffNameToCheck = "Эликсир поиска сокровищ"
local itemNameToCheck = "Мешочек сокровищ"
local countdownTime = 15

local frame = CreateFrame("Frame")
local countdownFrame = CreateFrame("Frame")
local timeLeft = countdownTime
local timerActive = false
local buffPresent = false

local bigTextFrame = CreateFrame("Frame", nil, UIParent)
bigTextFrame:SetSize(400, 300)
bigTextFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -50)
bigTextFrame.text = bigTextFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
bigTextFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 26)
bigTextFrame.text:SetPoint("CENTER", bigTextFrame, "CENTER")
bigTextFrame:Hide()


local killImageFrame = CreateFrame("Frame", nil, UIParent)
killImageFrame:SetSize(32, 32)
-- killImageFrame:SetPoint("CENTER", UIParent, "CENTER")
killImageFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -50)
killImageFrame.texture = killImageFrame:CreateTexture(nil, "BACKGROUND")
killImageFrame.texture:SetAllPoints(killImageFrame)
killImageFrame.texture:SetTexture("Interface\\AddOns\\MyGoldAddon\\inv_misc_bag_felclothbag.tga")
killImageFrame:Hide()


local function HasBuff()
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if name == buffNameToCheck then
            return true
        end
    end
    return false
end

local function ShowKillMessage()
    bigTextFrame:Hide()
    killImageFrame:Show()
end

local function EndCountdown()
    countdownFrame:SetScript("OnUpdate", nil)
    timerActive = false
    timeLeft = countdownTime
    bigTextFrame:Hide()
    UIErrorsFrame:Clear()
    ShowKillMessage()
end

local function StartCountdown()
    if timerActive then
        timeLeft = countdownTime
        UIErrorsFrame:Clear()
    else
        timerActive = true
        bigTextFrame:Hide()
        countdownFrame:SetScript("OnUpdate", function(self, elapsed)
            timeLeft = timeLeft - elapsed
            if timeLeft <= 0 then
                EndCountdown()
            else
                bigTextFrame.text:SetText(string.format("%.0f", timeLeft))
                bigTextFrame:Show()
            end
        end)
    end
end

local function OnEvent(self, event, msg)
    if event == "CHAT_MSG_LOOT" then
        if string.find(msg, itemNameToCheck) then
            StartCountdown()
        end
    elseif event == "UNIT_AURA" then
        if msg == "player" then
            local hasBuffNow = HasBuff()
            if hasBuffNow and not buffPresent then
                DEFAULT_CHAT_FRAME:AddMessage(addonName .. " ЗАПУЩЕН", 1, 1, 0)
                buffPresent = true
                ShowKillMessage()
                frame:RegisterEvent("CHAT_MSG_LOOT")
            elseif not hasBuffNow and buffPresent then
                DEFAULT_CHAT_FRAME:AddMessage(addonName .. " ОСТАНОВЛЕН", 1, 1, 0)
                buffPresent = false
                frame:UnregisterEvent("CHAT_MSG_LOOT")
                countdownFrame:SetScript("OnUpdate", nil)
                bigTextFrame:Hide()
                timerActive = false
                timeLeft = countdownTime
                UIErrorsFrame:Clear()
                killImageFrame:Hide()
            end
        end
    end
end

frame:RegisterEvent("UNIT_AURA")
frame:SetScript("OnEvent", OnEvent)
