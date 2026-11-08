{
  description = "Reusable Nix flake utilities for Rust projects";

  outputs = { ... }: {
    lib = import ./lib;
  };
}
