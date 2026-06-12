hl.window_rule({ name = "tag-thunar-rename",       match = { class = "(Thunar)", title = "(Rename)(.*)" },              tag = "+thunar" })
hl.window_rule({ name = "tag-thunar-rename2",      match = { class = "(thunar)", title = "(Rename)(.*)" },              tag = "+thunar" })
hl.window_rule({ name = "tag-thunar-progress",     match = { class = "(Thunar)", title = "(File Operation Progress)" }, tag = "+thunar" })
hl.window_rule({ name = "tag-thunar-progress2",    match = { class = "(thunar)", title = "(File Operation Progress)" }, tag = "+thunar" })
hl.window_rule({ name = "tag-thunar-save",         match = { title = "(Enter name of file to save to)(.*)" },           tag = "+thunar" })
hl.window_rule({ name = "tag-thunar-properties",   match = { title = "(.*)(Properties)" },                              tag = "+thunar" })
hl.window_rule({ name = "tag-thunar-portal",       match = { class = "(xdg-desktop-portal-gtk)" },                     tag = "+thunar" })

hl.window_rule({ name = "tag-music",               match = { class = "^(io.github.quodlibet.QuodLibet)$" },             tag = "+music" })
hl.window_rule({ name = "tag-copyq",               match = { class = "^(copyq)$" },                                     tag = "+copyq" })
hl.window_rule({ name = "tag-ts",                  match = { class = "^(TeamSpeak)$" },                                 tag = "+ts" })
hl.window_rule({ name = "tag-ts2",                 match = { class = "^(teamspeak-client)$" },                          tag = "+ts" })

hl.window_rule({ name = "suppress-maximize",       match = { class = ".*" },                                            suppress_event = "maximize" })

hl.window_rule({ name = "no-focus-empty",          match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, no_focus = true })
hl.window_rule({ name = "no-focus-steam-toast",    match = { class = "^(steam)$", title = "^(notificationtoasts_.*_desktop)$" }, no_focus = true })
hl.window_rule({ name = "float-steam",             match = { class = "^(steam)$" },                                    float = true })
hl.window_rule({ name = "monitor-steam",           match = { class = "^(steam)$", title = "^(Steam)$" },               monitor = 1 })

hl.window_rule({ name = "pin-float-center-thunar", match = { tag = "thunar" },                                         pin = true, float = true, center = true })

hl.window_rule({ name = "pin-float-pwvucontrol",   match = { class = "(com.saivert.pwvucontrol)" },                    pin = true, float = true })
hl.window_rule({ name = "pin-float-nm-conn-editor",match = { class = "(nm-connection-editor)" },                       pin = true, float = true })

hl.window_rule({ name = "float-ts",                match = { tag = "ts" },                                              float = true })
hl.window_rule({ name = "size-ts",                 match = { tag = "ts" },                                              size = { 662, 1036 } })

hl.window_rule({ name = "float-thunderbird",       match = { class = "^(org.mozilla.Thunderbird)$" },                  float = true })
hl.window_rule({ name = "size-thunderbird",        match = { class = "^(org.mozilla.Thunderbird)$" },                  size = { 1122, 882 } })
hl.window_rule({ name = "size-thunderbird-send",   match = { class = "^(org.mozilla.Thunderbird)$", title = "^(Sending Message)$" }, size = { 470, 107 } })

hl.window_rule({ name = "float-music",             match = { tag = "music" },                                          float = true })
hl.window_rule({ name = "size-music",              match = { tag = "music" },                                          size = { 1215, 563 } })
hl.window_rule({ name = "monitor-music",           match = { tag = "music" },                                          monitor = 1 })
hl.window_rule({ name = "move-music",              match = { tag = "music" },                                          move = "700 514" })

hl.window_rule({ name = "float-lutris",            match = { class = "^(net.lutris.Lutris)$" },                        float = true })

hl.window_rule({ name = "float-steam-acolyte",     match = { title = "^(Steam Acolyte)$" },                            float = true, monitor = 1 })
hl.window_rule({ name = "size-steam-acolyte",      match = { title = "^(Steam Acolyte)$" },                            size = { 285, 500 } })

hl.window_rule({ name = "pin-float-center-copyq",  match = { tag = "copyq" },                                          pin = true, float = true, center = true })
hl.window_rule({ name = "size-copyq",              match = { tag = "copyq" },                                          size = { 800, 600 } })

hl.window_rule({ name = "no-screenshare-bitwarden",match = { class = "(librewolf)", title = "^(.*Bitwarden.*)$" },     no_screen_share = true })
hl.window_rule({ name = "no-screenshare-special",  match = { workspace = "special:magic" },                            no_screen_share = true })
