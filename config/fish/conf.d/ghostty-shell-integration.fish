# If using distrobox, it's quite possible that the variables could be set
# but inaccessible.
# If using a Ghostty-derived terminal on macOS, the variables could be set
# but not what we expect them to be.
if set -q GHOSTTY_RESOURCES_DIR GHOSTTY_BIN_DIR
    and test -d $GHOSTTY_RESOURCES_DIR -a -d $GHOSTTY_BIN_DIR
    and not begin
        test (uname) = Darwin
        and test "$__CFBundleIdentifier" != "com.mitchellh.ghostty"
    end
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
    set --append fish_complete_path "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_completions.d"
    set --append PATH $GHOSTTY_BIN_DIR
end
