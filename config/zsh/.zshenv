local session_vars="$HOME/.local/share/zsh/hm-session-vars.sh"

if [[ -f $session_vars && -r $session_vars ]]; then
    source $session_vars
fi

