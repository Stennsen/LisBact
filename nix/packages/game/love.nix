# The love2d package: raw .love file plus a proper package layout.
{ pkgs, config, gameCompiled, gpuEnv, ... }:
let
  # the .love is just the precompiled game zipped deterministically
  # (sorted entries, no extra attrs, fixed timestamps)
  loveFile = pkgs.runCommand "${config.name}-${config.version}.love" { nativeBuildInputs = [ pkgs.zip ]; } ''
    cd ${gameCompiled}
    find . -type f | LC_ALL=C sort | env TZ=UTC zip -q -9 -X "$out" -@
  '';
in
{
  inherit loveFile;

  # proper package layout: the game ships as $out/bin/game.love with a
  # $out/bin/<name> launcher, so it can be installed on PATH and run by name
  game = pkgs.runCommand "${config.name}-${config.version}"
    { nativeBuildInputs = [ pkgs.makeWrapper ]; }
    ''
      mkdir -p "$out/bin"
      cp ${loveFile} "$out/bin/game.love"
      makeWrapper ${pkgs.love}/bin/love "$out/bin/${config.name}" \
        --run '${gpuEnv}' \
        --add-flags "$out/bin/game.love"
    '';
}
