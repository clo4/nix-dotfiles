# clo4's configuration

This is my dead-simple configuration, released to the public domain. Take inspiration if you're getting stuck configuring your own Nix flake setup. I currently actively maintain my nix-darwin and standalone Home Manager configurations, but supporting NixOS or WSL would be as simple as adding another entry to the `hosts` directory.

Traditional Nix system configuration encourages keeping configuration declarative, which requires a rebuild to apply new changes. I found this was discouraging me from making changes, so the structure is designed for faster iteration:

- Home Manager symlinks my config to the right location. This gives the normal instant feedback loop of editing dotfiles, with the certainty that it can be reapplied at any point exactly as it is now. As a bonus, dotfiles don't have to share a name with the file they link to, because the _link_ is declarative, not the content.
- The flake uses [Blueprint](https://github.com/numtide/blueprint), which eliminates all the glue code I'd otherwise need. Creating a host is as simple as adding a directory to `hosts`; creating a package is as simple as adding a file or directory to `packages`.

Program configuration is all stored in [config](/config).

My shared Home Manager config applies this configuration: [users/robert/home-configuration.nix](/users/robert/home-configuration.nix)

This configuration is applied for each configured user on each host, with host-specific tweaks on top: [hosts](/hosts)

## Custom stuff

Unfortunately, I keep finding yaks to shave.

- Fish is my interactive shell, but the login shell is ZSH. Keeping a POSIX-compatible shell as `$SHELL` means scripts never need to worry about what they can assume. ZSH hands off to Fish using `has-ancestor`, a small C program that exits 0 if any ancestor process matches a given name. Using C for this rather than a ZSH script makes the check faster and more reliable.
- I implemented a Fish plugin manager in Nix for declarative plugins with imperative configuration. Plugins don't clutter up my config and can't accidentally clobber any files. Updates are done by updating the Nix plugin package definitions.
- Homebrew is installed automatically and managed declaratively with [nix-homebrew](https://github.com/zhaofengli/nix-homebrew).
- Since Fish is the best language for shell scripting, I wrote a custom command runner for Fish functions. It replaces tools like `just` and common abuse of `make`. Write Fish functions in `run.fish`, then run them with `run`. Also available as `nix run github:clo4/nix-dotfiles#run`.
- My server hosts a Minecraft server using `virtualisation.oci-containers` with Podman. The container starts as root but switches to a system user/group. Its data lives in `/srv/minecraft/family` and it restarts daily at 4 am local time. This is possibly a good reference configuration for running a Minecraft server on NixOS.
- I built a simple DDNS client for Cloudflare to keep my DNS record in sync with my home IP because all the existing ones were too complicated. It's a small Go program that compiles quickly, runs updates concurrently, and caches the IP to avoid unnecessary updates. Credentials are stored encrypted with Agenix. It's moved into its own repository: [clo4/clouddns](https://github.com/clo4/clouddns).

## Hosts

- `pc3`
  - My main dev machine. It's a Linux system running CachyOS. Ryzen 9 9950X3D, Radeon RX 7900XTX, 64GB RAM (purchased right before the RAM shortage, I don't have that kind of money to throw around!)
- `macmini`
  - No longer being used, previously this was my main system. (Mac mini, M1)
- `macbook-air`
  - No longer being used, previously this was my secondary system. (MacBook Air, M1)
- `homeserver1`
  - My personal server. It's a Minisforum NAB6 Lite running an Intel Core i5-12600, drawing under 9W at idle.

### Building and switching

The dev environment includes a custom command runner called `run`: Fish functions in `run.fish`, invoked with `run`. Run it with no arguments to see available commands.

To build or switch the current system, run `run switch-host` or `run build-host`, replacing `host` with the actual host name from the `hosts` directory. Switching `homeserver1` when not on the server will apply the configuration remotely.

`run` works from any shell within the dev environment, but is intended for use within Fish.

### Bootstrapping homeserver1

This isn't in `run.fish` because it has to be run on the target system itself or over SSH.

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run github:clo4/nix-dotfiles/vps#homeserver1-install
```

## Personal notes

### Moving configuration directories

To migrate from one directory to another, create an exact copy of the configuration in the new destination **without removing the existing configuration.** Once copied, edit the new configuration and update `my.config.directory` to the new path. Then reapply from the new directory.
