module BetterLeveling

import BetterLevelingConfig.*


@wrapMethod(PlayerDevelopmentData)
public final const func AddExperience(amount: Int32, type: gamedataProficiencyType, telemetryGainReason: telemetryLevelGainReason, opt isDebug: Bool) -> Void {
    let modifiedAmount: Int32 = amount;
    
    if Settings.EnableXPMultiplier() {
        let multiplier: Float = 1.0;
        switch type {
            case gamedataProficiencyType.StreetCred:
                multiplier = Settings.XPMultiplierStreetCred();
                break;
            case gamedataProficiencyType.TechnicalAbilitySkill:
                multiplier = Settings.XPMultiplierEngineer();
                break;
            case gamedataProficiencyType.StrengthSkill:
                multiplier = Settings.XPMultiplierSolo();
                break;
            case gamedataProficiencyType.ReflexesSkill:
                multiplier = Settings.XPMultiplierHeadhunter();
                break;
            case gamedataProficiencyType.IntelligenceSkill:
                multiplier = Settings.XPMultiplierNetrunner();
                break;
            case gamedataProficiencyType.CoolSkill:
                multiplier = Settings.XPMultiplierShinobi();
                break;
            case gamedataProficiencyType.Level:
                multiplier = Settings.XPMultiplierLevel();
                break;
            default:
                multiplier = Settings.XPMultiplierLevel();
        }
        
        modifiedAmount = Cast<Int32>(Cast<Float>(amount) * multiplier);
        
        if amount != modifiedAmount {
            //FTLog("[Better Leveling] XP modified: " + ToString(amount) + " -> " + ToString(modifiedAmount) + " (x" + ToString(multiplier) + ")");
        }
    }
    
    wrappedMethod(modifiedAmount, type, telemetryGainReason, isDebug);
}

@wrapMethod(RPGManager)
public final static func CalculateMinorActivityReward(gi: GameInstance, experienceValue: Float) -> Float {
    let result: Float = wrappedMethod(gi, experienceValue);
    
    if Settings.EnableXPMultiplier() {
        result *= Settings.XPMultiplierLevel();
        //FTLog("[Better Leveling] Minor Activity XP modified: x" + ToString(Settings.XPMultiplierLevel()));
    }
    
    return result;
}

@wrapMethod(RPGManager)
public final static func CalculateStreetStoryReward(gi: GameInstance, experienceValue: Float) -> Float {
    let result: Float = wrappedMethod(gi, experienceValue);
    
    if Settings.EnableXPMultiplier() {
        result *= Settings.XPMultiplierLevel();
        //FTLog("[Better Leveling] Street Story XP modified: x" + ToString(Settings.XPMultiplierLevel()));
    }
    
    return result;
}

@wrapMethod(RPGManager)
public final static func CalculateEP1Reward(gi: GameInstance, experienceValue: Float, playerLevel: Float) -> Float {
    let result: Float = wrappedMethod(gi, experienceValue, playerLevel);
    
    if Settings.EnableXPMultiplier() {
        result *= Settings.XPMultiplierLevel();
        //FTLog("[Better Leveling] EP1 XP modified: x" + ToString(Settings.XPMultiplierLevel()));
    }
    
    return result;
}

@wrapMethod(RPGManager)
public final static func AwardXP(gi: GameInstance, amount: Float, type: gamedataProficiencyType) -> Void {
    let modifiedAmount: Float = amount;
    
    if Settings.EnableXPMultiplier() {
        let multiplier: Float = 1.0;
        switch type {
            case gamedataProficiencyType.StreetCred:
                multiplier = Settings.XPMultiplierStreetCred();
                break;
            case gamedataProficiencyType.TechnicalAbilitySkill:
                multiplier = Settings.XPMultiplierEngineer();
                break;
            case gamedataProficiencyType.StrengthSkill:
                multiplier = Settings.XPMultiplierSolo();
                break;
            case gamedataProficiencyType.ReflexesSkill:
                multiplier = Settings.XPMultiplierHeadhunter();
                break;
            case gamedataProficiencyType.IntelligenceSkill:
                multiplier = Settings.XPMultiplierNetrunner();
                break;
            case gamedataProficiencyType.CoolSkill:
                multiplier = Settings.XPMultiplierShinobi();
                break;
            case gamedataProficiencyType.Level:
                multiplier = Settings.XPMultiplierLevel();
                break;
            default:
                multiplier = Settings.XPMultiplierLevel();
        }
        modifiedAmount = amount * multiplier;
    }
    wrappedMethod(gi, modifiedAmount, type);
}

