ICDTrack = {};
ICDTrack.default_options = {
	track_buffs = {},
	best_times = {},
	last_times = {},
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
			ICDTrack.OnAura(ts, select(12, ...));
		end
	end
end

function ICDTrack.OnAura(ts, auraID)

	--print("Aura: "..auraID);

	if (_G.ICDTrackPrefs.track_buffs[auraID]) then
		local best = _G.ICDTrackPrefs.best_times[auraID];
		local last = _G.ICDTrackPrefs.last_times[auraID];

		_G.ICDTrackPrefs.last_times[auraID] = ts;

		local this = ts - last;

		local this_time = ICDTrack.FormatTime(this);
		local best_time = ICDTrack.FormatTime(best);
		local buff_name = ICDTrack.GetBuff(auraID);

		if (this < best) then
			_G.ICDTrackPrefs.best_times[auraID] = this;
			ICDTrack.out(string.format("Best proc for %s: %s", buff_name, this_time));
		else
			if (last == 0) then
				ICDTrack.out(string.format("First proc for %s", buff_name));
			else
				ICDTrack.out(string.format("Slow proc for %s: %s (best was %s)", buff_name, this_time, best_time));
			end
		end
	end
end

-- ############################# Start / Stop / Reset #############################

function ICDTrack.TrackAura(auraID)

	_G.ICDTrackPrefs.track_buffs[auraID] = 1;

	if (not _G.ICDTrackPrefs.last_times[auraID]) then
		_G.ICDTrackPrefs.last_times[auraID] = 0;
	end

	if (not _G.ICDTrackPrefs.best_times[auraID]) then
		_G.ICDTrackPrefs.best_times[auraID] = 99999;
	end

	local best = _G.ICDTrackPrefs.best_times[auraID];
	local best_time = ICDTrack.FormatTime(best);
	local buff_name = ICDTrack.GetBuff(auraID);

	if (best == 99999) then
		ICDTrack.out(string.format("Starting to track %s", buff_name));
	else
		ICDTrack.out(string.format("Resuming tracking of %s (best time: %s)", buff_name, best_time));
		ICDTrack.out(string.format("To reset timings: /icd reset %s", auraID));
	end
	ICDTrack.out(string.format("To stop tracking: /icd stop %s", auraID));
end

function ICDTrack.StopAura(auraID)
	_G.ICDTrackPrefs.track_buffs[auraID] = nil;
	
	local buff_name = ICDTrack.GetBuff(auraID);
	ICDTrack.out(string.format("Stopped tracking of %s", buff_name));
end

function ICDTrack.ResetAura(auraID)

	_G.ICDTrackPrefs.track_buffs[auraID] = 1;
	_G.ICDTrackPrefs.last_times[auraID] = 0;
	_G.ICDTrackPrefs.best_times[auraID] = 99999;

	local buff_name = ICDTrack.GetBuff(auraID);

	ICDTrack.out(string.format("Reset tracking of %s", buff_name));
end

-- ############################# Formatting #############################

function ICDTrack.out(str)
	print(str);
end

function ICDTrack.FormatTime(ts)
	return string.format("%.1fs", ts);
end

function ICDTrack.GetBuff(auraID)
	local name = GetSpellInfo(auraID);
	if (not name) then
		name = "Unknown Buff ("..auraID..")";
	end
	return name;
end

-- ############################# Slash Commands #############################

SLASH_ICDTRACK1 = '/icd';
SLASH_ICDTRACK2 = '/icdtrack';

function SlashCmdList.ICDTRACK(msg, editBox)

	local command, auraID = msg:match("^%s*(%S+)%s*(%d+)$");

	if (command == 'start') then
		return ICDTrack.TrackAura(tonumber(auraID));
	end
	if (command == 'stop') then
		return ICDTrack.StopAura(tonumber(auraID));
	end
	if (command == 'reset') then
		return ICDTrack.ResetAura(tonumber(auraID));
	end
	
	ICDTrack.out("ICDTrack Usage:");
	print("    /icd start 123 - Start tracking buff number 123");
	print("    /icd stop 123 - Stop tracking buff");
	print("    /icd reset 123 - Reset best times for buff");
end

-- ############################# Event Frame #############################

ICDTrack.EventFrame = CreateFrame("Frame");
ICDTrack.EventFrame:Show();
ICDTrack.EventFrame:SetScript("OnEvent", ICDTrack.OnEvent);
ICDTrack.EventFrame:SetScript("OnUpdate", ICDTrack.OnUpdate);
ICDTrack.EventFrame:RegisterEvent("ADDON_LOADED");
ICDTrack.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
