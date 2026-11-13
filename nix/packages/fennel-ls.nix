# fennel-ls wrapped with pinned third-party docsets (love2d), so the language
# server finds them in the nix store instead of ~/.local/share/fennel-ls.
# The dev shell uses this package instead of pkgs.fennel-ls; see nix/shell.nix.
{
  perSystem =
    { pkgs, ... }:
    let
      # Docsets fennel-ls can load. The key is the docset file name (minus .lua)
      # to reference in :libraries of a project's flsproject.fnl.
      availableDocsets = {
        love2d = pkgs.fetchurl {
          url = "https://p.hagelb.org/docsets/love2d.lua";
          hash = "sha256-QKd6xezF9eJY5zvtBodrmbpFky+8r5tPz2UKmhHgrbM=";
        };
      };
      enabledDocsets = [ "love2d" ];
      fennel-ls-docsets = pkgs.runCommand "fennel-ls-docsets" { } (
        ''
          mkdir -p $out/fennel-ls/docsets
        ''
        + pkgs.lib.concatMapStringsSep "\n" (
          name: ''cp ${availableDocsets.${name}} "$out/fennel-ls/docsets/${name}.lua"''
        ) enabledDocsets
      );
    in
    {
      packages.fennel-ls = pkgs.symlinkJoin {
        name = "fennel-ls-with-docsets";
        paths = [ pkgs.fennel-ls ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/fennel-ls" --set XDG_DATA_HOME ${fennel-ls-docsets}
        '';
      };
    };
}
