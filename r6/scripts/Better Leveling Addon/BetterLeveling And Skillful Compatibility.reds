module BetterLeveling_Skillful_Compatibility

import BetterLevelingConfig.*
import SkillfulConfig.*

@if(ModuleExists("SkillfulConfig"))
@replaceMethod(PlayerDevelopmentData)  
public final const func AddExperience(amount: Int32, type: gamedataProficiencyType, telemetryGainReason: telemetryLevelGainReason, opt isDebug: Bool) -> Void {
    let modifiedAmount: Int32 = amount;
    let config: ref<SBA_Skillful> = new SBA_Skillful();
    let isSplit: Bool = false;
    let splitTarget: gamedataProficiencyType;
    let splitPerc: Float;
    
    switch type {
        case gamedataProficiencyType.ReflexesSkill:
            modifiedAmount = this.SBA_CalExpMult_Compat(modifiedAmount, config.expMulReflexes_01, config.expMulReflexes_59, type, config.isProgressiveExpMul);
            isSplit = config.Shinobi2Solo >= 0.1 ? true : false;
            if isSplit {
                splitTarget = gamedataProficiencyType.StrengthSkill;
                splitPerc = config.Shinobi2Solo / 100.0;
            }
            break;
        case gamedataProficiencyType.TechnicalAbilitySkill:
            modifiedAmount = this.SBA_CalExpMult_Compat(modifiedAmount, config.expMulTechnicalAbility_01, config.expMulTechnicalAbility_59, type, config.isProgressiveExpMul);
            isSplit = config.Engineer2Netrunner >= 0.1 ? true : false;
            if isSplit {
                splitTarget = gamedataProficiencyType.IntelligenceSkill;
                splitPerc = config.Engineer2Netrunner / 100.0;
            }
            break;
        case gamedataProficiencyType.CoolSkill:
            modifiedAmount = this.SBA_CalExpMult_Compat(modifiedAmount, config.expMulCool_01, config.expMulCool_59, type, config.isProgressiveExpMul);
            break;
        case gamedataProficiencyType.IntelligenceSkill:
            modifiedAmount = this.SBA_CalExpMult_Compat(modifiedAmount, config.expMulIntelligence_01, config.expMulIntelligence_59, type, config.isProgressiveExpMul);
            break;
        case gamedataProficiencyType.StrengthSkill:
            modifiedAmount = this.SBA_CalExpMult_Compat(modifiedAmount, config.expMulStrength_01, config.expMulStrength_59, type, config.isProgressiveExpMul);
            break;
        case gamedataProficiencyType.Level:
            modifiedAmount = Cast<Int32>(Cast<Float>(modifiedAmount) * config.expMulLevel);
            break;
        case gamedataProficiencyType.StreetCred:
            modifiedAmount = Cast<Int32>(Cast<Float>(modifiedAmount) * config.expMulStreetCred);
            break;
    }
    
    if Settings.EnableXPMultiplier() {
        let betterLevelingMultiplier: Float = 1.0;
        switch type {
            case gamedataProficiencyType.StreetCred:
                betterLevelingMultiplier = Settings.XPMultiplierStreetCred();
                break;
            case gamedataProficiencyType.TechnicalAbilitySkill:
                betterLevelingMultiplier = Settings.XPMultiplierEngineer();
                break;
            case gamedataProficiencyType.StrengthSkill:
                betterLevelingMultiplier = Settings.XPMultiplierSolo();
                break;
            case gamedataProficiencyType.ReflexesSkill:
                betterLevelingMultiplier = Settings.XPMultiplierHeadhunter();
                break;
            case gamedataProficiencyType.IntelligenceSkill:
                betterLevelingMultiplier = Settings.XPMultiplierNetrunner();
                break;
            case gamedataProficiencyType.CoolSkill:
                betterLevelingMultiplier = Settings.XPMultiplierShinobi();
                break;
            case gamedataProficiencyType.Level:
                betterLevelingMultiplier = Settings.XPMultiplierLevel();
                break;
            default:
                betterLevelingMultiplier = Settings.XPMultiplierLevel();
        }
        modifiedAmount = Cast<Int32>(Cast<Float>(modifiedAmount) * betterLevelingMultiplier);
    }
    
    if isSplit {
        let sharedAmount: Int32 = FloorF(Cast<Float>(modifiedAmount) * splitPerc);
        let finalAmount: Int32 = modifiedAmount - sharedAmount;
        let awardedAmount: Int32;
        let proficiencyProgress: ref<ProficiencyProgressEvent>;
        let reqExp: Int32;
        let telemetryEvt: TelemetryLevelGained;
        let pIndex: Int32 = this.GetProficiencyIndexByType(type);
        let splitIndex: Int32 = this.GetProficiencyIndexByType(splitTarget);
        
        if pIndex >= 0 && !this.IsProficiencyMaxLvl(type) {
            this.ProcessExperienceVanilla(finalAmount, type, telemetryGainReason, isDebug, pIndex);
        }
        
        if splitIndex >= 0 && !this.IsProficiencyMaxLvl(splitTarget) {
            this.ProcessExperienceVanilla(sharedAmount, splitTarget, telemetryGainReason, isDebug, splitIndex);
        }
    } else {
        let pIndex: Int32 = this.GetProficiencyIndexByType(type);
        if pIndex >= 0 && !this.IsProficiencyMaxLvl(type) {
            this.ProcessExperienceVanilla(modifiedAmount, type, telemetryGainReason, isDebug, pIndex);
        }
    }
}

