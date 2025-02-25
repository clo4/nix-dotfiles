{
  config,
  lib,
  pkgs,
  ...
}:
let
  # This is declared in the configuration itself rather than being declared in
  # a let-in binding and assigned to an option.
  backend = config.virtualisation.oci-containers.backend;
in
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

  # Other users in the minecraft-family group will also be able to rwx
  # in this directory, meaning any system administrators.
  # Any files they create will of course be owned by them.
  systemd.tmpfiles.rules = [
    "d /srv/minecraft/family 0770 minecraft-family minecraft-family -"
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
      TYPE = "FABRIC";
      VERSION = "1.21.4";

      # Security
      ENABLE_WHITELIST = "TRUE";
      WHITELIST = "clo4_";
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
      "--no-healthcheck"
    ];
  };

  systemd.services."${backend}-minecraft-family" = {
    after = [ "network.target" ];
    requires = [ "network.target" ];
  };

  # Service to restart the Minecraft container
  systemd.services.minecraft-family-restart = {
    description = "Restart Minecraft Family Server";
    requires = [ "podman-minecraft-family.service" ];
    after = [ "podman-minecraft-family.service" ];
    script = ''
      ${pkgs.podman}/bin/podman exec minecraft-family rcon-cli "say Server will restart in 5 minutes."
      sleep 240
      ${pkgs.podman}/bin/podman exec minecraft-family rcon-cli "say Server will restart in 1 minute."
      sleep 50
      ${pkgs.podman}/bin/podman exec minecraft-family rcon-cli "say Server will restart in 10 seconds."
      sleep 5
      ${pkgs.podman}/bin/podman exec minecraft-family rcon-cli "say Server will restart in 5 seconds."
      sleep 5

      ${pkgs.systemd}/bin/systemctl restart podman-minecraft-family.service
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.minecraft-family-restart = {
    description = "Timer for daily Minecraft server restart";
    wantedBy = [ "timers.target" ];

    # Since the script starts warning players at 5 minutes before restart,
    # it neesd to be scheduled for 5 minutes before the intended time.
    timerConfig = {
      OnCalendar = "03:55:00";
      Unit = "minecraft-family-restart.service";
    };
  };
}
