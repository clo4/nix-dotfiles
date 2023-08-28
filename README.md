# My simple nix-darwin & NixOS (WSL) configuration

This is my dead-simple configuration. Maybe something to take inspiration from
if you're trying to get set up with your own cross-platform NixOS, WSL, and
nix-darwin configuration!

This repo entirely supersedes [clo4/dotfiles](https://github.com/clo4/dotfiles).

## Structure

- `flake.nix` is where the systems are declared and the modules they need are
  defined
- `host/` stores the system configuration for each host
  - `common.nix` contains the configuration shared by each system
  - `<host>/default.nix` is the system-specific config
- `home/` stores my home-manager config
  - `common.nix` is the configuration shared by each system
  - `<host>/default.nix` is the system-specific config
- `programs/*.nix` is where I move my program configuration when it gets too
  long to store in my home config

When I eventually have to define my own modules for whatever reason, they'll go
in either `modules/host` or `modules/home`.

## My PC situation

The GPU in my Intel machine has died entirely, so until I resolve that (which,
to be clear, I don't have the money to do right now) I can't make any
updates to my WSL config. So that's on pause. My Mac, which was already my
main device, is now my only device... yay.
