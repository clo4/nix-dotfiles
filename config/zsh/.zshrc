# In order to keep ZSH as the login shell but still use
# Fish interactively, this snippet will execute Fish if
# none of the parent processes were Fish.
#
# Terminal emulators should be manually configured to launch
# Fish, or better yet, use wait4path. This provides a fallback
# for SSH sessions and other programs that have not been
# configured.
#
# NOTE: this doesn't handle `nix shell` at all becuase
# it's difficult to determine if the current shell was
# directly invoked by it. Instead, I use a wrapper function
# in Fish that appends `--command $(status fish-path)`.

if [[ -o interactive ]]; then
    ppid=$$
    while [[ $ppid -gt 1 ]]; do
        if [[ $(ps -o comm= -p $ppid) =~ /fish$ ]]; then
            return
        fi
        ppid=$(ps -o ppid= -p $ppid)
    done
    SHELL=$(command -v fish)
    exec "$SHELL" -l
fi
