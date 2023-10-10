{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    devenv.url = "github:cachix/devenv";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    naersk.url = "github:nix-community/naersk";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    nixpkgs,
    flake-compat,
    devenv,
    flake-parts,
    treefmt-nix,
    naersk,
    rust-overlay,
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
        system,
        ...
      }: let
        cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        inherit (cargoToml.package) name;
        inherit (cargoToml.package) edition;
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        naersk' = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (import rust-overlay)
          ];
        };

        packages.default = config.packages.${name};
        packages.${name} = naersk'.buildPackage {
          src = ./.;
        };

        apps.${name} = {
          type = "app";
          program = "${config.packages.${name}}/bin/${name}";
        };

        devenv.shells.default = {
          packages = with pkgs; [
            bacon
            lldb
            commitizen
            config.treefmt.build.wrapper
          ];

          languages.nix.enable = true;
          languages.rust.enable = true;
          languages.rust.toolchain = {
            cargo = toolchain;
            clippy = toolchain;
            rust-analyzer = toolchain;
            rustc = toolchain;
            rustfmt = toolchain;
          };

          pre-commit.hooks.commitizen.enable = true;
          pre-commit.hooks.clippy.enable = true;
          pre-commit.hooks.convco.enable = true;
          pre-commit.hooks.treefmt.enable = true;

          pre-commit.settings.treefmt.package = config.treefmt.build.wrapper;

          difftastic.enable = true;
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            rustfmt.enable = true;
            rustfmt.package = toolchain;
            rustfmt.edition = edition;
          };
        };
      };
    };
}
