module BetterLeveling.Addon.SkillProgression

@addField(PlayerPuppet)
private let m_btlUndyingRageActive: Bool = false;

@addField(PlayerPuppet)
private let m_btlUndyingStartTime: Float = 0.0;

@addMethod(PlayerPuppet)
private func HasStrengthLevel150Active() -> Bool {
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
  if !IsDefined(dev) { return false; }
  return dev.GetProficiencyLevel(gamedataProficiencyType.StrengthSkill) >= 150;
}

@addMethod(PlayerPuppet)
private func BTL_CanTriggerUndyingRage() -> Bool {
  if !this.HasStrengthLevel150Active() { return false; }
  if this.m_btlUndyingRageActive { return false; }
  if GameObject.IsCooldownActive(this, n"BL_UndyingCooldown") { return false; }
  return true;
}

@addMethod(PlayerPuppet)
private func BTL_IsUndyingRageActive() -> Bool {
  if !this.m_btlUndyingRageActive { return false; }
  
  let currentTime: Float = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetGame()));
  if currentTime - this.m_btlUndyingStartTime >= 15.0 {
    this.BTL_DeactivateUndyingRage();
    return false;
  }
  
  return true;
}

@addMethod(PlayerPuppet)
private func BTL_ActivateUndyingRage() -> Void {
  this.m_btlUndyingRageActive = true;
  this.m_btlUndyingStartTime = EngineTime.ToFloat(GameInstance.GetEngineTime(this.GetGame()));
  GameObject.StartCooldown(this, n"BL_UndyingCooldown", 86400.00);
  
  StatusEffectHelper.ApplyStatusEffect(this, t"GameplayRestriction.NoDamage", this.GetEntityID());
  
}

@addMethod(PlayerPuppet)
private func BTL_DeactivateUndyingRage() -> Void {
  this.m_btlUndyingRageActive = false;
  
  StatusEffectHelper.RemoveStatusEffect(this, t"GameplayRestriction.NoDamage");
  
}

@wrapMethod(DamageSystem)
private final func PreProcess(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Bool {
  let victim: wref<PlayerPuppet> = hitEvent.target as PlayerPuppet;
  if IsDefined(victim) {
    if victim.BTL_CanTriggerUndyingRage() {
      let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(victim.GetGame());
      let curHP: Float = sps.GetStatPoolValue(Cast<StatsObjectID>(victim.GetEntityID()), gamedataStatPoolType.Health, false);
      let maxHP: Float = sps.GetStatPoolMaxPointValue(Cast<StatsObjectID>(victim.GetEntityID()), gamedataStatPoolType.Health);
      
      if curHP <= (maxHP * 0.25) {
        victim.BTL_ActivateUndyingRage();
      }
    }
    
    if victim.BTL_IsUndyingRageActive() {
      hitEvent.attackData.AddFlag(hitFlag.DealNoDamage, n"BL_UndyingRage");
      hitEvent.attackData.AddFlag(hitFlag.CannotKillPlayer, n"BL_UndyingRage");
      return false;
    }
  }
  
  return wrappedMethod(hitEvent, cache);
}