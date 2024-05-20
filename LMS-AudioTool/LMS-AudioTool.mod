return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`LMS-AudioTool` encountered an error loading the Darktide Mod Framework.")

		new_mod("LMS-AudioTool", {
			mod_script       = "LMS-AudioTool/scripts/mods/LMS-AudioTool/LMS-AudioTool",
			mod_data         = "LMS-AudioTool/scripts/mods/LMS-AudioTool/LMS-AudioTool_data",
			mod_localization = "LMS-AudioTool/scripts/mods/LMS-AudioTool/LMS-AudioTool_localization",
		})
	end,
	packages = {},
}
