# clo4's configuration

This is my dead-simple configuration. Maybe something to take inspiration from
if you're getting stuck configuring your own Nix flake setup! I currently
actively maintain my nix-darwin and standalone Home Manager configurations, but
supporting NixOS or WSL would be as simple as adding another entry to `hosts`.

Traditional Nix system configuration requires a rebuild to apply, but I found
that this was slowing me down and disincentivising me from changing things on my
system. This time around, everything about the way my config is structured is to
allow me to iterate raplidly:

- Home Manager symlinks my config to the right location. This results in the
  normal instant feedback loop of editing your dotfiles, but with the certainty
  that you can reapply it at any point exactly the same way it is now.
- The flake uses [Blueprint](https://github.com/numtide/blueprint), which gets
  rid of all the glue code I would otherwise need. Creating hosts is as simple
  as creating a directory in `hosts`, or making a package, creating a file in
  `packages`.

Program configuration is all stored in [config](/config).

My shared Home Manager config applies this configuration:
[users/robert/home-configuration.nix](/users/robert/home-configuration.nix)

This configuration is applied per-host with tweaks on top of it: [hosts](/hosts)

## Custom stuff

I keep finding yaks to shave.

- Fish is my interactive shell, but all _initial_ environment setup is delegated
  to ZSH. This means the login shell is always guaranteed to be POSIX-enough to
  work, but I still get to benefit from using the _best_ shell. I'm particularly
  proud that the `$PATH` works flawlessly on my Darwin systems, which has been a
  known issue with Fish + Nix.
- I implemented a Fish plugin manager in Nix for declarative plugins with
  imperative configuration. Plugins don't clutter up my config, nor can they
  accidentally clobber any files. Updates are done by updating the Nix plugin
  package definitions.
- This config uses
  [mattwparas' fork of Helix](https://github.com/mattwparas/helix/tree/steel-event-system)
  with support for plugins, though I haven't set up or written any plugins yet.
  I had to fork it to get the Steel language server integration working.
- Homebrew is installed automatically and managed declaratively with
  [nix-homebrew](https://github.com/zhaofengli/nix-homebrew)
- Since fish is the best language for shell scripting, I wrote a custom command
  runner for fish functions. It replaces tools like `just` and common abuse of
  `make`. You just write fish functions in `run.fish`, then run them with `run`.
  This is also usable as `nix run github:clo4/nix-dotfiles#run`.
- My server hosts a Minecraft server using `virtualisation.oci-containers` with
  podman. The container is launched as root, but switched to a system
  user/group. Its data is stored in `/srv/minecraft/family`. It restarts every
  day at 4 am local-time. It has a DDNS client. I think this may be the best
  reference configuration for setting up a Minecraft server on NixOS.
- I built a simple DDNS client for Cloudflare to keep my DNS record up to date
  with my home internet's IP address. It's a simple Go program, it compiles
  quickly, it caches IP to minimise useless updates. The credentials are stored
  encrypted with Agenix.

More of my custom things will be documented in the future.

## Hosts

- `macmini`
  - This is my main dev machine. Most configuration will be up-to-date for it.
    It's a nix-darwin system that also configures my user using Home Manager.
- `macbook-air`
  - This is my secondary computer. It's owned by my partner, so I haven't
    installed nix-darwin. Instead, this is a standalone configuration.
- `homeserver1`
  - This is my personal server. It's a Minisforum NAB6 Lite running an Intel
    Core i5 12600, so it uses <9w at idle.
  - Hopefully not the first of many, but knowing me, it's best to start adding
    versioning to the names.

### Building and switching

As a way to make sure I always get the commands right, there's a command runner
included in the developer environment named `run`. The following lines are
examples of how to switch config for each of the hosts.

```fish
run server switch
run macmini switch
run macbook switch
```

Instead of switch, the verb `build` can also be used.

Switching `macmini` and `macbook` will attempt to switch the currently active
device, but switching `server` will cause the server to rebuild and switch
remotely, allowing the command to be run from whatever device is being used
without an SSH connection. The only requirement is that Tailscale is up and
connected.

### Bootstrapping homeserver1

This isn't included in `run.fish` because it has to be executed from the system
itself or over SSH.

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:clo4/nix-dotfiles/vps#homeserver1-install
```
