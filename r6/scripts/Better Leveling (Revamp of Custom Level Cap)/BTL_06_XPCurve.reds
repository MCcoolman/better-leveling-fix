module BetterLeveling

import BetterLevelingConfig.*

@wrapMethod(PlayerDevelopmentData)
private final const func GetExperienceForNextLevel(type: gamedataProficiencyType) -> Int32 {
    let pIndex: Int32 = this.GetProficiencyIndexByType(type);
    if pIndex >= 0 {
        let currentLevel: Int32 = this.m_proficiencies[pIndex].currentLevel;
        
        if Settings.BeyondLevel60Curve() && Equals(type, gamedataProficiencyType.Level) && currentLevel >= 61 {
            return this.BTL_GetExtendedLevelXP(currentLevel + 1);
        }
        
        if Settings.BeyondStreetCredCurve() && Equals(type, gamedataProficiencyType.StreetCred) && currentLevel >= 61 {
            return this.BTL_GetExtendedStreetCredXP(currentLevel + 1);
        }
    }
    
    return wrappedMethod(type);
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_GetExtendedLevelXP(targetLevel: Int32) -> Int32 {
    let baseXP: Float = 10124.0;
    
    if targetLevel >= 135 {
        return 4000000;
    }
    
    if targetLevel >= 61 {
        let levelsAbove60: Int32 = targetLevel - 60;
        let multiplier: Float = 1.087; // 8.7% increase per level
        let scaledXP: Float = baseXP * PowF(multiplier, Cast<Float>(levelsAbove60));
        return RoundF(scaledXP);
    }
    
    return Cast<Int32>(baseXP);
}

@addMethod(PlayerDevelopmentData)
private final const func BTL_GetExtendedStreetCredXP(targetLevel: Int32) -> Int32 {
    let baseXP: Float = 10124.0;
    
    if targetLevel >= 350 {
        return 50000000;
    }
    
    if targetLevel >= 61 {
        let levelsAbove60: Int32 = targetLevel - 60;
        let multiplier: Float = 1.0305; // 3.05% increase per level
        let scaledXP: Float = baseXP * PowF(multiplier, Cast<Float>(levelsAbove60));
        return RoundF(scaledXP);
    }
    
    return Cast<Int32>(baseXP);
}