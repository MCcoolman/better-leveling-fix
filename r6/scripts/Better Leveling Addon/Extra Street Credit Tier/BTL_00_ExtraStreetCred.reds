module BetterLeveling

import BetterLevelingConfig.*

@addField(PlayerPuppet) private let BTL_extraBuyDiscMod: ref<gameStatModifierData>;
@addField(PlayerPuppet) private let BTL_extraBuyDiscPts: Int32;
@addField(PlayerPuppet) private let BTL_openVendorEID: EntityID;

private func BTL_FindIndexByLevel(arr: array<ref<LevelRewardDisplayData>>, lvl: Int32) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(arr) {
        if arr[i].level == lvl { 
            return i; 
        }
        i += 1;
    }
    return -1;
}

private func BTL_PushIfUnique(out dst: array<ref<LevelRewardDisplayData>>, item: ref<LevelRewardDisplayData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(dst) {
        if dst[i].level == item.level { 
            return; 
        }
        i += 1;
    }
    ArrayPush(dst, item);
}

private func BTL_SortByLevel(out arr: array<ref<LevelRewardDisplayData>>) -> Void {
    let n: Int32 = ArraySize(arr);
    if n <= 1 { 
        return; 
    }
    
    let i: Int32 = 0;
    while i < n - 1 {
        let j: Int32 = 0;
        while j < n - i - 1 {
            if arr[j].level > arr[j + 1].level {
                let tmp: ref<LevelRewardDisplayData> = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = tmp;
            }
            j += 1;
        }
        i += 1;
    }
}

public class BTL_ESCT_LOC extends IScriptable {

    private static func GetLoc(key: String) -> String {
        let sr: script_ref<String> = key;
        return GetLocalizedTextByKey(StringToName(key));
    }

    public static func BTL_ESCT_Desc(pct: Int32, idx: Int32) -> String {
        let key: String;
        
        switch idx {
            case 0: key = "BTL_ESCT_Tier00"; break;
            case 1: key = "BTL_ESCT_Tier01"; break;
            case 2: key = "BTL_ESCT_Tier02"; break;
            case 3: key = "BTL_ESCT_Tier03"; break;
            case 4: key = "BTL_ESCT_Tier04"; break;
            case 5: key = "BTL_ESCT_Tier05"; break;
            default: return "";
        }
        
        let desc: String = BTL_ESCT_LOC.GetLoc(key);
        desc = StrReplace(desc, "{PCT}", IntToString(pct));
        
        return desc;
    }
}

private func BTL_ExtraPointsFromSC(sc: Int32) -> Int32 {
    let pts: Int32 = 0;
    if sc >= 75  { pts += 5; }   // 5% discount at SC 75
    if sc >= 100 { pts += 5; }   // +5% discount at SC 100 (total 10%)
    if sc >= 150 { pts += 5; }   // +5% discount at SC 150 (total 15%)
    if sc >= 200 { pts += 5; }   // +5% discount at SC 200 (total 20%)
    if sc >= 250 { pts += 10; }  // +10% discount at SC 250 (total 30%)
    if sc >= 500 { pts += 15; }  // +15% discount at SC 500 (total 45%)
    return pts;
}

@wrapMethod(StatsStreetCredReward)
public final func SetData(rewardData: array<ref<LevelRewardDisplayData>>,
                          tooltipsManager: wref<gameuiTooltipsManager>,
                          currentLevel: Int32,
                          tooltipIndex: Int32,
                          const attributeName: script_ref<String>) -> Void {
    
    // Define our extra Street Cred tiers
    let tiers: array<Int32> = [75, 100, 150, 200, 250, 500];
    let discountPcts: array<Int32> = [5, 5, 5, 5, 10, 15];
    
    let i: Int32 = 0;
    while i < ArraySize(tiers) {
        if BTL_FindIndexByLevel(rewardData, tiers[i]) < 0 {
            let newReward: ref<LevelRewardDisplayData> = new LevelRewardDisplayData();
            newReward.level = tiers[i];
            newReward.description = BTL_ESCT_LOC.BTL_ESCT_Desc(discountPcts[i], i);
            ArrayPush(rewardData, newReward);
        }
        i += 1;
    }
    
    BTL_SortByLevel(rewardData);
    
    let MAX_TILES: Int32 = 9;
    let finalList: array<ref<LevelRewardDisplayData>>;
    
    if currentLevel < 51 {
        // For lower levels, show vanilla progression first
        let vanillaOrder: array<Int32> = [5, 10, 15, 20, 25, 30, 35, 40, 50];
        let v: Int32 = 0;
        while v < ArraySize(vanillaOrder) && ArraySize(finalList) < MAX_TILES {
            let idx: Int32 = BTL_FindIndexByLevel(rewardData, vanillaOrder[v]);
            if idx >= 0 { 
                BTL_PushIfUnique(finalList, rewardData[idx]); 
            }
            v += 1;
        }
        
        // Fill remaining slots with any other rewards
        let f: Int32 = 0;
        while ArraySize(finalList) < MAX_TILES && f < ArraySize(rewardData) {
            BTL_PushIfUnique(finalList, rewardData[f]);
            f += 1;
        }
    } else {
        // For higher levels, show the most recent rewards
        let count: Int32 = ArraySize(rewardData);
        let start: Int32 = (count - MAX_TILES) < 0 ? 0 : (count - MAX_TILES);
        let idx2: Int32 = start;
        
        // Skip level 30 if it would be in the display (avoid redundancy)
        if idx2 < count && rewardData[idx2].level == 30 { 
            idx2 += 1; 
        }
        
        while idx2 < count {
            ArrayPush(finalList, rewardData[idx2]);
            idx2 += 1;
        }
    }
    
    wrappedMethod(finalList, tooltipsManager, currentLevel, tooltipIndex, attributeName);
}

