{ treefmt-nix }:
{
  pkgs,
  rustToolchain,
  config ? { },
}:
let
  defaults = {
    projectRootFile = "flake.nix";

    programs.nixfmt.enable = true;

    programs.rustfmt = {
      enable = true;
      package = rustToolchain;
    };

    settings.formatter.tombi = {
      command = pkgs.lib.getExe pkgs.tombi;
      options = [
        "format"
        "--offline"
      ];
      includes = [ "*.toml" ];
    };

    settings.global.excludes = [
      "result/**"
      "target/**"
    ];
  };
in
treefmt-nix.lib.evalModule pkgs (pkgs.lib.recursiveUpdate defaults config)
