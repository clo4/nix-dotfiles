# 📂 home

This directory contains the definitions of my home-manager configurations. I have a few different hosts (see: [host](../host)) that each require slightly different configuration for my user account.

The configuration common to all hosts is in [common.nix](./common.nix). This file is imported by the configurations in the subdirectories, which are themselves imported in [../flake.nix](../flake.nix).

Not all hosts currently have any specific user configuration, but the files exist to allow me to add it easily in the future. Most changes are likely to be in the common options.
