{
  config,
  lib,
  pkgs,
  perSystem,
  flake,
  ...
}:
{
  users.users.mc-router = {
    isSystemUser = true;
    description = "Routes Minecraft client connections";
    group = "mc-router";
  };
  users.groups.mc-router = { };

  age.secrets.mc-router-mapping = {
    file = "${flake}/secrets/mc-router-mapping.age";
    owner = "mc-router";
    group = "mc-router";
    mode = "400";
  };

  systemd.services.mc-router = {
    description = perSystem.self.mc-router.meta.description;
    requires = [ "podman-minecraft-family.service" ];
    after = [ "podman-minecraft-family.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      export MAPPING=$(cat ${config.age.secrets.mc-router-mapping.path})
      ${perSystem.self.mc-router}/bin/mc-router
    '';
    serviceConfig = {
      User = "mc-router";
      Group = "mc-router";
    };
  };
}
