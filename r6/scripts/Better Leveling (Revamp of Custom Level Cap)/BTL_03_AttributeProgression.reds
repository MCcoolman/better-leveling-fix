module BetterLeveling

import BetterLevelingConfig.*

@addField(PlayerDevelopmentData) private let m_btlStrengthHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlIntelligenceHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlReflexesHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlTechnicalHandle: ref<gameStatModifierData>;
@addField(PlayerDevelopmentData) private let m_btlCoolHandle: ref<gameStatModifierData>;

@wrapMethod(PlayerDevelopmentData)
public final const func CanAttributeBeBought(type: gamedataStatType) -> Bool {
    if Settings.RemoveAttributeProgressionCap() && PlayerDevelopmentData.IsAttribute(type) {
        let attributeCap: Int32 = Settings.AttributeCap();
        
        if attributeCap <= 20 {
            return wrappedMethod(type);
        }
        
        return this.CanAttributeBeBoughtExtended(type);
    } else {
        return wrappedMethod(type);
    }
}

@addMethod(PlayerDevelopmentData)
private final const func CanAttributeBeBoughtExtended(type: gamedataStatType) -> Bool {
    let currVal: Int32;
    let enoughPoints: Bool;
    let objectID: StatsObjectID = Cast<StatsObjectID>(this.m_owner.GetEntityID());
    let dIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Attribute);
    
    if dIndex < 0 {
        return false;
    }
    
    currVal = Cast<Int32>(GameInstance.GetStatsSystem(this.m_owner.GetGame()).GetStatValue(objectID, type));
    enoughPoints = this.m_devPoints[dIndex].unspent >= this.GetAttributeNextLevelCost(type);
    
    let maxExtendedLevel: Int32 = 200;
    let maxLvlNotReached: Bool = maxExtendedLevel > currVal;
    
    if enoughPoints && maxLvlNotReached {
        return true;
    }
    
    return false;
}

@wrapMethod(PlayerDevelopmentData)
public final const func BuyAttribute(type: gamedataStatType) -> Bool {
    if Settings.RemoveAttributeProgressionCap() && PlayerDevelopmentData.IsAttribute(type) {
        let success: Bool = wrappedMethod(type);
        
        if success {
            this.BTL_ApplyAttributeBonusSnapshot();
        }
        
        return success;
    } else {
        return wrappedMethod(type);
    }
}

@wrapMethod(PlayerDevelopmentData)
public final const func SetAttribute(type: gamedataStatType, amount: Float) -> Void {
    wrappedMethod(type, amount);
    
    if Settings.RemoveAttributeProgressionCap() {
        this.BTL_ApplyAttributeBonusSnapshot();
    }
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_ClearAttributeModifiers() -> Void {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(this.m_owner.GetEntityID());
    
    if IsDefined(this.m_btlStrengthHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlStrengthHandle);
        this.m_btlStrengthHandle = null;
    }
    
    if IsDefined(this.m_btlIntelligenceHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlIntelligenceHandle);
        this.m_btlIntelligenceHandle = null;
    }
    
    if IsDefined(this.m_btlReflexesHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlReflexesHandle);
        this.m_btlReflexesHandle = null;
    }
    
    if IsDefined(this.m_btlTechnicalHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlTechnicalHandle);
        this.m_btlTechnicalHandle = null;
    }
    
    if IsDefined(this.m_btlCoolHandle) {
        statsSystem.RemoveModifier(objectID, this.m_btlCoolHandle);
        this.m_btlCoolHandle = null;
    }
}

@wrapMethod(PlayerDevelopmentData)
public final func OnRestored(gameInstance: GameInstance) -> Void {
    wrappedMethod(gameInstance);
    
    if Settings.RemoveAttributeProgressionCap() {
        this.BTL_ApplyAttributeBonusSnapshot();
    }
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_ApplyAttributeBonusSnapshot() -> Void {
    if !Settings.RemoveAttributeProgressionCap() {
        this.BTL_ClearAttributeModifiers();
        return;
    }
    
    this.BTL_ClearAttributeModifiers();
    
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_owner.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(this.m_owner.GetEntityID());
    
    let strengthVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Strength));
    let intelligenceVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Intelligence));
    let reflexesVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Reflexes));
    let technicalVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.TechnicalAbility));
    let coolVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Cool));
        
    if strengthVal > 20 {
        let healthBonus: Float = Cast<Float>((strengthVal - 20) * 2);
        this.m_btlStrengthHandle = RPGManager.CreateStatModifier(
            gamedataStatType.Health, 
            gameStatModifierType.Additive, 
            healthBonus
        );
        statsSystem.AddModifier(objectID, this.m_btlStrengthHandle);
    }
    
    if intelligenceVal > 20 {
        let ramBonus: Float = Cast<Float>((intelligenceVal - 20) / 4);
        if ramBonus > 0.0 {
            this.m_btlIntelligenceHandle = RPGManager.CreateStatModifier(
                gamedataStatType.Memory, 
                gameStatModifierType.Additive, 
                ramBonus
            );
            statsSystem.AddModifier(objectID, this.m_btlIntelligenceHandle);
        }
    }
    
    if reflexesVal > 20 {
        let critChance: Float = Cast<Float>(reflexesVal - 20) * 0.5;
        this.m_btlReflexesHandle = RPGManager.CreateStatModifier(
            gamedataStatType.CritChance, 
            gameStatModifierType.Additive, 
            critChance
        );
        statsSystem.AddModifier(objectID, this.m_btlReflexesHandle);
    }
    
    if technicalVal > 20 {
        let armorBonus: Float = Cast<Float>((technicalVal - 20) * 2);
        this.m_btlTechnicalHandle = RPGManager.CreateStatModifier(
            gamedataStatType.Armor, 
            gameStatModifierType.Additive, 
            armorBonus
        );
        statsSystem.AddModifier(objectID, this.m_btlTechnicalHandle);
    }
    
    if coolVal > 20 {
        let critDamage: Float = Cast<Float>(coolVal - 20) * 1.25;
        this.m_btlCoolHandle = RPGManager.CreateStatModifier(
            gamedataStatType.CritDamage, 
            gameStatModifierType.Additive, 
            critDamage
        );
        statsSystem.AddModifier(objectID, this.m_btlCoolHandle);
    }
}

