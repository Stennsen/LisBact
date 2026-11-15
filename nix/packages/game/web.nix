# The love.js web build: proper package layout with the payload in
# $out/share/<name>-<ver>-web/ and a $out/bin/serve-web launcher
# (COOP/COEP headers via serve.py, port from $1, default 8000), plus the
# same payload as a zip for deployment.
#
# Two runtime variants are built:
#   release  fast, uses pthreads/SharedArrayBuffer -> needs the COOP/COEP
#            headers that serve-web already sends (fine on localhost and on
#            hosts with cross-origin isolation, e.g. itch.io's experimental
#            SAB support)
#   compat   slower single-threaded fallback (-c), works without those
#            headers -> for hosts that can't set them
{ pkgs, config, loveVersion, webMemory, loveJsCli, loveFile, ... }:
let
  mkWeb =
    compat:
    pkgs.runCommand "${config.name}-${config.version}-web${pkgs.lib.optionalString compat "-compat"}"
      {
        nativeBuildInputs = [ pkgs.nodejs pkgs.makeWrapper ];
        inherit
          webMemory
          loveJsCli
          loveFile
          ;
      }
      ''
        set -e
        work=$(mktemp -d)
        node ${loveJsCli}/node_modules/love.js/index.js \
          ${pkgs.lib.optionalString compat "--compatibility"} \
          --title "${config.title}" --memory "$webMemory" \
          "$loveFile" "$work"
        dir="$out/share/${config.name}-${config.version}-web${pkgs.lib.optionalString compat "-compat"}"
        mkdir -p "$out/share" "$out/bin"
        mv "$work" "$dir"
        # the CLI copied src/${if compat then "compat" else "release"} (the
        # LÖVE ${loveVersion} runtime) into the output; just add the COOP/COEP
        # dev server from the package
        cp ${loveJsCli}/node_modules/love.js/sample/serve.py "$dir/serve.py"
        find "$dir" -exec touch -h -d '@1' {} +
        makeWrapper ${pkgs.python3}/bin/python3 "$out/bin/serve-web" \
          --run "cd $out/share/${config.name}-${config.version}-web${pkgs.lib.optionalString compat "-compat"}" \
          --add-flags "serve.py"
      '';

  mkZip =
    name: src:
    pkgs.runCommand "${name}.zip" { nativeBuildInputs = [ pkgs.zip ]; } ''
      cd ${src}/share
      env TZ=UTC zip -q -r -9 -X "$out" "${name}"
    '';

  webApp = mkWeb false;
  webAppCompat = mkWeb true;
in
{
  inherit webApp webAppCompat;
  webZip = mkZip "${config.name}-${config.version}-web" webApp;
  webCompatZip = mkZip "${config.name}-${config.version}-web-compat" webAppCompat;
}
