# ===================================================================
# STARSHIP PROMPT
# ===================================================================
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# ===================================================================
# WELCOME MESSAGE
# ===================================================================
if [[ -t 1 ]]; then
    echo -e "\n🚀 Welcome back, Kopy!\n"
    echo "Dev Stack Ready:"
    command -v java     &> /dev/null && echo "  ✓ Java $(java -version 2>&1 | head -n1 | awk -F'\"' '{print $2}')"
    command -v kotlin   &> /dev/null && echo "  ✓ Kotlin $(kotlin -version 2>&1 | awk '{print $3}')"
    command -v dotnet   &> /dev/null && echo "  ✓ .NET $(dotnet --version)"
    command -v go       &> /dev/null && echo "  ✓ Go $(go version | awk '{print $3}')"
    command -v node     &> /dev/null && echo "  ✓ Node $(node -v)"
    command -v bun      &> /dev/null && echo "  ✓ Bun $(bun -v)"
    command -v pdflatex &> /dev/null && echo "  ✓ LaTeX $(pdflatex --version | head -n1 | awk '{print $2}')"

    if command -v mise &> /dev/null; then
        active_count=$(mise current 2>/dev/null | grep -c .)
        installed_count=$(mise ls --installed 2>/dev/null | grep -c .)
        echo ""
        echo "Mise ($active_count active · $installed_count installed):"
        { mise current      2>/dev/null | sed 's/^/CUR /';
          mise ls --installed 2>/dev/null | sed 's/^/ALL /'; } | \
        awk '
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
        unset active_count installed_count
    fi
    echo ""
fi
