# ===================================================================
# COMMAND OVERRIDES   (same name as a real command + extra flags)
# These are functions (not abbrs) so they wrap transparently. Self-referential
# ones use `command` to avoid infinite recursion.
# Ported from bash/30-aliases.bash + 60-tools.bash.
# ===================================================================

# --- Listing: prefer eza, fall back to coreutils ls -----------------
if type -q eza
    function ls --wraps eza --description 'eza with icons'
        eza --icons $argv
    end
    function ll --wraps eza --description 'eza long+all+git'
        eza -lah --icons --git $argv
    end
    function la --wraps eza --description 'eza all'
        eza -a --icons $argv
    end
    function lt --wraps eza --description 'eza sorted by mtime'
        eza -lah --icons --git --sort=modified $argv
    end
    function lsize --wraps eza --description 'eza sorted by size'
        eza -l --icons --sort=size --reverse $argv
    end
    function l --wraps eza
        eza --icons $argv
    end
    function tree --wraps eza --description 'eza tree'
        eza --tree --icons $argv
    end
else
    function ls;    command ls --color=auto $argv; end
    function ll;    command ls -lh $argv; end
    function la;    command ls -lAh $argv; end
    function l;     command ls -CF $argv; end
    function lt;    command ls -lhtr $argv; end
    function lsize; command ls -lhS $argv; end
    function tree;  command tree -C $argv; end
end

# --- cat → bat (plain, no pager) ------------------------------------
if type -q bat
    function cat --wraps bat --description 'bat plain, no pager'
        command bat --style=plain --paging=never $argv
    end
    function bathelp --description 'bat as a --help pager'
        command bat --plain --language=help $argv
    end
    # `help <cmd>` → pretty-print that command's --help through bat.
    # (Shadows fish's `help` builtin, which opens web docs — remove if unwanted.)
    function help --description 'pretty --help via bat'
        $argv --help 2>&1 | bathelp
    end
end

# --- grep family: keep colour ---------------------------------------
function grep;  command grep --color=auto $argv; end
function egrep; command grep -E --color=auto $argv; end
function fgrep; command grep -F --color=auto $argv; end

# --- Safety nets ----------------------------------------------------
function rm;    command rm -I --preserve-root $argv; end
function cp;    command cp -i $argv; end
function mv;    command mv -i $argv; end
function mkdir; command mkdir -pv $argv; end
function chown; command chown --preserve-root $argv; end
function chmod; command chmod --preserve-root $argv; end
function chgrp; command chgrp --preserve-root $argv; end

# --- Human-readable sizes ------------------------------------------
function df; command df -h $argv; end
function du; command du -h $argv; end

# --- Misc -----------------------------------------------------------
function pgrep; command pgrep -l $argv; end
function g++;   command g++ -std=c++20 -Wall -Wextra $argv; end
