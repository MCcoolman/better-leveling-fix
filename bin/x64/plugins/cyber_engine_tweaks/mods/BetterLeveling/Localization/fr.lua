-- Localization/FR.lua
return {
    tab = "Leveling Amélioré",
    
    -- Subcategories
    levelSettings = "Paramètres de Niveau",
    attributeSettings = "Paramètres d'Attributs",
    cyberwareSettings = "Paramètres de Cyberware",
    xpSettings = "Multiplicateurs XP", 
    featureToggles = "Activer/Désactiver",
    
    -- Level Settings
    levelCap = "Niveau Maximum",
    levelCapDesc = "Niveau maximum du joueur. (défaut: 60)",
    streetCredCap = "Cote de Rue Maximum",
    streetCredCapDesc = "Niveau maximum de cote de rue (défaut: 50).",
    startPoints = "Points d'Attribut Initiaux",
    startPointsDesc = "Points d'attribut avec lesquels V commence. (défaut: 7)",
    maxAttribute = "Attribut Initial Max",
    maxAttributeDesc = "Points max par attribut à la création du personnage. (défaut: 6)",
    
    -- Attribute Settings
    attributeCap = "Limite d'Attribut",
    attributeCapDesc = "Définit la valeur maximale que chaque attribut peut atteindre. (défaut: 20)",
    attrPerLevel = "Points d'Attribut par Niveau",
    attrPerLevelDesc = "Total des points d'attribut gagnés par niveau de personnage.",
    perkPerLevel = "Points de Perk par Niveau", 
    perkPerLevelDesc = "Total des points de perk gagnés par niveau de personnage.",
    
    -- Cyberware Settings
    cyberwareCapacity = "Échelle Capacité Cyberware",
    cyberwareCapacityDesc = "Définit le facteur d'échelle pour la capacité cyberware selon votre niveau. (défaut: 6) (Redémarrage du jeu requis)",
    cyberwareCap = "Limite Capacité Cyberware",
    cyberwareCapDesc = "Définit la capacité cyberware maximale. (défaut: 1000) (Redémarrage du jeu requis)",

    SkillProgression = "Progression des compétences",
    SkillProgressionDesc = "Définir la progression des compétences (par défaut : 60)",
    
    -- XP Multipliers
    xpLevelMult = "Multiplicateur XP Niveau",
    xpStreetCredMult = "Multiplicateur XP Cote de Rue",
    xpHeadhunterMult = "Multiplicateur XP Headhunter", 
    xpNetrunnerMult = "Multiplicateur XP Netrunner",
    xpShinobiMult = "Multiplicateur XP Shinobi",
    xpSoloMult = "Multiplicateur XP Solo",
    xpEngineerMult = "Multiplicateur XP Ingénieur",
    xpMultDesc = "Multiplicateur pour cette catégorie XP. (défaut: 1.0)",
    
    -- Feature Toggle Labels
    toggleLevelCap = "Niveau Maximum",
    toggleStreetCredCap = "Cote de Rue Maximum",
    toggleAttributeCap = "Limite d'Attribut",
    toggleStartingAttr = "Attributs Initiaux", 
    toggleCyberwareScaling = "Échelle Cyberware",
    toggleCyberwareCap = "Limite Cyberware",
    toggleMoreAttrPerLevel = "Plus d'Attr par Niveau",
    toggleMorePerkPerLevel = "Plus de Perk par Niveau",
    toggleXPMultiplier = "Multiplicateurs XP",
    toggleRemoveLevelProgressionCap = "Supprimer Limite Progression Niveau",
    toggleRemoveAttributeProgressionCap = "Supprimer Limite Progression Attribut",
    toggleBeyondLevel60Curve = "Courbe XP Au-delà Niveau 60",
    toggleBeyondStreetCredCurve = "Courbe XP Cote de Rue Au-delà Niveau 60",
    toggleSkillProgression = "Activer la progression des compétences",

    -- Feature Toggle Descriptions
    toggleLevelCapDesc = "Activer la modification du niveau maximum",
    toggleStreetCredCapDesc = "Activer la modification de la cote de rue maximum", 
    toggleAttributeCapDesc = "Activer la modification de la limite d'attribut",
    toggleStartingAttrDesc = "Activer la modification des attributs initiaux",
    toggleCyberwareScalingDesc = "Activer l'échelle de capacité cyberware",
    toggleCyberwareCapDesc = "Activer la limite de capacité cyberware",
    toggleMoreAttrPerLevelDesc = "Activer les points d'attribut personnalisés par niveau",
    toggleMorePerkPerLevelDesc = "Activer les points de perk personnalisés par niveau",
    toggleXPMultiplierDesc = "Activer le système de multiplicateur XP",
    toggleRemoveLevelProgressionCapDesc = "Permet aux bonus de santé, stamina et autres passifs de continuer au-delà du niveau 60.",
    toggleRemoveAttributeProgressionCapDesc = "Permet aux attributs de dépasser 20 et de continuer à fournir des bonus.",
    toggleBeyondLevel60CurveDesc = "Active l'échelle XP exponentielle pour les niveaux 61-135, atteignant 4M XP au niveau 135.",
    toggleBeyondStreetCredCurveDesc = "Active l'échelle XP exponentielle de Cote de Rue pour les niveaux 61-350, atteignant 50M XP au niveau 350.",
    toggleSkillProgressionDesc = "Active la progression des compétences de 60 à la valeur choisie par l'utilisateur",
    
    -- Language
    languageLabel = "Langue",
    languageDesc = "Choisir la langue pour l'interface du mod.",
    languageChanged = "Langue changée. Veuillez rouvrir le menu du mod pour voir les changements."
}