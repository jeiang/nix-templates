{
  description = "My Rust Flake Template";

  outputs = { self }: {
    templates = {
      app = {
        path = ./app;
        description = "Flake for a Rust App using Naersk";
      };
    };

    defaultTemplate = self.templates.app;
  };
}
