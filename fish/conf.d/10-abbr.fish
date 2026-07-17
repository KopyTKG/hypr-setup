# ===================================================================
# ABBREVIATIONS   (ported from bash/30-aliases.bash + 40-dev.bash + 50-utils.bash)
# Fish abbrs expand inline as you type — hit space/enter to see the full command.
# Command-name overrides (ls, grep, rm, cat, …) live in 20-overrides.fish.
# ===================================================================

# --- Navigation -----------------------------------------------------
abbr -a -- .. 'cd ..'
abbr -a -- ... 'cd ../..'
abbr -a -- .... 'cd ../../..'
abbr -a -- ..... 'cd ../../../..'
abbr -a reload 'exec fish'          # was `source ~/.bashrc`

# --- System monitoring ---------------------------------------------
abbr -a ports 'netstat -tulanp'
abbr -a meminfo 'free -mth'
abbr -a psmem 'ps auxf | sort -nr -k 4 | head -10'
abbr -a pscpu 'ps auxf | sort -nr -k 3 | head -10'
abbr -a vaultInfo 'sudo mdadm --detail /dev/md0'
abbr -a raidStatus 'sudo mdadm --detail --scan'

# --- Git ------------------------------------------------------------
abbr -a lz lazygit
abbr -a g git
abbr -a gs 'git status'
abbr -a gss 'git status -s'
abbr -a ga 'git add'
abbr -a gaa 'git add --all'
abbr -a gc 'git commit -m'
abbr -a gca 'git commit --amend'
abbr -a gp 'git push'
abbr -a push 'git push'
abbr -a gpl 'git pull'
abbr -a pull 'git pull'
abbr -a gf 'git fetch'
abbr -a fetch 'git fetch'
abbr -a gl 'git log --oneline --graph --decorate -10'
abbr -a gla 'git log --oneline --graph --decorate --all'
abbr -a gd 'git diff'
abbr -a gds 'git diff --staged'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gb 'git branch'
abbr -a gba 'git branch -a'
abbr -a gbd 'git branch -d'
abbr -a gm 'git merge'
abbr -a gr 'git rebase'
abbr -a gst 'git stash'
abbr -a gstp 'git stash pop'
abbr -a gstl 'git stash list'

# --- Docker ---------------------------------------------------------
abbr -a d docker
abbr -a dps 'docker ps'
abbr -a dpsa 'docker ps -a'
abbr -a di 'docker images'
abbr -a dlog 'docker logs -f'
abbr -a dlogs 'docker logs -f'
abbr -a dex 'docker exec -it'
abbr -a dstop 'docker stop'
abbr -a dstart 'docker start'
abbr -a drm 'docker rm'
abbr -a drmi 'docker rmi'
abbr -a dprune 'docker system prune -af'
abbr -a dstat 'docker stats --no-stream'
abbr -a dc 'docker-compose'
abbr -a dcup 'docker-compose up -d'
abbr -a dcdown 'docker-compose down'
abbr -a dclog 'docker-compose logs -f'
abbr -a dcrestart 'docker-compose restart'

# --- Node / npm / bun / deno / yarn / pnpm --------------------------
abbr -a ni 'npm install'
abbr -a nid 'npm install --save-dev'
abbr -a nig 'npm install -g'
abbr -a nrun 'npm run'
abbr -a nstart 'npm start'
abbr -a ndev 'npm run dev'
abbr -a nbuild 'npm run build'
abbr -a ntest 'npm test'
abbr -a nup 'npm update'
abbr -a nout 'npm outdated'
abbr -a nls 'npm list --depth=0'
abbr -a nclean 'rm -rf node_modules package-lock.json && npm install'
abbr -a bi 'bun install'
abbr -a ba 'bun add'
abbr -a bad 'bun add --dev'
abbr -a br 'bun run'
abbr -a bx bunx
abbr -a bdev 'bun run dev'
abbr -a bbuild 'bun run build'
abbr -a btest 'bun test'
abbr -a bup 'bun update'
abbr -a dr 'deno run'
abbr -a dt 'deno task'
abbr -a dtest 'deno test'
abbr -a dfmt 'deno fmt'
abbr -a dlint 'deno lint'
abbr -a ya 'yarn add'
abbr -a yad 'yarn add --dev'
abbr -a yr 'yarn run'
abbr -a yup 'yarn upgrade'
abbr -a pi 'pnpm install'
abbr -a pa 'pnpm add'
abbr -a pr 'pnpm run'
abbr -a cra 'bunx create-react-app'
abbr -a cnext 'bunx create-next-app'
abbr -a cvite 'bunx create-vite'
abbr -a cpreact 'bunx create-preact'

# --- Python ---------------------------------------------------------
abbr -a py python
abbr -a py3 python3
abbr -a pip pip3
abbr -a venv 'python -m venv'
abbr -a activate 'source venv/bin/activate.fish'   # fish-native venv activate

# --- Go -------------------------------------------------------------
abbr -a gor 'go run'
abbr -a gob 'go build'
abbr -a got 'go test'
abbr -a goi 'go install'
abbr -a gom 'go mod'
abbr -a gomt 'go mod tidy'
abbr -a gomv 'go mod vendor'
abbr -a gog 'go get'

# --- Java / Maven / Gradle / Kotlin ---------------------------------
abbr -a jr java
abbr -a jc javac
abbr -a mvnc 'mvn clean'
abbr -a mvnci 'mvn clean install'
abbr -a mvnt 'mvn test'
abbr -a mvnp 'mvn package'
abbr -a gw './gradlew'
abbr -a ktc kotlinc
abbr -a ktrun kotlin

# --- C# / .NET ------------------------------------------------------
abbr -a dn dotnet
abbr -a dnr 'dotnet run'
abbr -a dnb 'dotnet build'
abbr -a dnt 'dotnet test'
abbr -a dnn 'dotnet new'
abbr -a dnw 'dotnet watch run'
abbr -a dnp 'dotnet publish'
abbr -a dnres 'dotnet restore'

# --- React Native / Expo --------------------------------------------
abbr -a rn 'npx react-native'
abbr -a rna 'npx react-native run-android'
abbr -a rni 'npx react-native run-ios'
abbr -a rns 'npx react-native start'
abbr -a rnc 'npx @react-native-community/cli init'
abbr -a ex 'npx expo'
abbr -a exs 'npx expo start'
abbr -a exa 'npx expo run:android'
abbr -a exi 'npx expo run:ios'
abbr -a exb 'npx expo prebuild'
abbr -a eas 'npx eas-cli'

# --- LaTeX ----------------------------------------------------------
abbr -a tex pdflatex
abbr -a xtex xelatex
abbr -a lutex lualatex
abbr -a bib bibtex
abbr -a texmk 'latexmk -pdf'
abbr -a texmkclean 'latexmk -c'

# --- C / C++ / CMake ------------------------------------------------
abbr -a cmake-build 'cmake -B build && cmake --build build'

# --- Dev utilities --------------------------------------------------
abbr -a serve 'python -m http.server'
abbr -a serve-bun 'bunx serve'
abbr -a fhere 'find . -name'
abbr -a grephere 'grep -r'
abbr -a ka killall
