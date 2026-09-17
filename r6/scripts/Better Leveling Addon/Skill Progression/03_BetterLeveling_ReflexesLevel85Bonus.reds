module BetterLeveling.Addon.SkillProgression

@addField(PlayerPuppet)
private let m_coolJumpModifier: ref<gameStatModifierData>;

@addMethod(PlayerPuppet)
private func HasCoolLevel85Active() -> Bool {
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
  return IsDefined(dev) && dev.GetProficiencyLevel(gamedataProficiencyType.CoolSkill) >= 85;
}

@addMethod(PlayerPuppet)
private func ApplyCoolJumpBonus() -> Void {
  if !IsDefined(this.m_coolJumpModifier) {
    this.m_coolJumpModifier = RPGManager.CreateStatModifier(
      gamedataStatType.JumpHeight, 
      gameStatModifierType.Multiplier, 
      1.5
    );
    
    GameInstance.GetStatsSystem(this.GetGame()).AddModifier(
      Cast<StatsObjectID>(this.GetEntityID()), 
      this.m_coolJumpModifier
    );
  }
}

@addMethod(PlayerPuppet)
private func RemoveCoolJumpBonus() -> Void {
  if IsDefined(this.m_coolJumpModifier) {
    GameInstance.GetStatsSystem(this.GetGame()).RemoveModifier(
      Cast<StatsObjectID>(this.GetEntityID()), 
      this.m_coolJumpModifier
    );
    this.m_coolJumpModifier = null;
  }
}

@wrapMethod(DodgeAirEvents)
protected final func Dodge(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>) -> Void {
    let impulseValue: Float = this.GetStaticFloatParameterDefault("impulse", 10.00) * 1.5;
    let dodgeHeading: Float = stateContext.GetConditionFloat(n"DodgeDirection");
    let impulse: Vector4 = Vector4.FromHeading(AngleNormalize180(Transform.GetYaw(scriptInterface.GetCameraWorldTransform()) + dodgeHeading)) * impulseValue;
    this.AddImpulse(stateContext, impulse);
    this.SetDetailedState(scriptInterface, gamePSMDetailedLocomotionStates.DodgeAir);
}

@wrapMethod(DodgeEvents)
protected final func Dash(stateContext: ref<StateContext>, scriptInterface: ref<StateGameScriptInterface>, isExhausted: Bool, treatDashAsAirDash: Bool) -> Void {
    let dodgeHeading: Float;
    let impulse: Vector4;
    let impulseValue: Float;
    let dashMovementDecelerationModifier: Float = this.GetStaticFloatParameterDefault("dashMovementDecelerationModifier", -0.71);
    let airDashMovementDecelerationModifier: Float = this.GetStaticFloatParameterDefault("airDashMovementDecelerationModifier", -0.71);
    
    if !this.IsTouchingGround(scriptInterface) {
      stateContext.SetPermanentBoolParameter(n"disableAirDash", true, true);
      if this.m_currentNumberOfJumps > 0 {
        this.m_currentNumberOfJumps += 1;
        stateContext.SetPermanentIntParameter(n"currentNumberOfJumps", this.m_currentNumberOfJumps, true);
      };
    };
    
    if treatDashAsAirDash {
      this.m_airDashDecelerationModifier = this.EnableMovementDecelerationStatModifier(stateContext, scriptInterface, this.m_airDashDecelerationModifier, airDashMovementDecelerationModifier);
      if isExhausted {
        impulseValue = this.GetStaticFloatParameterDefault("airDashImpulseNoStamina", 6.50) * 1.5;
      } else {
        impulseValue = this.GetStaticFloatParameterDefault("airDashImpulse", 10.00) * 1.5;
        StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.DodgeAirBuff");
      };
      if PlayerDevelopmentSystem.GetInstance(scriptInterface.executionOwner).IsNewPerkBought(scriptInterface.executionOwner, gamedataNewPerkType.Reflexes_Master_Perk_3) == 1 {
        scriptInterface.executionOwner.QueueEvent(new ReflexesMasterPerk3Triggerd());
      };
      StatusEffectHelper.ApplyStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.PlayerJustAirDashed");
    } else {
      this.m_dashDecelerationModifier = this.EnableMovementDecelerationStatModifier(stateContext, scriptInterface, this.m_dashDecelerationModifier, dashMovementDecelerationModifier);
      if isExhausted {
        impulseValue = this.GetStaticFloatParameterDefault("dashImpulseNoStamina", 7.80);
      } else {
        impulseValue = this.GetStaticFloatParameterDefault("dashImpulse", 10.00);
      };
    };
    
    dodgeHeading = stateContext.GetConditionFloat(n"DodgeDirection");
    impulse = Vector4.FromHeading(AngleNormalize180(Transform.GetYaw(scriptInterface.GetCameraWorldTransform()) + dodgeHeading)) * impulseValue;
    this.AddImpulse(stateContext, impulse);
    
    if !isExhausted {
      RPGManager.AwardExperienceFromLocomotion(scriptInterface.owner as PlayerPuppet, 5.00);
    };
}

@wrapMethod(PlayerDevelopmentData)
private final const func ModifyProficiencyLevel(proficiencyIndex: Int32, isDebug: Bool, opt levelIncrease: Int32) -> Void {
  wrappedMethod(proficiencyIndex, isDebug, levelIncrease);
  
  if Equals(this.m_proficiencies[proficiencyIndex].type, gamedataProficiencyType.CoolSkill) {
    let player: ref<PlayerPuppet> = this.GetOwner() as PlayerPuppet;
    if IsDefined(player) {
      if this.m_proficiencies[proficiencyIndex].currentLevel >= 85 {
        player.ApplyCoolJumpBonus();
      } else {
        player.RemoveCoolJumpBonus();
      }
    }
  }
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  wrappedMethod();
  let evt: ref<DelayEvent> = new DelayEvent();
  GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, 0.5);
  
  return true;
}

@addMethod(PlayerPuppet)
protected cb func OnDelayEvent(evt: ref<DelayEvent>) -> Bool {
  if this.HasCoolLevel85Active() {
    this.ApplyCoolJumpBonus();
  } else {
    this.RemoveCoolJumpBonus();
  }
}