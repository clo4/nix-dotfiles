{
  flake,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./home-configuration.nix
  ];

  # The work setups are managed much more imperatively than any of my personal
  # machines, mainly because it isn't worth my time while I'm working to set
  # up Nix correctly (without buy-in from anyone else on the team), and it
  # isn't worth my time when I'm not working because there are other things I'd
  # rather be doing. Instead, I can do as much as is reasonable in Nix, but
  # fall back to plugins and homebrew when stuff doesn't work right.

  my.programs.fish.plugins = [
    (pkgs.fetchFromGitHub {
      owner = "jorgebucaran";
      repo = "nvm.fish";
      rev = "846f1f20b2d1d0a99e344f250493c41a450f9448"; # current as of 2025-11-18
      hash = "sha256-u3qhoYBDZ0zBHbD+arDxLMM8XoLQlNI+S84wnM3nDzg=";
    })
  ];

  home.packages = [
    pkgs.awscli2
    pkgs.python3
    pkgs.nss_latest
    pkgs.ngrok
    pkgs.vtsls
    pkgs.mongosh
    pkgs.typos
    pkgs.typos-lsp
    pkgs.glow
    pkgs.deno
    pkgs._1password-cli
  ];
}
