module BetterLeveling

import Codeware.UI.*

public class BTL_SellPerkLoc extends IScriptable {
    public static func GetLoc(key: String) -> String {
        return GetLocalizedTextByKey(StringToName(key));
    }
}

@addField(PlayerDevelopmentData) 
private persistent let m_btlCurrentPerkSellPrice: Int32 = 15000;

@addMethod(PlayerDevelopmentData)
public final func GetCurrentPerkSellPrice() -> Int32 {
    if this.m_btlCurrentPerkSellPrice < 15000 {
        this.m_btlCurrentPerkSellPrice = 15000;
    }
    return this.m_btlCurrentPerkSellPrice;
}

@addMethod(PlayerDevelopmentData)
public final func IncreasePerkSellPrice() -> Void {
    this.m_btlCurrentPerkSellPrice = Min(this.m_btlCurrentPerkSellPrice + 5000, 50000);
}

@addMethod(PlayerDevelopmentData)
public final func SellPerkPointForEddies() -> Bool {
    let primDevIndex: Int32 = this.GetDevPointsIndex(gamedataDevelopmentPointType.Primary);
    if primDevIndex < 0 || this.m_devPoints[primDevIndex].unspent <= 0 {
        return false;
    }
    
    this.m_devPoints[primDevIndex].unspent -= 1;
    this.m_devPoints[primDevIndex].spent += 1;
    
    let currentPrice: Int32 = this.GetCurrentPerkSellPrice();
    GameInstance.GetTransactionSystem(this.m_owner.GetGame()).GiveItem(this.m_owner, MarketSystem.Money(), currentPrice);
    
    this.IncreasePerkSellPrice();
    
    return true;
}

public class SellPerkPointsButton extends CustomButton {
    protected let m_background: wref<inkImage>;
    protected let m_frame: wref<inkImage>;
    protected let m_hoverLayer: wref<inkCanvas>;
    protected let m_icon: wref<inkImage>;
    
    protected let m_hoverAnimDef: ref<inkAnimDef>;
    protected let m_hoverAnimProxy: ref<inkAnimProxy>;
    protected let m_pressAnimDef: ref<inkAnimDef>;
    protected let m_pressAnimProxy: ref<inkAnimProxy>;
    
    protected let m_defaultColor: HDRColor;
    protected let m_hoverColor: HDRColor;
    protected let m_pressedColor: HDRColor;

    protected func CreateWidgets() -> Void {
        this.InitializeColors();
        
        let root: ref<inkCanvas> = new inkCanvas();
        root.SetName(n"SellPerkPointsButton");
        root.SetSize(new Vector2(450.0, 70.0));
        root.SetInteractive(true);

        let background: ref<inkImage> = new inkImage();
        background.SetName(n"background");
        background.SetAtlasResource(r"base\\gameplay\\gui\\widgets\\notifications\\notification_assets.inkatlas");
        background.SetTexturePart(n"Plate_main_Stroke");
        background.SetAnchor(inkEAnchor.Fill);
        background.SetTintColor(this.m_defaultColor);
        background.SetOpacity(0.8);
        background.SetNineSliceScale(true);
        background.Reparent(root);

        let frame: ref<inkImage> = new inkImage();
        frame.SetName(n"frame");
        frame.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
        frame.SetTexturePart(n"cell_fg");
        frame.SetAnchor(inkEAnchor.Fill);
        frame.SetTintColor(this.m_defaultColor);
        frame.SetOpacity(0.3);
        frame.SetNineSliceScale(true);
        frame.Reparent(root);

        let hoverLayer: ref<inkCanvas> = new inkCanvas();
        hoverLayer.SetName(n"hoverLayer");
        hoverLayer.SetAnchor(inkEAnchor.Fill);
        hoverLayer.SetOpacity(0.0);
        hoverLayer.Reparent(root);

        let hoverBg: ref<inkImage> = new inkImage();
        hoverBg.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
        hoverBg.SetTexturePart(n"cell_bg");
        hoverBg.SetAnchor(inkEAnchor.Fill);
        hoverBg.SetTintColor(this.m_hoverColor);
        hoverBg.SetOpacity(0.2);
        hoverBg.SetNineSliceScale(true);
        hoverBg.Reparent(hoverLayer);

        let icon: ref<inkImage> = new inkImage();
        icon.SetName(n"icon");
        icon.SetAtlasResource(r"base\\gameplay\\gui\\fullscreen\\inventory\\inventory4_atlas.inkatlas");
        icon.SetTexturePart(n"icon_money");
        icon.SetSize(new Vector2(32.0, 32.0));
        icon.SetMargin(new inkMargin(15.0, 0.0, 0.0, 0.0));
        icon.SetAnchor(inkEAnchor.CenterLeft);
        icon.SetAnchorPoint(new Vector2(0.0, 0.5));
        icon.SetTintColor(new HDRColor(0.368, 0.964, 1.0, 1.0));
        icon.Reparent(root);

        let label: ref<inkText> = new inkText();
        label.SetName(n"label");
        label.SetText(BTL_SellPerkLoc.GetLoc("BTL_SellPerkButton"));
        label.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        label.SetFontStyle(n"Medium");
        label.SetFontSize(40);
        label.SetLetterCase(textLetterCase.UpperCase);
        label.SetMargin(new inkMargin(55.0, 0.0, 0.0, 0.0));
        label.SetAnchor(inkEAnchor.CenterLeft);
        label.SetAnchorPoint(new Vector2(0.0, 0.5));
        label.SetHorizontalAlignment(textHorizontalAlignment.Left);
        label.SetVerticalAlignment(textVerticalAlignment.Center);
        label.SetTintColor(new HDRColor(0.368, 0.964, 1.0, 1.0));
        label.Reparent(root);

        this.m_root = root;
        this.m_label = label;
        this.m_background = background;
        this.m_frame = frame;
        this.m_hoverLayer = hoverLayer;
        this.m_icon = icon;

        this.SetRootWidget(root);
        this.CreateAnimations();
    }

