function fish_greeting --description 'Welcome banner + dev-stack / mise summary'
    echo
    echo "🚀 Welcome back, Kopy!"
    echo
    echo "Dev Stack Ready:"
    type -q java     && echo "  ✓ Java "(java -version 2>&1 | head -n1 | awk -F'"' '{print $2}')
    type -q kotlin   && echo "  ✓ Kotlin "(kotlin -version 2>&1 | awk '{print $3}')
    type -q dotnet   && echo "  ✓ .NET "(dotnet --version)
    type -q go       && echo "  ✓ Go "(go version | awk '{print $3}')
    type -q node     && echo "  ✓ Node "(node -v)
    type -q bun      && echo "  ✓ Bun "(bun -v)
    type -q pdflatex && echo "  ✓ LaTeX "(pdflatex --version | head -n1 | awk '{print $2}')

    if type -q mise
        set -l active_count (mise current 2>/dev/null | grep -c .)
        set -l installed_count (mise ls --installed 2>/dev/null | grep -c .)
        echo
        echo "Mise ($active_count active · $installed_count installed):"
        begin
            mise current 2>/dev/null | sed 's/^/CUR /'
            mise ls --installed 2>/dev/null | sed 's/^/ALL /'
        end | awk '
            $1=="CUR" { active[$2] = $3; next }
            $1=="ALL" {
                tool = $2; ver = $3
                if (!(tool in seen)) { order[++n] = tool; seen[tool] = 1 }
                sep = (tool in versions ? ", " : "")
                if (ver == active[tool]) versions[tool] = versions[tool] sep "\033[1;38;2;224;175;104m" ver "\033[0m"
                else                     versions[tool] = versions[tool] sep ver
            }
            END {
                for (i = 1; i <= n; i++) printf "  ▸ %-8s %s\n", order[i], versions[order[i]]
            }'
    end
    echo
end
