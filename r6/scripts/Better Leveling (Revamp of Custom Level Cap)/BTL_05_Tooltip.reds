module BetterLeveling

import BetterLevelingConfig.*

@addMethod(PlayerDevelopmentSystem)
public static func BTL_GetAttrRec(attr: gamedataStatType) -> TweakDBID {
    return TDBID.Create(
        "BaseStats." + EnumValueToString("gamedataStatType", Cast<Int64>(EnumInt(attr)))
    );
}

@addMethod(PlayerDevelopmentSystem)
public static func BTL_ReadAttributeCap(attr: gamedataStatType) -> Int32 {
    if Settings.EnableAttributeCap() {
        return Settings.AttributeCap();
    }
    let rec: ref<Stat_Record> = TweakDBInterface.GetStatRecord(PlayerDevelopmentSystem.BTL_GetAttrRec(attr));
    if IsDefined(rec) {
        let capF: Float = rec.Max();
        if capF > 0.0 {
            return Cast<Int32>(capF);
        }
    }
    
    return 20;
}


@wrapMethod(PlayerDevelopmentDataManager)
private final func FillAttributeData(attribute: SAttribute, out outData: ref<AttributeData>) -> Void {
    wrappedMethod(attribute, outData);
    
    let actualCap: Int32 = PlayerDevelopmentSystem.BTL_ReadAttributeCap(attribute.attributeName);
    outData.maxValue = actualCap;
    outData.availableToUpgrade = outData.value < actualCap;
}

@wrapMethod(PerkMenuTooltipController)
public func SetData(tooltipData: ref<ATooltipData>) -> Void {
    wrappedMethod(tooltipData);
    this.m_maxProficiencyLevel = PlayerDevelopmentSystem.BTL_ReadAttributeCap(gamedataStatType.Strength);
}