module BetterLeveling

import BetterLevelingConfig.*


@addMethod(PlayerPuppet)
public final static func BTL_CheckDashBugStatus() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
    
    if !IsDefined(player) {
        FTLog("[Better Leveling] ERROR: Could not get player");
        return;
    }
    
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    
    let reflexValue: Int32 = Cast<Int32>(statsSystem.GetStatValue(
        Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.Reflexes));
    
    let milestone2: Int32 = devData.IsNewPerkBought(gamedataNewPerkType.Reflexes_Central_Milestone_2);
    let milestone3: Int32 = devData.IsNewPerkBought(gamedataNewPerkType.Reflexes_Central_Milestone_3);
    
    FTLog("DASH BUG STATUS CHECK");
    FTLog("Reflexes: " + ToString(reflexValue));
    FTLog("Milestone 2: " + ToString(milestone2));
    FTLog("Milestone 3: " + ToString(milestone3));
    FTLog("Attribute Cap Setting: " + ToString(Settings.AttributeCap()));
    
    if milestone2 == 2 && milestone3 != 3 && reflexValue >= 21 {
        FTLog("WARNING: Dash bug is ACTIVE!");
        FTLog("Your dash will not work in the air.");
        FTLog("To fix, run: PlayerPuppet.BTL_FixDashBug()");
    } else {
        FTLog("Status: Safe! No dash bug detected.");
    }
}

@addMethod(PlayerPuppet)
public final static func BTL_FixDashBug() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
    
    if !IsDefined(player) {
        FTLog("[Better Leveling] ERROR: Could not get player");
        return;
    }
    
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    
    let reflexValue: Int32 = Cast<Int32>(statsSystem.GetStatValue(
        Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.Reflexes));
    
    let milestone2: Int32 = devData.IsNewPerkBought(gamedataNewPerkType.Reflexes_Central_Milestone_2);
    let milestone3: Int32 = devData.IsNewPerkBought(gamedataNewPerkType.Reflexes_Central_Milestone_3);
    
    FTLog("DASH BUG FIX");
    
    if milestone2 == 2 && milestone3 != 3 && reflexValue >= 21 {
        FTLog("Bug detected! Applying fix...");
        
        devData.BuyNewPerk(gamedataNewPerkType.Reflexes_Central_Milestone_3);
        
        FTLog("SUCCESS: Dash ability unlocked!");
        FTLog("Milestone 3 has been purchased.");
        FTLog("The fix should prevent this from happening again.");
    } else {
        FTLog("Status: Normal - No fix needed");
        FTLog("Reflexes: " + ToString(reflexValue));
        FTLog("Milestone 2: " + ToString(milestone2));
        FTLog("Milestone 3: " + ToString(milestone3));
    }
}

@addMethod(PlayerPuppet)
public final static func BTL_IsModLoaded() -> Bool {
    FTLog("[Better Leveling] ===================================");
    FTLog("[Better Leveling] Redscript side is loaded and functional");
    FTLog("[Better Leveling] Version: Check mod files for version info");
    FTLog("[Better Leveling] ===================================");
    return true;
}

