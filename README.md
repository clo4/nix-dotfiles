# My simple nix-darwin & NixOS (WSL) configuration

This is my dead-simple configuration. Maybe something to take inspiration from
if you're trying to get set up with your own cross-platform NixOS, WSL, and
nix-darwin configuration!

This repo entirely supersedes [clo4/dotfiles](https://github.com/clo4/dotfiles).

## Structure

The goal of the directory structure is to be as simple and consistent as
possible.

- [`flake.nix`](./flake.nix) is where the systems are declared and the modules
  they need are defined.
- [`shared/`](./shared) defines the configuration shared between multiple hosts.
  - `home.nix` contains the home configuration shared by each system
  - `host.nix` contains the system configuration shared by each system
  - `brew.nix` defines homebrew-specific stuff for Macs that use nix-darwin.
- [`systems/`](./systems) stores the configuration for each machine.
  - `<host>/home.nix` is the system-specific home config
  - `<host>/host.nix` is the system-specific host config
- [`programs/`](./programs) is where I move my program configuration when it
  gets too long to store in my home config. By default, programs are configured
  wherever is most appropriate, and when they start to take up too much room or
  require certain things enabled on particular systems, I move the configuration
  to a module and put it in this directory.
- [`modules/`](./modules) is where modules are defined. This is both system and
  home-manager modules. These modules are imported by the respective `common`
  files, which allows any file that uses the common settings to use the modules
  too.

## My PC situation

The GPU in my Intel machine has died entirely, so until I resolve that (which,
to be clear, I don't have the money to do right now) I can't make any updates to
my WSL config. So that's on pause. My Mac, which was already my main device, is
now my only device... yay.

## Templates

> I'm going to rewrite this section once my workflow is a little more stable!

## Commit messages

I prefer to use the format of conventional commits but with tags that make sense
in this context.

- For changes to host-specific configuration, use the label `<host>:`, e.g.
  `macmini:`
- For changes to common configuration, use either `home:` or `host:` depending
  on what is changing.
- For changes to program configuration, use the name of the program, e.g.
  `fish:`
- For changes to modules, use the name of the module, e.g. `hammerspoon:`
