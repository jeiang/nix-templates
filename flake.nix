{
  description = "Templates for Nix Flakes";

  outputs = { self }: {
    templates = {
      rust-naersk = {
        path = ./rust-naersk;
        description = "Flake for a Rust App using Naersk";
      };
    };
  };
}
