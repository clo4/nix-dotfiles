function fish_greeting
    if test -n "$FISH_GREETING_CHECK_SUDO_TOUCHID"
        and not grep -qE '^auth\\s+sufficient\\s+pam_tid\\.so' /etc/pam.d/sudo_local
        gum style \
            --foreground 3 \
            --border-foreground 1 \
            --bold \
            --border rounded \
            --align center \
            --width 50 \
            --margin "1 3" \
            --padding "1 4" \
            'Touch ID will not work with sudo until the system configuration has been reapplied.'
        echo
    end

    if string match -q "/nix/store/*" "$NIX_CONFIG_DIR"
        gum style \
            --foreground 3 \
            --border-foreground 1 \
            --bold \
            --border rounded \
            --align center \
            --width 50 \
            --margin "1 3" \
            --padding "1 4" \
            'Configuration symlinked to /nix/store.
You should set a config directory.'
        echo
    end
end
