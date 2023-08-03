# 📂 host

This directory contains the definitions for each host. This is information that defines the system itself, such as what users are enabled, what their passwords are, etc. It doesn't change any home-manager options.

Configuration that is common between hosts is located in [common.nix](./common.nix). Everything else is located in a subdirectory.

There are (currently) 3 hosts to configure: my WSL setup, my virtual machine, and my Mac mini. These configurations all import the common file.
