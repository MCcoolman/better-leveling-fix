module BetterLeveling.Addon.SkillProgression

@addField(PlayerPuppet)
private let m_btlStealthBrokenCritBonus: Bool;

@addField(PlayerPuppet)
private let m_btlCoolLevel100CritHandle: ref<gameStatModifierData>;

@addMethod(PlayerPuppet)
private func HasCoolLevel100Active() -> Bool {
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
  return IsDefined(dev) && dev.GetProficiencyLevel(gamedataProficiencyType.CoolSkill) >= 100;
}

@addMethod(PlayerPuppet)
private func BTL_TriggerTimeSlow() -> Void {
  let reason: CName = n"BL_CoolLevel100";
  TimeDilationHelper.SetIgnoreTimeDilationOnLocalPlayerZero(this, true);
  TimeDilationHelper.SetTimeDilation(this, reason, 0.5, 2.0, n"None", n"None", true);
  let reset: ref<BTL_TimeSlowResetCallback> = new BTL_TimeSlowResetCallback();
  reset.pp = this;
  reset.reasonName = reason;
  GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(reset, 2.0);
  
  this.BTL_ApplyCritBoost();
}

@addMethod(PlayerPuppet)
private func BTL_ApplyCritBoost() -> Void {
  if IsDefined(this.m_btlCoolLevel100CritHandle) {
    return;
  }
  
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
  let objectID: StatsObjectID = Cast<StatsObjectID>(this.GetEntityID());
  
  this.m_btlCoolLevel100CritHandle = RPGManager.CreateStatModifier(
    gamedataStatType.CritDamage,
    gameStatModifierType.Additive,
    200.0
  );
  
  statsSystem.AddModifier(objectID, this.m_btlCoolLevel100CritHandle);
  this.m_btlStealthBrokenCritBonus = true;
}

@addMethod(PlayerPuppet)
private func BTL_RemoveCritBoost() -> Void {
  if !IsDefined(this.m_btlCoolLevel100CritHandle) {
    return;
  }
  
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
  let objectID: StatsObjectID = Cast<StatsObjectID>(this.GetEntityID());
  
  statsSystem.RemoveModifier(objectID, this.m_btlCoolLevel100CritHandle);
  this.m_btlCoolLevel100CritHandle = null;
  this.m_btlStealthBrokenCritBonus = false;
}

@wrapMethod(StatPoolsManager)
private final static func ApplyDamageSingle(hitEvent: ref<gameHitEvent>, dmgType: gamedataDamageType, initialDamageValue: Float, forReal: Bool, valuesLost: script_ref<[SDamageDealt]>) -> Void {
  let victim: wref<PlayerPuppet> = hitEvent.target as PlayerPuppet;
  if IsDefined(victim) && forReal && victim.HasCoolLevel100Active() && !victim.IsPuppetInCombat() && !GameObject.IsCooldownActive(victim, n"BL_Cool_SlowCD") {
    victim.BTL_TriggerTimeSlow();
    GameObject.StartCooldown(victim, n"BL_Cool_SlowCD", 60.0);
  };
  wrappedMethod(hitEvent, dmgType, initialDamageValue, forReal, valuesLost);
}

@wrapMethod(DamageSystem)
private final func SendDamageEvents(hitEvent: ref<gameHitEvent>, const resourcesLost: script_ref<[SDamageDealt]>) -> Void {
  let p: wref<PlayerPuppet> = hitEvent.attackData.GetInstigator() as PlayerPuppet;
  
  if IsDefined(p) && p.HasCoolLevel100Active() && !p.IsPuppetInCombat() && !GameObject.IsCooldownActive(p, n"BL_Cool_SlowCD") {
    p.BTL_TriggerTimeSlow();
    GameObject.StartCooldown(p, n"BL_Cool_SlowCD", 60.0);
  };
  
  wrappedMethod(hitEvent, resourcesLost);
  
  if IsDefined(p) && p.m_btlStealthBrokenCritBonus && p.HasCoolLevel100Active() {
    p.BTL_RemoveCritBoost();
  };
}

public class BTL_TimeSlowResetCallback extends DelayCallback {
  public let pp: wref<PlayerPuppet>;
  public let reasonName: CName;
  public func Call() -> Void {
    if IsDefined(this.pp) {
      TimeDilationHelper.UnSetTimeDilation(this.pp, this.reasonName, n"None");
      TimeDilationHelper.RestorePreviousIgnoreTimeDilationOnLocalPlayerZero(this.pp);
    }
  }
}