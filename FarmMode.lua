local addonName = ...
local farming = false
local db
local settingsCategory
local optionsPanel
local originalZoom

-- Keybinding globals
BINDING_HEADER_FARMMODE = "FarmMode"
BINDING_NAME_FARMMODE_TOGGLE = "Toggle Farm Mode"

local defaults = {
    scale = 1.5,
    xOffset = 0,
    yOffset = 300,
    draggable = true,
    zoom = 0,
    opacity = 100,
    hideClutter = false,
}

local clutterFrames = {
    "MinimapZoomIn",
    "MinimapZoomOut",
    "MiniMapWorldMapButton",
    "MiniMapTracking",
    "MinimapZoneTextButton",
    "MinimapToggleButton",
    "MinimapBorderTop",
    "GameTimeFrame",
}

-- Event frame
local frame = CreateFrame("Frame", "FarmModeFrame", UIParent)
frame:RegisterEvent("ADDON_LOADED")

local function InitDB()
    if not FarmModeDB then FarmModeDB = {} end
    for k, v in pairs(defaults) do
        if FarmModeDB[k] == nil then
            FarmModeDB[k] = v
        end
    end
    -- Migrate old 0.0-1.0 opacity values to 0-100 range
    if FarmModeDB.opacity and FarmModeDB.opacity <= 1 then
        FarmModeDB.opacity = math.floor(FarmModeDB.opacity * 100 + 0.5)
    end
    db = FarmModeDB
end

local function HideMinimapClutter()
    for _, name in ipairs(clutterFrames) do
        local f = _G[name]
        if f and f.Hide then f:Hide() end
    end
end

local function ShowMinimapClutter()
    for _, name in ipairs(clutterFrames) do
        local f = _G[name]
        if f and f.Show then f:Show() end
    end
end

-- Drag support
local function EnableDrag()
    Minimap:SetMovable(true)
    Minimap:RegisterForDrag("LeftButton")
    Minimap:SetScript("OnDragStart", function(self) self:StartMoving() end)
    Minimap:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local cx, cy = self:GetCenter()
        local ux, uy = UIParent:GetCenter()
        local s = self:GetScale()
        db.xOffset = math.floor(cx * s - ux + 0.5)
        db.yOffset = math.floor(cy * s - uy + 0.5)
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", db.xOffset, db.yOffset)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FarmMode:|r Position saved (" .. db.xOffset .. ", " .. db.yOffset .. ")")
    end)
end

local function DisableDrag()
    Minimap:SetMovable(false)
    Minimap:RegisterForDrag()
    Minimap:SetScript("OnDragStart", nil)
    Minimap:SetScript("OnDragStop", nil)
end

-- Toggle
local function FarmOn()
    originalZoom = Minimap:GetZoom()
    Minimap:ClearAllPoints()
    Minimap:SetPoint("CENTER", UIParent, "CENTER", db.xOffset, db.yOffset)
    Minimap:SetScale(db.scale)
    Minimap:SetZoom(db.zoom)
    Minimap:SetAlpha(db.opacity / 100)
    if db.draggable then EnableDrag() end
    if db.hideClutter then HideMinimapClutter() end
    farming = true
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FarmMode:|r On - Minimap centered and enlarged." ..
        (db.draggable and " Drag to reposition." or ""))
end

local function FarmOff()
    DisableDrag()
    ShowMinimapClutter()
    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
    Minimap:SetScale(1)
    Minimap:SetZoom(originalZoom or 3)
    Minimap:SetAlpha(1)
    farming = false
    DEFAULT_CHAT_FRAME:AddMessage("|cffff6600FarmMode:|r Off")
end

function FarmMode_Toggle()
    if farming then FarmOff() else FarmOn() end
end

