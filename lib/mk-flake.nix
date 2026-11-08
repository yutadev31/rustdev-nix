{
  mkPackage,
  mkDevShell,
  mkTreefmt,
  nixpkgs,
  rust-overlay,
}:
{
  inputs,
  src,
  systems ? [ "x86_64-linux" ],
  buildPackage ? true,
  packageAttrs ? { },
  devShellAttrs ? { },
  treefmtConfig ? { },
  extraPackages ? [ ],
}:
let
  inherit (nixpkgs.lib) genAttrs;

  resolve = value: args: if builtins.isFunction value then value args else value;

  forSystem =
    system:
    let
      pkgs = import nixpkgs {
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

      package =
        if buildPackage then
          mkPackage {
            inherit pkgs src rustPlatform;
            attrs = resolve packageAttrs args;
          }
        else
          null;

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
  packages =
    if buildPackage then
      genAttrs systems (system: {
        default = perSystem.${system}.package;
      })
    else
      { };

  devShells = genAttrs systems (system: {
    default = perSystem.${system}.devShell;
  });

  formatter = genAttrs systems (system: perSystem.${system}.treefmt.config.build.wrapper);

  checks = genAttrs systems (
    system:
    {
      treefmt = perSystem.${system}.treefmt.config.build.check inputs.self;
    }
    // (
      if buildPackage then
        {
          build = perSystem.${system}.package;
        }
      else
        { }
    )
  );
}