@addMethod(PlayerPuppet)
public final static func BTL_ShowCurrentConfig() -> Void {
    FTLog("BETTER LEVELING CONFIGURATION");
    FTLog("--- LEVEL SETTINGS ---");
    FTLog("Level Cap: " + ToString(Settings.NewLevelCap()) + " (Enabled: " + ToString(Settings.EnableLevelCap()) + ")");
    FTLog("Street Cred Cap: " + ToString(Settings.StreetCredCap()) + " (Enabled: " + ToString(Settings.EnableStreetCredCap()) + ")");
    FTLog("Skill Progression Cap: " + ToString(Settings.SkillProgressionCap()) + " (Enabled: " + ToString(Settings.ExtendSkillProgression()) + ")");
    FTLog("--- ATTRIBUTE SETTINGS ---");
    FTLog("Attribute Cap: " + ToString(Settings.AttributeCap()) + " (Enabled: " + ToString(Settings.EnableAttributeCap()) + ")");
    FTLog("Attr Points Per Level: " + ToString(Settings.AttrPointsPerLevel()) + " (Enabled: " + ToString(Settings.EnableMoreAttrPerLevel()) + ")");
    FTLog("Perk Points Per Level: " + ToString(Settings.PerkPointsPerLevel()) + " (Enabled: " + ToString(Settings.EnableMorePerkPerLevel()) + ")");
    FTLog("--- CHARACTER CREATION ---");
    FTLog("Starting Attr Points: " + ToString(Settings.StartingAttributePoints()) + " (Enabled: " + ToString(Settings.EnableStartingAttr()) + ")");
    FTLog("Max Starting Attr: " + ToString(Settings.MaxStartingAttribute()) + " (Enabled: " + ToString(Settings.EnableStartingAttr()) + ")");
    FTLog("--- CYBERWARE SETTINGS ---");
    FTLog("Cyberware Capacity Scaling: " + ToString(Settings.MoreCyberwareCapacity()) + " (Enabled: " + ToString(Settings.EnableCyberwareScaling()) + ")");
    FTLog("Cyberware Cap: " + ToString(Settings.CyberwareCap()) + " (Enabled: " + ToString(Settings.EnableCyberwareCap()) + ")");
    FTLog("--- PROGRESSION FEATURES ---");
    FTLog("Remove Level Progression Cap: " + ToString(Settings.RemoveLevelProgressionCap()));
    FTLog("Remove Attribute Progression Cap: " + ToString(Settings.RemoveAttributeProgressionCap()));
    FTLog("Beyond Level 60 Curve: " + ToString(Settings.BeyondLevel60Curve()));
    FTLog("Beyond Street Cred Curve: " + ToString(Settings.BeyondStreetCredCurve()));
    FTLog("--- XP MULTIPLIERS ---");
    FTLog("XP Multiplier Enabled: " + ToString(Settings.EnableXPMultiplier()));
    FTLog("Level XP: " + ToString(Settings.XPMultiplierLevel()));
    FTLog("Street Cred XP: " + ToString(Settings.XPMultiplierStreetCred()));
    FTLog("Headhunter XP: " + ToString(Settings.XPMultiplierHeadhunter()));
    FTLog("Netrunner XP: " + ToString(Settings.XPMultiplierNetrunner()));
    FTLog("Shinobi XP: " + ToString(Settings.XPMultiplierShinobi()));
    FTLog("Solo XP: " + ToString(Settings.XPMultiplierSolo()));
    FTLog("Engineer XP: " + ToString(Settings.XPMultiplierEngineer()));
}

