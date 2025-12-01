{ inputs, pkgs, ... }:
{
  _module.args.pkgs' = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
}
