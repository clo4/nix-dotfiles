# This uses a custom DDNS client written in Go explicitly for Cloudflare DNS.
# It's capable of updating multiple records at once, but I only use it to
# update one since I use SRV records to point at the target host.
#
# The client caches the current IP to prevent unnecessary requests if nothing
# has changed.
{
  config,
  lib,
  pkgs,
  perSystem,
  flake,
  ...
}:
{
  age.secrets.tinycfddnsclient-config = {
    file = ../tinycfddnsclient-config.age;
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