@addMethod(PlayerPuppet)
public final static func BTL_ShowPlayerStats() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
    
    if !IsDefined(player) {
        FTLog("[Better Leveling] ERROR: Could not get player");
        return;
    }
    
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(player.GetEntityID());
    
    FTLog("--- PROGRESSION ---");
    FTLog("Level: " + ToString(devData.GetProficiencyLevel(gamedataProficiencyType.Level)));
    FTLog("Street Cred: " + ToString(devData.GetProficiencyLevel(gamedataProficiencyType.StreetCred)));
    FTLog("--- ATTRIBUTES ---");
    FTLog("Strength: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Strength))));
    FTLog("Intelligence: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Intelligence))));
    FTLog("Reflexes: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Reflexes))));
    FTLog("Technical Ability: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.TechnicalAbility))));
    FTLog("Cool: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Cool))));
    FTLog("--- SKILLS ---");
    FTLog("Headhunter (Reflexes): " + ToString(devData.GetProficiencyLevel(gamedataProficiencyType.ReflexesSkill)));
    FTLog("Netrunner (Intelligence): " + ToString(devData.GetProficiencyLevel(gamedataProficiencyType.IntelligenceSkill)));
    FTLog("Shinobi (Cool): " + ToString(devData.GetProficiencyLevel(gamedataProficiencyType.CoolSkill)));
    FTLog("Solo (Strength): " + ToString(devData.GetProficiencyLevel(gamedataProficiencyType.StrengthSkill)));
    FTLog("Engineer (Technical): " + ToString(devData.GetProficiencyLevel(gamedataProficiencyType.TechnicalAbilitySkill)));
    FTLog("--- CORE STATS ---");
    FTLog("Health: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Health))));
    FTLog("Stamina: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Stamina))));
    FTLog("Armor: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Armor))));
    FTLog("Carry Capacity: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.CarryCapacity))));
    FTLog("Cyberware Capacity: " + ToString(Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Humanity))));
}

@addMethod(PlayerPuppet)
public final static func BTL_ShowAvailablePoints() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
    
    if !IsDefined(player) {
        FTLog("[Better Leveling] ERROR: Could not get player");
        return;
    }
    
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    
    FTLog("AVAILABLE POINTS");
    FTLog("Attribute Points: " + ToString(devData.GetDevPoints(gamedataDevelopmentPointType.Attribute)));
    FTLog("Perk Points: " + ToString(devData.GetDevPoints(gamedataDevelopmentPointType.Primary)));
}

@addMethod(PlayerPuppet)
public final static func BTL_ShowProgressionBonuses() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
    
    if !IsDefined(player) {
        FTLog("[Better Leveling] ERROR: Could not get player");
        return;
    }
    
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(player.GetEntityID());
    let currentLevel: Int32 = devData.GetProficiencyLevel(gamedataProficiencyType.Level);
    
    FTLog("PROGRESSION BONUSES");
    FTLog("Current Level: " + ToString(currentLevel));
    FTLog("");
    
    if currentLevel <= 60 {
        FTLog("Status: Within vanilla progression range");
        FTLog("Extended bonuses start at level 61");
    } else {
        FTLog("--- LEVEL-BASED BONUSES (61+) ---");
        if Settings.RemoveLevelProgressionCap() {
            FTLog("Level Progression Cap Removed: ACTIVE");
            FTLog("Receiving cumulative bonuses for levels 61-" + ToString(currentLevel));
        } else {
            FTLog("Level Progression Cap Removed: DISABLED");
        }
    }
    
    FTLog("--- ATTRIBUTE-BASED BONUSES ---");
    
    let strengthVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Strength));
    let intelligenceVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Intelligence));
    let reflexesVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Reflexes));
    let technicalVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.TechnicalAbility));
    let coolVal: Int32 = Cast<Int32>(statsSystem.GetStatValue(objectID, gamedataStatType.Cool));
    
    if Settings.RemoveAttributeProgressionCap() {
        FTLog("Attribute Progression Cap Removed: ACTIVE");
        
        if strengthVal > 20 {
            let bonus: Float = Cast<Float>((strengthVal - 20) * 2);
            FTLog("Strength (" + ToString(strengthVal) + "): +" + ToString(bonus) + " Health");
        } else {
            FTLog("Strength (" + ToString(strengthVal) + "): No bonus (need 21+)");
        }
        
        if intelligenceVal > 20 {
            let bonus: Float = Cast<Float>((intelligenceVal - 20) / 4);
            FTLog("Intelligence (" + ToString(intelligenceVal) + "): +" + ToString(bonus) + " RAM");
        } else {
            FTLog("Intelligence (" + ToString(intelligenceVal) + "): No bonus (need 21+)");
        }
        
        if reflexesVal > 20 {
            let bonus: Float = Cast<Float>(reflexesVal - 20) * 0.5;
            FTLog("Reflexes (" + ToString(reflexesVal) + "): +" + ToString(bonus) + "% Crit Chance");
        } else {
            FTLog("Reflexes (" + ToString(reflexesVal) + "): No bonus (need 21+)");
        }
        
        if technicalVal > 20 {
            let bonus: Float = Cast<Float>((technicalVal - 20) * 2);
            FTLog("Technical (" + ToString(technicalVal) + "): +" + ToString(bonus) + " Armor");
        } else {
            FTLog("Technical (" + ToString(technicalVal) + "): No bonus (need 21+)");
        }
        
        if coolVal > 20 {
            let bonus: Float = Cast<Float>(coolVal - 20) * 1.25;
            FTLog("Cool (" + ToString(coolVal) + "): +" + ToString(bonus) + "% Crit Damage");
        } else {
            FTLog("Cool (" + ToString(coolVal) + "): No bonus (need 21+)");
        }
    } else {
        FTLog("Attribute Progression Cap Removed: DISABLED");
        FTLog("All attributes capped at 20");
    }
}

@addMethod(PlayerPuppet)
public final static func BTL_ShowXPRequirements() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
    
    if !IsDefined(player) {
        FTLog("[Better Leveling] ERROR: Could not get player");
        return;
    }
    
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    let currentLevel: Int32 = devData.GetProficiencyLevel(gamedataProficiencyType.Level);
    let currentSC: Int32 = devData.GetProficiencyLevel(gamedataProficiencyType.StreetCred);
    
    FTLog("XP REQUIREMENTS");
    FTLog("--- CHARACTER LEVEL ---");
    FTLog("Current Level: " + ToString(currentLevel));
    
    if currentLevel < Settings.NewLevelCap() {
        let nextLevelXP: Int32 = devData.GetExperienceForNextLevel(gamedataProficiencyType.Level);
        FTLog("XP for Next Level: " + ToString(nextLevelXP));
        
        if Settings.BeyondLevel60Curve() && currentLevel >= 60 {
            FTLog("Using exponential curve (levels 61+)");
            FTLog("Target XP at level 135: 4,000,000");
        }
    } else {
        FTLog("LEVEL CAP REACHED: " + ToString(Settings.NewLevelCap()));
    }
    
    FTLog("--- STREET CRED ---");
    FTLog("Current Street Cred: " + ToString(currentSC));
    
    if currentSC < Settings.StreetCredCap() {
        let nextSCXP: Int32 = devData.GetExperienceForNextLevel(gamedataProficiencyType.StreetCred);
        FTLog("XP for Next Street Cred: " + ToString(nextSCXP));
        
        if Settings.BeyondStreetCredCurve() && currentSC >= 60 {
            FTLog("Using exponential curve (levels 61+)");
            FTLog("Target XP at level 350: 50,000,000");
        }
    } else {
        FTLog("STREET CRED CAP REACHED: " + ToString(Settings.StreetCredCap()));
    }
}

