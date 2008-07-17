events = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_FAILED_QUIET", -- might not need this!
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_CHANNEL_UPDATE", -- Fired when a channel spell gets interrupted or delayed
}
function oCastBarFrame_OnLoad(unit)
    -- Register all events!
    for _, ev in pairs(events) do
        this:RegisterEvent(ev)
    end
    
    CastingBarFrame:UnregisterAllEvents()
    this.unit = unit
    this.spellTexture = getglobal(this:GetName() .. "Icon")
    this.castBarSpellName = getglobal(this:GetName() .. "Name")
    this.backDrop = getglobal(this:GetName() .. "Backdrop")
    this.isCasting = nil
    this.startTime = nil
    this.endTime = nil
end
-- START: 1.0, 0.7, 0, 1.0
-- STOP: 0.0, 1.0, 0.0
-- FAILED / INTERRUPTED: 1.0, 0.0, 0.0
-- DELAYED: 1.0, 0.7, 0.0
-- CHANNEL_START: 0.0, 1.0, 0.0
-- Implement:
-- SavedVariabled & a config, so that user can move the bar, etc..
-- Channeled spells
function oCastBarFrame_OnEvent(nevent, narg)
    if nevent == "UNIT_SPELLCAST_START" then
        local spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unit)
        if not spell then 
            return
        end
 
        if this.backDrop then
            this.backDrop:SetVertexColor(1.0, 0.7, 0.0)
            this.backDrop:SetAlpha(0.5)
        end
        this.isCasting = true
        this.startTime = startTime / 1000; this.endTime = endTime / 1000
        this:SetMinMaxValues(this.startTime, this.endTime)
        this:SetValue(this.startTime)
        this:SetStatusBarColor(1.0, 0.7, 0, 1.0)
        if this.spellTexture then
            this.spellTexture:SetTexture(icon)
            this.spellTexture:Show()
        end
        if this.castBarSpellName then
            this.castBarSpellName:SetText(string.format("%s %s", displayName, rank))
        end
        this:Show()
    elseif nevent == "UNIT_SPELLCAST_DELAYED" then
        local spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unit)
        if not spell then
            return
        end
        
        this.startTime = startTime / 1000; this.endTime = endTime / 1000
        this:SetMinMaxValues(this.startTime, this.endTime)
        this:SetValue(this.startTime)
    elseif nevent == "UNIT_SPELLCAST_END" then
        this.isCasting = false
        this:Hide()
    elseif nevent == "UNIT_SPELLCAST_INTERRUPTED" then
        this.isCasting = false
        this:Hide()
    elseif nevent == "UNIT_SPELLCAST_SUCCEEDED" then
        this.isCasting = false
        this:Hide()
    end
end

function oCastBarFrame_OnUpdate()
    if this.isCasting then
        local current = GetTime()
        if current > this.endTime then
            current = this.endTime
        end
        this:SetValue(current)
    end
end

