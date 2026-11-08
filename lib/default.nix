{ rust-overlay }:
let
  mkPackage = import ./mk-package.nix;
  mkDevShell = import ./mk-dev-shell.nix;

  mkFlake = import ./mk-flake.nix {
    inherit mkPackage mkDevShell rust-overlay;
  };
in
{
  inherit mkPackage mkDevShell mkFlake;
}
