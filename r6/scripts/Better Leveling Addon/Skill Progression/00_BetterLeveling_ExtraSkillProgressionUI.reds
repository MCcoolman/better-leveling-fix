module BetterLeveling.Addon.SkillProgression

import BetterLevelingConfig.*

public class BetterLevelingTweak extends ScriptableTweak {
    protected cb func OnApply() -> Void {
        this.AddCustomPassiveBonuses();
    }

    private final func AddCustomPassiveBonuses() -> Void {
        this.AddBonusesToSkill(n"Proficiencies.StrengthSkill", "Strength");
        this.AddBonusesToSkill(n"Proficiencies.ReflexesSkill", "Reflexes");
        this.AddBonusesToSkill(n"Proficiencies.IntelligenceSkill", "Intelligence");
        this.AddBonusesToSkill(n"Proficiencies.TechnicalAbilitySkill", "Technical");
        this.AddBonusesToSkill(n"Proficiencies.CoolSkill", "Cool");
    }

    private final func AddBonusesToSkill(skillName: CName, skillPrefix: String) -> Void {
        let skillNameStr: String = NameToString(skillName);
        let skillID: TweakDBID = TDBID.Create(skillNameStr);
        
        TweakDBManager.SetFlat(TDBID.Create(skillNameStr + ".maxLevel"), ToVariant(150));
        
        let bonusesID: TweakDBID = TDBID.Create(skillNameStr + ".passiveBonuses");
        let bonusesFlat: Variant = TweakDBInterface.GetFlat(bonusesID);
        let currentBonuses: array<TweakDBID>;
        
        if IsDefined(bonusesFlat) {
            currentBonuses = FromVariant<array<TweakDBID>>(bonusesFlat);
        }
        
        while ArraySize(currentBonuses) < 150 {
            ArrayPush(currentBonuses, TDBID.Create(""));
        }
        
        currentBonuses[64] = TDBID.Create("BTL." + skillPrefix + "Level65");   // Level 65
        currentBonuses[74] = TDBID.Create("BTL." + skillPrefix + "Level75");   // Level 75
        currentBonuses[84] = TDBID.Create("BTL." + skillPrefix + "Level85");   // Level 85
        currentBonuses[99] = TDBID.Create("BTL." + skillPrefix + "Level100");  // Level 100
        currentBonuses[119] = TDBID.Create("BTL." + skillPrefix + "Level120"); // Level 120
        currentBonuses[149] = TDBID.Create("BTL." + skillPrefix + "Level150"); // Level 150

        TweakDBManager.SetFlat(TDBID.Create(skillNameStr + ".passiveBonuses"), ToVariant(currentBonuses));
        TweakDBManager.UpdateRecord(skillID);
    }
}

@wrapMethod(NewPerksSkillBarLogicController)
private final func UpdateSkillsCount() -> Void {
    let i: Int32 = 3;
    let counter: Int32 = 0;
    let limit: Int32 = this.m_requestedSkills;
    
    let skillLevel: Int32 = IsDefined(this.m_data) ? this.m_data.m_level : 0;
    let shouldUseSlindingWindow: Bool = skillLevel >= 35;
    let visibleLevels: array<Int32> = [35, 40, 45, 50, 55, 60, 65, 75, 85, 100, 120, 150];
    
    while i < limit {
        if IsDefined(this.m_levelsControllers[counter]) {
            let levelData: ref<LevelRewardDisplayData> = this.m_data.m_passiveBonusesData[i];
            let shouldShow: Bool = true;
            
            if shouldUseSlindingWindow && IsDefined(levelData) {
                if levelData.level < 35 {
                    shouldShow = false;
                } else {
                    shouldShow = false;
                    let j: Int32 = 0;
                    while j < ArraySize(visibleLevels) {
                        if levelData.level == visibleLevels[j] {
                            shouldShow = true;
                            break;
                        }
                        j += 1;
                    }
                }
            }
            
            this.m_levelsControllers[counter].GetRootWidget().SetVisible(shouldShow);
            
            if shouldShow {
                this.SetSkillLevelData(this.m_levelsControllers[counter], levelData);
            }
        }
        counter += 1;
        i += 5;
    };
    
    limit = ArraySize(this.m_data.m_passiveBonusesData);
    while this.m_requestedSkills < limit {
        this.AsyncSpawnFromLocal(inkWidgetRef.Get(this.m_levelsContainer), n"SkillLevel", this, n"OnSkillLevelSpawned");
        this.m_requestedSkills += 5;
    };
}

@wrapMethod(NewPerksSkillBarLogicController)
protected cb func OnSkillLevelSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let index: Int32;
    ArrayPush(this.m_levelsControllers, widget.GetController() as NewPerksSkillLevelLogicController);
    index = ArraySize(this.m_levelsControllers) - 1;
    
    let skillLevel: Int32 = IsDefined(this.m_data) ? this.m_data.m_level : 0;
    let shouldUseSlindingWindow: Bool = skillLevel >= 35;
    let visibleLevels: array<Int32> = [35, 40, 45, 50, 55, 60, 65, 75, 85, 100, 120, 150];
    
    let levelData: ref<LevelRewardDisplayData> = this.m_data.m_passiveBonusesData[3 + index * 5];
    let shouldShow: Bool = true;
    
    if shouldUseSlindingWindow && IsDefined(levelData) {
        if levelData.level < 35 {
            shouldShow = false;
        } else {
            shouldShow = false;
            let j: Int32 = 0;
            while j < ArraySize(visibleLevels) {
                if levelData.level == visibleLevels[j] {
                    shouldShow = true;
                    break;
                }
                j += 1;
            }
        }
    }
    
    widget.SetVisible(shouldShow);
    
    if shouldShow {
        this.SetSkillLevelData(this.m_levelsControllers[index], levelData);
        this.m_levelsControllers[index].RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
        this.m_levelsControllers[index].RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    }
    
    return true;
}