----------------------------------------------------------------
-- ElvUI-style Options Panel
----------------------------------------------------------------
local function CreateOptions()
    local panel = CreateFrame("Frame", "FarmModeOptions", UIParent)
    panel.name = addonName

    -- Color palette
    local C_ACCENT  = {0.00, 0.70, 1.00}
    local C_GOLD    = {1.00, 0.82, 0.00}
    local C_TRACK   = {0.12, 0.12, 0.12}
    local C_EDITBG  = {0.08, 0.08, 0.08}
    local C_HOVER   = {0.25, 0.25, 0.25}

    -- Panel background
    local panelBg = panel:CreateTexture(nil, "BACKGROUND")
    panelBg:SetAllPoints()
    panelBg:SetColorTexture(0.05, 0.05, 0.05, 0.9)

    --------------------------------------------------------
    -- Helpers
    --------------------------------------------------------
    local function AddBorder(f)
        local t
        t = f:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetPoint("TOPLEFT", -1, 1)
        t:SetPoint("TOPRIGHT", 1, 1)
        t:SetHeight(1)
        t:SetColorTexture(0, 0, 0, 1)

        t = f:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetPoint("BOTTOMLEFT", -1, -1)
        t:SetPoint("BOTTOMRIGHT", 1, -1)
        t:SetHeight(1)
        t:SetColorTexture(0, 0, 0, 1)

        t = f:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetPoint("TOPLEFT", -1, 1)
        t:SetPoint("BOTTOMLEFT", -1, -1)
        t:SetWidth(1)
        t:SetColorTexture(0, 0, 0, 1)

        t = f:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetPoint("TOPRIGHT", 1, 1)
        t:SetPoint("BOTTOMRIGHT", 1, -1)
        t:SetWidth(1)
        t:SetColorTexture(0, 0, 0, 1)
    end

    -- Styled slider with fill bar + editbox
    local function MakeSlider(anchor, yOff, labelText, minVal, maxVal, step, fmt)
        -- Label
        local label = panel:CreateFontString(nil, "OVERLAY")
        label:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        label:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff)
        label:SetText(labelText)

        -- Value readout next to label
        local valText = panel:CreateFontString(nil, "OVERLAY")
        valText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        valText:SetTextColor(1, 1, 1)
        valText:SetPoint("LEFT", label, "RIGHT", 6, 0)

        -- Slider track
        local s = CreateFrame("Slider", nil, panel)
        s:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
        s:SetSize(200, 12)
        s:SetMinMaxValues(minVal, maxVal)
        s:SetValueStep(step)
        s:SetObeyStepOnDrag(true)
        s:EnableMouse(true)

        local bg = s:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(C_TRACK[1], C_TRACK[2], C_TRACK[3], 1)
        AddBorder(s)

        -- Accent fill bar
        local fill = s:CreateTexture(nil, "ARTWORK")
        fill:SetPoint("TOPLEFT")
        fill:SetPoint("BOTTOMLEFT")
        fill:SetColorTexture(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.35)
        fill:SetWidth(1)

        -- Thumb
        s:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
        local thumb = s:GetThumbTexture()
        thumb:SetVertexColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 1)
        thumb:SetSize(8, 12)

        -- Editbox
        local eb = CreateFrame("EditBox", nil, panel)
        eb:SetPoint("LEFT", s, "RIGHT", 10, 0)
        eb:SetSize(52, 18)
        eb:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        eb:SetAutoFocus(false)
        eb:SetJustifyH("CENTER")
        eb:SetTextColor(1, 1, 1)

        local eBg = eb:CreateTexture(nil, "BACKGROUND")
        eBg:SetAllPoints()
        eBg:SetColorTexture(C_EDITBG[1], C_EDITBG[2], C_EDITBG[3], 1)
        AddBorder(eb)

        -- Display helper
        local function Display(value)
            local fmtText = fmt and string.format(fmt, value) or tostring(value)
            valText:SetText(fmtText)
            -- Editbox shows bare number
            local bare
            if step >= 1 then
                bare = tostring(math.floor(value + 0.5))
            else
                bare = string.format("%." .. math.max(1, math.ceil(-math.log10(step))) .. "f", value)
            end
            if not eb:HasFocus() then eb:SetText(bare) end
            -- Fill width
            local pct = (value - minVal) / (maxVal - minVal)
            fill:SetWidth(math.max(1, s:GetWidth() * pct))
        end

        s:SetScript("OnValueChanged", function(self, value)
            if step >= 1 then
                value = math.floor(value + 0.5)
            else
                local m = 1 / step
                value = math.floor(value * m + 0.5) / m
            end
            Display(value)
            if self.onChange then self.onChange(value) end
        end)

        eb:SetScript("OnEnterPressed", function(self)
            local v = tonumber(self:GetText())
            if v then
                v = math.max(minVal, math.min(maxVal, v))
                if step >= 1 then
                    v = math.floor(v / step + 0.5) * step
                else
                    local m = 1 / step
                    v = math.floor(v * m + 0.5) / m
                end
                s:SetValue(v)
            else
                Display(s:GetValue())
            end
            self:ClearFocus()
        end)

        eb:SetScript("OnEscapePressed", function(self)
            Display(s:GetValue())
            self:ClearFocus()
        end)

        s._anchor = s  -- next element anchors to the slider
        return s
    end

    -- Styled checkbox
    local function MakeCheck(anchor, yOff, labelText)
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(16, 16)
        btn:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(C_TRACK[1], C_TRACK[2], C_TRACK[3], 1)
        AddBorder(btn)

        local mark = btn:CreateTexture(nil, "ARTWORK")
        mark:SetPoint("TOPLEFT", 3, -3)
        mark:SetPoint("BOTTOMRIGHT", -3, 3)
        mark:SetColorTexture(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 1)
        mark:Hide()

        btn.checked = false

        btn:SetScript("OnClick", function(self)
            self.checked = not self.checked
            if self.checked then mark:Show() else mark:Hide() end
            PlaySound(856)
            if self.onChange then self.onChange(self.checked) end
        end)

        function btn:SetChecked(val)
            self.checked = val and true or false
            if self.checked then mark:Show() else mark:Hide() end
        end
        function btn:GetChecked() return self.checked end

        local label = panel:CreateFontString(nil, "OVERLAY")
        label:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        label:SetTextColor(0.9, 0.9, 0.9)
        label:SetPoint("LEFT", btn, "RIGHT", 8, 0)
        label:SetText(labelText)

        return btn
    end

    -- Styled button
    local function MakeButton(anchor, yOff, text, width)
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(width or 120, 22)
        btn:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(C_TRACK[1], C_TRACK[2], C_TRACK[3], 1)
        AddBorder(btn)

        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        lbl:SetPoint("CENTER")
        lbl:SetText(text)
        lbl:SetTextColor(1, 1, 1)

        btn:SetScript("OnEnter", function() bg:SetColorTexture(C_HOVER[1], C_HOVER[2], C_HOVER[3], 1) end)
        btn:SetScript("OnLeave", function() bg:SetColorTexture(C_TRACK[1], C_TRACK[2], C_TRACK[3], 1) end)

        return btn
    end

    --------------------------------------------------------
    -- Layout
    --------------------------------------------------------

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
    title:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("FarmMode")

    -- Subtitle
    local desc = panel:CreateFontString(nil, "OVERLAY")
    desc:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    desc:SetTextColor(0.6, 0.6, 0.6)
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    desc:SetText("Minimap position, scale, and appearance for gathering.")

    -- Thin accent line under header
    local headerLine = panel:CreateTexture(nil, "ARTWORK")
    headerLine:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -6)
    headerLine:SetSize(270, 1)
    headerLine:SetColorTexture(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.4)

    -- Sliders
    local scaleSlider = MakeSlider(headerLine, -14, "Scale", 1.0, 3.0, 0.1, "%.1f")
    scaleSlider.onChange = function(v)
        db.scale = v
        if farming then Minimap:SetScale(v) end
    end

    local zoomSlider = MakeSlider(scaleSlider, -20, "Zoom Level", 0, 5, 1, "%d")
    zoomSlider.onChange = function(v)
        db.zoom = v
        if farming then Minimap:SetZoom(v) end
    end

    local opacitySlider = MakeSlider(zoomSlider, -20, "Opacity", 30, 100, 5, "%d%%")
    opacitySlider.onChange = function(v)
        db.opacity = v
        if farming then Minimap:SetAlpha(v / 100) end
    end

    local xSlider = MakeSlider(opacitySlider, -20, "X Offset  (Left / Right)", -500, 500, 10, "%d")
    xSlider.onChange = function(v)
        db.xOffset = v
        if farming then
            Minimap:ClearAllPoints()
            Minimap:SetPoint("CENTER", UIParent, "CENTER", db.xOffset, db.yOffset)
        end
    end

    local ySlider = MakeSlider(xSlider, -20, "Y Offset  (Down / Up)", -500, 500, 10, "%d")
    ySlider.onChange = function(v)
        db.yOffset = v
        if farming then
            Minimap:ClearAllPoints()
            Minimap:SetPoint("CENTER", UIParent, "CENTER", db.xOffset, db.yOffset)
        end
    end

    -- Checkboxes
    local dragCheck = MakeCheck(ySlider, -18, "Allow dragging minimap in farm mode")
    dragCheck.onChange = function(checked)
        db.draggable = checked
        if farming then
            if checked then EnableDrag() else DisableDrag() end
        end
    end

    local clutterCheck = MakeCheck(dragCheck, -8, "Hide minimap buttons in farm mode")
    clutterCheck.onChange = function(checked)
        db.hideClutter = checked
        if farming then
            if checked then HideMinimapClutter() else ShowMinimapClutter() end
        end
    end

    -- Separator
    local sepLine = panel:CreateTexture(nil, "ARTWORK")
    sepLine:SetPoint("TOPLEFT", clutterCheck, "BOTTOMLEFT", 0, -12)
    sepLine:SetSize(270, 1)
    sepLine:SetColorTexture(0.2, 0.2, 0.2, 1)

    -- Reset button
    local resetBtn = MakeButton(sepLine, -10, "Reset Defaults", 110)
    resetBtn:SetScript("OnClick", function()
        for k, v in pairs(defaults) do db[k] = v end
        scaleSlider:SetValue(db.scale)
        zoomSlider:SetValue(db.zoom)
        opacitySlider:SetValue(db.opacity)
        xSlider:SetValue(db.xOffset)
        ySlider:SetValue(db.yOffset)
        dragCheck:SetChecked(db.draggable)
        clutterCheck:SetChecked(db.hideClutter)
        if farming then
            Minimap:SetScale(db.scale)
            Minimap:SetZoom(db.zoom)
            Minimap:SetAlpha(db.opacity / 100)
            Minimap:ClearAllPoints()
            Minimap:SetPoint("CENTER", UIParent, "CENTER", db.xOffset, db.yOffset)
            if db.draggable then EnableDrag() else DisableDrag() end
            ShowMinimapClutter()
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FarmMode:|r Settings reset to defaults")
    end)

    -- Hint
    local hint = panel:CreateFontString(nil, "OVERLAY")
    hint:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    hint:SetTextColor(0.4, 0.4, 0.4)
    hint:SetPoint("TOPLEFT", resetBtn, "BOTTOMLEFT", 0, -12)
    hint:SetText("Changes apply live  |  Key Bindings > FarmMode for hotkey")

    local url = panel:CreateFontString(nil, "OVERLAY")
    url:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    url:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.6)
    url:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -6)
    url:SetText("github.com/paradosi/FarmMode")

    --------------------------------------------------------
    -- OnShow — sync UI to saved values
    --------------------------------------------------------
    panel:SetScript("OnShow", function()
        scaleSlider:SetValue(db.scale)
        zoomSlider:SetValue(db.zoom)
        opacitySlider:SetValue(db.opacity)
        xSlider:SetValue(db.xOffset)
        ySlider:SetValue(db.yOffset)
        dragCheck:SetChecked(db.draggable)
        clutterCheck:SetChecked(db.hideClutter)
    end)

    --------------------------------------------------------
    -- Register
    --------------------------------------------------------
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, addonName)
        Settings.RegisterAddOnCategory(category)
        settingsCategory = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end

    optionsPanel = panel
end

-- Event handler
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitDB()
        CreateOptions()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Slash command
SLASH_FARMMODE1 = "/farm"
SlashCmdList["FARMMODE"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$") or ""
    if msg == "config" or msg == "options" or msg == "settings" then
        if Settings and Settings.OpenToCategory and settingsCategory then
            Settings.OpenToCategory(settingsCategory:GetID())
        elseif InterfaceOptionsFrame_OpenToCategory and optionsPanel then
            InterfaceOptionsFrame_OpenToCategory(optionsPanel)
            InterfaceOptionsFrame_OpenToCategory(optionsPanel)
        end
        return
    end
    FarmMode_Toggle()
end
