{
  pkgs,
  src,
  rustPlatform ? pkgs.rustPlatform,
  manifestPath ? "Cargo.toml",
  attrs ? { },
}:
let
  rootCargo = builtins.fromTOML (builtins.readFile (src + "/Cargo.toml"));
  cargo = builtins.fromTOML (builtins.readFile (src + "/${manifestPath}"));
  workspacePackage = rootCargo.workspace.package or { };
  package = cargo.package or { };
  version = package.version or (workspacePackage.version or "0.0.0");
  memberSelected = manifestPath != "Cargo.toml";

  defaults = {
    pname = package.name or "rust-workspace";
    version =
      if builtins.isAttrs version && (version.workspace or false) then
        workspacePackage.version
      else
        version;

    inherit src;

    cargoLock.lockFile = src + "/Cargo.lock";
  }
  // pkgs.lib.optionalAttrs memberSelected {
    cargoBuildFlags = [
      "--package"
      package.name
    ];
    cargoTestFlags = [
      "--package"
      package.name
    ];
  }
  // pkgs.lib.optionalAttrs (!memberSelected && rootCargo ? workspace) {
    cargoBuildFlags = [ "--workspace" ];
    cargoTestFlags = [ "--workspace" ];
  };
in
rustPlatform.buildRustPackage (pkgs.lib.recursiveUpdate defaults attrs)
