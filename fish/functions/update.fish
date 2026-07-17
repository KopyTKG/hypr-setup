function update --description 'Update system (pacman/AUR) + flatpak + mise, snapshot-bracketed'
    # --- snapper pre snapshot (only if snapper + a `root` config exist) -----
    set -l pre
    if type -q snapper; and sudo snapper -c root list &>/dev/null
        set pre (sudo snapper -c root create --type pre --cleanup-algorithm number \
            --print-number --description "system update"); or return 1
    end

    # --- System + AUR: yay covers the pacman repos too ----------------------
    if type -q yay
        yay -Syyu --noconfirm --useask --cleanafter
    else if type -q pacman
        sudo pacman -Syyu --noconfirm
    end

    # --- Flatpak (no-op if not installed) -----------------------------------
    if type -q flatpak
        flatpak update -y
        flatpak uninstall --unused -y
    end

    # --- mise-managed runtimes (the SUPER+ALT+SPACE › Install › mise flow) ---
    if type -q mise
        mise upgrade
    end

    echo
    echo "Note: ProtonGE and Chromium web-apps update on their own schedule —"
    echo "      re-run their installers from SUPER+ALT+SPACE › Install to bump them."

    # --- snapper post snapshot ---------------------------------------------
    if set -q pre[1]; and test -n "$pre"
        sudo snapper -c root create --type post --pre-number "$pre" \
            --cleanup-algorithm number --description "system update"
    end

    # Refresh the waybar update badge (should now drop to zero / hide).
    type -q arch-update-check; and arch-update-check >/dev/null
end