    protected func InitializeColors() -> Void {
        this.m_defaultColor = new HDRColor(1.0, 0.2, 0.2, 1.0);
        this.m_hoverColor = new HDRColor(1.4, 0.4, 0.4, 1.0);
        this.m_pressedColor = new HDRColor(1.8, 0.6, 0.6, 1.0);
    }

    protected func CreateAnimations() -> Void {
        let hoverTransparency: ref<inkAnimTransparency> = new inkAnimTransparency();
        hoverTransparency.SetStartTransparency(0.0);
        hoverTransparency.SetEndTransparency(1.0);
        hoverTransparency.SetDuration(0.15);
        hoverTransparency.SetType(inkanimInterpolationType.Quadratic);
        hoverTransparency.SetMode(inkanimInterpolationMode.EasyOut);

        this.m_hoverAnimDef = new inkAnimDef();
        this.m_hoverAnimDef.AddInterpolator(hoverTransparency);

        let pressScale: ref<inkAnimScale> = new inkAnimScale();
        pressScale.SetStartScale(new Vector2(1.0, 1.0));
        pressScale.SetEndScale(new Vector2(0.98, 0.98));
        pressScale.SetDuration(0.1);
        pressScale.SetType(inkanimInterpolationType.Linear);

        this.m_pressAnimDef = new inkAnimDef();
        this.m_pressAnimDef.AddInterpolator(pressScale);
    }

    protected func ApplyHoveredState() -> Void {
        if IsDefined(this.m_hoverAnimProxy) {
            this.m_hoverAnimProxy.Stop();
        }

        let reverseOpts: inkAnimOptions;
        reverseOpts.playReversed = !this.m_isHovered;

        this.m_hoverAnimProxy = this.m_hoverLayer.PlayAnimationWithOptions(this.m_hoverAnimDef, reverseOpts);

        if this.m_isHovered {
            this.m_background.SetTintColor(this.m_hoverColor);
            this.m_frame.SetTintColor(this.m_hoverColor);
            this.m_label.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
            this.PlayHoverSound();
        } else {
            this.m_background.SetTintColor(this.m_defaultColor);
            this.m_frame.SetTintColor(this.m_defaultColor);
            this.m_label.SetTintColor(new HDRColor(0.368, 0.964, 1.0, 1.0));
        }
    }

    protected func ApplyPressedState() -> Void {
        if IsDefined(this.m_pressAnimProxy) {
            this.m_pressAnimProxy.Stop();
        }

        if this.m_isPressed {
            this.m_background.SetTintColor(this.m_pressedColor);
            this.m_frame.SetTintColor(this.m_pressedColor);
            this.m_pressAnimProxy = this.m_root.PlayAnimation(this.m_pressAnimDef);
            this.PlayPressSound();
        }
    }

    protected func PlayHoverSound() -> Void {
        this.PlaySound(n"Button", n"OnHover");
    }

    protected func PlayPressSound() -> Void {
        this.PlaySound(n"Attributes", n"OnPress");
    }

    public func SetEnabled(enabled: Bool) -> Void {
        this.m_root.SetInteractive(enabled);
        
        if enabled {
            this.m_root.SetOpacity(1.0);
            this.m_background.SetTintColor(this.m_defaultColor);
        } else {
            this.m_root.SetOpacity(0.5);
            this.m_background.SetTintColor(new HDRColor(0.5, 0.5, 0.5, 1.0));
        }
    }

