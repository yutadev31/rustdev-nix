{
  pkgs,
  src,
  rustToolchain,
  rustPlatform ? pkgs.makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  },
  attrs ? { },
}:
let
  mkPackage = import ./mk-package.nix;

  package = mkPackage {
    inherit
      pkgs
      src
      rustPlatform
      attrs
      ;
  };

  cargoCheck =
    name: command:
    package.overrideAttrs (_: {
      pname = "cargo-${name}";
      buildPhase = ''
        runHook preBuild
        ${command}
        runHook postBuild
      '';
      doCheck = false;
      doInstallCheck = false;
      installPhase = ''
        mkdir -p "$out"
      '';
    });
in
{
  fmt = pkgs.runCommand "cargo-fmt" { nativeBuildInputs = [ rustToolchain ]; } ''
    cp -r ${src} source
    chmod -R u+w source
    cd source
    cargo fmt --all --check
    mkdir -p "$out"
  '';
  check = cargoCheck "check" "cargo check --offline --workspace --all-targets";
  clippy = cargoCheck "clippy" "cargo clippy --offline --workspace --all-targets -- -D warnings";
  test = cargoCheck "test" "cargo test --offline --workspace";
}
