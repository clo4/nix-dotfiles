# This is a helix setup on either the latest (or close to the latest) version of
# the plugin system fork, which is usually quite stable and only a couple of weeks
# behind upstream. This wraps my existing Helix configuration, allowing me to use
# it on all systems.
{
  perSystem,
  pkgs,
  flake,
}:
pkgs.writeShellScriptBin "hx" ''
  export PATH=${perSystem.self.ccase}/bin:$PATH
  exec ${perSystem.self.helix}/bin/hx -c ${flake}/config/helix/config.toml "$@"
''
