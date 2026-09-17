local _tweakDBUpdated = false

local settings = {
    -- Level Settings
    NewLevelCap = 60,
    StreetCredCap = 50,
    StartingAttributePoints = 7,
    MaxStartingAttribute = 6,
    
    -- Attribute Settings
    AttributeCap = 20,
    AttrPointsPerLevel = 1,
    PerkPointsPerLevel = 1,
    
    -- Cyberware Settings
    MoreCyberwareCapacity = 6,
    CyberwareCap = 1000,

    -- Skill Progression
    SkillProgressionCap = 60,
    
    -- Feature Flags
    FeatureFlags = {
        LevelCap = true,
        StreetCredCap = true,
        AttributeCap = true,
        StartingAttr = true,
        CyberwareScaling = true,
        CyberwareCap = true,
        MoreAttrPerLevel = true,
        MorePerkPerLevel = true,
        XPMultiplier = true,
        RemoveLevelProgressionCap = true,
        RemoveAttributeProgressionCap = true,
        BeyondLevel60Curve = true,
        BeyondStreetCredCurve = true,
        ExtendSkillProgression = true
    },
    -- XP Multipliers
    XPValues = {
        Level = 1.0,
        StreetCred = 1.0,
        Headhunter = 1.0,
        Netrunner = 1.0,
        Shinobi = 1.0,
        Solo = 1.0,
        Engineer = 1.0
    },
    -- Language
    Language = 1
}

local function getLocalization(languageId)
    local languageFiles = {
        [1] = "Localization/EN",
        [2] = "Localization/FR",
        [3] = "Localization/DE",
        [4] = "Localization/ZH",
        [5] = "Localization/ZHTR",
        [6] = "Localization/RU",
        [7] = "Localization/UA",
        [8] = "Localization/JP",
        [9] = "Localization/KR",
        [10] = "Localization/MS",
        [11] = "Localization/PT",  -- Portuguese
        [12] = "Localization/ES", -- Spanish
        [13] = "Localization/IT", -- Italian
        [14] = "Localization/TH", -- Thai
        [15] = "Localization/VI", -- Vietnamese
        [16] = "Localization/AR", -- Arabic
        [17] = "Localization/PL", -- Polish
        [18] = "Localization/CS", -- Czech
        [19] = "Localization/HU", -- Hungarian
        [20] = "Localization/TR"  -- Turkish
    }
    
    local fileName = languageFiles[languageId or 1]
    if not fileName then
        fileName = "Localization/EN"
    end
    
    local success, localization = pcall(function()
        return require(fileName)
    end)
    
    if success and localization then
        return localization
    else
        -- print("[Better Leveling] Failed to load localization: " .. tostring(fileName))
        return require("Localization/EN")
    end
end

function LoadSettings()
    local file = io.open("Data/config.json", "r")
    if file ~= nil then
        local contents = file:read("*a")
        local validJson, savedState = pcall(function() return json.decode(contents) end)
        
        if validJson then
            file:close()
            for key, _ in pairs(settings) do
                if savedState[key] ~= nil then
                    if key == "FeatureFlags" or key == "XPValues" then
                        for subKey, _ in pairs(settings[key]) do
                            if savedState[key][subKey] ~= nil then
                                settings[key][subKey] = savedState[key][subKey]
                            end
                        end
                    else
                        settings[key] = savedState[key]
                        -- print("[Better Leveling] Loaded " .. key .. " = " .. tostring(savedState[key]))
                    end
                end
            end
        end
    else
        -- print("[Better Leveling] No config file found, using defaults")
    end
end

function SaveSettings()
    local validJson, contents = pcall(function() return json.encode(settings) end)
    
    if validJson and contents ~= nil then
        local file = io.open("Data/config.json", "w")
        if file then
            file:write(contents)
            file:close()
        end
    end
end

LoadSettings()
local nativeSettings = nil

registerForEvent("onTweak", function()
    if settings.FeatureFlags.CyberwareCap then
        TweakDB:SetFlat("BaseStats.Humanity.max", settings.CyberwareCap)
        TweakDB:Update("BaseStats.Humanity.max")
        -- print("[Better Leveling] Set cyberware capacity cap to: " .. settings.CyberwareCap)
    end
    
    if settings.FeatureFlags.CyberwareScaling then
        TweakDB:SetFlat("Character.PlayerCyberwareSystem_inline11.value", settings.MoreCyberwareCapacity)
        TweakDB:Update("Character.PlayerCyberwareSystem_inline11")
    else
        -- print("[Better Leveling DEBUG] CyberwareScaling is DISABLED - skipping")
    end
end)

