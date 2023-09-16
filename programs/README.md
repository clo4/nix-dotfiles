# 📂 programs

This directory contains definitions of the `my.programs` options. It:

- Defines my configuration for each program
- Defines the options
- Imports the modules (see [default.nix](./default.nix))

## Why modules?

Using modules allows you to define all the configuration in one place and either
enable or disable pieces of it depending on the system.

This is only slightly more complicated but gives excellent flexibility for
future modifications.

For a good example of this, see [fish.nix](./fish.nix), which defines my entire
shell configuration. There are multiple options that can be enabled which will
enable other pieces of the configuration, such as Mac-specific startup checks.
