{
  pkgs,
  src,
  attrs ? { },
}:
let
  cargo = builtins.fromTOML (builtins.readFile src + "Cargo.toml");

  defaults = {
    pname = cargo.package.name;
    version = cargo.package.version;

    inherit src;

    cargoLock.lockFile = src + "Cargo.lock";
  };
in
pkgs.rustPlatform.buildRustPackage (pkgs.lib.recursiveUpdate defaults attrs)