    public func SetPosition(position: Vector2) -> Void {
        this.m_root.SetTranslation(position.X, position.Y);
    }

    public func SetSize(size: Vector2) -> Void {
        this.m_root.SetSize(size);
    }

    public static func Create() -> ref<SellPerkPointsButton> {
        let self: ref<SellPerkPointsButton> = new SellPerkPointsButton();
        self.CreateInstance();
        return self;
    }
}

@addField(NewPerksCategoriesGameController)
private let m_sellPerkPointsButton: ref<SellPerkPointsButton>;

@addField(NewPerksCategoriesGameController)
private let m_buttonAnimProxy: ref<inkAnimProxy>;

@addField(NewPerksCategoriesGameController)
private let m_sellConfirmationToken: ref<inkGameNotificationToken>;

@wrapMethod(NewPerksCategoriesGameController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    this.SetupSellPerkPointsButton();
}

@wrapMethod(NewPerksCategoriesGameController)
protected cb func OnUninitialize() -> Bool {
    this.CleanupSellPerkPointsButton();
    wrappedMethod();
}

@addMethod(NewPerksCategoriesGameController)
private final func SetupSellPerkPointsButton() -> Void {
    let resetButton: wref<inkWidget> = inkWidgetRef.Get(this.m_resetAttributesButton);
    if !IsDefined(resetButton) {
        return;
    }
    
    let parentContainer: wref<inkCompoundWidget> = resetButton.GetParentWidget() as inkCompoundWidget;
    if !IsDefined(parentContainer) {
        return;
    }

    this.m_sellPerkPointsButton = SellPerkPointsButton.Create();
    this.m_sellPerkPointsButton.SetSize(resetButton.GetSize());
    this.m_sellPerkPointsButton.SetPosition(new Vector2(135.0, 1660.0));
    this.m_sellPerkPointsButton.Reparent(parentContainer);

    this.m_sellPerkPointsButton.RegisterToCallback(n"OnRelease", this, n"OnSellPerkPointsClick");
    
    this.PlayButtonIntroAnimation();
    
    this.m_sellPerkPointsButton.SetEnabled(true);
    
}

@addMethod(NewPerksCategoriesGameController)
private final func CleanupSellPerkPointsButton() -> Void {
    if IsDefined(this.m_sellPerkPointsButton) {
        this.m_sellPerkPointsButton.UnregisterFromCallback(n"OnRelease", this, n"OnSellPerkPointsClick");
        
        if IsDefined(this.m_buttonAnimProxy) {
            this.m_buttonAnimProxy.Stop();
        }
    }
    
    if IsDefined(this.m_sellConfirmationToken) {
        this.m_sellConfirmationToken = null;
    }
}

@addMethod(NewPerksCategoriesGameController)
private final func PlayButtonIntroAnimation() -> Void {
    if !IsDefined(this.m_sellPerkPointsButton) {
        return;
    };
    
    this.m_sellPerkPointsButton.GetRootWidget().SetTranslation(200.0, 1660.0);
    this.m_sellPerkPointsButton.GetRootWidget().SetOpacity(0.0);
    
    let introAnimDef: ref<inkAnimDef> = new inkAnimDef();
    
    let slideIn: ref<inkAnimTranslation> = new inkAnimTranslation();
    slideIn.SetStartTranslation(new Vector2(200.0, 1660.0));
    slideIn.SetEndTranslation(new Vector2(135.0, 1660.0));
    slideIn.SetDuration(0.3);
    slideIn.SetStartDelay(0.2);
    slideIn.SetType(inkanimInterpolationType.Quadratic);
    slideIn.SetMode(inkanimInterpolationMode.EasyOut);
    
    let fadeIn: ref<inkAnimTransparency> = new inkAnimTransparency();
    fadeIn.SetStartTransparency(0.0);
    fadeIn.SetEndTransparency(1.0);
    fadeIn.SetDuration(0.3);
    fadeIn.SetStartDelay(0.2);
    fadeIn.SetType(inkanimInterpolationType.Linear);
    
    introAnimDef.AddInterpolator(slideIn);
    introAnimDef.AddInterpolator(fadeIn);
    
    this.m_buttonAnimProxy = this.m_sellPerkPointsButton.GetRootWidget().PlayAnimation(introAnimDef);
}

