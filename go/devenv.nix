{pkgs, ...}: {
  packages = with pkgs; [];

  languages.go.enable = true;

  pre-commit.hooks = {
    gofmt.enable = true;
    gotest.enable = true;
  };
}
