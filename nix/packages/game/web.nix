# The love.js web build: proper package layout with the payload in
# $out/share/<name>-<version>-web/ and a $out/bin/serve-web launcher
# (COOP/COEP headers via serve.py, port from $1, default 8000), plus the
# same payload as a zip for deployment.
{ pkgs, config, loveVersion, webMemory, loveJsCli, loveFile, ... }:
let
  webApp = pkgs.runCommand "${config.name}-${config.version}-web"
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
        --compatibility --title "${config.title}" --memory "$webMemory" \
        "$loveFile" "$work"
      dir="$out/share/${config.name}-${config.version}-web"
      mkdir -p "$out/share" "$out/bin"
      mv "$work" "$dir"
      # the CLI copied src/compat (the LÖVE ${loveVersion} runtime) into
      # the output; just add the COOP/COEP dev server from the package
      cp ${loveJsCli}/node_modules/love.js/sample/serve.py "$dir/serve.py"
      find "$dir" -exec touch -h -d '@1' {} +
      makeWrapper ${pkgs.python3}/bin/python3 "$out/bin/serve-web" \
        --run "cd $out/share/${config.name}-${config.version}-web" \
        --add-flags "serve.py"
    '';

  webZip = pkgs.runCommand "${config.name}-${config.version}-web.zip" { nativeBuildInputs = [ pkgs.zip ]; } ''
    cd ${webApp}/share
    env TZ=UTC zip -q -r -9 -X "$out" "${config.name}-${config.version}-web"
  '';
in
{
  inherit webApp webZip;
}
