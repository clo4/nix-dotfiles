{
  config,
  perSystem,
  ...
}:
{
  age.secrets.clouddns-config = {
    file = ./clouddns-config.json.age;
    owner = "clouddns";
    group = "clouddns";
    mode = "400";
  };

  users.users.clouddns = {
    description = "System user for clouddns";
    isSystemUser = true;
    group = "clouddns";
  };

  users.groups.clouddns = { };

  systemd.services.clouddns = {
    description = "Update Cloudflare DNS records with the current IP address";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      NoNewPrivileges = true;
      PrivateDevices = true;
      MemoryDenyWriteExecute = true;
      User = "clouddns";
      Group = "clouddns";
      Environment = [
        "DDNS_CONFIG_PATH=${config.age.secrets.clouddns-config.path}"
        "DDNS_CACHE_PATH=/var/tmp"
      ];
      ExecStart = "${perSystem.clouddns.default}/bin/clouddns";
    };
  };

  systemd.timers.clouddns = {
    description = "Timer for clouddns";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "1m";
      OnCalendar = "*:0/20";
    };
  };
}
