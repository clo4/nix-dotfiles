local session_vars="$HOME/.local/share/zsh/hm-session-vars.sh"

if [[ -f $session_vars && -r $session_vars ]]; then
    source $session_vars
fi

# In order to keep ZSH as the login shell but still use
# Fish interactively, this snippet will execute Fish if
# none of the parent processes were Fish. Unless I run into
# some serious issues, I've consolidated on all shells
# launching ZSH, which does some amount of generic init,
# then puts me into Fish if the session is interactive.
#
# .zshenv is the first file that ZSH executes, and it executes
# it unconditionally. Putting this snippet in .zshenv allows
# the entire init to be skipped for non-ZSH sessions.
#
# NOTE: this doesn't handle `nix shell` at all becuase
# it's difficult to determine if the current shell was
# directly invoked by it. Instead, I use a wrapper function
# in Fish that appends `--command $(status fish-path)`.

if [[ -o interactive ]]; then
  if type fish >/dev/null; then
    ppid=$$
    while [[ $ppid -gt 1 ]]; do
      if [[ $(ps -o comm= -p $ppid) =~ /fish$ ]]; then
        return
      fi
      ppid=$(ps -o ppid= -p $ppid)
    done
    SHELL=$(command -v fish)
    exec "$SHELL" -l
  else
    echo
    echo "  WARNING: fish not found in PATH - falling back to zsh"
    echo
  fi
fi

# Beyond this point, we're setting up ZSH. If Fish doesn't exist on PATH
# then I'll know that by now, so just set things up nicely.
