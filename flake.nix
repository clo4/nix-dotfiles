{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # blueprint.url = "path:/Users/robert/Developer/blueprint";
    # blueprint.url = "github:numtide/blueprint";
    blueprint.url = "github:clo4/blueprint/generic-users";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # helix.url = "github:clo4/helix/helix-cogs-steel-language-server";
    # helix.inputs.nixpkgs.follows = "nixpkgs";
    # helix.inputs.crane.follows = "crane";
    # crane.url = "github:ipetkov/crane";
    # steel.url = "github:mattwparas/steel";
    # steel.inputs.nixpkgs.follows = "nixpkgs";

    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nix-darwin";
    agenix.inputs.home-manager.follows = "home-manager";

    clouddns.url = "github:clo4/clouddns";
    clouddns.inputs.nixpkgs.follows = "nixpkgs";
    clouddns.inputs.blueprint.follows = "blueprint";
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}
