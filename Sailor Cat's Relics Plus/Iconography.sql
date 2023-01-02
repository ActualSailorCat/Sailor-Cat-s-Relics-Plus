/*
INSERT INTO IconTextureAtlases
		(Name,								Baseline,	IconSize,	IconsPerRow, IconsPerColumn,	Filename)
VALUES	('ATLAS_ICON_GOVERNOR_YRYR',		0,			32,			8,			 1,					'Sailor_YRYR_Governors32'),
		('ATLAS_ICON_GOVERNOR_YRYR',		0,			64,			8,			 1,					'Sailor_YRYR_Governors64'),
		-- CityBanner Meters
		('ATLAS_ICON_GOVERNOR_YRYR_FILL',	0,			32,			9,			 1,					'Sailor_YRYR_Governors_Fill32'),
		('ATLAS_ICON_GOVERNOR_YRYR_SLOT',	0,			32,			9,			 1,					'Sailor_YRYR_Governors_Slot32'),
		('ATLAS_ICON_GOVERNOR_YRYR_FILL',	6,			22,			9,			 1,					'Sailor_YRYR_Governors_Fill22'),
		('ATLAS_ICON_GOVERNOR_YRYR_SLOT',	6,			22,			9,			 1,					'Sailor_YRYR_Governors_Slot22'),
		-- Promotions Screen	
		('ATLAS_ICON_GOVERNOR_YRYR_PROMO',	0,			24,			9,			 1,					'Sailor_YRYR_GovernorPromotions');
*/
INSERT OR REPLACE INTO IconDefinitions
		(Name,								Atlas,							"Index")
VALUES	('ICON_BELIEF_SAILOR_INVESTITURE',	'ICON_ATLAS_BELIEFS_PATHEON',	4);