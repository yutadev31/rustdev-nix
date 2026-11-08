{
  mkPackage,
  mkDevShell,
  mkTreefmt,
  rust-overlay,
}:
{
  inputs,
  src,
  systems ? [ "x86_64-linux" ],
  packageAttrs ? { },
  devShellAttrs ? { },
  treefmtConfig ? { },
  extraPackages ? [ ],
}:
let
  inherit (inputs.nixpkgs.lib) genAttrs;

  resolve = value: args: if builtins.isFunction value then value args else value;

  forSystem =
    system:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      rustToolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [
          "rust-src"
          "rust-analyzer"
        ];
      };

      rustPlatform = pkgs.makeRustPlatform {
        cargo = rustToolchain;
        rustc = rustToolchain;
      };

      args = {
        inherit pkgs system;
        inherit rustToolchain rustPlatform;
      };

      treefmt = mkTreefmt {
        inherit pkgs rustToolchain;
        config = resolve treefmtConfig args;
      };

      package = mkPackage {
        inherit pkgs src rustPlatform;
        attrs = resolve packageAttrs args;
      };

      devShell = mkDevShell {
        inherit pkgs package rustToolchain;
        extraPackages = [ treefmt.config.build.wrapper ] ++ resolve extraPackages args;
        attrs = resolve devShellAttrs args;
      };
    in
    {
      inherit treefmt package devShell;
    };

  perSystem = genAttrs systems forSystem;
in
{
  packages = genAttrs systems (system: {
    default = perSystem.${system}.package;
  });

  devShells = genAttrs systems (system: {
    default = perSystem.${system}.devShell;
  });

  formatter = genAttrs systems (system: perSystem.${system}.treefmt.config.build.wrapper);

  checks = genAttrs systems (system: {
    build = perSystem.${system}.package;
    treefmt = perSystem.${system}.treefmt.config.build.check inputs.self;
  });
}
