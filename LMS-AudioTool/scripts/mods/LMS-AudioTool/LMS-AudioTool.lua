local mod = get_mod("LMS-AudioTool")
local Audio

local WwiseGameSyncSettings = require("scripts/settings/wwise_game_sync/wwise_game_sync_settings")
local PlayerUnitMusicParameterExtension = require("scripts/extension_systems/music_parameter/player_unit_music_parameter_extension")
local WwiseStateGroupObjective = require("scripts/managers/wwise_game_sync/wwise_state_groups/wwise_state_group_objective")

local cur_lms, old_lms
mod.replacement_audio = nil
mod.audio_id = nil

mod.set_replacement_audio = function(path)
    if type(path) ~= "string" then
        mod:error("set_replacement_audio: path must be a string.")
        return
    end

    mod.replacement_audio = path
end

mod.on_all_mods_loaded = function()
    Audio = get_mod("Audio")

    if not Audio then
        mod:error("Audio Plugin is not present, This utility will not work.")
        return
    end

    mod:hook_safe(PlayerUnitMusicParameterExtension, "_update_last_man_standing", function(self)
        if not mod:get("lmsat_enabled") then
            old_lms, cur_lms = nil, nil
            mod.audio_id = nil
            return
        end

        old_lms = cur_lms
        cur_lms = self._last_man_standing

        if cur_lms and not old_lms then
            mod:echo("last man standing: true")
            mod:echo(mod.replacement_audio)
            mod:echo(mod.audio_id)
            if mod.replacement_audio and not mod.audio_id then
                mod.audio_id = get_mod("Audio").play_file(mod.replacement_audio, {
                    audio_type = "music",
                    track_status = true,
                    loop = 0
                })
            end
        elseif not cur_lms and old_lms then
            if Audio.is_file_playing(mod.audio_id) then
                Audio.stop_file(mod.audio_id)
                mod.audio_id = nil
            end
            mod:echo("last man standing: false")
        end
    end)

    mod:hook(WwiseStateGroupObjective, "update", function(func, self, dt, t)
        if not mod:get("lmsat_enabled") or not mod.replacement_audio then func(self, dt, t) return end

        self.super.update(self, dt, t)

        local mission_objective_system = self._mission_objective_system
        local wwise_state = nil

        if not wwise_state and mission_objective_system then
            local objective_event_music = mission_objective_system:get_objective_event_music()

            if objective_event_music then
                wwise_state = objective_event_music
                self._old_objecitve_state = objective_event_music
                self._music_reset_timer = WwiseGameSyncSettings.music_state_reset_time
            else
                self._music_reset_timer = self._music_reset_timer - dt

                if self._music_reset_timer <= 0 then
                    self._old_objecitve_state = nil
                    wwise_state = nil
                else
                    wwise_state = self._old_objecitve_state
                end
            end
        end

        wwise_state = wwise_state or WwiseGameSyncSettings.default_group_state

        self:_set_wwise_state(wwise_state)
    end)
end