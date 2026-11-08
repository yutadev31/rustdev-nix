{
  description = "Reusable Nix flake utilities for Rust projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      treefmt-nix,
      ...
    }:
    {
      lib = import ./lib {
        inherit nixpkgs rust-overlay treefmt-nix;
      };
    };
}