registerForEvent("onInit", function()
    nativeSettings = GetMod("nativeSettings")
    if nativeSettings then
        -- Settings already loaded at script load time
        BuildSettingsMenu()
        SetupConfigOverrides()
        -- print("[Better Leveling] CET initialized, will trigger TweakDB update shortly...")
    else
        print("[Better Leveling] NativeSettings not found. Using default config values.")
    end
end)

registerForEvent("onUpdate", function(deltaTime)
    -- Only run once, after game is fully loaded
    if Game.GetPlayer() and not _tweakDBUpdated then
        _tweakDBUpdated = true
        TriggerTweakDBUpdate()
    end
end)

function TriggerTweakDBUpdate()
    local tweakDBService = Game.GetScriptableServiceContainer():GetService("BetterLeveling.BetterLevelingTweakDBService")
    if tweakDBService then
        tweakDBService:UpdateAllTweakDBRecords()
        -- print("[Better Leveling] TweakDB records updated successfully")
    else
        print("[Better Leveling] Warning: TweakDB service not found - install Codeware dependency")
    end
end

function BuildSettingsMenu()
    local loc = getLocalization(settings.Language)
    
    nativeSettings.addTab("/BetterLeveling", loc.tab)
    
    -- Subcategories
    nativeSettings.addSubcategory("/BetterLeveling/LevelSettings", loc.levelSettings)
    nativeSettings.addSubcategory("/BetterLeveling/AttributeSettings", loc.attributeSettings)
    nativeSettings.addSubcategory("/BetterLeveling/CyberwareSettings", loc.cyberwareSettings)
    nativeSettings.addSubcategory("/BetterLeveling/XPSettings", loc.xpSettings)
    nativeSettings.addSubcategory("/BetterLeveling/FeatureToggles", loc.featureToggles)
    
    -- Language selector (put it first in Feature Toggles)
    nativeSettings.addSelectorString(
        "/BetterLeveling/FeatureToggles",
        loc.languageLabel,
        loc.languageDesc,
        {"English", "Français", "Deutsch", "中文", "漢語", "Русский", "українська" ,"日本語", "한국어", "Bahasa Melayu",
        "Português", "Español", "Italiano", "ไทย", "Tiếng Việt", "العربية", "Polski", "Čeština",
        "Magyar", "Türkçe"},
        settings.Language,
        1,
        function(val)
            settings.Language = val
            SaveSettings()
            -- print("[Better Leveling] " .. loc.languageChanged)
        end
    )
    
    -- Level Settings
    addIntSlider("/BetterLeveling/LevelSettings", loc.levelCap, loc.levelCapDesc, 
                 1, 500, 1, "NewLevelCap", 60, "LevelCap")
    
    addIntSlider("/BetterLeveling/LevelSettings", loc.streetCredCap, loc.streetCredCapDesc,
                 1, 500, 1, "StreetCredCap", 50, "StreetCredCap")
    
    addIntSlider("/BetterLeveling/LevelSettings", loc.startPoints, loc.startPointsDesc,
                 7, 50, 1, "StartingAttributePoints", 7, "StartingAttr")
    
    addIntSlider("/BetterLeveling/LevelSettings", loc.maxAttribute, loc.maxAttributeDesc,
                 6, 20, 1, "MaxStartingAttribute", 6, "StartingAttr")

    addIntSlider("/BetterLeveling/LevelSettings", loc.SkillProgression, loc.SkillProgressionDesc,
             60, 300, 1, "SkillProgressionCap", 60, "ExtendSkillProgression")
    
    -- Attribute Settings
    addIntSlider("/BetterLeveling/AttributeSettings", loc.attributeCap, loc.attributeCapDesc,
                 20, 200, 1, "AttributeCap", 20, "AttributeCap")
    
    addIntSlider("/BetterLeveling/AttributeSettings", loc.attrPerLevel, loc.attrPerLevelDesc,
                 1, 10, 1, "AttrPointsPerLevel", 1, "MoreAttrPerLevel")
    
    addIntSlider("/BetterLeveling/AttributeSettings", loc.perkPerLevel, loc.perkPerLevelDesc,
                 1, 10, 1, "PerkPointsPerLevel", 1, "MorePerkPerLevel")
    
    -- Cyberware Settings
    addIntSlider("/BetterLeveling/CyberwareSettings", loc.cyberwareCapacity, loc.cyberwareCapacityDesc,
                 1, 1000, 1, "MoreCyberwareCapacity", 6, "CyberwareScaling")
    
    addIntSlider("/BetterLeveling/CyberwareSettings", loc.cyberwareCap, loc.cyberwareCapDesc,
                 100, 10000, 50, "CyberwareCap", 1000, "CyberwareCap")

    -- XP Multipliers - NOW USING LOCALIZATION
    addFloatSlider("/BetterLeveling/XPSettings", loc.xpLevelMult, loc.xpMultDesc,
                   "Level", 1.0, "XPMultiplier")
    
    addFloatSlider("/BetterLeveling/XPSettings", loc.xpStreetCredMult, loc.xpMultDesc,
                   "StreetCred", 1.0, "XPMultiplier")
    
    addFloatSlider("/BetterLeveling/XPSettings", loc.xpHeadhunterMult, loc.xpMultDesc,
                   "Headhunter", 1.0, "XPMultiplier")
    
    addFloatSlider("/BetterLeveling/XPSettings", loc.xpNetrunnerMult, loc.xpMultDesc,
                   "Netrunner", 1.0, "XPMultiplier")
    
    addFloatSlider("/BetterLeveling/XPSettings", loc.xpShinobiMult, loc.xpMultDesc,
                   "Shinobi", 1.0, "XPMultiplier")
    
    addFloatSlider("/BetterLeveling/XPSettings", loc.xpSoloMult, loc.xpMultDesc,
                   "Solo", 1.0, "XPMultiplier")
    
    addFloatSlider("/BetterLeveling/XPSettings", loc.xpEngineerMult, loc.xpMultDesc,
                   "Engineer", 1.0, "XPMultiplier")

    -- Feature Toggles - NOW USING LOCALIZATION
    local toggles = {
        {"LevelCap", "toggleLevelCap", "toggleLevelCapDesc"},
        {"StreetCredCap", "toggleStreetCredCap", "toggleStreetCredCapDesc"},
        {"AttributeCap", "toggleAttributeCap", "toggleAttributeCapDesc"},
        {"StartingAttr", "toggleStartingAttr", "toggleStartingAttrDesc"},
        {"ExtendSkillProgression", "toggleSkillProgression", "toggleSkillProgressionDesc"},
        {"CyberwareScaling", "toggleCyberwareScaling", "toggleCyberwareScalingDesc"},
        {"CyberwareCap", "toggleCyberwareCap", "toggleCyberwareCapDesc"},
        {"MoreAttrPerLevel", "toggleMoreAttrPerLevel", "toggleMoreAttrPerLevelDesc"},
        {"MorePerkPerLevel", "toggleMorePerkPerLevel", "toggleMorePerkPerLevelDesc"},
        {"XPMultiplier", "toggleXPMultiplier", "toggleXPMultiplierDesc"},
        {"RemoveLevelProgressionCap", "toggleRemoveLevelProgressionCap", "toggleRemoveLevelProgressionCapDesc"},
        {"RemoveAttributeProgressionCap", "toggleRemoveAttributeProgressionCap", "toggleRemoveAttributeProgressionCapDesc"},
        {"BeyondLevel60Curve", "toggleBeyondLevel60Curve", "toggleBeyondLevel60CurveDesc"},
        {"BeyondStreetCredCurve", "toggleBeyondStreetCredCurve", "toggleBeyondStreetCredCurveDesc"},
    }
    
    for _, toggle in ipairs(toggles) do
        addSwitch("/BetterLeveling/FeatureToggles", loc[toggle[2]], loc[toggle[3]], toggle[1])
    end
