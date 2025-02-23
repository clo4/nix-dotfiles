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
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  users.groups.minecraft-family = { };

  systemd.tmpfiles.rules = [
    "d /srv/minecraft/family 0750 minecraft-family minecraft-family -"
  ];

  systemd.services.minecraft-family = {
    description = "Minecraft Family Server Container";
    wantedBy = [ "multi-user.target" ];
    requires = [ "podman.socket" ];
    after = [ "podman.socket" ];

    path = [ "/run/wrappers" ];

    serviceConfig = {
      User = "minecraft-family";
      Group = "minecraft-family";
      Restart = "on-failure";
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name minecraft-family \
          --rm \
          --pull=missing \
          -v /srv/minecraft/family:/data:Z \
          -e EULA=TRUE \
          -e TYPE=VANILLA \
          -e UID=0 \
          -e GID=0 \
          itzg/minecraft-server
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop minecraft-family";
    };
  };
}
