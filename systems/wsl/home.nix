{...}: {
  imports = [
    ../../shared/home.nix
  ];

  home.homeDirectory = "/home/robert";

  home.stateVersion = "23.11";

  my.programs.fish.enableWslFunctions = true;

  programs.git.extraConfig.core.sshCommand = "ssh.exe";
}
