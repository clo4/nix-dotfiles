{
  config,
  lib,
  pkgs,
  ...
}:
let
  uid = 399;
  gid = 398;
in
{
  users.users.minecraft-family = {
    inherit uid;
    isSystemUser = true;
    group = "minecraft-family";
    home = "/srv/minecraft/family";

    # I'm not certain if these are necessary any more, but they don't hurt.
    linger = true;
    autoSubUidGidRange = true;
  };

  # The group needs its own GID because the container references it directly.
  users.groups.minecraft-family = {
    inherit gid;
  };

  users.users.robert.extraGroups = [ "minecraft-family" ];

  # rwxrwx--- so the minecraft-family group can also make changes.
  systemd.tmpfiles.rules = [
    "d /srv/minecraft/family 0770 minecraft-family minecraft-family -"
  ];

  networking.firewall.allowedTCPPorts = [ 25565 ];
  # For voice chat mods:
  # networking.firewall.allowedUDPPorts = [ 24464 ];

  virtualisation.oci-containers.containers.minecraft-family = {
    image = "docker.io/itzg/minecraft-server";
    autoStart = true;
    # This service doesn't run on the normal Minecraft port because mc-router
    # runs on 25565 and will forward its traffic to this port.
    ports = [ "25580:25565" ];

    # Launched by root, then changed to minecraft-family:minecraft-family.
    # Because the user has been set, it's also respected inside the container.
    user = "${toString uid}:${toString gid}";

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
      "--tty"
    ];
  };

  systemd.services.podman-minecraft-family = {
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
    timerConfig = {
      # Since the script starts warning players at 5 minutes before restart,
      # it needs to be scheduled for 5 minutes before the intended time.
      OnCalendar = "03:55:00";
      Unit = "minecraft-family-restart.service";
    };
  };
}
