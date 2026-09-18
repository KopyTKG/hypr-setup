hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm-app -- hypridle")
    hl.exec_cmd("uwsm-app -- mako")
    hl.exec_cmd("uwsm-app -- waybar")
    hl.exec_cmd("uwsm-app -- fcitx5 --disable notificationitem")
    hl.exec_cmd("uwsm-app -- swaybg -i ~/.config/hypr/theme/background.jpg -m fill")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- Slow app launch fix -- set systemd vars. elephant starts before this runs,
    -- so restart it to pick up the session env (XDG_DATA_DIRS → flatpak apps in walker).
    hl.exec_cmd("systemctl --user import-environment $(env | cut -d'=' -f 1)"
        .. " && dbus-update-activation-environment --systemd --all"
        .. " && systemctl --user try-restart elephant.service")
end)
