# WORKING
{ config, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
  };

  users.users.minecraft-family = {
    isSystemUser = true;
    group = "minecraft-family";
    home = "/srv/minecraft/family";
    extraGroups = [ "podman" ];
    linger = true;
    autoSubUidGidRange = true;
  };

  users.groups.minecraft-family = { };
  security.polkit.enable = true;

  systemd.tmpfiles.rules = [
    "d /srv/minecraft/family 0750 minecraft-family minecraft-family -"
  ];

  virtualisation.quadlet.containers.minecraft-family = {
    autoStart = true;
    serviceConfig = {
      User = "minecraft-family";
      Group = "minecraft-family";
    };
    containerConfig = {
      image = "docker.io/itzg/minecraft-server:latest";
      environments = {
        UID = "0";
        GID = "0";
        EULA = "TRUE";
        TYPE = "VANILLA";
      };
    };
  };
}
