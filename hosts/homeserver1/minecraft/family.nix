# This is a fully configured Minecraft server. It uses the itzg/minecraft-server
# docker image, but is fully managed by NixOS and systemd. The service is
# launched by root, but is run as a system user (minecraft-family) instead.
# The server will be restarted by another service on a timer at 4 am every day.
#
# There is also a DDNS configuration for Cloudflare, and the data is stored
# using agenix for security. This step may not be necessary for you if you're
# copying parts of this configuration.
{
  config,
  lib,
  pkgs,
  perSystem,
  flake,
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

  virtualisation.podman.enable = true;

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.minecraft-family = {
    image = "docker.io/itzg/minecraft-server";
    autoStart = true;
    ports = [ "25565:25565" ];

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

  age.secrets.tinycfddnsclient-config = {
    file = "${flake}/secrets/tinycfddnsclient-config.age";
    owner = "tinycfddnsclient";
    group = "tinycfddnsclient";
    mode = "400";
  };

  users.users.tinycfddnsclient = {
    description = "System user for tinycfddnsclient";
    isSystemUser = true;
    group = "tinycfddnsclient";
  };

  users.groups.tinycfddnsclient = { };

  systemd.services.tinycfddnsclient = {
    description = "Update Cloudflare DNS records with the current IP address";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      # This service can't use PrivateTmp because it's a oneshot that writes stateful
      # data to the tmp as a cache. This data doesn't need to persist across reboots.
      NoNewPrivileges = true;
      PrivateDevices = true;
      MemoryDenyWriteExecute = true;
      User = "tinycfddnsclient";
      Group = "tinycfddnsclient";
      Environment = [
        "CONFIG_PATH=${config.age.secrets.tinycfddnsclient-config.path}"
      ];
      ExecStartPre = "-rm -rf /var/tmp/tinycfddns_ip_cache.txt";
      ExecStart = "${perSystem.self.tinycfddnsclient}/bin/tinycfddnsclient";
    };
  };

  systemd.timers.tinycfddnsclient = {
    description = "Timer for Tiny Cloudflare DDNS Client";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "10s";
      OnCalendar = "*:0/20";
    };
  };
}
