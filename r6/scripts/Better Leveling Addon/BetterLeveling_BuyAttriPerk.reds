module BetterLeveling

import Codeware.UI.*

public class BTL_BuyPointsLoc extends IScriptable {
    public static func GetLoc(key: String) -> String {
        return GetLocalizedTextByKey(StringToName(key));
    }
}

@addField(PlayerDevelopmentData) 
private persistent let m_btlCurrentAttributeBuyPrice: Int32 = 30000;

@addField(PlayerDevelopmentData) 
private persistent let m_btlCurrentPerkBuyPrice: Int32 = 15000;

@addField(PlayerDevelopmentData)
private let m_btlPendingAttributePurchase: gamedataStatType;

@addField(PlayerDevelopmentData)
private let m_btlPendingPerkPurchase: gamedataNewPerkType;

@addField(PlayerDevelopmentData)
private let m_btlPendingOldPerkPurchase: gamedataPerkType;

@addField(PlayerDevelopmentData)
private let m_btlPendingTraitPurchase: gamedataTraitType;

@addField(PlayerDevelopmentData)
private let m_btlAutoConversionConfirmed: Bool;

@addMethod(PlayerDevelopmentData)
public final func BTL_GetCurrentAttributeBuyPrice() -> Int32 {
    if this.m_btlCurrentAttributeBuyPrice < 30000 {
        this.m_btlCurrentAttributeBuyPrice = 30000;
    }
    return this.m_btlCurrentAttributeBuyPrice;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_IncreaseAttributeBuyPrice() -> Void {
    this.m_btlCurrentAttributeBuyPrice = Min(this.m_btlCurrentAttributeBuyPrice + 10000, 200000);
}

@addMethod(PlayerDevelopmentData)
public final func BTL_BuyAttributePointWithEddies() -> Bool {
    let attrDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Attribute);
    if attrDevIndex < 0 {
        return false;
    }
    
    let currentPrice: Int32 = this.BTL_GetCurrentAttributeBuyPrice();
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let playerMoney: Int32 = transactionSystem.GetItemQuantity(this.m_owner, MarketSystem.Money());
    
    if playerMoney < currentPrice {
        return false;
    }
    
    transactionSystem.RemoveItem(this.m_owner, MarketSystem.Money(), currentPrice);
    this.m_devPoints[attrDevIndex].unspent += 1;
    this.BTL_IncreaseAttributeBuyPrice();
    
    return true;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_GetCurrentPerkBuyPrice() -> Int32 {
    if this.m_btlCurrentPerkBuyPrice < 15000 {
        this.m_btlCurrentPerkBuyPrice = 15000;
    }
    return this.m_btlCurrentPerkBuyPrice;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_IncreasePerkBuyPrice() -> Void {
    this.m_btlCurrentPerkBuyPrice = Min(this.m_btlCurrentPerkBuyPrice + 10000, 200000);
}

@addMethod(PlayerDevelopmentData)
public final func BTL_BuyPerkPointWithEddies() -> Bool {
    let primDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
    if primDevIndex < 0 {
        return false;
    }
    
    let currentPrice: Int32 = this.BTL_GetCurrentPerkBuyPrice();
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_owner.GetGame());
    let playerMoney: Int32 = transactionSystem.GetItemQuantity(this.m_owner, MarketSystem.Money());
    
    if playerMoney < currentPrice {
        return false;
    }
    
    transactionSystem.RemoveItem(this.m_owner, MarketSystem.Money(), currentPrice);
    this.m_devPoints[primDevIndex].unspent += 1;
    this.BTL_IncreasePerkBuyPrice();
    
    return true;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_CheckLocalPlayerMoney(amount: Int32) -> Bool {
    return GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GetItemQuantity(this.m_owner, MarketSystem.Money()) >= amount;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_PayLocalPlayerMoney(amount: Int32) -> Void {
    GameInstance.GetTransactionSystem(this.m_owner.GetGame()).RemoveItem(this.m_owner, MarketSystem.Money(), amount);
}

@addMethod(PlayerDevelopmentData)
public final func BTL_CalculateAttributePointsCost(numPoints: Int32) -> Int32 {
    let totalCost: Int32 = 0;
    let currentPrice: Int32 = this.BTL_GetCurrentAttributeBuyPrice();
    let i: Int32 = 0;
    
    while i < numPoints {
        totalCost += currentPrice;
        currentPrice = Min(currentPrice + 10000, 200000);
        i += 1;
    }
    
    return totalCost;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_CalculatePerkPointsCost(numPoints: Int32) -> Int32 {
    let totalCost: Int32 = 0;
    let currentPrice: Int32 = this.BTL_GetCurrentPerkBuyPrice();
    let i: Int32 = 0;
    
    while i < numPoints {
        totalCost += currentPrice;
        currentPrice = Min(currentPrice + 10000, 200000);
        i += 1;
    }
    
    return totalCost;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_BuyMultipleAttributePoints(numPoints: Int32) -> Bool {
    let attrDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Attribute);
    if attrDevIndex < 0 {
        return false;
    }
    
    let totalCost: Int32 = this.BTL_CalculateAttributePointsCost(numPoints);
    
    if !this.BTL_CheckLocalPlayerMoney(totalCost) {
        return false;
    }
    
    this.BTL_PayLocalPlayerMoney(totalCost);
    this.m_devPoints[attrDevIndex].unspent += numPoints;
    
    let i: Int32 = 0;
    while i < numPoints {
        this.BTL_IncreaseAttributeBuyPrice();
        i += 1;
    }
    
    return true;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_BuyMultiplePerkPoints(numPoints: Int32) -> Bool {
    let primDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
    if primDevIndex < 0 {
        return false;
    }
    
    let totalCost: Int32 = this.BTL_CalculatePerkPointsCost(numPoints);
    
    if !this.BTL_CheckLocalPlayerMoney(totalCost) {
        return false;
    }
    
    this.BTL_PayLocalPlayerMoney(totalCost);
    this.m_devPoints[primDevIndex].unspent += numPoints;
    
    let i: Int32 = 0;
    while i < numPoints {
        this.BTL_IncreasePerkBuyPrice();
        i += 1;
    }
    
    return true;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_ShowAutoConversionDialog(pointType: String, pointsNeeded: Int32, moneyCost: Int32) -> Void {
    let evt: ref<BTL_ShowAutoConversionDialogEvent> = new BTL_ShowAutoConversionDialogEvent();
    evt.pointType = pointType;
    evt.pointsNeeded = pointsNeeded;
    evt.moneyCost = moneyCost;
    GameInstance.GetUISystem(this.m_owner.GetGame()).QueueEvent(evt);
}

@addMethod(PlayerDevelopmentData)
public final func BTL_ConfirmAutoConversion() -> Void {
    this.m_btlAutoConversionConfirmed = true;
}

@addMethod(PlayerDevelopmentData)
public final func BTL_ClearAutoConversionState() -> Void {
    this.m_btlAutoConversionConfirmed = false;
}

@wrapMethod(PlayerDevelopmentData)
public final const func BuyAttribute(type: gamedataStatType) -> Bool {
    let dIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Attribute);
    
    if dIndex >= 0 {
        let cost: Int32 = this.GetAttributeNextLevelCost(type);
        let unspent: Int32 = this.m_devPoints[dIndex].unspent;
        
        if unspent < cost && !this.m_btlAutoConversionConfirmed {
            let difference: Int32 = cost - unspent;
            let moneyCost: Int32 = this.BTL_CalculateAttributePointsCost(difference);
            
            if this.BTL_CheckLocalPlayerMoney(moneyCost) {
                this.m_btlPendingAttributePurchase = type;
                this.BTL_ShowAutoConversionDialog("Attribute", difference, moneyCost);
                return false;
            }
        }
        
        if unspent < cost && this.m_btlAutoConversionConfirmed {
            let difference: Int32 = cost - unspent;
            
            if this.BTL_BuyMultipleAttributePoints(difference) {
            }
            
            this.BTL_ClearAutoConversionState();
        }
    }
    
    return wrappedMethod(type);
}

@wrapMethod(PlayerDevelopmentData)
public final func BuyNewPerk(perkType: gamedataNewPerkType, opt forceBuy: Bool) -> Bool {
    if !forceBuy && !this.m_btlAutoConversionConfirmed {
        let i: Int32;
        let j: Int32;
        
        if this.FindNewPerk(perkType, i, j) {
            let isEspionagePerk: Bool = Equals(this.m_attributesData[i].type, gamedataAttributeDataType.EspionageAttributeData);
            let isEspionageMilestonePerk: Bool = this.IsEspionageMilestonePerk(this.m_attributesData[i].unlockedPerks[j].type);
            let devPointType: gamedataDevelopmentPointType = isEspionagePerk ? gamedataDevelopmentPointType.Espionage : gamedataDevelopmentPointType.Primary;
            let devIndex: Int32 = this.GetDevPointsIndex(devPointType);
            
            if devIndex >= 0 {
                let requiredPoints: Int32 = isEspionageMilestonePerk ? 3 : 1;
                let unspent: Int32 = this.m_devPoints[devIndex].unspent;
                
                if unspent < requiredPoints {
                    let difference: Int32 = requiredPoints - unspent;
                    let moneyCost: Int32 = this.BTL_CalculatePerkPointsCost(difference);
                    
                    if this.BTL_CheckLocalPlayerMoney(moneyCost) {
                        this.m_btlPendingPerkPurchase = perkType;
                        this.BTL_ShowAutoConversionDialog("Perk", difference, moneyCost);
                        return false;
                    }
                }
            }
        }
    }
    
    if !forceBuy && this.m_btlAutoConversionConfirmed {
        let i: Int32;
        let j: Int32;
        
        if this.FindNewPerk(perkType, i, j) {
            let isEspionagePerk: Bool = Equals(this.m_attributesData[i].type, gamedataAttributeDataType.EspionageAttributeData);
            let isEspionageMilestonePerk: Bool = this.IsEspionageMilestonePerk(this.m_attributesData[i].unlockedPerks[j].type);
            let devPointType: gamedataDevelopmentPointType = isEspionagePerk ? gamedataDevelopmentPointType.Espionage : gamedataDevelopmentPointType.Primary;
            let devIndex: Int32 = this.GetDevPointsIndex(devPointType);
            
            if devIndex >= 0 {
                let requiredPoints: Int32 = isEspionageMilestonePerk ? 3 : 1;
                let unspent: Int32 = this.m_devPoints[devIndex].unspent;
                
                if unspent < requiredPoints {
                    let difference: Int32 = requiredPoints - unspent;
                    
                    if this.BTL_BuyMultiplePerkPoints(difference) {
                    }
                }
            }
        }
        
        this.BTL_ClearAutoConversionState();
    }
    
    return wrappedMethod(perkType, forceBuy);
}

@wrapMethod(PlayerDevelopmentData)
public final const func BuyPerk(perkType: gamedataPerkType) -> Bool {
    let primDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
    
    if primDevIndex >= 0 && this.m_devPoints[primDevIndex].unspent <= 0 {
        if !this.m_btlAutoConversionConfirmed {
            let moneyCost: Int32 = this.BTL_CalculatePerkPointsCost(1);
            
            if this.BTL_CheckLocalPlayerMoney(moneyCost) {
                this.m_btlPendingOldPerkPurchase = perkType;
                this.BTL_ShowAutoConversionDialog("Perk", 1, moneyCost);
                return false;
            }
        } else {
            if this.BTL_BuyMultiplePerkPoints(1) {
            }
            this.BTL_ClearAutoConversionState();
        }
    }
    
    return wrappedMethod(perkType);
}

@wrapMethod(PlayerDevelopmentData)
public final const func IncreaseTraitLevel(traitType: gamedataTraitType) -> Bool {
    let primDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
    
    if primDevIndex >= 0 && this.m_devPoints[primDevIndex].unspent <= 0 {
        if !this.m_btlAutoConversionConfirmed {
            let moneyCost: Int32 = this.BTL_CalculatePerkPointsCost(1);
            
            if this.BTL_CheckLocalPlayerMoney(moneyCost) {
                this.m_btlPendingTraitPurchase = traitType;
                this.BTL_ShowAutoConversionDialog("Perk", 1, moneyCost);
                return false;
            }
        } else {
            if this.BTL_BuyMultiplePerkPoints(1) {
            }
            this.BTL_ClearAutoConversionState();
        }
    }
    
    return wrappedMethod(traitType);
}

public class BTL_ShowAutoConversionDialogEvent extends Event {
    public let pointType: String;
    public let pointsNeeded: Int32;
    public let moneyCost: Int32;
}

@addField(NewPerksCategoriesGameController)
private let m_buyAttributeConfirmationToken: ref<inkGameNotificationToken>;

@addField(NewPerksCategoriesGameController)
private let m_buyPerkConfirmationToken: ref<inkGameNotificationToken>;

@addField(NewPerksCategoriesGameController)
private let m_autoConversionConfirmationToken: ref<inkGameNotificationToken>;

@wrapMethod(NewPerksCategoriesGameController)
protected cb func OnInitialize() -> Bool {
    let result: Bool = wrappedMethod();
    this.SetupClickablePointsDisplay();
    this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    return result;
}

@wrapMethod(NewPerksCategoriesGameController)
protected cb func OnUninitialize() -> Bool {
    this.CleanupBuyPointsDialogs();
    this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
    return wrappedMethod();
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsHandled() {
        return false;
    }
    return false;
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnBTLShowAutoConversionDialog(evt: ref<BTL_ShowAutoConversionDialogEvent>) -> Bool {
    this.ShowAutoConversionDialog(evt.pointType, evt.pointsNeeded, evt.moneyCost);
    return true;
}


@addMethod(NewPerksCategoriesGameController)
private final func ShowAutoConversionDialog(pointType: String, pointsNeeded: Int32, moneyCost: Int32) -> Void {
    if IsDefined(this.m_autoConversionConfirmationToken) {
        return;
    }
    
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_player.GetGame());
    let playerMoney: Int32 = transactionSystem.GetItemQuantity(this.m_player, MarketSystem.Money());
    
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    let currentPrice: Int32;
    let nextPrice: Int32;
    
    if Equals(pointType, "Attribute") {
        currentPrice = developmentData.BTL_GetCurrentAttributeBuyPrice();
        nextPrice = Min(currentPrice + 10000, 200000);
    } else {
        currentPrice = developmentData.BTL_GetCurrentPerkBuyPrice();
        nextPrice = Min(currentPrice + 10000, 200000);
    }
    
    let messageLine1: String = BTL_BuyPointsLoc.GetLoc("BTL_AutoConvertNoPoints");
    messageLine1 = StrReplace(messageLine1, "{TYPE}", pointType);
    
    let messageLine2: String = BTL_BuyPointsLoc.GetLoc("BTL_AutoConvertQuestion");
    messageLine2 = StrReplace(messageLine2, "{COST}", IntToString(moneyCost));
    messageLine2 = StrReplace(messageLine2, "{POINTS}", IntToString(pointsNeeded));
    messageLine2 = StrReplace(messageLine2, "{TYPE}", pointType);
    
    let priceInfo: String;
    if pointsNeeded == 1 {
        priceInfo = BTL_BuyPointsLoc.GetLoc("BTL_AutoConvertPriceSingle");
        priceInfo = StrReplace(priceInfo, "{CURRENT}", IntToString(currentPrice));
        priceInfo = StrReplace(priceInfo, "{NEXT}", IntToString(nextPrice));
    } else {
        priceInfo = BTL_BuyPointsLoc.GetLoc("BTL_AutoConvertPriceMultiple");
        priceInfo = StrReplace(priceInfo, "{CURRENT}", IntToString(currentPrice));
    }
    
    let messageLine3: String = BTL_BuyPointsLoc.GetLoc("BTL_AutoConvertMoney");
    messageLine3 = StrReplace(messageLine3, "{MONEY}", IntToString(playerMoney));
    
    let message: String = messageLine1 + "\n\n" + messageLine2 + "\n\n" + priceInfo + "\n" + messageLine3;
    let title: String = BTL_BuyPointsLoc.GetLoc("BTL_AutoConvertTitle");
    
    this.m_autoConversionConfirmationToken = GenericMessageNotification.Show(
        this, 
        title, 
        message, 
        GenericMessageNotificationType.YesNo
    );
    
    if IsDefined(this.m_autoConversionConfirmationToken) {
        this.m_autoConversionConfirmationToken.RegisterListener(this, n"OnAutoConversionConfirmation");
    }
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnAutoConversionConfirmation(data: ref<inkGameNotificationData>) -> Bool {
    this.m_autoConversionConfirmationToken = null;
    
    let resultData: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    
    if IsDefined(resultData) && Equals(resultData.result, GenericMessageNotificationResult.Yes) {
        let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
        if IsDefined(developmentData) {
            developmentData.BTL_ConfirmAutoConversion();
            
            if NotEquals(developmentData.m_btlPendingAttributePurchase, gamedataStatType.Invalid) {
                let attrType: gamedataStatType = developmentData.m_btlPendingAttributePurchase;
                developmentData.m_btlPendingAttributePurchase = gamedataStatType.Invalid;
                developmentData.BuyAttribute(attrType);
                
                let devUpdateEvent: ref<PlayerDevUpdateDataEvent> = new PlayerDevUpdateDataEvent();
                GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(devUpdateEvent);
                
            } else if NotEquals(developmentData.m_btlPendingPerkPurchase, gamedataNewPerkType.Invalid) {
                let perkType: gamedataNewPerkType = developmentData.m_btlPendingPerkPurchase;
                developmentData.m_btlPendingPerkPurchase = gamedataNewPerkType.Invalid;
                
                let buyPerkRequest: ref<BuyNewPerk> = new BuyNewPerk();
                buyPerkRequest.Set(this.m_player, perkType);
                PlayerDevelopmentSystem.GetInstance(this.m_player).QueueRequest(buyPerkRequest);
                
                UIInventoryScriptableSystem.GetInstance(this.m_player.GetGame()).QueueRequest(buyPerkRequest);
                
            } else if NotEquals(developmentData.m_btlPendingOldPerkPurchase, gamedataPerkType.Invalid) {
                let oldPerkType: gamedataPerkType = developmentData.m_btlPendingOldPerkPurchase;
                developmentData.m_btlPendingOldPerkPurchase = gamedataPerkType.Invalid;
                
                let buyOldPerkRequest: ref<BuyPerk> = new BuyPerk();
                buyOldPerkRequest.Set(this.m_player, oldPerkType);
                PlayerDevelopmentSystem.GetInstance(this.m_player).QueueRequest(buyOldPerkRequest);
                
            } else if NotEquals(developmentData.m_btlPendingTraitPurchase, gamedataTraitType.Invalid) {
                let traitType: gamedataTraitType = developmentData.m_btlPendingTraitPurchase;
                developmentData.m_btlPendingTraitPurchase = gamedataTraitType.Invalid;
                
                let increaseTraitRequest: ref<IncreaseTraitLevel> = new IncreaseTraitLevel();
                increaseTraitRequest.Set(this.m_player, traitType);
                PlayerDevelopmentSystem.GetInstance(this.m_player).QueueRequest(increaseTraitRequest);
            }
            
            this.PlaySound(n"Attributes", n"OnBuy");
        }
    } else {
        let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
        if IsDefined(developmentData) {
            developmentData.m_btlPendingAttributePurchase = gamedataStatType.Invalid;
            developmentData.m_btlPendingPerkPurchase = gamedataNewPerkType.Invalid;
            developmentData.m_btlPendingOldPerkPurchase = gamedataPerkType.Invalid;
            developmentData.m_btlPendingTraitPurchase = gamedataTraitType.Invalid;
        }
    }
    
    return true;
}

@addMethod(NewPerksCategoriesGameController)
private final func SetupClickablePointsDisplay() -> Void {
    let pointsDisplayWidget: wref<inkWidget>;
    let compound: wref<inkCompoundWidget>;
    let listWidget: wref<inkWidget>;
    let listCompound: wref<inkCompoundWidget>;
    let attributeWidget: wref<inkWidget>;
    let perkWidget: wref<inkWidget>;
    
    if !inkWidgetRef.IsValid(this.m_pointsDisplay) {
        return;
    }
    
    pointsDisplayWidget = inkWidgetRef.Get(this.m_pointsDisplay);
    compound = pointsDisplayWidget as inkCompoundWidget;
    
    if !IsDefined(compound) {
        return;
    }
    
    listWidget = compound.GetWidget(n"list");
    
    if !IsDefined(listWidget) {
        return;
    }
    
    listCompound = listWidget as inkCompoundWidget;
    
    if !IsDefined(listCompound) {
        return;
    }
    
    attributeWidget = listCompound.GetWidget(n"valueWrapper1");
    perkWidget = listCompound.GetWidget(n"valueWrapper2");
    
    if IsDefined(attributeWidget) {
        attributeWidget.SetInteractive(true);
        attributeWidget.RegisterToCallback(n"OnRelease", this, n"OnAttributePointsClick");
    }
    
    if IsDefined(perkWidget) {
        perkWidget.SetInteractive(true);
        perkWidget.RegisterToCallback(n"OnRelease", this, n"OnPerkPointsClick");
    }
}

@addMethod(NewPerksCategoriesGameController)
private final func CleanupBuyPointsDialogs() -> Void {
    if IsDefined(this.m_buyAttributeConfirmationToken) {
        this.m_buyAttributeConfirmationToken = null;
    }
    
    if IsDefined(this.m_buyPerkConfirmationToken) {
        this.m_buyPerkConfirmationToken = null;
    }
    
    if IsDefined(this.m_autoConversionConfirmationToken) {
        this.m_autoConversionConfirmationToken = null;
    }
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnAttributePointsClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
        if IsDefined(this.m_buyAttributeConfirmationToken) {
            return false;
        }
        
        this.ShowBuyAttributePointDialog();
        this.PlaySound(n"Button", n"OnPress");
    }
    
    return true;
}

@addMethod(NewPerksCategoriesGameController)
private final func ShowBuyAttributePointDialog() -> Void {
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    if !IsDefined(developmentData) {
        return;
    }
    
    let currentPrice: Int32 = developmentData.BTL_GetCurrentAttributeBuyPrice();
    let nextPrice: Int32 = Min(currentPrice + 10000, 200000);
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_player.GetGame());
    let playerMoney: Int32 = transactionSystem.GetItemQuantity(this.m_player, MarketSystem.Money());
    
    if playerMoney < currentPrice {
        let menuNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
        menuNotification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(menuNotification);
        return;
    }
    
    let messageLine1: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyAttributeMessage");
    messageLine1 = StrReplace(messageLine1, "{PRICE}", IntToString(currentPrice));
    
    let messageLine2: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyAttributeNextPrice");
    messageLine2 = StrReplace(messageLine2, "{NEXT}", IntToString(nextPrice));
    
    let messageLine3: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyAttributeMoney");
    messageLine3 = StrReplace(messageLine3, "{MONEY}", IntToString(playerMoney));
    
    let message: String = messageLine1 + "\n\n" + messageLine2 + "\n" + messageLine3;
    let title: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyAttributeTitle");
    
    this.m_buyAttributeConfirmationToken = GenericMessageNotification.Show(
        this, 
        title, 
        message, 
        GenericMessageNotificationType.YesNo
    );
    
    if IsDefined(this.m_buyAttributeConfirmationToken) {
        this.m_buyAttributeConfirmationToken.RegisterListener(this, n"OnBuyAttributeConfirmation");
    } else {
        this.ExecuteAttributePointPurchase();
    }
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnBuyAttributeConfirmation(data: ref<inkGameNotificationData>) -> Bool {
    this.m_buyAttributeConfirmationToken = null;
    
    let resultData: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    
    if IsDefined(resultData) {
        if Equals(resultData.result, GenericMessageNotificationResult.Yes) {
            this.ExecuteAttributePointPurchase();
        }
    }
    
    return true;
}

@addMethod(NewPerksCategoriesGameController)
private final func ExecuteAttributePointPurchase() -> Void {
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    if !IsDefined(developmentData) {
        return;
    }
    
    if developmentData.BTL_BuyAttributePointWithEddies() {
        let devUpdateEvent: ref<PlayerDevUpdateDataEvent> = new PlayerDevUpdateDataEvent();
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(devUpdateEvent);
        
        this.PlaySound(n"Attributes", n"OnBuy");
    } else {
        let errorNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
        errorNotification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(errorNotification);
    }
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnPerkPointsClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
        if IsDefined(this.m_buyPerkConfirmationToken) {
            return false;
        }
        
        this.ShowBuyPerkPointDialog();
        this.PlaySound(n"Button", n"OnPress");
    }
    
    return true;
}

@addMethod(NewPerksCategoriesGameController)
private final func ShowBuyPerkPointDialog() -> Void {
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    if !IsDefined(developmentData) {
        return;
    }
    
    let currentPrice: Int32 = developmentData.BTL_GetCurrentPerkBuyPrice();
    let nextPrice: Int32 = Min(currentPrice + 10000, 200000);
    let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_player.GetGame());
    let playerMoney: Int32 = transactionSystem.GetItemQuantity(this.m_player, MarketSystem.Money());
    
    if playerMoney < currentPrice {
        let menuNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
        menuNotification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(menuNotification);
        return;
    }
    
    let messageLine1: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyPerkMessage");
    messageLine1 = StrReplace(messageLine1, "{PRICE}", IntToString(currentPrice));
    
    let messageLine2: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyPerkNextPrice");
    messageLine2 = StrReplace(messageLine2, "{NEXT}", IntToString(nextPrice));
    
    let messageLine3: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyPerkMoney");
    messageLine3 = StrReplace(messageLine3, "{MONEY}", IntToString(playerMoney));
    
    let message: String = messageLine1 + "\n\n" + messageLine2 + "\n" + messageLine3;
    let title: String = BTL_BuyPointsLoc.GetLoc("BTL_BuyPerkTitle");
    
    this.m_buyPerkConfirmationToken = GenericMessageNotification.Show(
        this, 
        title, 
        message, 
        GenericMessageNotificationType.YesNo
    );
    
    if IsDefined(this.m_buyPerkConfirmationToken) {
        this.m_buyPerkConfirmationToken.RegisterListener(this, n"OnBuyPerkConfirmation");
    } else {
        this.ExecutePerkPointPurchase();
    }
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnBuyPerkConfirmation(data: ref<inkGameNotificationData>) -> Bool {
    this.m_buyPerkConfirmationToken = null;
    
    let resultData: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    
    if IsDefined(resultData) {
        if Equals(resultData.result, GenericMessageNotificationResult.Yes) {
            this.ExecutePerkPointPurchase();
        }
    }
    
    return true;
}

@addMethod(NewPerksCategoriesGameController)
private final func ExecutePerkPointPurchase() -> Void {
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    if !IsDefined(developmentData) {
        return;
    }
    
    if developmentData.BTL_BuyPerkPointWithEddies() {
        let devUpdateEvent: ref<PlayerDevUpdateDataEvent> = new PlayerDevUpdateDataEvent();
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(devUpdateEvent);
        
        this.PlaySound(n"Attributes", n"OnBuy");
    } else {
        let errorNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
        errorNotification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(errorNotification);
    }
}