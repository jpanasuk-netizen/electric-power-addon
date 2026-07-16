function (self, unitId, unitFrame, envTable, modTable)

    --------------------------------------------------------------------
    -- Config
    --------------------------------------------------------------------
    local STAR_TEX  = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
    local SPARK_TEX = "Interface\\Cooldown\\star4"
    local SOLID     = "Interface\\Buttons\\WHITE8X8"
    local HOLY_POWER = Enum.PowerType.HolyPower

    local DEBUG    = false
    local SOUND_ON = true

    local SND_FIVE = SOUNDKIT.UI_72_ARTIFACT_FORGE_TRAIT_EMBUE
                  or SOUNDKIT.UI_EPICLOOT_TOAST
                  or SOUNDKIT.IG_QUEST_LOG_OPEN

    local WAKE_OF_ASHES = 255937
    local SPENDERS = {
        [85256]  = true,
        [336872] = true,
        [383328] = true,
        [224239] = true,
        [215661] = true,
        [53600]  = true,
        [85673]  = true,
    }

    local sin, min, max = math.sin, math.min, math.max

    local BLOCK = 40
    local STEP  = 47
    local NUM   = 5
    local BAR_W = 250
    local STARTX = (BAR_W - (NUM - 1) * STEP) / 2

    local function HasWings()
        return (AuraUtil.FindAuraByName("Avenging Wrath", "player") ~= nil)
            or (AuraUtil.FindAuraByName("Crusade", "player") ~= nil)
    end

    local function SafePlaySound(kit)
        if SOUND_ON and kit then
            PlaySound(kit, "SFX", true)
        end
    end

    if not _G.BigJ_StarBar_Final then
        local bar = CreateFrame("Frame", "BigJ_StarBar_Final", UIParent)
        bar:SetSize(BAR_W, 70)
        bar:SetFrameStrata("HIGH")
        bar:SetFrameLevel(100)
        bar.blocks = {}
        bar.dawnlightsLeft = 0
        bar.lastPower = -1
        bar.popImpulse = 0
        bar.lastUpdate = 0
        bar.lastDecrement = 0
        bar.flash = 0
        bar.hasWings = HasWings()
        bar.gR, bar.gG, bar.gB = 0.85, 0.83, 0.82
        bar.auraA = 0.06

        bar.aura = bar:CreateTexture(nil, "BACKGROUND")
        bar.aura:SetTexture(SOLID)
        bar.aura:SetBlendMode("ADD")
        bar.aura:SetSize(BAR_W - 6, 26)
        bar.aura:SetPoint("CENTER", bar, "CENTER", 0, 0)
        bar.aura:SetVertexColor(bar.gR, bar.gG, bar.gB)
        bar.aura:SetAlpha(0.06)

        bar.spine = bar:CreateTexture(nil, "ARTWORK")
        bar.spine:SetTexture(SOLID)
        bar.spine:SetSize((NUM - 1) * STEP + BLOCK * 0.7, 3)
        bar.spine:SetPoint("CENTER", bar, "CENTER", 0, 0)
        bar.spine:SetVertexColor(bar.gR, bar.gG, bar.gB)
        bar.spine:SetAlpha(0.22)

        for i = 1, NUM do
            local s = CreateFrame("Frame", nil, bar)
            s:SetFrameLevel(bar:GetFrameLevel() + 2)
            s:SetSize(BLOCK, BLOCK)
            s:SetPoint("CENTER", bar, "LEFT", STARTX + (i - 1) * STEP, 0)

            s.o7 = i * 0.7
            s.o9 = i * 0.9
            s.pp = i / NUM

            local bp = s:CreateTexture(nil, "BACKGROUND")
            bp:SetTexture(STAR_TEX)
            bp:SetTexCoord(0, 0.25, 0, 0.25)
            bp:SetSize(BLOCK * 1.45, BLOCK * 1.45)
            bp:SetPoint("CENTER", s, "CENTER", 0, 0)
            bp:SetVertexColor(0.02, 0.08, 0.12)
            bp:SetAlpha(0.45)

            local ho = s:CreateTexture(nil, "BORDER")
            ho:SetTexture(STAR_TEX)
            ho:SetTexCoord(0, 0.25, 0, 0.25)
            ho:SetBlendMode("ADD")
            ho:SetSize(BLOCK * 1.95, BLOCK * 1.95)
            ho:SetPoint("CENTER", s, "CENTER", 0, 0)
            ho:SetAlpha(0)

            local hi = s:CreateTexture(nil, "ARTWORK")
            hi:SetTexture(STAR_TEX)
            hi:SetTexCoord(0, 0.25, 0, 0.25)
            hi:SetBlendMode("ADD")
            hi:SetSize(BLOCK * 1.3, BLOCK * 1.3)
            hi:SetPoint("CENTER", s, "CENTER", 0, 0)
            hi:SetAlpha(0)

            local co = s:CreateTexture(nil, "ARTWORK")
            co:SetTexture(STAR_TEX)
            co:SetTexCoord(0, 0.25, 0, 0.25)
            co:SetSize(BLOCK, BLOCK)
            co:SetPoint("CENTER", s, "CENTER", 0, 0)
            co:SetVertexColor(0.97, 0.96, 0.94)

            local hot = s:CreateTexture(nil, "OVERLAY")
            hot:SetTexture(STAR_TEX)
            hot:SetTexCoord(0, 0.25, 0, 0.25)
            hot:SetBlendMode("ADD")
            hot:SetSize(BLOCK * 0.55, BLOCK * 0.55)
            hot:SetPoint("CENTER", s, "CENTER", 0, 0)
            hot:SetVertexColor(0.96, 0.88, 0.52)
            hot:SetAlpha(0)

            local sp = s:CreateTexture(nil, "OVERLAY")
            sp:SetTexture(SPARK_TEX)
            sp:SetBlendMode("ADD")
            sp:SetSize(BLOCK * 1.25, BLOCK * 1.25)
            sp:SetPoint("CENTER", s, "CENTER", 0, 0)
            sp:SetVertexColor(0.96, 0.88, 0.62)
            sp:SetAlpha(0)

            s.bp, s.ho, s.hi, s.co, s.hot, s.sp = bp, ho, hi, co, hot, sp
            s.spin = 0
            s.curScale = 1
            s.cR, s.cG, s.cB = 0.97, 0.96, 0.94
            s.hoA, s.hiA, s.hotA, s.spA, s.bpA = 0, 0, 0, 0, 0.45

            bar.blocks[i] = s
        end

        local ef = CreateFrame("Frame")
        ef:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        ef:RegisterEvent("UNIT_AURA")
        ef:SetScript("OnEvent", function(_, event, unit, _, spellID)
            if event == "UNIT_AURA" then
                if unit == "player" then
                    bar.hasWings = HasWings()
                end
                return
            end
            if unit ~= "player" then return end
            local now = GetTime()
            if spellID == WAKE_OF_ASHES then
                bar.dawnlightsLeft = 3
                bar.lastDecrement = now
            elseif SPENDERS[spellID] then
                if bar.dawnlightsLeft > 0 and (now - bar.lastDecrement) > 0.5 then
                    bar.dawnlightsLeft = bar.dawnlightsLeft - 1
                    bar.lastDecrement = now
                    if DEBUG then print("[StarBar] spender", spellID, "-> dawnlights", bar.dawnlightsLeft) end
                end
            end
        end)

        bar:SetScript("OnUpdate", function(self, elapsed)
            self.lastUpdate = self.lastUpdate + elapsed
            if self.lastUpdate < 1/30 then return end
            local dt = self.lastUpdate
            self.lastUpdate = 0

            local plate = C_NamePlate.GetNamePlateForUnit("target")
            if plate then
                self:ClearAllPoints()
                self:SetPoint("BOTTOM", plate, "TOP", 0, 18)
                self:Show()
            else
                self:Hide()
                self.lastPower = -1
                return
            end

            local power = UnitPower("player", HOLY_POWER) or 0
            local now = GetTime()

            local hasWings = self.hasWings

            if power < self.lastPower and (self.lastPower - power) >= 3 then
                if self.dawnlightsLeft > 0 and (now - self.lastDecrement) > 0.5 then
                    self.dawnlightsLeft = self.dawnlightsLeft - 1
                    self.lastDecrement = now
                    if DEBUG then print("[StarBar] power-drop spender -> dawnlights", self.dawnlightsLeft) end
                end
            end

            local inAnshe = self.dawnlightsLeft > 0

            local hitFive = self.lastPower >= 0 and self.lastPower < 5 and power >= 5
            if hitFive then
                SafePlaySound(SND_FIVE)
            end

            if DEBUG and (inAnshe or hasWings) then
                print("[StarBar] dawnlights", self.dawnlightsLeft, "wings", hasWings)
            end

            if power > self.lastPower then
                self.popImpulse = 0.34
                self.flash = 1
            elseif power < self.lastPower then
                self.popImpulse = -0.22
            end
            self.lastPower = power

            self.popImpulse = self.popImpulse > 0
                and max(0, self.popImpulse - dt * 8)
                or  min(0, self.popImpulse + dt * 8)
            self.flash = max(0, self.flash - dt * 4)

            local t = now * 3
            local k = min(1, dt * 12)

            local mode = "normal"
            local baseScale, spinSpeed = 1.0, 3.0
            local coR, coG, coB = 1, 1, 1
            local gR, gG, gB = 0.25, 0.85, 1.0
            local haloA, glowA = 0.18, 0.45
            local spineA, auraA = 0.22, 0.06
            local sparkleOn = false

            if inAnshe and hasWings then
                mode = "both"
                baseScale, spinSpeed = 1.65, 2.8
                local p = (sin(now * 5.5) + 1) / 2
                coR, coG, coB = 0.97, 0.92*(1-p)+0.78*p, 0.85*(1-p)+0.48*p
                gR, gG, gB = 0.92, 0.88, 0.70
                haloA, glowA = 0.40, 0.72
                spineA, auraA = 0.38, 0.12
                sparkleOn = true

            elseif inAnshe then
                mode = "anshe"
                baseScale, spinSpeed = 1.35, 2.4
                local p = (sin(now * 4.2) + 1) / 2
                coR, coG, coB = 0.97, 0.90*(1-p)+0.60*p, 0.85*(1-p)+0.15*p
                gR, gG, gB = 0.90, 0.82, 0.55
                haloA, glowA = 0.30, 0.58
                spineA, auraA = 0.32, 0.08
                sparkleOn = true

            elseif hasWings then
                mode = "wings"
                baseScale, spinSpeed = 1.45, 2.1
                local p = (sin(now * 3.8) + 1) / 2
                coR, coG, coB = 0.97, 0.70*(1-p)+0.50*p, 0.50*(1-p)+0.15*p
                gR, gG, gB = 0.88, 0.75, 0.45
                haloA, glowA = 0.35, 0.68
                spineA, auraA = 0.40, 0.10
                sparkleOn = true
            else
                baseScale = (power >= 5 and 1.40) or (power >= 3 and 1.15) or 0.88
                baseScale = baseScale + sin(t) * 0.03
            end

            local flashMix = self.flash * 0.45
            local fR = coR*(1-flashMix) + 1*flashMix
            local fG = coG*(1-flashMix) + 1*flashMix
            local fB = coB*(1-flashMix) + 1*flashMix
            local hotBoost = self.flash * 0.5

            self.gR = self.gR + (gR - self.gR) * k
            self.gG = self.gG + (gG - self.gG) * k
            self.gB = self.gB + (gB - self.gB) * k
            self.auraA = self.auraA + (auraA - self.auraA) * k
            self.spine:SetVertexColor(self.gR, self.gG, self.gB)
            self.spine:SetAlpha(spineA)
            self.aura:SetVertexColor(self.gR, self.gG, self.gB)
            self.aura:SetAlpha(self.auraA)

            for i = 1, NUM do
                local b = self.blocks[i]
                local active = i <= power
                local psh = (sin(t + b.o9) + 1) / 2

                local tScale, tcoR, tcoG, tcoB
                local tHoA, tHiA, tHotA, tSpA, tBpA
                local tSpin

                if mode == "normal" then
                    if active then
                        tScale = baseScale + sin(t + b.o7) * 0.04
                        if power >= 5 then
                            tcoR, tcoG, tcoB = 0.97, 0.88, 0.60
                            tHoA, tHiA = 0.18, 0.48
                        else
                            tcoR, tcoG, tcoB = 0.85 + b.pp*0.12, 0.80 + b.pp*0.16, 0.70 + b.pp*0.24
                            tHoA, tHiA = 0.14 + psh*0.05, 0.38
                        end
                        tHotA = 0.30 + psh*0.10
                        tSpA = (power >= 5) and (0.10 + psh*0.08) or 0
                        tBpA = 0.45
                        tSpin = 1.8
                    else
                        tScale = 0.78 + sin(t + b.o7) * 0.02
                        tcoR, tcoG, tcoB = 0.45, 0.42, 0.38
                        tHoA, tHiA, tHotA, tSpA = 0.02, 0.02, 0, 0
                        tBpA = 0.28
                        tSpin = 0
                    end
                else
                    if active then
                        tScale = baseScale + sin(t + b.o7) * 0.06
                        tcoR, tcoG, tcoB = fR, fG, fB
                        tHoA = haloA * (0.85 + psh*0.15)
                        tHiA = glowA * (0.85 + psh*0.15)
                        tHotA = 0.45 + psh*0.15 + hotBoost
                        tSpA = sparkleOn and (0.18 + psh*0.14) or 0
                        tBpA = 0.5
                        tSpin = spinSpeed
                    else
                        tScale = (baseScale * 0.82) + sin(t + b.o7) * 0.03
                        tcoR, tcoG, tcoB = coR*0.20, coG*0.20, coB*0.20
                        tHoA, tHiA = 0.04, 0.05
                        tHotA, tSpA = 0, 0
                        tBpA = 0.34
                        tSpin = spinSpeed * 0.4
                    end
                end

                if active and i == power and self.popImpulse > 0.05 then
                    tScale = tScale + self.popImpulse * 0.5
                    tHotA = tHotA + self.popImpulse * 0.4
                end

                b.curScale = b.curScale + (tScale - b.curScale) * k
                b.cR = b.cR + (tcoR - b.cR) * k
                b.cG = b.cG + (tcoG - b.cG) * k
                b.cB = b.cB + (tcoB - b.cB) * k
                b.hoA = b.hoA + (tHoA - b.hoA) * k
                b.hiA = b.hiA + (tHiA - b.hiA) * k
                b.hotA = b.hotA + (tHotA - b.hotA) * k
                b.spA = b.spA + (tSpA - b.spA) * k
                b.bpA = b.bpA + (tBpA - b.bpA) * k

                b.spin = b.spin + dt * tSpin

                b:SetScale(b.curScale)
                b.bp:SetAlpha(b.bpA)
                b.bp:SetRotation(b.spin * 0.25)

                b.ho:SetVertexColor(self.gR, self.gG, self.gB)
                b.ho:SetAlpha(b.hoA)
                b.ho:SetRotation(-b.spin * 0.6)

                b.hi:SetVertexColor(self.gR, self.gG, self.gB)
                b.hi:SetAlpha(b.hiA)
                b.hi:SetRotation(b.spin * 0.9)

                b.co:SetVertexColor(b.cR, b.cG, b.cB)
                b.co:SetAlpha(active and 1 or 0.85)
                b.co:SetRotation(b.spin * 0.18)

                b.hot:SetAlpha(b.hotA)
                b.hot:SetRotation(-b.spin * 1.6)

                b.sp:SetAlpha(b.spA)
                b.sp:SetRotation(-b.spin * 1.1 + i * 0.5)
            end
        end)

        _G.BigJ_StarBar_Final = bar
    end
end
