# My simple nix-darwin & NixOS configuration

This is my dead-simple configuration. Maybe something to take inspiration from
if you're trying to get set up with your own cross-platform NixOS, WSL, and
nix-darwin configuration!

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

## To do

- I use Alacritty on Windows (not because I want to, I just haven't bothered
  setting up WezTerm properly). The configuration can be managed by home-manager
  too, although I'm not 100% sure that's a good idea.
- Need to configure my Mac's dock and Finder settings
