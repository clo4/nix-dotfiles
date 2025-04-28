{
  pkgs,
  config,
  ...
}:
{
  systemd.tmpfiles.rules = [
    "d /srv/vrising 0700 root root -"
    "d /srv/vrising/server 0700 root root -"
    "d /srv/vrising/data 0700 root root -"
  ];

  virtualisation.oci-containers.containers.vrising = {
    image = "docker.io/trueosiris/vrising";
    autoStart = true;
    ports = [
      "9876:9876/udp"
      "9877:9877/udp"
    ];
    volumes = [
      "/srv/vrising/server:/mnt/vrising/server"
      "/srv/vrising/data:/mnt/vrising/persistentdata"
    ];
    environment = {
      TZ = config.time.timeZone;
      SERVERNAME = "vrising-clo4";
    };
    extraOptions = [
      "--network=bridge"
    ];
  };

  systemd.services.podman-vrising = {
    after = [ "network.target" ];
    requires = [ "network.target" ];
  };

  # systemd.services.vrising-restart = {
  #   description = "Restart V-Rising Server";
  #   requires = [ "podman-vrising.service" ];
  #   after = [ "podman-vrising.service" ];
  #   script = ''
  #     ${pkgs.systemd}/bin/systemctl restart podman-vrising.service
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #   };
  # };

  # systemd.timers.vrising-restart = {
  #   description = "Timer for daily Minecraft server restart";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "04:00:00";
  #     Unit = "vrising-restart.service";
  #   };
  # };
}
