module BetterLeveling.Addon.SkillProgression

@addField(PlayerPuppet)
private let m_btlLastHealTime: Float = 0.0;

@addField(PlayerPuppet)
private let m_btlCachedWeaponIsMelee: Bool = false;

@wrapMethod(DamageSystem)
private final func SendDamageEvents(hitEvent: ref<gameHitEvent>, const resourcesLost: script_ref<[SDamageDealt]>) -> Void {
  let total: Float = 0.00;
  let i: Int32 = 0;
  while i < ArraySize(Deref(resourcesLost)) {
    total += Deref(resourcesLost)[i].value;
    i += 1;
  };
  wrappedMethod(hitEvent, resourcesLost);
  let p: wref<PlayerPuppet> = hitEvent.attackData.GetInstigator() as PlayerPuppet;
  if !IsDefined(p) { return; }
  if total <= 0.00 { return; }
  if !p.HasStrengthLevel120Active() { return; }
  if !p.BTL_IsMeleeHit(hitEvent) { return; }
  p.BTL_HealPlayer(total * 0.15);
}

@addMethod(PlayerPuppet)
private func BTL_IsMeleeHit(hitEvent: ref<gameHitEvent>) -> Bool {
  if Equals(hitEvent.attackData.GetAttackType(), gamedataAttackType.Melee) { return true; }
  let w: wref<WeaponObject> = hitEvent.attackData.GetWeapon() as WeaponObject;
  if !IsDefined(w) { return false; }
  if w.HasTag(n"MeleeWeapon") { return true; }
  return w.HasTag(n"Blade")
      || w.HasTag(n"Katana")
      || w.HasTag(n"Chainsword")
      || w.HasTag(n"Machete")
      || w.HasTag(n"Axe")
      || w.HasTag(n"Blunt")
      || w.HasTag(n"One-Handed Club")
      || w.HasTag(n"Two-Handed Club")
      || w.HasTag(n"Knife")
      || w.HasTag(n"Thrown");
}

@addMethod(PlayerPuppet)
private func HasStrengthLevel120Active() -> Bool {
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
  if !IsDefined(dev) { return false; }
  return dev.GetProficiencyLevel(gamedataProficiencyType.StrengthSkill) >= 120;
}

@addMethod(PlayerPuppet)
private func BTL_HealPlayer(amount: Float) -> Void {
  let currentTime: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGame()));
  if currentTime - this.m_btlLastHealTime < 0.1 { return; }
  
  let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGame());
  let id: StatsObjectID = Cast<StatsObjectID>(this.GetEntityID());
  let cur: Float = sps.GetStatPoolValue(id, gamedataStatPoolType.Health, false);
  let maxv: Float = sps.GetStatPoolMaxPointValue(id, gamedataStatPoolType.Health);
  let tgt: Float = MinF(cur + amount, maxv);
  let delta: Float = tgt - cur;
  if delta > 0.00 {
    sps.RequestChangingStatPoolValue(id, gamedataStatPoolType.Health, delta, this, false, false);
    this.m_btlLastHealTime = currentTime;
  };
}

@wrapMethod(PlayerPuppet)
protected cb func OnItemAddedToSlot(evt: ref<ItemAddedToSlot>) -> Bool {
  if Equals(evt.GetSlotID(), t"AttachmentSlots.WeaponRight") {
    this.m_btlCachedWeaponIsMelee = false;
  }
  return wrappedMethod(evt);
}