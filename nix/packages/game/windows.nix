# Windows build: fuse the .love into the official prebuilt love.exe (LÖVE
# runs a zip appended to the exe as the game). Shipped as a folder with the
# runtime dlls in $out/share/<name>-<ver>-win64/ (the exe needs them next to
# it), plus a distributable zip. The runtime is pinned by hash.
{ pkgs, config, loveVersion, loveFile, ... }:
let
  loveWinZip = pkgs.fetchurl {
    url = "https://github.com/love2d/love/releases/download/${loveVersion}/love-${loveVersion}-win64.zip";
    hash = "sha256-um5WviaF5TyBd0nEpQB/URNxNv5aOrZJIFCLq8LnQ2k=";
  };

  winApp = pkgs.runCommand "${config.name}-${config.version}-win64"
    { nativeBuildInputs = [ pkgs.unzip ]; }
    ''
      dir="$out/share/${config.name}-${config.version}-win64"
      mkdir -p "$dir"
      unzip -q ${loveWinZip} -d tmp
      mv tmp/love-${loveVersion}-win64/* "$dir/"
      # fused standalone exe: love.exe with the game appended
      cat "$dir/love.exe" ${loveFile} > "$dir/${config.name}.exe"
      rm "$dir/love.exe"
      find "$dir" -exec touch -h -d '@1' {} +
    '';

  winZip = pkgs.runCommand "${config.name}-${config.version}-win64.zip" { nativeBuildInputs = [ pkgs.zip ]; } ''
    cd ${winApp}/share
    env TZ=UTC zip -q -r -9 -X "$out" "${config.name}-${config.version}-win64"
  '';
in
{
  inherit winApp winZip;
}
