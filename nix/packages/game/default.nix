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
      loveVersion = "11.5"; # must match game/conf.lua t.version
      webMemory = 67108864; # wasm heap for the love.js runtime, in bytes (64 MiB)

      # only what goes into the .love: lua/fennel sources in any directory
      # plus everything in lib/ and assets/; dev-only scripts/ is excluded
      gameSrc = builtins.path {
        path = ../../../game;
        name = "${gameName}-src";
        filter =
          path: type:
          let
            rel = pkgs.lib.removePrefix "${toString ../../../game}/" (toString path);
          in
          type == "directory"
          || (
            !(pkgs.lib.hasPrefix "." rel)
            && !(pkgs.lib.hasPrefix "scripts/" rel)
            && (
              pkgs.lib.hasSuffix ".lua" rel
              || pkgs.lib.hasSuffix ".fnl" rel
              || pkgs.lib.hasSuffix ".fnlm" rel
              || pkgs.lib.hasPrefix "lib/" rel
              || pkgs.lib.hasPrefix "assets/" rel
            )
          );
      };

      loveFile = pkgs.runCommand "${gameName}-${gameVersion}.love" { nativeBuildInputs = [ pkgs.zip ]; } ''
        cd ${gameSrc}
        find . -type f | LC_ALL=C sort | env TZ=UTC zip -q -9 -X "$out" -@
      '';

      # love.js (https://github.com/Davidobot/love.js) CLI run under node to
      # render the web template and crunch the .love into game.data; its npm
      # dependencies are pinned below by registry integrity hash, so no
      # template files are vendored in this repo.
      npmTarball =
        name: version: hash:
        pkgs.fetchurl {
          url = "https://registry.npmjs.org/${name}/-/${name}-${version}.tgz";
          inherit hash;
        };
      # love.js itself from Davidobot/love.js (the repo the npm `love.js` CLI
      # package is published from), pinned at a commit whose src/compat ships
      # the LÖVE ${loveVersion} runtime; the published npm tarball only has 11.4
      loveJsCommit = "c4f04e185033a7c9fbefa9be3bec88c41a90421b";
      loveJsSrc = pkgs.fetchurl {
        url = "https://codeload.github.com/Davidobot/love.js/tar.gz/${loveJsCommit}";
        hash = "sha256-tDEpaEqh+3tjMGTDeILSWngJ5ePE0Nk4iFvzldJOfRM=";
      };
      loveJsCli = pkgs.runCommand "love.js-cli" { nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ]; } (
        ''
          mkdir -p $out/node_modules
        ''
        + pkgs.lib.concatMapStringsSep "\n" (p: ''
          mkdir -p $out/node_modules/${p.name}
          tar xzf ${p.src} -C $out/node_modules/${p.name} --strip-components=1
        '') [
          {
            name = "love.js";
            src = loveJsSrc;
          }
          {
            name = "commander";
            src = npmTarball "commander" "2.20.3" "sha512-GpVkmM8vF2vQUkj2LvZmD35JxeJOLCwJ9cUkugyk2nuhbv3+mJvpLYYt+0+USMxE+oj+ey/lJEnhZw75x/OMcQ==";
          }
          {
            name = "fs-extra";
            src = npmTarball "fs-extra" "3.0.1" "sha512-V3Z3WZWVUYd8hoCL5xfXJCaHWYzmtwW5XWYSlLgERi8PWd8bx1kUHUk8L1BT57e49oKnDDD180mjfrHc1yA9rg==";
          }
          {
            name = "graceful-fs";
            src = npmTarball "graceful-fs" "4.2.11" "sha512-RbJ5/jmFcNNCcDV5o9eTnBLJ/HszWV0P73bc+Ff4nS/rJj+YaS6IGyiOL0VoBYX+l1Wrl3k63h/KrH+nhJ0XvQ==";
          }
          {
            name = "jsonfile";
            src = npmTarball "jsonfile" "2.4.0" "sha512-PKllAqbgLgxHaj8TElYymKCAgrASebJrWpTnEkOaTowt23VKXXN0sUeriJ+eh7y6ufb/CC5ap11pz71/cM0hUw==";
          }
          {
            name = "klaw-sync";
            src = npmTarball "klaw-sync" "2.1.0" "sha512-lIxVCUMQIF7hfygFfdZgv4Z+e1smLroaYNQMUcf1TcJ5oqxj9m8qk19iIuMVl+tXQPr3CSE4V+4XjGEqmsth0Q==";
          }
          {
            name = "mustache";
            src = npmTarball "mustache" "2.3.2" "sha512-KpMNwdQsYz3O/SBS1qJ/o3sqUJ5wSb8gb0pul8CO0S56b9Y2ALm8zCfsjPXsqGFfoNBkDwZuZIAjhsZI03gYVQ==";
          }
          {
            name = "universalify";
            src = npmTarball "universalify" "0.1.2" "sha512-rBJeI5CXAlmy1pV+617WB9J63U6XcazHHF2f2dbJix4XzpUF0RS3Zbj0FGIOCAva5P/d/GBOYaACQ1w+0azUkg==";
          }
          {
            name = "uuid";
            src = npmTarball "uuid" "3.4.0" "sha512-HjSDRw6gZE5JMggctHBcjVak08+KEVhSIiDzFnT9S9aegmp85S/bReBVTb4QTFaRNptJ9kuYaNhnbNEOkbKb/A==";
          }
        ]
      );

      webRoot = pkgs.runCommand "${gameName}-${gameVersion}-web"
        {
          nativeBuildInputs = [ pkgs.nodejs ];
          inherit
            gameName
            gameVersion
            webMemory
            loveJsCli
            ;
          loveFile = "${loveFile}";
        }
        ''
          set -e
          title=$(printf '%s' "$gameName" | sed -r 's/\<./\U&/g' | sed -r 's/-/ /g')
          work=$(mktemp -d)
          node ${loveJsCli}/node_modules/love.js/index.js \
            --compatibility --title "$title" --memory "$webMemory" \
            "$loveFile" "$work"
          dir="$out/${gameName}-${gameVersion}-web"
          mkdir -p "$out"
          mv "$work" "$dir"
          # the CLI copied src/compat (the LÖVE ${loveVersion} runtime) into
          # the output; just add the COOP/COEP dev server from the package
          cp ${loveJsCli}/node_modules/love.js/sample/serve.py "$dir/serve.py"
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
          # GPU drivers; use nixpkgs' Mesa, see nix/gpu-env.nix.
          program = "${pkgs.writeShellScript "yeti-run" ''
            ${import ../../gpu-env.nix pkgs}
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
