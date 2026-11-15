# Windows build: fuse the .love into the official prebuilt love.exe (LÖVE
# runs a zip appended to the exe as the game). Layout mirrors the other
# packages: $out/bin/ is the self-contained runnable folder (fused
# <name>.exe + the runtime dlls, which Windows resolves next to the exe),
# $out/share/<name>-<ver>-win64/ holds license/changes/readme. The runtime
# is pinned by hash. winZip packs bin/ + docs as one distributable folder.
{ pkgs, config, loveVersion, loveFile, ... }:
let
  loveWinZip = pkgs.fetchurl {
    url = "https://github.com/love2d/love/releases/download/${loveVersion}/love-${loveVersion}-win64.zip";
    hash = "sha256-um5WviaF5TyBd0nEpQB/URNxNv5aOrZJIFCLq8LnQ2k=";
  };

  winApp = pkgs.runCommand "${config.name}-${config.version}-win64"
    { nativeBuildInputs = [ pkgs.unzip ]; }
    ''
      mkdir -p "$out/bin" "$out/share/${config.name}-${config.version}-win64"
      unzip -q ${loveWinZip} -d tmp
      src=tmp/love-${loveVersion}-win64
      cp "$src"/*.dll "$src"/*.ico "$out/bin/"
      # fused standalone exe: love.exe with the game appended
      cat "$src/love.exe" ${loveFile} > "$out/bin/${config.name}.exe"
      cp "$src"/license.txt "$src"/changes.txt "$src"/readme.txt \
        "$out/share/${config.name}-${config.version}-win64/"
      find "$out" -exec touch -h -d '@1' {} +
    '';

  winZip = pkgs.runCommand "${config.name}-${config.version}-win64.zip" { nativeBuildInputs = [ pkgs.zip ]; } ''
    stage=$(mktemp -d)/${config.name}-${config.version}-win64
    mkdir -p "$stage"
    cp -r ${winApp}/bin/. "$stage/"
    cp ${winApp}/share/${config.name}-${config.version}-win64/* "$stage/"
    cd "$(dirname "$stage")"
    env TZ=UTC zip -q -r -9 -X "$out" "${config.name}-${config.version}-win64"
  '';
in
{
  inherit winApp winZip;
}
