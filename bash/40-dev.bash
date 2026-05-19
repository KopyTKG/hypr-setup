# ===================================================================
# NODE/NPM/BUN/DENO ALIASES
# ===================================================================
# NPM
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nrun='npm run'
alias nstart='npm start'
alias ndev='npm run dev'
alias nbuild='npm run build'
alias ntest='npm test'
alias nup='npm update'
alias nout='npm outdated'
alias nls='npm list --depth=0'
alias nclean='rm -rf node_modules package-lock.json && npm install'

# Bun
alias bi='bun install'
alias ba='bun add'
alias bad='bun add --dev'
alias br='bun run'
alias bx='bunx'
alias bdev='bun run dev'
alias bbuild='bun run build'
alias btest='bun test'
alias bup='bun update'

# Deno
alias dr='deno run'
alias dt='deno task'
alias dtest='deno test'
alias dfmt='deno fmt'
alias dlint='deno lint'

# Yarn
alias ya='yarn add'
alias yad='yarn add --dev'
alias yr='yarn run'
alias yup='yarn upgrade'

# pnpm
alias pi='pnpm install'
alias pa='pnpm add'
alias pr='pnpm run'

# React/Next.js
alias cra='bunx create-react-app'
alias cnext='bunx create-next-app'
alias cvite='bunx create-vite'

# ===================================================================
# PYTHON ALIASES
# ===================================================================
alias py='python'
alias py3='python3'
alias pip='pip3'
alias venv='python -m venv'
alias activate='source venv/bin/activate'

function mkvenv() {
    python -m venv ${1:-.venv}
    source ${1:-.venv}/bin/activate
    pip install --upgrade pip
}

# ===================================================================
# GO ALIASES
# ===================================================================
alias gor='go run'
alias gob='go build'
alias got='go test'
alias goi='go install'
alias gom='go mod'
alias gomt='go mod tidy'
alias gomv='go mod vendor'
alias gog='go get'

# ===================================================================
# JAVA ALIASES
# ===================================================================
alias jr='java'
alias jc='javac'
# Maven
alias mvnc='mvn clean'
alias mvnci='mvn clean install'
alias mvnt='mvn test'
alias mvnp='mvn package'
# Gradle (project wrapper preferred)
alias gw='./gradlew'

# ===================================================================
# KOTLIN ALIASES
# ===================================================================
alias ktc='kotlinc'
alias ktrun='kotlin'

# ===================================================================
# C# / .NET ALIASES
# ===================================================================
alias dn='dotnet'
alias dnr='dotnet run'
alias dnb='dotnet build'
alias dnt='dotnet test'
alias dnn='dotnet new'
alias dnw='dotnet watch run'
alias dnp='dotnet publish'
alias dnres='dotnet restore'

# ===================================================================
# REACT NATIVE ALIASES
# ===================================================================
alias rn='npx react-native'
alias rna='npx react-native run-android'
alias rni='npx react-native run-ios'
alias rns='npx react-native start'
alias rnc='npx @react-native-community/cli init'

# ===================================================================
# EXPO ALIASES
# ===================================================================
alias ex='npx expo'
alias exs='npx expo start'
alias exa='npx expo run:android'
alias exi='npx expo run:ios'
alias exb='npx expo prebuild'
alias eas='npx eas-cli'

# ===================================================================
# PREACT ALIASES
# ===================================================================
alias cpreact='bunx create-preact'

# ===================================================================
# LATEX ALIASES
# ===================================================================
alias tex='pdflatex'
alias xtex='xelatex'
alias lutex='lualatex'
alias bib='bibtex'
alias texmk='latexmk -pdf'
alias texmkclean='latexmk -c'

# ===================================================================
# C++ ALIASES
# ===================================================================
alias g++='g++ -std=c++20 -Wall -Wextra'
alias cmake-build='cmake -B build && cmake --build build'
