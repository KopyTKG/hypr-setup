# ===================================================================
# LONG-COMMAND NOTIFICATIONS
# When a command runs longer than $LONG_CMD_SECONDS and you are not looking at
# this terminal, send a desktop notification (mako via notify-send).
# Failures are sent as critical. Interactive programs are skipped.
# ===================================================================
set -q LONG_CMD_SECONDS; or set -g LONG_CMD_SECONDS 30
set -g __notify_skip nvim vim vi less man bat btop htop top yazi y lazygit lazydocker ssh fssh mosh tmux watch tail journalctl claude fzf gum

function __notify_long_cmd --on-event fish_postexec
    set -l code $status
    set -l secs (math --scale=0 "$CMD_DURATION / 1000")
    test $secs -ge $LONG_CMD_SECONDS; or return
    type -q notify-send; or return

    set -l words (string split -n ' ' -- $argv[1])
    test "$words[1]" = sudo; and set -e words[1]
    contains -- "$words[1]" $__notify_skip; and return

    # Skip when this terminal is the focused window (you are watching it anyway)
    if type -q hyprctl; and type -q jq
        set -l focused (hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty')
        set -l term (ps -o ppid= -p $fish_pid 2>/dev/null | string trim)
        test -n "$focused"; and test "$focused" = "$term"; and return
    end

    set -l cmd (string sub -l 80 -- $argv[1])
    if test $code -eq 0
        notify-send -a fish -u normal -i utilities-terminal "Done ($secs s)" "$cmd"
    else
        notify-send -a fish -u critical -i dialog-error "Failed: exit $code ($secs s)" "$cmd"
    end
end
