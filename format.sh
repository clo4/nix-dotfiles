#!/usr/bin/env nix-shell
#!nix-shell -i bash -p alejandra deno

shopt -s globstar

echo "formatting nix files with alejandra..."
alejandra --quiet .

echo "formatting markdown files with deno..."
deno fmt --quiet **/*.md
