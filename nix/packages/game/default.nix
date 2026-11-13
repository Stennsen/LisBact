# Build and run outputs for the love2d/fennel game in ../../../game:
#   packages.love        the .love file
#   packages.web         the love.js web build (zip)
#   apps.run             nix run .#run         (love on the game source)
#   apps.serve-web       nix run .#serve-web   (serve the web build on :8000)
{
  perSystem =
    { pkgs, ... }:
    let
      gameName = "yeti";
      gameVersion = "0.1.0";
      gameAuthor = "Your Name";
      loveVersion = "11.5"; # must match game/conf.lua t.version
      canvasWidth = 720; # match game/conf.lua t.window.width
      canvasHeight = 450; # match game/conf.lua t.window.height
      canvasColour = "54,69,79";
      textColour = "240,234,214";

      # only what goes into the .love: top-level .lua/.fnl/.fnlm plus lib/ and assets/
      gameSrc = builtins.path {
        path = ../../../game;
        name = "${gameName}-src";
        filter =
          path: type:
          let
            rel = pkgs.lib.removePrefix "${toString ../../../game}/" (toString path);
            topLevel = !(pkgs.lib.hasInfix "/" rel);
          in
          type == "directory"
          || (topLevel && rel != "flsproject.fnl" && (
            pkgs.lib.hasSuffix ".lua" rel
            || pkgs.lib.hasSuffix ".fnl" rel
            || pkgs.lib.hasSuffix ".fnlm" rel
          ))
          || pkgs.lib.hasPrefix "lib/" rel
          || pkgs.lib.hasPrefix "assets/" rel;
      };

      loveFile = pkgs.runCommand "${gameName}-${gameVersion}.love" { nativeBuildInputs = [ pkgs.zip ]; } ''
        cd ${gameSrc}
        find . -type f | LC_ALL=C sort | env TZ=UTC zip -q -9 -X "$out" -@
      '';

      # prebuilt love.js runtime, fetched from the upstream template with pinned
      # hashes (the *.wasm files are gitignored, so the flake cannot see them in-repo)
      loveJsRuntime = {
        "11.5" = {
          js = pkgs.fetchurl {
            url = "https://codeberg.org/alexjgriffith/min-love2d-fennel/raw/branch/master/buildtools/love-js/src/love-11.5/compat/love.js";
            hash = "sha256-1AHQIjBcCxOj+l9VfpHeo51r5iOhqzeJzrPrvloFtkc=";
          };
          wasm = pkgs.fetchurl {
            url = "https://codeberg.org/alexjgriffith/min-love2d-fennel/raw/branch/master/buildtools/love-js/src/love-11.5/compat/love.wasm";
            hash = "sha256-qy2ZQ2ySci8+nP6R+thzzoSxCrPM8MZNd0ctMlvqJIg=";
          };
        };
      };

      # the web templates (index.html, game.js, love.css, serve.py, consolewrapper.js)
      # are vendored next to this module in ./love-js; the wasm runtime is fetched
      # pinned (loveJsRuntime), so the build is just sed/cp
      webRoot = pkgs.runCommand "${gameName}-${gameVersion}-web"
        {
          nativeBuildInputs = [ pkgs.zip ];
          inherit
            gameName
            gameVersion
            gameAuthor
            loveVersion
            canvasWidth
            canvasHeight
            canvasColour
            textColour
            ;
          loveJsSrc = ./love-js;
          loveFile = "${loveFile}";
          uuid = "2fd99e56-5455-45dd-86dd-7af724874d65";
        }
        ''
          set -e
          module_size=$(stat -c%s "$loveFile")
          title=$(printf '%s' "$gameName" | sed -r 's/\<./\U&/g' | sed -r 's/-/ /g')
          dir="$out/${gameName}-${gameVersion}-web"
          mkdir -p "$dir/theme"
          sed -e "s/{{title}}/$title/g" -e "s/{{version}}/$gameVersion/g" -e "s/{{author}}/$gameAuthor/g" \
              -e "s/{{width}}/$canvasWidth/g" -e "s/{{height}}/$canvasHeight/g" \
              -e "s/{{initial-memory}}/0/g" -e "s/{{canvas-colour}}/$canvasColour/g" \
              -e "s/{{text-colour}}/$textColour/g" \
              "$loveJsSrc/index.html" > "$dir/index.html"
          sed "s/{{page-colour}}/$canvasColour/g" "$loveJsSrc/love.css" > "$dir/theme/love.css"
          sed -e "s/{{{cachemodule}}}/true/g" \
              -e "s|{{{metadata}}}|{\"package_uuid\":\"$uuid\",\"remote_package_size\":$module_size,\"files\":[{\"filename\":\"/game.love\",\"crunched\":0,\"start\":0,\"end\":$module_size,\"audio\":false}]}|g" \
              "$loveJsSrc/game.js" > "$dir/game.js"
          cp "$loveJsSrc/serve.py" "$loveJsSrc/consolewrapper.js" "$dir/"
          cp "$loveFile" "$dir/game.love"
          cp ${loveJsRuntime.${loveVersion}.js} "$dir/love.js"
          cp ${loveJsRuntime.${loveVersion}.wasm} "$dir/love.wasm"
          find "$dir" -exec touch -h -d '@1' {} +
        '';

      web = pkgs.runCommand "${gameName}-${gameVersion}-web.zip" { nativeBuildInputs = [ pkgs.zip ]; } ''
        cd ${webRoot}
        env TZ=UTC zip -q -r -9 -X "$out" "${gameName}-${gameVersion}-web"
      '';
    in
    {
      packages = {
        love = loveFile;
        web = web;
        default = loveFile;
      };

      apps = {
        # nix run .#run -- launch the game locally with love; the flake is
        # re-evaluated on each run, so edits in game/ are picked up
        run = {
          type = "app";
          # On non-NixOS hosts the nix-built love binary cannot see the system
          # GPU drivers; expose them the same way nix/shell.nix does (host
          # dirs last, nix glvnd first, glvnd vendor configs from the host).
          program = "${pkgs.writeShellScript "yeti-run" ''
            if [[ "$(uname -s)" == "Linux" && ! -e /etc/NIXOS ]]; then
              hostDirs=""
              for d in /usr/lib/*-linux-gnu /usr/lib64 /usr/lib; do
                [[ -d "$d" ]] && hostDirs="$hostDirs:$d"
              done
              [[ -n "$hostDirs" ]] && export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.libglvnd ]}$hostDirs''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
              export __EGL_VENDOR_LIBRARY_DIRS="/usr/share/glvnd/egl_vendor.d:/etc/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"
            fi
            exec ${pkgs.love}/bin/love ${gameSrc} "$@"
          ''}";
        };
        # nix run .#serve-web -- serve the web build on http://localhost:8000
        # (custom port: nix run .#serve-web -- 8080); serve.py sets the
        # COOP/COEP headers love.js needs
        serve-web = {
          type = "app";
          program = "${pkgs.writeShellScript "yeti-serve-web" ''cd ${webRoot}/${gameName}-${gameVersion}-web && exec ${pkgs.python3}/bin/python3 serve.py "$@"''}";
        };
      };
    };
}