@addMethod(PlayerDevelopmentData)
private final const func ProcessExperienceVanilla(amount: Int32, type: gamedataProficiencyType, telemetryGainReason: telemetryLevelGainReason, isDebug: Bool, pIndex: Int32) -> Void {
    let awardedAmount: Int32;
    let proficiencyProgress: ref<ProficiencyProgressEvent>;
    let reqExp: Int32;
    let telemetryEvt: TelemetryLevelGained;
    
    if pIndex >= 0 && !this.IsProficiencyMaxLvl(type) {
        while amount > 0 && !this.IsProficiencyMaxLvl(type) {
            reqExp = this.GetRemainingExpForLevelUp(type);
            if amount - reqExp >= 0 {
                awardedAmount += reqExp;
                amount -= reqExp;
                this.m_proficiencies[pIndex].currentExp += reqExp;
                this.m_proficiencies[pIndex].expToLevel = this.GetRemainingExpForLevelUp(type);
                if this.CanGainNextProficiencyLevel(pIndex) {
                    this.ModifyProficiencyLevel(type, isDebug);
                    this.UpdateUIBB();
                    if this.m_owner.IsPlayerControlled() && NotEquals(telemetryGainReason, telemetryLevelGainReason.Ignore) {
                        telemetryEvt.playerPuppet = this.m_owner;
                        telemetryEvt.proficiencyType = type;
                        telemetryEvt.proficiencyValue = this.m_proficiencies[pIndex].currentLevel;
                        telemetryEvt.isDebugEvt = Equals(telemetryGainReason, telemetryLevelGainReason.IsDebug);
                        telemetryEvt.perkPointsAwarded = this.GetDevPointsForLevel(this.m_proficiencies[pIndex].currentLevel, type, gamedataDevelopmentPointType.Primary);
                        telemetryEvt.attributePointsAwarded = this.GetDevPointsForLevel(this.m_proficiencies[pIndex].currentLevel, type, gamedataDevelopmentPointType.Attribute);
                        GameInstance.GetTelemetrySystem(this.m_owner.GetGame()).LogLevelGained(telemetryEvt);
                    }
                } else {
                    return;
                }
            } else {
                this.m_proficiencies[pIndex].currentExp += amount;
                this.m_proficiencies[pIndex].expToLevel = this.GetRemainingExpForLevelUp(type);
                awardedAmount += amount;
                amount -= amount;
            }
        }
        if awardedAmount > 0 {
            if this.m_displayActivityLog {
                if Equals(type, gamedataProficiencyType.StreetCred) && GameInstance.GetQuestsSystem(this.m_owner.GetGame()).GetFact(n"street_cred_tutorial") == 0 && GameInstance.GetQuestsSystem(this.m_owner.GetGame()).GetFact(n"disable_tutorials") == 0 && Equals(telemetryGainReason, telemetryLevelGainReason.Gameplay) && GameInstance.GetQuestsSystem(this.m_owner.GetGame()).GetFact(n"q001_show_sts_tut") > 0 {
                    GameInstance.GetQuestsSystem(this.m_owner.GetGame()).SetFact(n"street_cred_tutorial", 1);
                }
            }
            proficiencyProgress = new ProficiencyProgressEvent();
            proficiencyProgress.type = type;
            proficiencyProgress.expValue = this.GetCurrentLevelProficiencyExp(type);
            proficiencyProgress.delta = awardedAmount;
            proficiencyProgress.remainingXP = this.GetRemainingExpForLevelUp(type);
            proficiencyProgress.currentLevel = this.GetProficiencyLevel(type);
            proficiencyProgress.isLevelMaxed = this.GetProficiencyLevel(type) + 1 == this.GetProficiencyAbsoluteMaxLevel(type);
            GameInstance.GetUISystem(this.m_owner.GetGame()).QueueEvent(proficiencyProgress);
            if Equals(type, gamedataProficiencyType.Level) {
                this.UpdatePlayerXP();
            }
        }
    }
}

