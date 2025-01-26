# In order to keep ZSH as the login shell but still use
# Fish interactively, this snippet will execute Fish if
# none of the parent processes were Fish. Unless I run into
# some serious issues, I've consolidated on all shells
# launching ZSH, which does some amount of generic init,
# then puts me into Fish if the session is interactive.
#
# zshenv is the first file that ZSH executes, but a standalone
# Home Manager installation adds the Nix setup to zshrc,
# so the necessary setup would be skipped in that system.
# Everything that zshenv does can also be done in zshrc,
# unless it has to be done unconditionally for non-interactive
# shells - in which case that's also the best spot for it,
# since the spawned and exec'd fish shell will inherit
# the variables.
#
# NOTE: this doesn't handle `nix shell` at all becuase
# it's difficult to determine if the current shell was
# directly invoked by it. Instead, I use a wrapper function
# in Fish that appends `--command $(status fish-path)`.

if [[ -o interactive ]]; then
  found_fish=0
  if type fish >/dev/null; then
    ppid=$$
    while [[ $ppid -gt 1 ]]; do
      if [[ $(ps -o comm= -p $ppid) =~ /fish$ ]]; then
        found_fish=1
        break
      fi
      ppid=$(ps -o ppid= -p $ppid)
    done
    if [[ $found_fish -eq 0 ]]; then
      SHELL=$(command -v fish)
      exec "$SHELL" -l
    fi
  else
    echo
    echo "  WARNING: fish not found in PATH - falling back to zsh"
    echo
  fi
fi

# Beyond this point, we're setting up ZSH. If Fish doesn't exist on PATH
# then I'll know that by now, so just set things up nicely.

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# Removes duplicates by keeping the first occurrence of each item, left to right.
typeset -U path cdpath fpath manpath

for profile in ${(z)NIX_PROFILES}; do
    fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done

HISTFILE=$HOME/.local/share/zsh/.zsh_history
