# nix-templates

My nix templates for projects.

## TODO:

- [X] Add treefmt to template for formatting.
- [ ] Use nix flake method to build on github actions
- [ ] Use github actions to run tests

### Zig

- [ ] Perhaps make a shim build.zig which loads $NIX_CFLAGS_COMPILE to add dependency paths, or find a way to add 
  it to zig
- [ ] move packages to per system

### Go

- [ ] Switch to a flake
- [ ] Use Go build module or something to build the package

### Rust

- [ ] add devenv
