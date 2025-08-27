{ inputs, pkgs, ... }:
{
  _module.args.pkgs' = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
}
