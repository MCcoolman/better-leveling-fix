-- Localization/EN.lua
return {
    tab = "Better Leveling",
    
    -- Subcategories
    levelSettings = "Level Settings",
    attributeSettings = "Attribute Settings",
    cyberwareSettings = "Cyberware Settings", 
    xpSettings = "XP Multipliers",
    featureToggles = "Feature Toggles",
    
    -- Level Settings
    levelCap = "Level Cap",
    levelCapDesc = "Max player level. (default: 60)",
    streetCredCap = "Street Cred Cap", 
    streetCredCapDesc = "Maximum street cred level (default: 50).",
    startPoints = "Starting Attribute Points",
    startPointsDesc = "Attribute points V starts with. (default: 7)",
    maxAttribute = "Max Starting Attribute",
    maxAttributeDesc = "Max points per attribute at character creation. (default: 6)",
    
    -- Attribute Settings
    attributeCap = "Attribute Cap",
    attributeCapDesc = "Sets the maximum value each attribute can reach. (default: 20)",
    attrPerLevel = "Attribute Points per Level", 
    attrPerLevelDesc = "Total Attribute points you gain per character level.",
    perkPerLevel = "Perk Points per Level",
    perkPerLevelDesc = "Total Perk points you gain per character level.",
    
    -- Cyberware Settings
    cyberwareCapacity = "Cyberware Capacity Scaling",
    cyberwareCapacityDesc = "Sets the scaling factor for Cyberware capacity based on your level. (default: 6) (Rest Game require)",
    cyberwareCap = "Cyberware Capacity Cap",
    cyberwareCapDesc = "Set the max cyberware capacity. (default: 1000) (Rest Game require)",

    SkillProgression = "Skill Progression",
    SkillProgressionDesc = "Set the Skill Progression (default: 60)",
    
    -- XP Multipliers
    xpLevelMult = "Level XP Multiplier",
    xpStreetCredMult = "Street Cred XP Multiplier", 
    xpHeadhunterMult = "Headhunter XP Multiplier",
    xpNetrunnerMult = "Netrunner XP Multiplier",
    xpShinobiMult = "Shinobi XP Multiplier",
    xpSoloMult = "Solo XP Multiplier",
    xpEngineerMult = "Engineer XP Multiplier",
    xpMultDesc = "Multiplier for this XP category. (default: 1.0)",
    
    -- Feature Toggle Labels
    toggleLevelCap = "Level Cap",
    toggleStreetCredCap = "Street Cred Cap", 
    toggleAttributeCap = "Attribute Cap",
    toggleStartingAttr = "Starting Attributes",
    toggleSkillProgression = "Enable Skill Progress",
    toggleCyberwareScaling = "Cyberware Scaling",
    toggleCyberwareCap = "Cyberware Cap",
    toggleMoreAttrPerLevel = "More Attr Per Level",
    toggleMorePerkPerLevel = "More Perk Per Level", 
    toggleXPMultiplier = "XP Multipliers",
    toggleRemoveLevelProgressionCap = "Remove Level Progression Cap",
    toggleRemoveAttributeProgressionCap = "Remove Attribute Progression Cap",
    toggleBeyondLevel60Curve = "Beyond Level 60 XP Curve",
    toggleBeyondStreetCredCurve = "Beyond Level 60 Street Cred XP Curve",
    
    -- Feature Toggle Descriptions
    toggleLevelCapDesc = "Enable level cap modification",
    toggleStreetCredCapDesc = "Enable street cred cap modification",
    toggleAttributeCapDesc = "Enable attribute cap modification", 
    toggleStartingAttrDesc = "Enable starting attribute modification",
    toggleSkillProgressionDesc = "Enables Skill Progression From 60 to user value",
    toggleCyberwareScalingDesc = "Enable cyberware capacity scaling",
    toggleCyberwareCapDesc = "Enable cyberware capacity cap",
    toggleMoreAttrPerLevelDesc = "Enable custom attribute points per level",
    toggleMorePerkPerLevelDesc = "Enable custom perk points per level",
    toggleXPMultiplierDesc = "Enable XP multiplier system", 
    toggleRemoveLevelProgressionCapDesc = "Allows health, stamina, and other passive bonuses to continue beyond level 60.",
    toggleRemoveAttributeProgressionCapDesc = "Allows attributes to go beyond 20 and continue providing bonuses.",
    toggleBeyondLevel60CurveDesc = "Enables exponential XP scaling for levels 61-135, reaching 4M XP at level 135.",
    toggleBeyondStreetCredCurveDesc = "Enables exponential Street Cred XP scaling for levels 61-350, reaching 50M XP at level 350.",
    
    -- Language
    languageLabel = "Language",
    languageDesc = "Choose language for the mod interface.",
    languageChanged = "Language changed. Please reopen the mod menu to see changes."
}