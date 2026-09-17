module BetterLeveling.Addon.SkillProgression

public class BTL_EndReaperEvent extends Event {}

@addField(PlayerPuppet)
private let m_btlReaperActive: Bool;

@addField(PlayerPuppet)
private let m_btlReaperEndId: DelayID;

@addField(PlayerPuppet)
private let m_btlReaperStreakCount: Int32;

@addField(PlayerPuppet)
private let m_btlReaperStreakUntil: Float;

@addField(PlayerPuppet)
private let m_btlReaperTickId: DelayID;

@addField(PlayerPuppet)
private let m_btlReaperCritDmgHandle: ref<gameStatModifierData>;

@addMethod(PlayerPuppet)
private func HasCoolLevel150Active() -> Bool {
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
  let hasLevel: Bool = IsDefined(dev) && dev.GetProficiencyLevel(gamedataProficiencyType.CoolSkill) >= 150;
  return hasLevel;
}

@addMethod(PlayerPuppet)
private func BTL_IsUndetected() -> Bool {
  let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(this.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
  if !IsDefined(bb) { 
    return false; 
  }
  
  let locoState: Int32 = bb.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Locomotion);
  let isUndetected: Bool = (locoState == 1 || locoState == 13);
  
  return isUndetected;
}

@addMethod(PlayerPuppet)
private func BTL_ReaperResetStreak(now: Float) -> Void {
  this.m_btlReaperStreakCount = 1;
  this.m_btlReaperStreakUntil = now + 10.0;
}

@addMethod(PlayerPuppet)
private func BTL_ReaperTryActivate() -> Void {
  let onCD: Bool = GameObject.IsCooldownActive(this, n"BL_Reaper_CD");
  
  if this.m_btlReaperActive { return; }
  if onCD { return; }
  if !this.HasCoolLevel150Active() { return; }
  
  this.m_btlReaperActive = true;
  this.m_btlReaperEndId = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new BTL_EndReaperEvent(), 15.0);
  this.BTL_ReaperStartTick();
  
  StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.OpticalCamoPlayerBuffBase");
  
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
  let objectID: StatsObjectID = Cast<StatsObjectID>(this.GetEntityID());
  
  this.m_btlReaperCritDmgHandle = RPGManager.CreateStatModifier(
    gamedataStatType.CritDamage,
    gameStatModifierType.Additive,
    200.0
  );
  statsSystem.AddModifier(objectID, this.m_btlReaperCritDmgHandle);
}

@addMethod(PlayerPuppet)
private func BTL_ReaperRefresh() -> Void {
  if !this.m_btlReaperActive { return; }
  
  GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_btlReaperEndId);
  this.m_btlReaperEndId = GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, new BTL_EndReaperEvent(), 15.0);
  
  StatusEffectHelper.ApplyStatusEffect(this, t"BaseStatusEffect.OpticalCamoPlayerBuffBase");
  GameObjectEffectHelper.StartEffectEvent(this, n"falling", true, null, true);
}

@addMethod(PlayerPuppet)
private func BTL_ReaperStartTick() -> Void {
  let cb: ref<BTL_ReaperTickCb> = new BTL_ReaperTickCb();
  cb.pp = this;
  this.m_btlReaperTickId = GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(cb, 0.5);
  GameObjectEffectHelper.StartEffectEvent(this, n"falling", true, null, true);
}

@addMethod(PlayerPuppet)
private func BTL_ReaperStopTick() -> Void {
  GameInstance.GetDelaySystem(this.GetGame()).CancelDelay(this.m_btlReaperTickId);
}

@addMethod(PlayerPuppet)
private func BTL_ReaperTick() -> Void {
  if !this.m_btlReaperActive { return; }
  
  let ses: ref<StatusEffectSystem> = GameInstance.GetStatusEffectSystem(this.GetGame());
  let eid: EntityID = this.GetEntityID();
  if ses.HasStatusEffect(eid, t"BaseStatusEffect.OpticalCamoPlayerBuffBase") {
    ses.ApplyStatusEffect(eid, t"BaseStatusEffect.OpticalCamoPlayerBuffBase");
  }
  
  GameObjectEffectHelper.StartEffectEvent(this, n"falling", true, null, true);
  
  let cb: ref<BTL_ReaperTickCb> = new BTL_ReaperTickCb();
  cb.pp = this;
  this.m_btlReaperTickId = GameInstance.GetDelaySystem(this.GetGame()).DelayCallback(cb, 0.5);
}

@addMethod(PlayerPuppet)
protected cb func OnBTL_EndReaperEvent(evt: ref<BTL_EndReaperEvent>) -> Bool {
  this.m_btlReaperActive = false;
  this.BTL_ReaperStopTick();
  GameObjectEffectHelper.StopEffectEvent(this, n"falling");
  
  StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.OpticalCamoPlayerBuffBase");
  
  if IsDefined(this.m_btlReaperCritDmgHandle) {
    let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
    let objectID: StatsObjectID = Cast<StatsObjectID>(this.GetEntityID());
    statsSystem.RemoveModifier(objectID, this.m_btlReaperCritDmgHandle);
    this.m_btlReaperCritDmgHandle = null;
  }
  
  GameObject.StartCooldown(this, n"BL_Reaper_CD", 120.0);
  return true;
}

@wrapMethod(NPCPuppet)
protected cb func OnDeath(evt: ref<gameDeathEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  
  let player: ref<PlayerPuppet> = evt.instigator as PlayerPuppet;
  if !IsDefined(player) { 
    return result; 
  }
  
  let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(player.GetGame()));
  let wasUndetected: Bool = player.BTL_IsUndetected();
  
  if wasUndetected && !player.m_btlReaperActive {
    if now <= player.m_btlReaperStreakUntil && player.m_btlReaperStreakCount > 0 {
      player.m_btlReaperStreakCount += 1;
    } else {
      player.BTL_ReaperResetStreak(now);
    }
    
    if player.m_btlReaperStreakCount >= 3 {
      player.m_btlReaperStreakCount = 0;
      player.m_btlReaperStreakUntil = 0.0;
      player.BTL_ReaperTryActivate();
    }
  }
  
  if player.m_btlReaperActive {
    player.BTL_ReaperRefresh();
  }
  
  return result;
}

@wrapMethod(DamageSystem)
private final func SendDamageEvents(hitEvent: ref<gameHitEvent>, const resourcesLost: script_ref<[SDamageDealt]>) -> Void {
  wrappedMethod(hitEvent, resourcesLost);
}

public class BTL_ReaperTickCb extends DelayCallback {
  public let pp: wref<PlayerPuppet>;
  public func Call() -> Void {
    if IsDefined(this.pp) {
      this.pp.BTL_ReaperTick();
    }
  }
}