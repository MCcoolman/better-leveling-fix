module BetterLeveling

import BetterLevelingConfig.*

@addField(PlayerDevelopmentData) private let m_btlHealthHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlArmorHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlStaminaHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlCarryHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlOxygenHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlStaminaRegenHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlLastAppliedLevel: Int32;

@wrapMethod(PlayerDevelopmentData)
private final const func ProcessProficiencyPassiveBonus(profIndex: Int32) -> Void {
    if Settings.RemoveLevelProgressionCap() {
        this.ProcessExtendedProficiencyPassiveBonus(profIndex);
    } else {
        wrappedMethod(profIndex);
    }
}

@addMethod(PlayerDevelopmentData)
private final const func ProcessExtendedProficiencyPassiveBonus(profIndex: Int32) -> Void {
    let profType: gamedataProficiencyType = this.m_proficiencies[profIndex].type;
    let currentLevel: Int32 = this.m_proficiencies[profIndex].currentLevel;
    
    if Equals(profType, gamedataProficiencyType.Level) {
        this.BTL_ApplyLevelBonusSnapshot(currentLevel);
    }
    
    let bonusRecord: ref<PassiveProficiencyBonus_Record>;
    let effectorRecord: ref<Effector_Record>;
    let maxBonuses: Int32 = this.GetProficiencyRecordByIndex(profIndex).GetPassiveBonusesCount();
    
    if maxBonuses > 0 {
        let bonusIndex: Int32 = Min(currentLevel - 1, maxBonuses - 1);
        if bonusIndex >= 0 {
            bonusRecord = this.GetProficiencyRecordByIndex(profIndex).GetPassiveBonusesItem(bonusIndex);
            effectorRecord = bonusRecord.EffectorToTrigger();
            if IsDefined(effectorRecord) {
                GameInstance.GetEffectorSystem(this.m_owner.GetGame()).ApplyEffector(this.m_owner.GetEntityID(), this.m_owner, effectorRecord.GetID());
            }
        }
    }
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_IsLevelBonusEnabled() -> Bool {
    return Settings.RemoveLevelProgressionCap();
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_ClearOwnModifiers() -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(this.m_owner.GetEntityID());
    
    if IsDefined(this.m_btlHealthHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlHealthHandle);
        this.m_btlHealthHandle = null;
    }
    
    if IsDefined(this.m_btlArmorHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlArmorHandle);
        this.m_btlArmorHandle = null;
    }
    
    if IsDefined(this.m_btlStaminaHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlStaminaHandle);
        this.m_btlStaminaHandle = null;
    }
    
    if IsDefined(this.m_btlCarryHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlCarryHandle);
        this.m_btlCarryHandle = null;
    }
    
    if IsDefined(this.m_btlOxygenHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlOxygenHandle);
        this.m_btlOxygenHandle = null;
    }
    
    if IsDefined(this.m_btlStaminaRegenHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlStaminaRegenHandle);
        this.m_btlStaminaRegenHandle = null;
    }
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_AddModifier(stat: gamedataStatType, value: Float) -> ref<gameStatModifierData> {
    if value == 0.0 {
        return null;
    }
    
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(this.m_owner.GetEntityID());
    let mod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(stat, gameStatModifierType.Additive, value);
    
    statsSystem.AddModifier(objectID, mod);
    return mod;
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_CumulativeForLevel(level: Int32, out health: Float, out armor: Float, out stamina: Float, out carry: Float, out oxygen: Float, out staminaRegen: Float) -> Void {
    health = 0.0;
    armor = 0.0;
    stamina = 0.0;
    carry = 0.0;
    oxygen = 0.0;
    staminaRegen = 0.0;
    
    if level <= 60 {
        return;
    }
    
    let currentLevel: Int32 = 61;
    while currentLevel <= level {
        if currentLevel >= 61 && currentLevel <= 80 {
            if (currentLevel - 60) % 2 == 0 {
                health += 5.0;
                armor += 5.0;
            }
        } else if currentLevel >= 81 && currentLevel <= 140 {
            if (currentLevel - 80) % 3 == 0 {
                health += 50.0;
                armor += 50.0;
            }
        } else if currentLevel >= 141 && currentLevel <= 200 {
            if (currentLevel - 140) % 2 == 0 {
                health += 100.0;
                armor += 100.0;
            }
        } else if currentLevel >= 201 && currentLevel <= 500 {
            health += 20.0;
            armor += 20.0;
        }
        
        if (currentLevel - 60) % 5 == 0 {
            stamina += 5.0;
        }
        
        if (currentLevel - 60) % 5 == 0 {
            oxygen += 5.0;
        }
        
        if (currentLevel - 60) % 10 == 0 {
            staminaRegen += 1.0;
        }
        
        carry += 2.0;
        
        currentLevel += 1;
    }
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_ApplyLevelBonusSnapshot(level: Int32) -> Void {
    if !this.BTL_IsLevelBonusEnabled() || level <= 60 {
        this.BTL_ClearOwnModifiers();
        this.m_btlLastAppliedLevel = level;
        return;
    }
    
    if level == this.m_btlLastAppliedLevel {
        return;
    }
    
    this.BTL_ClearOwnModifiers();
    
    let health: Float;
    let armor: Float;
    let stamina: Float;
    let carry: Float;
    let oxygen: Float;
    let staminaRegen: Float;
    this.BTL_CumulativeForLevel(level, health, armor, stamina, carry, oxygen, staminaRegen);
    
    this.m_btlHealthHandle = this.BTL_AddModifier(gamedataStatType.Health, health);
    this.m_btlArmorHandle = this.BTL_AddModifier(gamedataStatType.Armor, armor);
    this.m_btlStaminaHandle = this.BTL_AddModifier(gamedataStatType.Stamina, stamina);
    this.m_btlCarryHandle = this.BTL_AddModifier(gamedataStatType.CarryCapacity, carry);
    this.m_btlOxygenHandle = this.BTL_AddModifier(gamedataStatType.Oxygen, oxygen);
    this.m_btlStaminaRegenHandle = this.BTL_AddModifier(gamedataStatType.StaminaRegenRate, staminaRegen);
    
    this.m_btlLastAppliedLevel = level;
}

@wrapMethod(PlayerDevelopmentData)
private final const func RestoreProficiencyPassiveBonuses(profIndex: Int32, gameInstance: GameInstance) -> Void {
    if Settings.RemoveLevelProgressionCap() {
        this.RestoreExtendedProficiencyPassiveBonuses(profIndex, gameInstance);
    } else {
        wrappedMethod(profIndex, gameInstance);
    }
}

@addMethod(PlayerDevelopmentData)
private final const func RestoreExtendedProficiencyPassiveBonuses(profIndex: Int32, gameInstance: GameInstance) -> Void {
    let profType: gamedataProficiencyType = this.m_proficiencies[profIndex].type;
    let currentLevel: Int32 = this.m_proficiencies[profIndex].currentLevel;
    
    if Equals(profType, gamedataProficiencyType.Level) {
        this.BTL_ApplyLevelBonusSnapshot(currentLevel);
    }
    
    let bonusRecord: ref<PassiveProficiencyBonus_Record>;
    let effectorRecord: ref<Effector_Record>;
    let proficiencyRecord: ref<Proficiency_Record> = this.GetProficiencyRecordByIndex(profIndex);
    let effectorSystem: ref<EffectorSystem> = GameInstance.GetEffectorSystem(gameInstance);
    let maxLevel: Int32 = proficiencyRecord.GetPassiveBonusesCount();
    
    let i: Int32 = 0;
    while i < currentLevel {
        if i >= maxLevel {
            break;
        }
        
        bonusRecord = proficiencyRecord.GetPassiveBonusesItem(i);
        effectorRecord = bonusRecord.EffectorToTrigger();
        if IsDefined(effectorRecord) && !effectorRecord.IsA(n"gamedataAddDevelopmentPointEffector_Record") {
            effectorSystem.ApplyEffector(this.m_ownerID, this.m_owner, effectorRecord.GetID());
        }
        i += 1;
    }
}