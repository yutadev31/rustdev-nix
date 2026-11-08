{
  description = "Reusable Nix flake utilities for Rust projects";

  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { rust-overlay, treefmt-nix, ... }: {
    lib = import ./lib {
      inherit rust-overlay treefmt-nix;
    };
  };
}
