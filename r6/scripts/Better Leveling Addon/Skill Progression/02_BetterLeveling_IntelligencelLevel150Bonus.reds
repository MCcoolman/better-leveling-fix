module BetterLeveling.Addon.SkillProgression

@addMethod(PlayerPuppet)
private func HasIntelligenceLevel150Active() -> Bool {
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this);
  return IsDefined(dev) && dev.GetProficiencyLevel(gamedataProficiencyType.IntelligenceSkill) >= 150;
}

public class BTL_BartmossSpreadEvent extends Event {
  public let actionID: TweakDBID;
  public let playerID: EntityID;
  public let originalTargetID: EntityID;
  public let targets: array<EntityID>;
  public let currentIndex: Int32;
}

public class BTL_BartmossReapplyEvent extends Event {
  public let actionID: TweakDBID;
  public let playerID: EntityID;
  public let targetID: EntityID;
  public let remainingApplications: Int32;
}

public func BTL_ApplyQuickhack(target: wref<GameObject>, actionID: TweakDBID, player: wref<GameObject>) -> Bool {
  if IsDefined(target as PlayerPuppet) { 
    return false; 
  }
  
  let puppet: wref<ScriptedPuppet> = target as ScriptedPuppet;
  if !IsDefined(puppet) || puppet.IsDead() { 
    return false; 
  }
  
  let act: ref<PuppetAction> = new PuppetAction();
  act.RegisterAsRequester(target.GetEntityID());
  act.SetExecutor(player);
  act.SetObjectActionID(actionID);
  act.SetUp(puppet.GetPuppetPS());
  act.SetDisableSpread(true);
  act.ProcessRPGAction(target.GetGame());
  
  return true;
}

@wrapMethod(ScriptedPuppet)
protected cb func OnUploadProgressStateChanged(evt: ref<UploadProgramProgressEvent>) -> Bool {
  let result: Bool = wrappedMethod(evt);
  
  if NotEquals(evt.state, EUploadProgramState.COMPLETED) {
    return result;
  }
  
  if NotEquals(evt.progressBarContext, EProgressBarContext.QuickHack) {
    return result;
  }
  
  let player: ref<PlayerPuppet> = evt.action.GetExecutor() as PlayerPuppet;
  if !IsDefined(player) || !player.HasIntelligenceLevel150Active() {
    return result;
  }
  
  if evt.action.IsSpreadDisabled() {
    return result;
  }
  
  let nearbyNPCs: array<ref<NPCPuppet>> = player.GetNPCsAroundObject(20.0);
  let validTargets: array<EntityID>;
  let maxSpread: Int32 = 2;
  let originalTargetPos: Vector4 = this.GetWorldPosition();
  
  let i: Int32 = 0;
  while i < ArraySize(nearbyNPCs) && ArraySize(validTargets) < maxSpread {
    let target: ref<NPCPuppet> = nearbyNPCs[i];
    
    if IsDefined(target) && target.GetEntityID() != this.GetEntityID() {
      let attitude: EAIAttitude = GameObject.GetAttitudeTowards(target, player);
      
      if Equals(attitude, EAIAttitude.AIA_Hostile) &&
          ScriptedPuppet.IsActive(target) && 
          target.IsQuickHackAble() &&
          !target.IsDead() {
        
        let distance: Float = Vector4.Distance(originalTargetPos, target.GetWorldPosition());
        
        if distance <= 20.0 {
          ArrayPush(validTargets, target.GetEntityID());
        }
      }
    }
    i += 1;
  }
  
  let unfilledSlots: Int32 = maxSpread - ArraySize(validTargets);
  
  if ArraySize(validTargets) > 0 {
    let spreadEvent: ref<BTL_BartmossSpreadEvent> = new BTL_BartmossSpreadEvent();
    spreadEvent.actionID = evt.action.GetObjectActionID();
    spreadEvent.playerID = player.GetEntityID();
    spreadEvent.originalTargetID = this.GetEntityID();
    spreadEvent.targets = validTargets;
    spreadEvent.currentIndex = 0;
    
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(
      this,
      spreadEvent,
      0.5
    );
  }
  
  if unfilledSlots > 0 {
    let reapplyEvent: ref<BTL_BartmossReapplyEvent> = new BTL_BartmossReapplyEvent();
    reapplyEvent.actionID = evt.action.GetObjectActionID();
    reapplyEvent.playerID = player.GetEntityID();
    reapplyEvent.targetID = this.GetEntityID();
    reapplyEvent.remainingApplications = unfilledSlots;
    
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(
      this,
      reapplyEvent,
      1.0
    );
  }
  
  return result;
}

@addMethod(ScriptedPuppet)
protected cb func OnBTL_BartmossSpreadEvent(evt: ref<BTL_BartmossSpreadEvent>) -> Bool {
  if evt.currentIndex >= ArraySize(evt.targets) {
    return true;
  }
  
  let target: wref<GameObject> = GameInstance.FindEntityByID(this.GetGame(), evt.targets[evt.currentIndex]) as GameObject;
  let player: wref<GameObject> = GameInstance.FindEntityByID(this.GetGame(), evt.playerID) as GameObject;
  
  if IsDefined(target) && IsDefined(player) {
    let success: Bool = BTL_ApplyQuickhack(target, evt.actionID, player);
    
    if success {
    }
    
    if evt.currentIndex + 1 < ArraySize(evt.targets) {
      let nextEvent: ref<BTL_BartmossSpreadEvent> = new BTL_BartmossSpreadEvent();
      nextEvent.actionID = evt.actionID;
      nextEvent.playerID = evt.playerID;
      nextEvent.originalTargetID = evt.originalTargetID;
      nextEvent.targets = evt.targets;
      nextEvent.currentIndex = evt.currentIndex + 1;
      
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(
        this,
        nextEvent,
        0.3
      );
    }
  }
  
  return true;
}

@addMethod(ScriptedPuppet)
protected cb func OnBTL_BartmossReapplyEvent(evt: ref<BTL_BartmossReapplyEvent>) -> Bool {
  if evt.remainingApplications <= 0 {
    return true;
  }
  
  let target: wref<ScriptedPuppet> = GameInstance.FindEntityByID(this.GetGame(), evt.targetID) as ScriptedPuppet;
  let player: wref<GameObject> = GameInstance.FindEntityByID(this.GetGame(), evt.playerID) as GameObject;
  
  if !IsDefined(target) || !IsDefined(player) || target.IsDead() || !ScriptedPuppet.IsActive(target) {
    return true;
  }
  
  let success: Bool = BTL_ApplyQuickhack(target, evt.actionID, player);
  
  if success {
    
    if evt.remainingApplications > 1 && !target.IsDead() {
      let nextReapply: ref<BTL_BartmossReapplyEvent> = new BTL_BartmossReapplyEvent();
      nextReapply.actionID = evt.actionID;
      nextReapply.playerID = evt.playerID;
      nextReapply.targetID = evt.targetID;
      nextReapply.remainingApplications = evt.remainingApplications - 1;
      
      GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(
        this,
        nextReapply,
        1.5
      );
    }
  }
  
  return true;
}