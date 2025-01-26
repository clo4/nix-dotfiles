# This module is loosely translated from
# https://github.com/LnL7/nix-darwin/blob/6a1fdb2a1204c0de038847b601cff5012e162b5e/modules/programs/fish.nix
# to resolve some issues with the environment not being set correctly.
{ pkgs, config, ... }:
let
  babelfishTranslate =
    path: name:
    pkgs.runCommand "${name}.fish" { } ''
      ${pkgs.babelfish}/bin/babelfish < ${path} > $out
    '';
in
{
  # Fish from Nix has a hook to setup the environment correctly, which
  # requires this exact path: /etc/fish/nixos-env-preinit.fish
  # The fish module sets this up correctly, but since we're not using
  # that, we have to do it manually.
  environment.etc."fish/nixos-env-preinit.fish".text = ''
    if [ -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE" ]
      source /etc/fish/setEnvironment.fish
    end
  '';
  environment.etc."fish/setEnvironment.fish".source =
    babelfishTranslate config.system.build.setEnvironment "setEnvironment";
}