@addMethod(PlayerDevelopmentData)
private final func SBA_CalExpMult_Compat(amount: Int32, Mult_Level_1: Float, Mult_Level_59: Float, type: gamedataProficiencyType, isProgressiveExpMul: Bool) -> Int32 {
    let expMultiplier: Float;
    if isProgressiveExpMul || Mult_Level_1 != Mult_Level_59 {
        expMultiplier = Mult_Level_1 - (Mult_Level_1 - Mult_Level_59) / 59.00 * Cast<Float>(this.GetProficiencyLevel(type));
    } else {
        expMultiplier = Mult_Level_1;
    }
    return Cast<Int32>(Cast<Float>(amount) * expMultiplier);
}

@if(ModuleExists("SkillfulConfig"))
@replaceMethod(PlayerDevelopmentData)
private final const func ModifyProficiencyLevel(proficiencyIndex: Int32, isDebug: Bool, opt levelIncrease: Int32) -> Void {
    if proficiencyIndex < 0 || proficiencyIndex >= ArraySize(this.m_proficiencies) {
        return;
    }
    
    let type: gamedataProficiencyType = this.m_proficiencies[proficiencyIndex].type;
    let config: ref<SBA_Skillful> = new SBA_Skillful();
    
    let Blackboard: ref<IBlackboard>;
    let effectTags: array<CName>;
    let effects: array<ref<StatusEffect>>;
    let i: Int32;
    let level: LevelUpData;
    let statusEffectSys: ref<StatusEffectSystem>;
    if levelIncrease == 0 {
        levelIncrease = 1;
    }
    this.m_proficiencies[proficiencyIndex].currentLevel += levelIncrease;
    this.m_proficiencies[proficiencyIndex].currentExp = 0;
    this.m_proficiencies[proficiencyIndex].expToLevel = this.GetRemainingExpForLevelUp(this.m_proficiencies[proficiencyIndex].type);
    if !isDebug {
        this.ModifyDevPoints(this.m_proficiencies[proficiencyIndex].type, this.m_proficiencies[proficiencyIndex].currentLevel);
    }
    level.lvl = this.m_proficiencies[proficiencyIndex].currentLevel;
    level.type = this.m_proficiencies[proficiencyIndex].type;
    level.perkPoints = this.GetDevPoints(gamedataDevelopmentPointType.Primary);
    level.attributePoints = this.GetDevPoints(gamedataDevelopmentPointType.Attribute);
    level.espionagePoints = this.GetDevPoints(gamedataDevelopmentPointType.Espionage);
    this.SetProficiencyStat(this.m_proficiencies[proficiencyIndex].type, this.m_proficiencies[proficiencyIndex].currentLevel);
    this.ProcessProficiencyPassiveBonus(proficiencyIndex);
    Blackboard = GameInstance.GetBlackboardSystem(this.m_owner.GetGame()).Get(GetAllBlackboardDefs().UI_LevelUp);
    if IsDefined(Blackboard) && this.m_owner == GameInstance.GetPlayerSystem(this.m_owner.GetGame()).GetLocalPlayerMainGameObject() {
        Blackboard.SetVariant(GetAllBlackboardDefs().UI_LevelUp.level, ToVariant(level));
        Blackboard.SignalVariant(GetAllBlackboardDefs().UI_LevelUp.level);
    }
    
    if Equals(type, gamedataProficiencyType.Level) {
        if Settings.EnableMoreAttrPerLevel() {
            let basePoints: Int32 = 1;
            let configuredPoints: Int32 = Settings.AttrPointsPerLevel();
            let additionalPoints: Int32 = configuredPoints - basePoints;
            
            if additionalPoints > 0 {
                this.AddDevelopmentPoints(additionalPoints, gamedataDevelopmentPointType.Attribute);
            }
        }
        
        if Settings.EnableMorePerkPerLevel() {
            let basePoints: Int32 = 1;
            let configuredPoints: Int32 = Settings.PerkPointsPerLevel();
            let additionalPoints: Int32 = configuredPoints - basePoints;
            
            if additionalPoints > 0 {
                this.AddDevelopmentPoints(additionalPoints, gamedataDevelopmentPointType.Primary);
            }
        }
    }
    
    switch type {
        case gamedataProficiencyType.Level:
            if config.perkPointAmount_characterLevel > 0 
               && config.perkPointWall_characterLevel > 0 
               && this.m_proficiencies[proficiencyIndex].currentLevel % config.perkPointWall_characterLevel == 0 {
                
                let skillfulAmount: Int32 = config.perkPointAmount_characterLevel;
                if Settings.EnableMorePerkPerLevel() {
                    skillfulAmount *= Settings.PerkPointsPerLevel();
                }
                this.AddDevelopmentPoints(skillfulAmount, gamedataDevelopmentPointType.Primary);
            }
            break;
        case gamedataProficiencyType.StreetCred:
            if config.perkPointAmount_streetCred > 0 
               && config.perkPointWall_streetCred > 0 
               && this.m_proficiencies[proficiencyIndex].currentLevel % config.perkPointWall_streetCred == 0 {
                
                let skillfulAmount: Int32 = config.perkPointAmount_streetCred;
                if Settings.EnableMorePerkPerLevel() {
                    skillfulAmount *= Settings.PerkPointsPerLevel();
                }
                this.AddDevelopmentPoints(skillfulAmount, gamedataDevelopmentPointType.Primary);
            }
            break;
        case gamedataProficiencyType.ReflexesSkill:
        case gamedataProficiencyType.TechnicalAbilitySkill:
        case gamedataProficiencyType.CoolSkill:
        case gamedataProficiencyType.IntelligenceSkill:
        case gamedataProficiencyType.StrengthSkill:
            if config.perkPointAmount_proficiency > 0 
               && config.perkPointWall_proficiency > 0 
               && this.m_proficiencies[proficiencyIndex].currentLevel % config.perkPointWall_proficiency == 0 {
                
                let skillfulPerkAmount: Int32 = config.perkPointAmount_proficiency;
                let skillfulAttrAmount: Int32 = config.perkPointAmount_proficiency;
                
                if Settings.EnableMorePerkPerLevel() {
                    skillfulPerkAmount *= Settings.PerkPointsPerLevel();
                }
                if Settings.EnableMoreAttrPerLevel() {
                    skillfulAttrAmount *= Settings.AttrPointsPerLevel();
                }
                
                this.AddDevelopmentPoints(skillfulPerkAmount, gamedataDevelopmentPointType.Primary);
                this.AddDevelopmentPoints(skillfulAttrAmount, gamedataDevelopmentPointType.Attribute);
            }
            break;
    }
    
    this.ModifyCyberwareCapacity_Skillful(type, config);
    
    this.SetAchievementProgress(proficiencyIndex);
    if this.m_proficiencies[proficiencyIndex].currentLevel == RPGManager.GetProficiencyRecord(this.m_proficiencies[proficiencyIndex].type).MaxLevel() {
        if Equals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.StreetCred) {
            this.SendMaxStreetCredLevelReachedTrackingRequest();
        } else {
            if NotEquals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.Level) && NotEquals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.Espionage) {
                this.CheckSpecialistAchievement(proficiencyIndex);
            }
        }
    }
    
    if Equals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.Level) {
        this.ProcessTutorialFacts();
        if Equals(GameInstance.GetStatsDataSystem(this.m_owner.GetGame()).GetDifficulty(), gameDifficulty.Story) {
            GameInstance.GetStatPoolsSystem(this.m_owner.GetGame()).RequestSettingStatPoolValue(Cast<StatsObjectID>(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, 100.00, this.m_owner);
            statusEffectSys = GameInstance.GetStatusEffectSystem(this.m_owner.GetGame());
            statusEffectSys.GetAppliedEffects(this.m_owner.GetEntityID(), effects);
            i = 0;
            while i < ArraySize(effects) {
                effectTags = effects[i].GetRecord().GameplayTags();
                if effects[i].GetRemainingDuration() > 0.00 && ArrayContains(effectTags, n"Debuff") {
                    statusEffectSys.RemoveStatusEffect(this.m_owner.GetEntityID(), effects[i].GetRecord().GetID(), effects[i].GetStackCount());
                }
                i += 1;
            }
        }
    }
}

