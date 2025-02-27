{ config, ... }:
{
  imports = [
    ./servers/family.nix
    ./ddns.nix
  ];
  assertions = [
    {
      assertion = config.virtualisation.oci-containers.backend == "podman";
      message = ''
        You can't change to Docker without also updating minecraft/servers/*.nix as these
        files explicitly invoke podman.
      '';
    }
  ];
}
