# This is a helix setup on either the latest (or close to the latest) version of
# the plugin system fork, which is usually quite stable and only a couple of weeks
# behind upstream. This wraps my existing Helix configuration, allowing me to use
# it on all systems.
{
  perSystem,
  pkgs,
  flake,
}:
let
  steelWithLsp = perSystem.steel.default.overrideAttrs (oldAttrs: {
    cargoBuildFlags = "-p cargo-steel-lib -p steel-interpreter -p steel-language-server";
  });
in
pkgs.writeShellScriptBin "hx" ''
  export PATH=${steelWithLsp}/bin:$PATH
  export STEEL_HOME=${perSystem.helix.helix-cogs}
  export STEEL_LSP_HOME=${perSystem.helix.helix-cogs}/steel-language-server
  exec ${perSystem.helix.default}/bin/hx -c ${flake}/config/helix/config.toml "$@"
''
