# nix-dotfiles

Nix is extremely capable for writing configuration, but I found that things tended to become
complicated and difficult to change. I changed my program configuration less than I wanted to
because any change involved rebuilding my system and applying the result.

One thing I know about myself is that if there is any amount of friction between thinking about
doing something and actually doing that thing, I just... won't. So, I needed to remove as much
friction as possible.

The solution, for me, is to use Home Manager as a declarative symlink manager. Instead of declaring
the configuration that I want to apply, I declare the locations on my system that I want a directory
to be linked to, and have HM generate the symlink to my config directory. This gives me all the
advantages of declarative *and* imperative configuration management.

This is still only finished for my Mac mini. Things may change when I start porting this
configuration to other computers.