private func BTL_ReapplyExtraDiscount(player: wref<PlayerPuppet>) -> Void {
    if !IsDefined(player) { 
        return; 
    }
    
    let dev: wref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(player);
    if !IsDefined(dev) { 
        return; 
    }
    
    let currentSC: Int32 = dev.GetProficiencyLevel(gamedataProficiencyType.StreetCred);
    let wantedPoints: Int32 = BTL_ExtraPointsFromSC(currentSC);
    
    // Only update if the discount has changed
    if player.BTL_extraBuyDiscPts != wantedPoints {
        let gameInstance: GameInstance = player.GetGame();
        let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(gameInstance);
        let objectID: StatsObjectID = Cast<StatsObjectID>(player.GetEntityID());
        
        // Remove old modifier if it exists
        if IsDefined(player.BTL_extraBuyDiscMod) {
            statsSystem.RemoveModifier(objectID, player.BTL_extraBuyDiscMod);
            player.BTL_extraBuyDiscMod = null;
        }
        
        // Update tracking
        player.BTL_extraBuyDiscPts = wantedPoints;
        
        // Apply new modifier if points > 0
        if wantedPoints > 0 {
            let newMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(
                gamedataStatType.VendorBuyPriceDiscount,
                gameStatModifierType.Additive,
                Cast<Float>(wantedPoints)
            );
            statsSystem.AddModifier(objectID, newMod);
            player.BTL_extraBuyDiscMod = newMod;
            
            //FTLog("[Better Leveling] Applied SC discount: " + ToString(wantedPoints) + "% at SC level " + ToString(currentSC));
        }
    }
    
    if EntityID.IsDefined(player.BTL_openVendorEID) {
        let vendorObj: wref<GameObject> = GameInstance.FindEntityByID(player.GetGame(), player.BTL_openVendorEID) as GameObject;
        if IsDefined(vendorObj) {
            GameInstance.GetTransactionSystem(player.GetGame()).ReinitializeStatsOnEntityItems(vendorObj);
        }
    }
}

@wrapMethod(PlayerDevelopmentSystem)
private final func OnExperienceAdded(request: ref<AddExperience>) -> Void {
    let player: wref<PlayerPuppet> = request.owner as PlayerPuppet;
    let beforeSC: Int32 = IsDefined(player) 
        ? PlayerDevelopmentSystem.GetData(player).GetProficiencyLevel(gamedataProficiencyType.StreetCred)
        : 0;
    
    wrappedMethod(request);
    
    if IsDefined(player) {
        let afterSC: Int32 = PlayerDevelopmentSystem.GetData(player).GetProficiencyLevel(gamedataProficiencyType.StreetCred);
        if afterSC != beforeSC {
            BTL_ReapplyExtraDiscount(player);
        }
    }
}

@wrapMethod(Vendor)
public final func OnVendorMenuOpen() -> Void {
    wrappedMethod();
    
    let vendorObj: wref<GameObject> = this.GetVendorObject();
    let player: wref<PlayerPuppet> = GetPlayer(this.m_gameInstance);
    
    if IsDefined(vendorObj) && IsDefined(player) {
        player.BTL_openVendorEID = vendorObj.GetEntityID();
        BTL_ReapplyExtraDiscount(player);
    }
}

@wrapMethod(Vendor)
public final func OnDeattach(owner: wref<GameObject>) -> Void {
    wrappedMethod(owner);
    
    let player: wref<PlayerPuppet> = GetPlayer(this.m_gameInstance);
    if IsDefined(player) {
        let emptyID: EntityID;
        player.BTL_openVendorEID = emptyID;
    }
}

/*
public static func TestStreetCredEnhancements() -> Void {
    FTLog("[Better Leveling] Street Cred enhancements loaded");
    FTLog("[Better Leveling] Extra SC tiers: 75(5%), 100(10%), 150(15%), 200(20%), 250(30%), 500(45%)");
    FTLog("[Better Leveling] Use this function to verify the Street Cred system is active");
}
 */