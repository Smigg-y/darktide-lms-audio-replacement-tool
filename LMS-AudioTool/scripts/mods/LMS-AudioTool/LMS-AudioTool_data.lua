local mod = get_mod("LMS-AudioTool")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_toggleable = false,
    options = {
        widgets = {
            {
                setting_id = "lmsat_enabled",
                type = "checkbox",
                default_value = true,
            }
        }
    }
}