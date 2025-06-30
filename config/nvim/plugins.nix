{ pkgs, ... }:
[
  {
    name = "lazy.nvim";
    path = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "lazy.nvim";
      rev = "6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a";
      hash = "sha256-nQ8PR9DTdzg6Z2rViuVD6Pswc2VvDQwS3uMNgyDh5ls=";
    };
  }
  {
    name = "oil.nvim";
    path = pkgs.fetchFromGitHub {
      owner = "stevearc";
      repo = "oil.nvim";
      rev = "08c2bce8b00fd780fb7999dbffdf7cd174e896fb";
      hash = "sha256-fbRbRT9VJdppOs4hML1J113qLHdj7YRuSDQgZkt34cM=";
    };
  }
  {
    name = "mini.icons";
    path = pkgs.fetchFromGitHub {
      owner = "echasnovski";
      repo = "mini.icons";
      rev = "94848dad1589a199f876539bd79befb0c5e3abf0";
      hash = "sha256-2S9w8OGfV0QFs814cYMOzYiZwCZmyDl6n0TMsNWuIKA=";
    };
  }
  {
    name = "mini.surround";
    path = pkgs.fetchFromGitHub {
      owner = "echasnovski";
      repo = "mini.surround";
      rev = "1a2b59c77a0c4713a5bd8972da322f842f4821b1";
      hash = "sha256-khhvGI4aWVgdTeBabxncVNWPI5vouSTpHAUYfEhgISs=";
    };
  }
  {
    name = "telescope.nvim";
    path = pkgs.fetchFromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "b4da76be54691e854d3e0e02c36b0245f945c2c7";
      hash = "sha256-JpW0ehsX81yVbKNzrYOe1hdgVMs6oaaxMLH6lECnOJg=";
    };
  }
  {
    name = "plenary.nvim";
    path = pkgs.fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "857c5ac632080dba10aae49dba902ce3abf91b35";
      hash = "sha256-8FV5RjF7QbDmQOQynpK7uRKONKbPRYbOPugf9ZxNvUs=";
    };
  }
  {
    name = "telescope-fzf-native.nvim";
    # This package relies on being built, but keeping the build directory
    # in the same directory as the plugin itself. For Nix, this means building
    # it and copying *all* the files to the $out directory.
    path = pkgs.stdenv.mkDerivation {
      name = "telescope-fzf-native";
      src = pkgs.fetchFromGitHub {
        owner = "nvim-telescope";
        repo = "telescope-fzf-native.nvim";
        rev = "1f08ed60cafc8f6168b72b80be2b2ea149813e55";
        hash = "sha256-Zyv8ikxdwoUiDD0zsqLzfhBVOm/nKyJdZpndxXEB6ow=";
      };
      installPhase = ''
        runHook preInstall
        all_files=$(ls)
        mkdir -p $out
        cp -R $all_files $out
        runHook postInstall
      '';
    };
  }
]
