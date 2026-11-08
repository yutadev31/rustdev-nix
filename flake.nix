{
  description = "Reusable Nix flake utilities for Rust projects";

  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { rust-overlay, ... }: {
    lib = import ./lib {
      inherit rust-overlay;
    };
  };
}
