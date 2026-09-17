module BetterLevelingConfig

public class Settings {


    // ---- LEVEL SETTINGS ----
    public static func NewLevelCap() -> Int32 { return 60; }
    public static func StreetCredCap() -> Int32 { return 50; }
    public static func StartingAttributePoints() -> Int32 { return 7; }
    public static func MaxStartingAttribute() -> Int32 { return 6; }
    public static func RemoveLevelProgressionCap() -> Bool { return true; }
    public static func RemoveAttributeProgressionCap() -> Bool { return true; }
    public static func SkillProgressionCap() -> Int32 { return 60; }

    // ---- ATTRIBUTE SETTINGS ----
    public static func AttributeCap() -> Int32 { return 20; }
    public static func AttrPointsPerLevel() -> Int32 { return 1; }
    public static func PerkPointsPerLevel() -> Int32 { return 1; }

    // ---- CYBERWARE SETTINGS ----
    public static func MoreCyberwareCapacity() -> Int32 { return 6; }
    public static func CyberwareCap() -> Int32 { return 1000; }

    // ---- FEATURE FLAGS ----
    public static func EnableLevelCap() -> Bool { return true; }
    public static func EnableStreetCredCap() -> Bool { return true; }
    public static func EnableAttributeCap() -> Bool { return true; }
    public static func EnableStartingAttr() -> Bool { return true; }
    public static func EnableCyberwareScaling() -> Bool { return true; }
    public static func EnableCyberwareCap() -> Bool { return true; }
    public static func EnableMoreAttrPerLevel() -> Bool { return true; }
    public static func EnableMorePerkPerLevel() -> Bool { return true; }
    public static func EnableXPMultiplier() -> Bool { return true; }
    public static func BeyondLevel60Curve() -> Bool { return true; }
    public static func BeyondStreetCredCurve() -> Bool { return true; }
    public static func ExtendSkillProgression() -> Bool { return true; }

    // ---- XP MULTIPLIERS (Separate functions to avoid parameter issues) ----
    public static func XPMultiplierLevel() -> Float { return 1.0; }
    public static func XPMultiplierStreetCred() -> Float { return 1.0; }
    public static func XPMultiplierHeadhunter() -> Float { return 1.0; }
    public static func XPMultiplierNetrunner() -> Float { return 1.0; }
    public static func XPMultiplierShinobi() -> Float { return 1.0; }
    public static func XPMultiplierSolo() -> Float { return 1.0; }
    public static func XPMultiplierEngineer() -> Float { return 1.0; }
}