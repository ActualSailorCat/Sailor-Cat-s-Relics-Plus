local tTombofAnnihilation	= {}
local ruinIndex				= GameInfo.Improvements["IMPROVEMENT_SAILOR_RUIN"].Index;
local sContinentsInUse		= Map.GetContinentsInUse();
-- Gather applicable plots. Could be more refined, but this will do.
for _, k in ipairs(sContinentsInUse) do
	local sContinentPlots = Map.GetContinentPlots(k)
	for _, v in ipairs(sContinentPlots) do
		local sPlot = Map.GetPlotByIndex(v)
		if ImprovementBuilder.CanHaveImprovement(sPlot, ruinIndex, -1) then
			if sPlot:GetImprovementType() == -1 and sPlot:GetResourceType() == -1 and not sPlot:IsImpassable() and not sPlot:IsWater() and sPlot:GetUnitCount() < 1 then
				table.insert(tTombofAnnihilation, sPlot);
			end
		end
	end
end
-- // Roll for dungeon spawn.
local iPlayers = PlayerManager.GetWasEverAliveMajorsCount();
local iDungeonNum = math.ceil(iPlayers / 4);
function Sailor_Dungeoneering()
	local counter = 0;
	while counter < iDungeonNum do
		local iRand = Game.GetRandNum(#tTombofAnnihilation, "Ruin Spawner")+1
		for i, target in ipairs(tTombofAnnihilation) do
			if i == iRand then
				ImprovementBuilder.SetImprovementType(target, ruinIndex, -1);
			end
		end
		counter = counter + 1;
	end
end
LuaEvents.NewGameInitialized.Add(Sailor_Dungeoneering);
--GameEvents.OnGameTurnStarted.Add(Sailor_Dungeoneering);