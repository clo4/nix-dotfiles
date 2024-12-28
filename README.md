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

My configuration is currently under a lot of flux. I'm refactoring it so that some programs are managed imperatively, and some are managed with Nix.
I found that after about a year and a half of using this system to manage my configuration, the rate of changes had gone down, but my desire to make changes hadn't. I'd been making more identical changes in every repository, instead of configuring things globally. I'd been testing things out using temporary config files in different directories. But none of the changes were really propagating back to my config.

So, we'll see how this goes. This branch is applied to my Mac mini, which is the main computer I'm using.
