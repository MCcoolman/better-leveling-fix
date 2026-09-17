module BetterLeveling

import BetterLevelingConfig.*

public class BetterLevelingTweakDBService extends ScriptableService {

    private cb func OnInitialize() -> Void {
        this.UpdateAllTweakDBRecords();
    }

    public func UpdateAllTweakDBRecords() -> Void {
        this.UpdateLevelCap();
        this.UpdateStreetCredCap();
        this.UpdateAttributeCaps();
        this.UpdateStartingAttributes();
        this.UpdateSkillCaps();
        this.UpdateCyberwareCapacity();
    }

    private func UpdateLevelCap() -> Void {
        let isEnabled: Bool = Settings.EnableLevelCap();
        if !isEnabled { return; }

        let levelCap: Int32 = Settings.NewLevelCap();

        TweakDBManager.SetFlat(t"Proficiencies.Level.maxLevel", levelCap);
        TweakDBManager.UpdateRecord(t"Proficiencies.Level");

        TweakDBManager.SetFlat(t"LootPrereqs.BelowMaxPlayerLevelPrereq.valueToCheck", Cast<Float>(levelCap));
        TweakDBManager.UpdateRecord(t"LootPrereqs.BelowMaxPlayerLevelPrereq");

        TweakDBManager.SetFlat(t"LootPrereqs.MaxPlayerLevelPrereq.valueToCheck", Cast<Float>(levelCap));
        TweakDBManager.UpdateRecord(t"LootPrereqs.MaxPlayerLevelPrereq");

        TweakDBManager.SetFlat(t"LootPrereqs.CyberpsychoWeaponInLootPrereq_end_inline1.valueToCheck", Cast<Float>(levelCap));
        TweakDBManager.UpdateRecord(t"LootPrereqs.CyberpsychoWeaponInLootPrereq_end_inline1");

        TweakDBManager.SetFlat(t"LootPrereqs.LegendaryCWLevelAvailabilityAtVendor_inline1.valueToCheck", Cast<Float>(levelCap));
        TweakDBManager.UpdateRecord(t"LootPrereqs.LegendaryCWLevelAvailabilityAtVendor_inline1");
    }

    private func UpdateStreetCredCap() -> Void {
        let isEnabled: Bool = Settings.EnableStreetCredCap();
        if !isEnabled { return; }

        let streetCredCap: Int32 = Settings.StreetCredCap();

        TweakDBManager.SetFlat(t"BaseStats.StreetCred.max", streetCredCap);
        TweakDBManager.UpdateRecord(t"BaseStats.StreetCred");

        TweakDBManager.SetFlat(t"Proficiencies.StreetCred.maxLevel", streetCredCap);
        TweakDBManager.UpdateRecord(t"Proficiencies.StreetCred");
    }

    private func UpdateAttributeCaps() -> Void {
        let isEnabled: Bool = Settings.EnableAttributeCap();
        if !isEnabled { return; }

        let attributeCap: Int32 = Settings.AttributeCap();
        let tweakDBCap: Float = attributeCap > 20 ? 20.0 : Cast<Float>(attributeCap);

        TweakDBManager.SetFlat(t"BaseStats.Strength.max", tweakDBCap);
        TweakDBManager.UpdateRecord(t"BaseStats.Strength");

        TweakDBManager.SetFlat(t"BaseStats.Reflexes.max", tweakDBCap);
        TweakDBManager.UpdateRecord(t"BaseStats.Reflexes");

        TweakDBManager.SetFlat(t"BaseStats.TechnicalAbility.max", tweakDBCap);
        TweakDBManager.UpdateRecord(t"BaseStats.TechnicalAbility");

        TweakDBManager.SetFlat(t"BaseStats.Intelligence.max", tweakDBCap);
        TweakDBManager.UpdateRecord(t"BaseStats.Intelligence");

        TweakDBManager.SetFlat(t"BaseStats.Cool.max", tweakDBCap);
        TweakDBManager.UpdateRecord(t"BaseStats.Cool");
    }

    private func UpdateStartingAttributes() -> Void {
        let isEnabled: Bool = Settings.EnableStartingAttr();
        if !isEnabled { return; }

        let startingPoints: Int32 = Settings.StartingAttributePoints();
        let maxPerAttribute: Int32 = Settings.MaxStartingAttribute();
        let minPerAttribute: Int32 = 3;

        TweakDBManager.SetFlat(t"UICharacterCreationGeneral.BaseValues.attributePointsAvailable", startingPoints);
        TweakDBManager.UpdateRecord(t"UICharacterCreationGeneral.BaseValues");

        TweakDBManager.SetFlat(t"UICharacterCreationGeneral.BaseValues.maxAttributeValue", maxPerAttribute);
        TweakDBManager.UpdateRecord(t"UICharacterCreationGeneral.BaseValues");

        TweakDBManager.SetFlat(t"UICharacterCreationGeneral.BaseValues.minAttributeValue", minPerAttribute);
        TweakDBManager.UpdateRecord(t"UICharacterCreationGeneral.BaseValues");

        TweakDBManager.SetFlat(t"BTL.StartingAttributePoints", startingPoints);
        TweakDBManager.SetFlat(t"BTL.MaxStartingAttribute", maxPerAttribute);
    }

    private func UpdateSkillCaps() -> Void {
        let isEnabled: Bool = Settings.ExtendSkillProgression();
        if !isEnabled { return; }
    
        let skillCap: Int32 = Settings.SkillProgressionCap();
    
        TweakDBManager.SetFlat(t"Proficiencies.StrengthSkill.maxLevel", skillCap);
        TweakDBManager.SetFlat(t"Proficiencies.ReflexesSkill.maxLevel", skillCap);
        TweakDBManager.SetFlat(t"Proficiencies.IntelligenceSkill.maxLevel", skillCap);
        TweakDBManager.SetFlat(t"Proficiencies.TechnicalAbilitySkill.maxLevel", skillCap);
        TweakDBManager.SetFlat(t"Proficiencies.CoolSkill.maxLevel", skillCap);
        TweakDBManager.SetFlat(t"Proficiencies.EspionageSkill.maxLevel", skillCap);
    
        TweakDBManager.UpdateRecord(t"Proficiencies.StrengthSkill");
        TweakDBManager.UpdateRecord(t"Proficiencies.ReflexesSkill");
        TweakDBManager.UpdateRecord(t"Proficiencies.IntelligenceSkill");
        TweakDBManager.UpdateRecord(t"Proficiencies.TechnicalAbilitySkill");
        TweakDBManager.UpdateRecord(t"Proficiencies.CoolSkill");
        TweakDBManager.UpdateRecord(t"Proficiencies.EspionageSkill");
    }

    private func UpdateCyberwareCapacity() -> Void {
        let isEnabled: Bool = Settings.EnableCyberwareScaling();
        if !isEnabled { return; }

        let capacityScaling: Float = Cast<Float>(Settings.MoreCyberwareCapacity());

        TweakDBManager.SetFlat(t"Constants.CyberwareCapacity.cyberwarePointsIncreasePerLevel", capacityScaling);
        TweakDBManager.UpdateRecord(t"Constants.CyberwareCapacity");

        if Settings.EnableCyberwareCap() {
            let cyberwareCap: Float = Cast<Float>(Settings.CyberwareCap());
            TweakDBManager.SetFlat(t"Constants.CyberwareCapacity.cyberwarePointsMax", cyberwareCap);
            TweakDBManager.UpdateRecord(t"Constants.CyberwareCapacity");
        }
    }
}