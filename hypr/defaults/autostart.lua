hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm-app -- hypridle")
    hl.exec_cmd("uwsm-app -- mako")
    hl.exec_cmd("uwsm-app -- waybar")
    hl.exec_cmd("uwsm-app -- fcitx5 --disable notificationitem")
    hl.exec_cmd("uwsm-app -- swaybg -i ~/.config/hypr/theme/background.jpg -m fill")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    -- animated wallpaper on top of swaybg, only on AC power (no-op until a video is picked)
    hl.exec_cmd("sleep 2 && uwsm-app -- arch-wallpaper watch")
    -- spot daemon: one window for every menu/dialog (only if this spot has one;
    -- older builds would read "daemon" as a config name).
    hl.exec_cmd("sh -c 'spot --help 2>&1 | grep -q -- --dismiss && exec uwsm-app -- spot daemon'")

    -- Slow app launch fix -- set systemd vars. elephant starts before this runs,
    -- so restart it to pick up the session env (XDG_DATA_DIRS → flatpak apps in walker).
    hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)"
        .. " && dbus-update-activation-environment --systemd --all"
        .. " && systemctl --user try-restart elephant.service")
end)