@addMethod(PlayerDevelopmentData)
private final func ModifyCyberwareCapacity_Skillful(type: gamedataProficiencyType, config: ref<SBA_Skillful>) -> Void {
    let permaMod: ref<gameStatModifierData>;
    let CWCapAmount: Float;
    let CWCapWall: Int32;
    
    switch type {
        case gamedataProficiencyType.ReflexesSkill:
            CWCapAmount = config.CWCapAmount_Reflex;
            CWCapWall = config.CWCapWall_Reflex;
            break;
        case gamedataProficiencyType.TechnicalAbilitySkill:
            CWCapAmount = config.CWCapAmount_Tech;
            CWCapWall = config.CWCapWall_Tech;
            break;
        case gamedataProficiencyType.CoolSkill:
            CWCapAmount = config.CWCapAmount_Cool;
            CWCapWall = config.CWCapWall_Cool;
            break;
        case gamedataProficiencyType.IntelligenceSkill:
            CWCapAmount = config.CWCapAmount_Int;
            CWCapWall = config.CWCapWall_Int;
            break;
        case gamedataProficiencyType.StrengthSkill:
            CWCapAmount = config.CWCapAmount_Strength;
            CWCapWall = config.CWCapWall_Strength;
            break;
        case gamedataProficiencyType.Level:
            CWCapAmount = config.CWCapAmount_characterLevel;
            CWCapWall = config.CWCapWall_characterLevel;
            break;
        default:
            return;
    }

    if CWCapAmount > 0.0 && CWCapWall > 0 && this.m_proficiencies[this.GetProficiencyIndexByType(type)].currentLevel % CWCapWall == 0 {
        permaMod = RPGManager.CreateStatModifier(gamedataStatType.Humanity, gameStatModifierType.Additive, CWCapAmount);
        GameInstance.GetStatsSystem(this.m_owner.GetGame()).AddSavedModifier(Cast<StatsObjectID>(this.m_owner.GetEntityID()), permaMod);
    }
}

@wrapMethod(RPGManager)
public final static func CalculateMinorActivityReward(gi: GameInstance, experienceValue: Float) -> Float {
    let result: Float = wrappedMethod(gi, experienceValue);
    
    if Settings.EnableXPMultiplier() {
        result *= Settings.XPMultiplierLevel();
    }
    
    return result;
}

@wrapMethod(RPGManager)
public final static func CalculateStreetStoryReward(gi: GameInstance, experienceValue: Float) -> Float {
    let result: Float = wrappedMethod(gi, experienceValue);
    
    if Settings.EnableXPMultiplier() {
        result *= Settings.XPMultiplierLevel();
    }
    
    return result;
}

@wrapMethod(RPGManager)
public final static func CalculateEP1Reward(gi: GameInstance, experienceValue: Float, playerLevel: Float) -> Float {
    let result: Float = wrappedMethod(gi, experienceValue, playerLevel);
    
    if Settings.EnableXPMultiplier() {
        result *= Settings.XPMultiplierLevel();
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