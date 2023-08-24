{
  description = "Templates for Nix Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    devenv,
    flake-parts,
    treefmt-nix,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        devenv.flakeModule
        treefmt-nix.flakeModule
      ];

      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        devenv.shells.default = {
          packages = with pkgs; [
            commitizen
            config.treefmt.build.wrapper
          ];

          languages.nix.enable = true;

          pre-commit.hooks.alejandra.enable = true;
          pre-commit.hooks.commitizen.enable = true;
          pre-commit.hooks.convco.enable = true;
          difftastic.enable = true;
        };
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
          };
        };
      };

      flake = {
        templates = {
          rust-naersk = {
            path = ./rust-naersk;
            description = "Flake for a Rust App using Naersk";
          };
          zig = {
            path = ./zig;
            descriptions = "Flake for a Zig program using the latest version of zig";
          };
          go = {
            path = ./go;
            descriptions = "Flake for a go program";
          };
        };
      };
    };
}
