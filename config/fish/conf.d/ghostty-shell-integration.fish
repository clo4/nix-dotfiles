# If using distrobox, it's quite possible that the variables could be set
# but inaccessible.
if set -q GHOSTTY_RESOURCES_DIR GHOSTTY_BIN_DIR
    and test -d $GHOSTTY_RESOURCES_DIR -a -d $GHOSTTY_BIN_DIR
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
    set --append fish_complete_path "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_completions.d"
    set --append PATH $GHOSTTY_BIN_DIR
end
