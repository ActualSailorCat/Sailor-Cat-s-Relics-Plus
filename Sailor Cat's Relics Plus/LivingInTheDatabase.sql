-- // World Wonders with relic slots grant a free relic.
-- Temp table so we don't need to keep running this query.
CREATE TABLE Temp_Sailor_RelicsPlus AS
SELECT BuildingType FROM Building_GreatWorks
WHERE GreatWorkSlotType = 'GREATWORKSLOT_RELIC' AND NumSlots > 0
AND BuildingType NOT IN -- Exclude any that already do so (directly, anyway).
	(SELECT BuildingType FROM BuildingModifiers WHERE ModifierId IN
		(SELECT ModifierId FROM Modifiers WHERE ModifierType IN
			(SELECT ModifierType FROM DynamicModifiers WHERE EffectType = 'EFFECT_GRANT_RELIC')
		)
	)
AND BuildingType IN
	(SELECT BuildingType FROM Buildings WHERE IsWonder = 1);
--
INSERT OR REPLACE INTO BuildingModifiers
SELECT BuildingType, 'SAILOR_RELICSPLUS_FREE_RELIC_'||RowID
FROM Temp_Sailor_RelicsPlus;

INSERT OR REPLACE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent)
SELECT 'SAILOR_RELICSPLUS_FREE_RELIC_'||RowID, 'MODIFIER_PLAYER_GRANT_RELIC', 1, 1
FROM Temp_Sailor_RelicsPlus;

INSERT OR REPLACE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'SAILOR_RELICSPLUS_FREE_RELIC_'||RowID, 'Amount', 1
FROM Temp_Sailor_RelicsPlus;

-- // Add a top-level GoodyHut specific to relics.
INSERT INTO Types (Type, Kind) VALUES ('GOODYHUT_SAILOR_RELIC', 'KIND_GOODY_HUT');
INSERT INTO GoodyHuts (GoodyHutType, ImprovementType, Weight, ShowMoment)
SELECT 'GOODYHUT_SAILOR_RELIC', ImprovementType, 100, ShowMoment
FROM GoodyHuts WHERE GoodyHutType = 'GOODYHUT_CULTURE';

INSERT INTO GoodyHutSubTypes (GoodyHut, SubTypeGoodyHut, Description, Weight, ModifierID, Relic, MinOneCity, Turn)
SELECT 'GOODYHUT_SAILOR_RELIC', 'GOODYHUT_SUB_SAILOR_RELIC', Description, 100, ModifierID, 1, 1, 0
FROM GoodyHutSubTypes WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_RELIC';

-- Distribute old relic weight to culture hut subtypes.
UPDATE GoodyHutSubTypes
SET Weight = Weight +
	(
	(SELECT Weight FROM GoodyHutSubTypes WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_RELIC') /
	((SELECT COUNT(*) FROM GoodyHutSubTypes WHERE GoodyHut = 'GOODYHUT_CULTURE') - 1)
	)
	+ 1
WHERE GoodyHut = 'GOODYHUT_CULTURE';

-- // Unexplored Ruin
INSERT INTO Types (Type, Kind) VALUES ('IMPROVEMENT_SAILOR_RUIN', 'KIND_IMPROVEMENT');
INSERT INTO Improvements (
		ImprovementType,
		Name,
		Description,
		Icon,
		Buildable,
		PlunderType,
		RemoveOnEntry,
		Goody
		)
SELECT
		'IMPROVEMENT_SAILOR_RUIN',
		'LOC_IMPROVEMENT_SAILOR_RUIN_NAME',
		'LOC_IMPROVEMENT_SAILOR_RUIN_DESCRIPTION',
		Icon,
		Buildable,
		PlunderType,
		RemoveOnEntry,
		Goody
FROM Improvements WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

INSERT INTO Improvement_ValidTerrains (ImprovementType, TerrainType)
SELECT 'IMPROVEMENT_SAILOR_RUIN', TerrainType
FROM Improvement_ValidTerrains WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

INSERT INTO Improvement_ValidFeatures (ImprovementType, FeatureType)
SELECT 'IMPROVEMENT_SAILOR_RUIN', FeatureType
FROM Improvement_ValidFeatures WHERE ImprovementType = 'IMPROVEMENT_GOODY_HUT';

-- Goody Stuff
INSERT INTO GoodyHuts (GoodyHutType, ImprovementType, Weight, ShowMoment)
VALUES	('SAILOR_RUIN_GOODY', 'IMPROVEMENT_SAILOR_RUIN', 100, 0);

INSERT INTO GoodyHutSubTypes (GoodyHut, SubTypeGoodyHut, Description, Weight, ModifierID, Relic, MinOneCity, Turn)
SELECT 'SAILOR_RUIN_GOODY', 'SAILOR_RUIN_GOODY_RELIC', Description, 100, 'SAILOR_RUIN_GOODY_MODIFIER', 1, 1, 0
FROM GoodyHutSubTypes WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_RELIC';

INSERT OR REPLACE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent)
VALUES	('SAILOR_RUIN_GOODY_MODIFIER', 'MODIFIER_PLAYER_GRANT_RELIC', 0, 1);

