# ===================================================================
# OH-MY-BASH CONFIGURATION
# ===================================================================
if [[ -d "$HOME/.oh-my-bash" ]]; then
    export OSH="$HOME/.oh-my-bash"

    OSH_THEME="lambda"
    ENABLE_CORRECTION="true"
    COMPLETION_WAITING_DOTS="true"
    HIST_STAMPS='yyyy-mm-dd'
    OMB_USE_SUDO=true
    OMB_PROMPT_SHOW_PYTHON_VENV=true
    OMB_PROMPT_SHOW_SPACK_ENV=true

    completions=(
      git
      ssh
      npm
      docker
    )

    aliases=(
      general
    )

    plugins=(
      git
      bashmarks
    )

    source "$OSH"/oh-my-bash.sh
fi
