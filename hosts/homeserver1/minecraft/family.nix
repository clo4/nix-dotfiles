{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.minecraft-family = {
    isSystemUser = true;
    uid = 399;
    group = "minecraft-family";
    home = "/srv/minecraft/family";
    linger = true;
    autoSubUidGidRange = true;
  };

  # The group needs its own GID because the container references it directly.
  users.groups.minecraft-family = {
    gid = 398;
  };

  systemd.tmpfiles.rules = [
    "d /srv/minecraft/family 0750 minecraft-family minecraft-family -"
  ];

  virtualisation.podman.enable = true;

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.minecraft-family = {
    image = "docker.io/itzg/minecraft-server";
    autoStart = true;
    ports = [ "25565:25565" ];

    # The container is launched by root, then changes to
    # minecraft-family:minecraft-family.
    user = "${toString config.users.users.minecraft-family.uid}:${toString config.users.groups.minecraft-family.gid}";

    # All the actual server configuration is done manually in server.properties.
    environment = {
      EULA = "TRUE";
      TYPE = "VANILLA";
      OPS = "clo4_";

      # Performance settings
      MEMORY = "8G";
      USE_AIKAR_FLAGS = "TRUE";

      # Auto-pause configuration
      ENABLE_AUTOPAUSE = "TRUE";
      # Wait 1 minute after server initialisation before pausing
      AUTOPAUSE_TIMEOUT_INIT = "60";
      # Wait 30 minutes after last player disconnection before pausing
      AUTOPAUSE_TIMEOUT_EST = "1800";
      # This fixes the "unable to start knockd" issue
      SKIP_SUDO = "TRUE";

      # Disable unnecessary watchdog timers
      MAX_TICK_TIME = "-1";
      WATCHDOG = "-1";
    };

    volumes = [
      "/srv/minecraft/family:/data"
    ];

    extraOptions = [
      "--cap-add=CAP_NET_RAW" # Required for autopause
      "--no-healthcheck" # Explicitly disable health checking
    ];
  };

  systemd.services.podman-minecraft-family = {
    after = [ "network.target" ];
    requires = [ "network.target" ];
  };
}
