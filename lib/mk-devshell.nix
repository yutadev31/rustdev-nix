{
  pkgs,
  rustToolchain,
  package ? null,
  extraPackages ? [ ],
  attrs ? { },
}:
let
  defaults = {
    inputsFrom = pkgs.lib.optional (package != null) package;

    packages =
      with pkgs;
      [
        nixd
        nixfmt
        typos-lsp
        tombi

        rustToolchain
      ]
      ++ extraPackages;
  };
in
pkgs.mkShell (defaults // attrs)
