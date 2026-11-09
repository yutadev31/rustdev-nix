{
  nixpkgs,
  rust-overlay,
  treefmt-nix,
}:
let
  mkPackage = import ./mk-package.nix;
  mkChecks = import ./mk-checks.nix;
  mkDevShell = import ./mk-dev-shell.nix;
  mkTreefmt = import ./mk-treefmt.nix {
    inherit treefmt-nix;
  };

  mkFlake = import ./mk-flake.nix {
    inherit
      mkPackage
      mkChecks
      mkDevShell
      mkTreefmt
      nixpkgs
      rust-overlay
      ;
  };
in
{
  inherit
    mkPackage
    mkChecks
    mkDevShell
    mkTreefmt
    mkFlake
    ;
}
