{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.programs.fish;
  language = name: text: text;
in {
  # It makes more sense for this module to be defined for the system
  # than for the individual user because it's not a problem that just
  # affects individuals. It's not a preference thing, it's an unfortunate
  # side-effect of a bunch of different systems working together.
  # Context: https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
  options.programs.fish.fixPathOrder = mkEnableOption "the path ordering fix (nix-darwin#122)";

  # This doesn't need to be gated on whether fish is enabled because if fish
  # *isn't* enabled then this will do nothing at all.
  config = mkIf cfg.fixPathOrder {
    programs.fish.loginShellInit = let
      # If there's ever a double quote in a path, something has obviously gone
      # very, very wrong. Have to use double quotes because some entries include
      # variables like $HOME and $USER that need to expand.
      dquote = str: "\"" + str + "\"";
      makeBinPathList = map (path: path + "/bin");
    in
      language "fish" ''
        fish_add_path --move --prepend --path ${
          lib.concatMapStringsSep " " dquote
          (makeBinPathList config.environment.profiles)
        }
        # This line is only necessary for the side effect of updating the
        # path ordering (see: `functions __fish_reconstruct_path`)
        set fish_user_paths $fish_user_paths
      '';
  };
}