@wrapMethod(PlayerDevelopmentData)
private final const func CanGainNextProficiencyLevel(pIndex: Int32) -> Bool {
    if pIndex >= 0 && pIndex < ArraySize(this.m_proficiencies) {
        let profType: gamedataProficiencyType = this.m_proficiencies[pIndex].type;

        if Settings.EnableLevelCap() && Equals(profType, gamedataProficiencyType.Level) {
            let currentLevel: Int32 = this.m_proficiencies[pIndex].currentLevel;
            let maxLevel: Int32 = Settings.NewLevelCap();
            return currentLevel < maxLevel;
        }
        
        if Settings.EnableStreetCredCap() && Equals(profType, gamedataProficiencyType.StreetCred) {
            let currentLevel: Int32 = this.m_proficiencies[pIndex].currentLevel;
            let maxLevel: Int32 = Settings.StreetCredCap();
            return currentLevel < maxLevel;
        }
    }
    
    return wrappedMethod(pIndex);
}

@wrapMethod(PlayerDevelopmentData)
private final const func ModifyProficiencyLevel(proficiencyIndex: Int32, isDebug: Bool, opt levelIncrease: Int32) -> Void {
    wrappedMethod(proficiencyIndex, isDebug, levelIncrease);
    
    if Settings.EnableMoreAttrPerLevel() && 
       proficiencyIndex >= 0 && 
       proficiencyIndex < ArraySize(this.m_proficiencies) &&
       Equals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.Level) {
        
        let basePoints: Int32 = 1;
        let configuredPoints: Int32 = Settings.AttrPointsPerLevel();
        let additionalPoints: Int32 = configuredPoints - basePoints;
        
        if additionalPoints > 0 {
            this.AddDevelopmentPoints(additionalPoints, gamedataDevelopmentPointType.Attribute);
        }
    }
    
    if Settings.EnableMorePerkPerLevel() && 
       proficiencyIndex >= 0 && 
       proficiencyIndex < ArraySize(this.m_proficiencies) &&
       Equals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.Level) {
        
        let basePoints: Int32 = 1;
        let configuredPoints: Int32 = Settings.PerkPointsPerLevel();
        let additionalPoints: Int32 = configuredPoints - basePoints;
        
        if additionalPoints > 0 {
            this.AddDevelopmentPoints(additionalPoints, gamedataDevelopmentPointType.Primary);
        }
    }
}

@wrapMethod(PlayerDevelopmentData)
public final const func CanAttributeBeBought(type: gamedataStatType) -> Bool {
    if Settings.EnableAttributeCap() && PlayerDevelopmentData.IsAttribute(type) {
        let customCap: Int32 = Settings.AttributeCap();
        if customCap <= 20 {
            return wrappedMethod(type);
        }
        let currVal: Int32 = Cast<Int32>(GameInstance.GetStatsSystem(this.m_owner.GetGame())
            .GetStatValue(Cast<StatsObjectID>(this.m_owner.GetEntityID()), type));
        
        if currVal >= customCap {
            return false;
        }
        if this.GetDevPoints(gamedataDevelopmentPointType.Attribute) <= 0 {
            return false;
        }
        return true;
    }
    
    return wrappedMethod(type);
}

@wrapMethod(PlayerDevelopmentData)
public final const func SetAttribute(type: gamedataStatType, amount: Float) -> Void {
    let finalAmount: Float = amount;
    
    if Settings.EnableAttributeCap() && PlayerDevelopmentData.IsAttribute(type) {
        let customCap: Int32 = Settings.AttributeCap();
        if finalAmount > Cast<Float>(customCap) {
            finalAmount = Cast<Float>(customCap);
        }
    }
    
    wrappedMethod(type, finalAmount);
}

@wrapMethod(CharacterCreationStatsMenu)
private final func ResetAllBtnBackToBaseline() -> Void {
    if Settings.EnableStartingAttr() {
        let customStartingPoints: Int32 = Settings.StartingAttributePoints();
        let customMinAttribute: Int32 = 3;
        
        let i: Int32 = 0;
        while i < ArraySize(this.m_attributesControllers) {
            this.m_attributesControllers[i].data.SetValue(customMinAttribute);
            this.m_attributesControllers[i].Refresh();
            i += 1;
        };
        
        this.m_startingAttributePoints = customStartingPoints;
        this.m_attributePointsAvailable = customStartingPoints;
        inkTextRef.SetText(this.m_skillPointLabel, ToString(this.m_attributePointsAvailable));
        this.RefreshPointsLabel();
        this.ManageAllButtonsVisibility();
    } else {
        wrappedMethod();
    }
}

@wrapMethod(CharacterCreationStatsMenu)
protected cb func OnInitialize() -> Bool {
    let result: Bool = wrappedMethod();
    
    if Settings.EnableStartingAttr() {
        let customStartingPoints: Int32 = Settings.StartingAttributePoints();
        
        this.m_characterCustomizationState.SetAttributePointsAvailable(Cast<Uint32>(customStartingPoints));
        this.m_attributePointsAvailable = customStartingPoints;
        this.m_startingAttributePoints = customStartingPoints;
        inkTextRef.SetText(this.m_skillPointLabel, ToString(this.m_attributePointsAvailable));
        this.RefreshPointsLabel();
        this.ManageAllButtonsVisibility();
    }
    
    return result;
}