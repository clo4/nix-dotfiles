{ pkgs, ... }:
let
  fromGitHub =
    {
      owner,
      repo,
      name ? repo,
      rev,
      hash,
      opt ? false,
      recursive ? false,
    }:
    {
      inherit name recursive;
      start = !opt;
      src = pkgs.fetchFromGitHub {
        inherit
          owner
          repo
          rev
          hash
          ;
      };
    };
in
{
  my.programs.neovim.packages.nix-managed = [
    (fromGitHub {
      owner = "echasnovski";
      repo = "mini.surround";
      rev = "1a2b59c77a0c4713a5bd8972da322f842f4821b1";
      hash = "sha256-khhvGI4aWVgdTeBabxncVNWPI5vouSTpHAUYfEhgISs=";
    })

    (fromGitHub {
      owner = "sainnhe";
      repo = "gruvbox-material";
      rev = "66cfeb7050e081a746a62dd0400446433e802368";
      hash = "sha256-EPz9jIbyext4WEjzh5V8JKMeMBVgUzmgeBPqiWf0dc4=";
    })

    (fromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "1f069f1bc610493d38276023165075f7424ca7b4";
      hash = "sha256-PABUBcr0QFROpO3WHi1BwHpXk4Pe+cm4vr3otiyEK/4=";
    })

    # Oil depends on at least one library to do icons
    (fromGitHub {
      owner = "stevearc";
      repo = "oil.nvim";
      rev = "08c2bce8b00fd780fb7999dbffdf7cd174e896fb";
      hash = "sha256-fbRbRT9VJdppOs4hML1J113qLHdj7YRuSDQgZkt34cM=";
    })
    (fromGitHub {
      owner = "echasnovski";
      repo = "mini.icons";
      rev = "94848dad1589a199f876539bd79befb0c5e3abf0";
      hash = "sha256-2S9w8OGfV0QFs814cYMOzYiZwCZmyDl6n0TMsNWuIKA=";
    })

    # Telescope has a few dependencies.
    (fromGitHub {
      owner = "nvim-telescope";
      repo = "telescope.nvim";
      rev = "b4da76be54691e854d3e0e02c36b0245f945c2c7";
      hash = "sha256-JpW0ehsX81yVbKNzrYOe1hdgVMs6oaaxMLH6lECnOJg=";
    })
    (fromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "857c5ac632080dba10aae49dba902ce3abf91b35";
      hash = "sha256-8FV5RjF7QbDmQOQynpK7uRKONKbPRYbOPugf9ZxNvUs=";
    })

    {
      name = "telescope-fzf-native.nvim";
      src = pkgs.stdenv.mkDerivation {
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
  ];
}
