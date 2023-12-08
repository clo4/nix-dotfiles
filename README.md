# My simple nix-darwin & NixOS (WSL) configuration

This is my dead-simple configuration. Maybe something to take inspiration from
if you're trying to get set up with your own cross-platform NixOS, WSL, and
nix-darwin configuration!

This repo entirely supersedes [clo4/dotfiles](https://github.com/clo4/dotfiles).

## License

This repository is public domain. You can copy/paste any code from it that you
want. I don't believe that something as small and inconsequential as my
computer's configuration should have any protections applied to it - this is
stuff we should be sharing freely to improve everyone's setups! If you find
anything in this repo that you like, feel free to take it and use it anywhere.

Any code in this repository that is under another license (at time of writing,
there is none) will have the appropriate license above it and the section of
code that the license applies to will be clearly delineated.

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

## My Nix Workflow

There are projects I want to contribute to that don't use Nix, but I want to
keep all the tools local to the project so I don't pollute my global
configuration. I _could_ do this using `shell.nix` or something like that, but
flakes are a much better solution. Unfortunately, flakes need to be checked into
the repository, so that's inconvenient.

The solution I came up with is to create a `.flake/` directory. This is a self
contained git repository, in the root of the project's repo. This is globally
ignored by Git so it will never be checked in. Using this, you can simply `cd`
into it, make any changes you like, and run a shell from it with
`nix shell .flake`. It's a really simple workflow!

To make this work, this repo contains a template (`templates/untracked-flake`)
and a fish function (`mkflake`). Those are the only additional things required,
because you can use the tooling you already know for the rest.

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
