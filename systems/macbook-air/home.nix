{...}: let
  language = name: text: text;
in {
  imports = [
    ../../shared/home.nix
  ];

  home.homeDirectory = "/Users/robert";
  home.stateVersion = "24.05";

  # Interestingly this is actually broken in macOS! I went on a deep-dive
  # and eventually found that the Zed team has run into this issue as well.
  # https://github.com/zed-industries/community/issues/1373#issuecomment-1499033975
  home.file.".hushlogin".text = "";

  my.programs.ghostty.enable = true;
  my.programs.fish.setupNixEnv = true;
  # my.programConfig.zed.enable = true;

  nixpkgs.config.allowUnfree = true;
}