@addMethod(NewPerksCategoriesGameController)
private final func UpdateSellButtonState() -> Void {
    if !IsDefined(this.m_sellPerkPointsButton) {
        return;
    };
    
    let playerDevSystem: ref<PlayerDevelopmentSystem> = PlayerDevelopmentSystem.GetInstance(this.m_player);
    let hasPoints: Bool = playerDevSystem.GetDevPoints(this.m_player, gamedataDevelopmentPointType.Primary) > 0;
    
    this.m_sellPerkPointsButton.SetEnabled(hasPoints);
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnSellPerkPointsClick(evt: ref<inkPointerEvent>) -> Bool {
    if evt.IsAction(n"click") {
        if IsDefined(this.m_sellConfirmationToken) {
            return false;
        }
        
        this.ShowSellPerkPointsDialog();
    }
}

@addMethod(NewPerksCategoriesGameController)
private final func ShowSellPerkPointsDialog() -> Void {
    
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    if !IsDefined(developmentData) {
        return;
    }
    
    let perkPoints: Int32 = developmentData.GetDevPoints(gamedataDevelopmentPointType.Primary);
    
    
    if perkPoints <= 0 {
        let menuNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
        menuNotification.m_notificationType = UIMenuNotificationType.NoPerksPoints;
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(menuNotification);
        return;
    }
    
    let currentPrice: Int32 = developmentData.GetCurrentPerkSellPrice();
    let nextPrice: Int32 = Min(currentPrice + 5000, 50000);
        
    let messageLine1: String = BTL_SellPerkLoc.GetLoc("BTL_SellPerkMessage");
    messageLine1 = StrReplace(messageLine1, "{PRICE}", IntToString(currentPrice));
    
    let messageLine2: String = BTL_SellPerkLoc.GetLoc("BTL_SellPerkNextPrice");
    messageLine2 = StrReplace(messageLine2, "{NEXT}", IntToString(nextPrice));
    
    let messageLine3: String = BTL_SellPerkLoc.GetLoc("BTL_SellPerkRemaining");
    messageLine3 = StrReplace(messageLine3, "{REMAINING}", IntToString(perkPoints - 1));
    
    let message: String = messageLine1 + "\n\n" + messageLine2 + "\n" + messageLine3;
    
    let title: String = BTL_SellPerkLoc.GetLoc("BTL_SellPerkTitle");
    
    this.m_sellConfirmationToken = GenericMessageNotification.Show(
        this, 
        title, 
        message, 
        GenericMessageNotificationType.YesNo
    );
    
    if IsDefined(this.m_sellConfirmationToken) {
        this.m_sellConfirmationToken.RegisterListener(this, n"OnSellConfirmation");
    } else {
        this.ExecutePerkPointSale();
    }
}

@addMethod(NewPerksCategoriesGameController)
protected cb func OnSellConfirmation(data: ref<inkGameNotificationData>) -> Bool {
    
    this.m_sellConfirmationToken = null;
    
    let resultData: ref<GenericMessageNotificationCloseData> = data as GenericMessageNotificationCloseData;
    
    if IsDefined(resultData) {
        
        if Equals(resultData.result, GenericMessageNotificationResult.Yes) {
            this.ExecutePerkPointSale();
        } else {
            // FTLog("BetterLeveling: Player cancelled selling perk point");
        }
    } else {
        // FTLog("BetterLeveling: Invalid confirmation data received");
    }
}

@addMethod(NewPerksCategoriesGameController)
private final func ExecutePerkPointSale() -> Void {
    
    let developmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(this.m_player);
    if !IsDefined(developmentData) {
        return;
    }
    
    let currentPrice: Int32 = developmentData.GetCurrentPerkSellPrice();
    let perkPoints: Int32 = developmentData.GetDevPoints(gamedataDevelopmentPointType.Primary);
    
    
    if perkPoints <= 0 {
        let menuNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
        menuNotification.m_notificationType = UIMenuNotificationType.NoPerksPoints;
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(menuNotification);
        return;
    }
    
    if developmentData.SellPerkPointForEddies() {
        this.UpdateSellButtonState();
        let devUpdateEvent: ref<PlayerDevUpdateDataEvent> = new PlayerDevUpdateDataEvent();
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(devUpdateEvent);
    } else {
        let errorNotification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
        errorNotification.m_notificationType = UIMenuNotificationType.InventoryActionBlocked;
        GameInstance.GetUISystem(this.m_player.GetGame()).QueueEvent(errorNotification);
    }
}

@wrapMethod(NewPerksCategoriesGameController)
protected cb func OnPlayerDevUpdateData(evt: ref<PlayerDevUpdateDataEvent>) -> Bool {
    let result: Bool = wrappedMethod(evt);
    
    this.UpdateSellButtonState();
    
    return result;
}