INSERT OR REPLACE INTO ModifierArguments (ModifierId, Name, Value)
VALUES	('SAILOR_RUIN_GOODY_MODIFIER', 'Amount', 1);

-- // Pantheon: Investiture
INSERT OR REPLACE INTO Building_GreatWorks (BuildingType, GreatWorkSlotType, NumSlots)
SELECT	CivUniqueBuildingType, 'GREATWORKSLOT_RELIC', 0 FROM BuildingReplaces WHERE ReplacesBuildingType = 'BUILDING_MONUMENT'
AND NOT EXISTS (SELECT GreatWorkObjectType FROM GreatWorks WHERE GreatWorkObjectType = 'GREATWORKOBJECT_HERO');

-- Heroes Mode
/*
INSERT OR REPLACE INTO Building_GreatWorks (BuildingType, GreatWorkSlotType, NumSlots)
SELECT	'BUILDING_MONUMENT', 'GREATWORKSLOT_HERO', 0
WHERE EXISTS (SELECT GreatWorkObjectType FROM GreatWorks WHERE GreatWorkObjectType = 'GREATWORKOBJECT_HERO');

INSERT OR REPLACE INTO Building_GreatWorks (BuildingType, GreatWorkSlotType, NumSlots)
SELECT	CivUniqueBuildingType, 'GREATWORKSLOT_HERO', 0 FROM BuildingReplaces
WHERE ReplacesBuildingType = 'BUILDING_MONUMENT'
AND EXISTS (SELECT GreatWorkObjectType FROM GreatWorks WHERE GreatWorkObjectType = 'GREATWORKOBJECT_HERO');
*/
--

INSERT OR REPLACE INTO Types (Type, Kind)
VALUES	('BELIEF_SAILOR_INVESTITURE', 'KIND_BELIEF'),
		('MODIFIER_SAILOR_ALL_CITIES_SLOTS', 'KIND_MODIFIER'),
		('MODIFIER_SAILOR_ALL_PLAYERS_RELIC', 'KIND_MODIFIER');

INSERT OR REPLACE INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES	('MODIFIER_SAILOR_ALL_CITIES_SLOTS', 'COLLECTION_ALL_CITIES', 'EFFECT_ADJUST_EXTRA_GREAT_WORK_SLOTS'),
		('MODIFIER_SAILOR_ALL_PLAYERS_RELIC', 'COLLECTION_ALL_PLAYERS', 'EFFECT_GRANT_RELIC');

INSERT OR REPLACE INTO Beliefs (BeliefType, Name, Description, BeliefClassType)
VALUES	('BELIEF_SAILOR_INVESTITURE',
		'LOC_BELIEF_SAILOR_INVESTITURE_NAME',
		'LOC_BELIEF_SAILOR_INVESTITURE_DESCRIPTION',
		'BELIEF_CLASS_PANTHEON');

INSERT INTO BeliefModifiers (BeliefType, ModifierID)
VALUES	('BELIEF_SAILOR_INVESTITURE', 'SAILOR_INVESTITURE_SLOTS'),
		('BELIEF_SAILOR_INVESTITURE', 'SAILOR_INVESTITURE_RELIC');

INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId, Permanent)
VALUES	('SAILOR_INVESTITURE_SLOTS', 'MODIFIER_SAILOR_ALL_CITIES_SLOTS', 'CITY_FOLLOWS_PANTHEON_REQUIREMENTS', 1),
		('SAILOR_INVESTITURE_RELIC', 'MODIFIER_SAILOR_ALL_PLAYERS_RELIC', 'PLAYER_HAS_PANTHEON_REQUIREMENTS', 1);

INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES	('SAILOR_INVESTITURE_SLOTS', 'Amount', 1),
		('SAILOR_INVESTITURE_SLOTS', 'BuildingType', 'BUILDING_MONUMENT'),
		('SAILOR_INVESTITURE_SLOTS', 'GreatWorkSlotType', 'GREATWORKSLOT_RELIC'),
		('SAILOR_INVESTITURE_RELIC', 'Amount', 1);

-- Heroes & SS Modes
INSERT OR REPLACE INTO Building_GreatWorks (BuildingType, GreatWorkSlotType, NumSlots)
SELECT	CivUniqueBuildingType, 'GREATWORKSLOT_RELIC', 0 FROM BuildingReplaces WHERE ReplacesBuildingType = 'BUILDING_SHRINE'
AND	(
		EXISTS 
			(SELECT Kind FROM Kinds WHERE Kind = 'KIND_SECRETSOCIETY')
		OR EXISTS
			(SELECT Kind FROM Kinds WHERE Kind = 'KIND_HEROCLASS')
	);

UPDATE ModifierArguments SET Value = 'BUILDING_SHRINE' WHERE ModifierId = 'SAILOR_INVESTITURE_SLOTS' AND Name = 'BuildingType'
AND	(
		EXISTS 
			(SELECT Kind FROM Kinds WHERE Kind = 'KIND_SECRETSOCIETY')
		OR EXISTS
			(SELECT Kind FROM Kinds WHERE Kind = 'KIND_HEROCLASS')
	);

UPDATE Beliefs SET Description = 'LOC_BELIEF_SAILOR_INVESTITURE_DESCRIPTION_MODE' WHERE BeliefType = 'BELIEF_SAILOR_INVESTITURE'
AND	(
		EXISTS 
			(SELECT Kind FROM Kinds WHERE Kind = 'KIND_SECRETSOCIETY')
		OR EXISTS
			(SELECT Kind FROM Kinds WHERE Kind = 'KIND_HEROCLASS')
	);
--

-- // Relic slot fix.
-- Discovered while testing this mod with Valkrana mod. Thanks to Leugi for the fix suggestion.
-- Initializes any buildings that are granted a relic slot.
INSERT OR IGNORE INTO Building_GreatWorks (BuildingType, GreatWorkSlotType, NumSlots)
SELECT BuildingType, 'GREATWORKSLOT_RELIC', 0
FROM Buildings WHERE BuildingType IN
	(SELECT Value FROM ModifierArguments WHERE Name = 'BuildingType' AND ModifierId IN
		(SELECT ModifierId FROM Modifiers WHERE ModifierType IN
			(SELECT ModifierType FROM DynamicModifiers WHERE EffectType = 'EFFECT_ADJUST_EXTRA_GREAT_WORK_SLOTS')
		)
	)
	OR BuildingType IN
	(SELECT CivUniqueBuildingType FROM BuildingReplaces WHERE ReplacesBuildingType IN
		(SELECT Value FROM ModifierArguments WHERE Name = 'BuildingType' AND ModifierId IN
			(SELECT ModifierId FROM Modifiers WHERE ModifierType IN
				(SELECT ModifierType FROM DynamicModifiers WHERE EffectType = 'EFFECT_ADJUST_EXTRA_GREAT_WORK_SLOTS')
			)
		)
	);

-- // Cleanup
DELETE FROM GoodyHutSubTypes WHERE SubTypeGoodyHut = 'GOODYHUT_ONE_RELIC';
DROP TABLE Temp_Sailor_RelicsPlus;

-- // Testing
--UPDATE GoodyHuts SET Weight = 0 WHERE GoodyHutType != 'GOODYHUT_SAILOR_RELIC' AND GoodyHutType != 'SAILOR_RUIN_GOODY';