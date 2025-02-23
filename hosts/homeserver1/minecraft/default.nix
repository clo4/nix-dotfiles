{
  config,
  lib,
  pkgs,
  ...
}:
{
  users = {
    users.minecraft-family = {
      isSystemUser = true;
      group = "minecraft-family";
      description = "Minecraft family server service user";
      home = "/srv/minecraft/family";
      createHome = false;
      packages = [ pkgs.dbus ];
    };

    groups.minecraft-family = { };
  };

  # Directory structure
  systemd.tmpfiles.rules = [
    "d /srv/minecraft/family 0750 minecraft-family minecraft-family -"
  ];

  # Container configuration
  virtualisation = {
    podman.enable = true;
    oci-containers = {
      backend = "podman";
      containers.minecraft-family = {
        image = "docker.io/itzg/minecraft-server";
        autoStart = true;
        ports = [ "25565:25565" ];

        environment = {
          EULA = "TRUE";
          TYPE = "VANILLA";
          OPS = "clo4_";

          # Performance settings
          MEMORY = "8G";
          USE_AIKAR_FLAGS = "TRUE";
          SIMULATION_DISTANCE = "16";
          VIEW_DISTANCE = "16";

          # Auto-pause configuration
          ENABLE_AUTOPAUSE = "TRUE";
          # Wait 30 minutes after last player disconnection before pausing
          AUTOPAUSE_TIMEOUT_EST = "1800";
          # Wait 3 minutes after server initialisation before pausing
          AUTOPAUSE_TIMEOUT_INIT = "180";

          # Disable unnecessary watchdog timers
          MAX_TICK_TIME = "-1";
          WATCHDOG = "-1";

          # Do I need both this and the `user` config? Not sure.
          UID = toString config.users.users.minecraft-family.uid;
          GID = toString config.users.groups.minecraft-family.gid;
        };

        volumes = [
          "/srv/minecraft/family:/data"
        ];

        extraOptions = [
          "--cap-add=CAP_NET_RAW" # Required for autopause
          "--no-healthcheck" # Explicitly disable health checking
        ];
      };
    };
  };

  # Service configuration
  systemd.services.podman-minecraft-family = {
    after = [ "network.target" ];
    requires = [ "network.target" ];

    serviceConfig = {
      RestartSec = "10s";
      User = "minecraft-family";
      Group = "minecraft-family";
    };
  };
}