@addMethod(PlayerPuppet)
public final static func BTL_ShowStreetCredBenefits() -> Void {
    let player: ref<PlayerPuppet> = GetPlayer(GetGameInstance());
    
    if !IsDefined(player) {
        FTLog("[Better Leveling] ERROR: Could not get player");
        return;
    }
    
    let devData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(player.GetEntityID());
    let currentSC: Int32 = devData.GetProficiencyLevel(gamedataProficiencyType.StreetCred);
    
    FTLog("STREET CRED BENEFITS");
    FTLog("Current Street Cred: " + ToString(currentSC));
    
    FTLog("--- VANILLA VENDOR DISCOUNTS ---");
    if currentSC >= 5 { FTLog("[X] SC 5: Unlocked"); } else { FTLog("[ ] SC 5: Locked"); }
    if currentSC >= 10 { FTLog("[X] SC 10: Unlocked"); } else { FTLog("[ ] SC 10: Locked"); }
    if currentSC >= 15 { FTLog("[X] SC 15: Unlocked"); } else { FTLog("[ ] SC 15: Locked"); }
    if currentSC >= 20 { FTLog("[X] SC 20: Unlocked"); } else { FTLog("[ ] SC 20: Locked"); }
    if currentSC >= 25 { FTLog("[X] SC 25: Unlocked"); } else { FTLog("[ ] SC 25: Locked"); }
    if currentSC >= 30 { FTLog("[X] SC 30: Unlocked"); } else { FTLog("[ ] SC 30: Locked"); }
    if currentSC >= 35 { FTLog("[X] SC 35: Unlocked"); } else { FTLog("[ ] SC 35: Locked"); }
    if currentSC >= 40 { FTLog("[X] SC 40: Unlocked"); } else { FTLog("[ ] SC 40: Locked"); }
    if currentSC >= 50 { FTLog("[X] SC 50: Unlocked"); } else { FTLog("[ ] SC 50: Locked"); }

    FTLog("--- EXTRA VENDOR DISCOUNTS (Better Leveling) ---");
    if currentSC >= 75 { FTLog("[X] SC 75: +5% discount"); } else { FTLog("[ ] SC 75: +5% discount (Locked)"); }
    if currentSC >= 100 { FTLog("[X] SC 100: +5% discount (total 10%)"); } else { FTLog("[ ] SC 100: +5% discount (Locked)"); }
    if currentSC >= 150 { FTLog("[X] SC 150: +5% discount (total 15%)"); } else { FTLog("[ ] SC 150: +5% discount (Locked)"); }
    if currentSC >= 200 { FTLog("[X] SC 200: +5% discount (total 20%)"); } else { FTLog("[ ] SC 200: +5% discount (Locked)"); }
    if currentSC >= 250 { FTLog("[X] SC 250: +10% discount (total 30%)"); } else { FTLog("[ ] SC 250: +10% discount (Locked)"); }
    if currentSC >= 500 { FTLog("[X] SC 500: +15% discount (total 45%)"); } else { FTLog("[ ] SC 500: +15% discount (Locked)"); }

    FTLog("--- CURRENT DISCOUNT ---");
    let vendorDiscount: Float = statsSystem.GetStatValue(objectID, gamedataStatType.VendorBuyPriceDiscount);
    FTLog("Total Vendor Discount: " + ToString(vendorDiscount) + "%");
}

@addMethod(PlayerPuppet)
public final static func BTL_FullDiagnostic() -> Void {
    FTLog("#################################");
    FTLog("BETTER LEVELING - FULL DIAGNOSTIC");
    FTLog("#################################");
    
    PlayerPuppet.BTL_IsModLoaded();
    PlayerPuppet.BTL_ShowCurrentConfig();
    PlayerPuppet.BTL_ShowPlayerStats();
    PlayerPuppet.BTL_ShowAvailablePoints();
    PlayerPuppet.BTL_ShowProgressionBonuses();
    PlayerPuppet.BTL_ShowXPRequirements();
    PlayerPuppet.BTL_ShowStreetCredBenefits();
    PlayerPuppet.BTL_CheckDashBugStatus();
    
    FTLog("###################");
    FTLog("DIAGNOSTIC COMPLETE");
    FTLog("###################");
}