end

function addIntSlider(path, label, desc, min, max, step, key, default, featureKey)
    nativeSettings.addRangeInt(
        path, label, desc,
        min, max, step,
        settings[key] or default,
        default,
        function(v)
            if not featureKey or settings.FeatureFlags[featureKey] then
                settings[key] = v
                -- print("[Better Leveling] Setting " .. key .. " to " .. tostring(v))
                SaveSettings()
                TriggerTweakDBUpdate()
            end
        end
    )
end

function addFloatSlider(path, label, desc, key, default, featureKey)
    nativeSettings.addRangeFloat(
        path, label, desc,
        0.1, 10.0, 0.1, "%.2f",
        settings.XPValues[key] or default,
        default,
        function(v)
            if not featureKey or settings.FeatureFlags[featureKey] then
                settings.XPValues[key] = v
                SaveSettings()
            end
        end
    )
end

function addSwitch(path, label, desc, key)
    nativeSettings.addSwitch(
        path, label, desc,
        settings.FeatureFlags[key],
        true,
        function(val)
            settings.FeatureFlags[key] = val
            SaveSettings()
            TriggerTweakDBUpdate()
        end
    )
end

function SetupConfigOverrides()
    -- print("[Better Leveling] Setting up config overrides...")
    
    -- Level Settings
    Override("BetterLevelingConfig.Settings", "NewLevelCap;", function() 
        return settings.NewLevelCap 
    end)
    Override("BetterLevelingConfig.Settings", "StreetCredCap;", function() return settings.StreetCredCap end)
    Override("BetterLevelingConfig.Settings", "StartingAttributePoints;", function() return settings.StartingAttributePoints end)
    Override("BetterLevelingConfig.Settings", "MaxStartingAttribute;", function() return settings.MaxStartingAttribute end)
    
    -- Attribute Settings
    Override("BetterLevelingConfig.Settings", "AttributeCap;", function() return settings.AttributeCap end)
    Override("BetterLevelingConfig.Settings", "AttrPointsPerLevel;", function() return settings.AttrPointsPerLevel end)
    Override("BetterLevelingConfig.Settings", "PerkPointsPerLevel;", function() return settings.PerkPointsPerLevel end)
    
    -- Cyberware Settings
    Override("BetterLevelingConfig.Settings", "MoreCyberwareCapacity;", function() return settings.MoreCyberwareCapacity end)
    Override("BetterLevelingConfig.Settings", "CyberwareCap;", function() return settings.CyberwareCap end)
    
    Override("BetterLevelingConfig.Settings", "SkillProgressionCap;", function() return settings.SkillProgressionCap end)
    -- Feature Flags
    Override("BetterLevelingConfig.Settings", "EnableLevelCap;", function() 
        return settings.FeatureFlags.LevelCap 
    end)
    Override("BetterLevelingConfig.Settings", "EnableStreetCredCap;", function() return settings.FeatureFlags.StreetCredCap end)
    Override("BetterLevelingConfig.Settings", "EnableAttributeCap;", function() return settings.FeatureFlags.AttributeCap end)
    Override("BetterLevelingConfig.Settings", "EnableStartingAttr;", function() return settings.FeatureFlags.StartingAttr end)
    Override("BetterLevelingConfig.Settings", "EnableCyberwareScaling;", function() return settings.FeatureFlags.CyberwareScaling end)
    Override("BetterLevelingConfig.Settings", "EnableCyberwareCap;", function() return settings.FeatureFlags.CyberwareCap end)
    Override("BetterLevelingConfig.Settings", "EnableMoreAttrPerLevel;", function() return settings.FeatureFlags.MoreAttrPerLevel end)
    Override("BetterLevelingConfig.Settings", "EnableMorePerkPerLevel;", function() return settings.FeatureFlags.MorePerkPerLevel end)
    Override("BetterLevelingConfig.Settings", "EnableXPMultiplier;", function() return settings.FeatureFlags.XPMultiplier end)
    Override("BetterLevelingConfig.Settings", "RemoveLevelProgressionCap;", function() return settings.FeatureFlags.RemoveLevelProgressionCap end)
    Override("BetterLevelingConfig.Settings", "RemoveAttributeProgressionCap;", function() return settings.FeatureFlags.RemoveAttributeProgressionCap end)
    Override("BetterLevelingConfig.Settings", "BeyondLevel60Curve;", function() return settings.FeatureFlags.BeyondLevel60Curve end)
    Override("BetterLevelingConfig.Settings", "BeyondStreetCredCurve;", function() return settings.FeatureFlags.BeyondStreetCredCurve end)
    Override("BetterLevelingConfig.Settings", "ExtendSkillProgression;", function() return settings.FeatureFlags.ExtendSkillProgression end)
    
    -- XP Multipliers (Individual functions to avoid parameter issues)
    Override("BetterLevelingConfig.Settings", "XPMultiplierLevel;", function() return settings.XPValues.Level end)
    Override("BetterLevelingConfig.Settings", "XPMultiplierStreetCred;", function() return settings.XPValues.StreetCred end)
    Override("BetterLevelingConfig.Settings", "XPMultiplierHeadhunter;", function() return settings.XPValues.Headhunter end)
    Override("BetterLevelingConfig.Settings", "XPMultiplierNetrunner;", function() return settings.XPValues.Netrunner end)
    Override("BetterLevelingConfig.Settings", "XPMultiplierShinobi;", function() return settings.XPValues.Shinobi end)
    Override("BetterLevelingConfig.Settings", "XPMultiplierSolo;", function() return settings.XPValues.Solo end)
    Override("BetterLevelingConfig.Settings", "XPMultiplierEngineer;", function() return settings.XPValues.Engineer end)
    
    print("[Better Leveling] Config overrides setup complete")
end

function TestOverride()
    -- print("[Better Leveling] Current NewLevelCap setting: " .. tostring(settings.NewLevelCap))
    -- print("[Better Leveling] Current LevelCap feature flag: " .. tostring(settings.FeatureFlags.LevelCap))
end

return true