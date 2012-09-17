
ICDTrack = {};
ICDTrack.default_options = {
	track_buffs = {},
	best_times = {},
};


function ICDTrack.OnReady()

	-- set up default options
	_G.ICDTrackPrefs = _G.ICDTrackPrefs or {};

	for k,v in pairs(ICDTrack.default_options) do
		if (not _G.ICDTrackPrefs[k]) then
			_G.ICDTrackPrefs[k] = v;
		end
	end
end

function ICDTrack.OnEvent(frame, event, ...)

	if (event == 'ADDON_LOADED') then
		local name = ...;
		if name == 'ICDTrack' then
			ICDTrack.OnReady();
		end
		return;
	end

	if (event == 'COMBAT_LOG_EVENT_UNFILTERED') then
		local ts, event, hideCaster, sourceGuid = ...;
		local us = UnitGUID("player");
		if ((us == sourceGuid) and (event == 'SPELL_AURA_APPLIED')) then
			local spellId = select(12, ...);
			print("aura applied: "..spellId);
		end
	end
end

-- ##################################################################

ICDTrack.EventFrame = CreateFrame("Frame");
ICDTrack.EventFrame:Show();
ICDTrack.EventFrame:SetScript("OnEvent", ICDTrack.OnEvent);
ICDTrack.EventFrame:SetScript("OnUpdate", ICDTrack.OnUpdate);
ICDTrack.EventFrame:RegisterEvent("ADDON_LOADED");
ICDTrack.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
