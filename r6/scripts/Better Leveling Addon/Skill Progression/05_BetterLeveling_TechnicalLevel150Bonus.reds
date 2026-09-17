module BetterLeveling.Addon.SkillProgression

@addMethod(PlayerPuppet)
private func HasTechnicalLevel150Active() -> Bool {
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
  return IsDefined(dev) && dev.GetProficiencyLevel(gamedataProficiencyType.TechnicalAbilitySkill) >= 150;
}

@wrapMethod(CraftingSystem)
private final func UpgradeItem(owner: wref<GameObject>, itemID: ItemID) -> Void {
  let ingredientQuality: gamedataQuality;
  let mod: ref<gameStatModifierData>;
  let recipeXP: Int32;
  let xpID: TweakDBID;
  let randF: Float = RandF();
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGameInstance());
  let TS: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.GetGameInstance());
  let itemData: wref<gameItemData> = TS.GetItemData(owner, itemID);
  let oldVal: Float = itemData.GetStatValueByType(gamedataStatType.WasItemUpgraded);
  
  let player: wref<PlayerPuppet> = owner as PlayerPuppet;
  let upgradeAmount: Float = 1.00;
  let hasTech150: Bool = false;
  
  if IsDefined(player) && player.HasTechnicalLevel150Active() {
    upgradeAmount = 2.00;
    hasTech150 = true;
  }
  
  let newVal: Float = oldVal + upgradeAmount;
  let tempStat: Float = statsSystem.GetStatValue(Cast<StatsObjectID>(owner.GetEntityID()), gamedataStatType.UpgradingMaterialRetrieveChance);
  let ingredients: array<IngredientData> = this.GetItemFinalUpgradeCost(itemData);
  
  let i: Int32 = 0;
  while i < ArraySize(ingredients) {
    if randF >= tempStat {
      TS.RemoveItemByTDBID(owner, ingredients[i].id.GetID(), ingredients[i].quantity, true);
    };
    ingredientQuality = RPGManager.GetItemQualityFromRecord(TweakDBInterface.GetItemRecord(ingredients[i].id.GetID()));
    switch ingredientQuality {
      case gamedataQuality.Common:
        xpID = t"Constants.CraftingSystem.commonIngredientXP";
        break;
      case gamedataQuality.Uncommon:
        xpID = t"Constants.CraftingSystem.uncommonIngredientXP";
        break;
      case gamedataQuality.Rare:
        xpID = t"Constants.CraftingSystem.rareIngredientXP";
        break;
      case gamedataQuality.Epic:
        xpID = t"Constants.CraftingSystem.epicIngredientXP";
        break;
      case gamedataQuality.Legendary:
        xpID = t"Constants.CraftingSystem.legendaryIngredientXP";
        break;
      default:
    };
    recipeXP += TweakDBInterface.GetInt(xpID, 0) * ingredients[i].quantity;
    i += 1;
  };
  
  statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.WasItemUpgraded, true);
  mod = RPGManager.CreateStatModifier(gamedataStatType.WasItemUpgraded, gameStatModifierType.Additive, newVal);
  statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), mod);
  
  if hasTech150 {
    let currentMarker: Float = itemData.GetStatValueByType(gamedataStatType.BonusQuickHackDamage);
    let newMarker: Float = currentMarker + 1.00;
    
    statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.BonusQuickHackDamage, true);
    mod = RPGManager.CreateStatModifier(gamedataStatType.BonusQuickHackDamage, gameStatModifierType.Additive, newMarker);
    statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), mod);
    
    let itemRecord: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
    let itemCategory: gamedataItemCategory = itemRecord.ItemCategory().Type();
    
    if Equals(itemCategory, gamedataItemCategory.Weapon) {
      let damageBoost: Float = 0.50;
      let totalMultiplier: Float = 1.0 + (damageBoost * newMarker);
      
      mod = RPGManager.CreateStatModifier(gamedataStatType.PhysicalDamage, gameStatModifierType.Multiplier, totalMultiplier);
      statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), mod);
      
      mod = RPGManager.CreateStatModifier(gamedataStatType.ThermalDamage, gameStatModifierType.Multiplier, totalMultiplier);
      statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), mod);
      
      mod = RPGManager.CreateStatModifier(gamedataStatType.ChemicalDamage, gameStatModifierType.Multiplier, totalMultiplier);
      statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), mod);
      
      mod = RPGManager.CreateStatModifier(gamedataStatType.ElectricDamage, gameStatModifierType.Multiplier, totalMultiplier);
      statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), mod);
    }
  }
  
  this.ProcessCraftSkill(Cast<Float>(recipeXP));
}