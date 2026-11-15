# Build and run outputs for the love2d/fennel game in ../../../game.
# The game's name/version/title/loveVersion live in game/conf.json (via
# config.nix) — change them there.
#
#   packages.game        $out/bin/game.love + $out/bin/<name> launcher (default)
#   packages.love        the raw .love file
#   packages.web         release love.js build (fast, needs COOP/COEP): share/ + bin/serve-web
#   packages.webZip      the release web build as a zip
#   packages.webCompat   compat love.js build (-c, slower, no COOP/COEP needed)
#   packages.webCompatZip  the compat web build as a zip
#   packages.win         $out/bin/<name>.exe + dlls (self-contained), docs in share/
#   packages.winZip      the windows build as a zip (one distributable folder)
#   checks.game-loads    the packaged .love is precompiled lua with all entry points present
#   apps.run             nix run .#run         (love on the game source)
#   apps.serve-web       nix run .#serve-web   (serve the web build on :8000)
#
# split into config.nix (reads game/conf.json), src.nix (source/constants),
# love.nix (desktop), lovejs.nix (web toolchain), web.nix (web), windows.nix (win64)
{
  perSystem =
    args@{ pkgs, lib, ... }:
    let
      src = import ./src.nix args;
      config = src.config;
      lovejs = import ./lovejs.nix (args // src);
      love = import ./love.nix (args // src);
      web = import ./web.nix (args // src // lovejs // love);
      win = import ./windows.nix (args // src // love);

      meta = {
        license = lib.licenses.gpl3Only;
        homepage = config.homepage;
      };

      game = love.game // {
        meta = meta // {
          description = "${config.title}: love2d/fennel game — bin/game.love plus a ${config.name} launcher";
          mainProgram = config.name;
        };
      };
    in
    {
      packages = {
        inherit game;
        love = love.loveFile // {
          meta = meta // {
            description = "${config.title} as a raw .love file";
          };
        };
        web = web.webApp // {
          meta = meta // {
            description = "${config.title} web build (love.js release runtime, fast): share/<name>-<ver>-web plus a serve-web launcher";
          };
        };
        webZip = web.webZip // {
          meta = meta // {
            description = "${config.title} web build (release runtime) as a zip";
          };
        };
        webCompat = web.webAppCompat // {
          meta = meta // {
            description = "${config.title} web build (love.js compat runtime, slower, works without COOP/COEP headers)";
          };
        };
        webCompatZip = web.webCompatZip // {
          meta = meta // {
            description = "${config.title} web build (compat runtime) as a zip";
          };
        };
        win = win.winApp // {
          meta = meta // {
            description = "${config.title} Windows build: self-contained bin/ with fused ${config.name}.exe + dlls, docs in share/";
          };
        };
        winZip = win.winZip // {
          meta = meta // {
            description = "${config.title} Windows build as a zip (distribute the whole folder, the exe needs its dlls)";
          };
        };
        default = game;
      };

      # smoke check on the packaged game: entry points and compiled modules
      # present, no fennel sources shipped
      checks.game-loads = pkgs.runCommand "${config.name}-game-loads"
        { nativeBuildInputs = [ pkgs.unzip ]; }
        ''
          mkdir game && cd game
          unzip -q ${love.loveFile}
          test -f main.lua
          test -f conf.lua
          test -f conf.json
          test -f wrap.lua
          test -f modes/map.lua
          test -f lib/fennel.lua
          if find . \( -name '*.fnl' -o -name '*.fnlm' \) | grep -q .; then
            echo "packaged game still contains fennel sources" >&2
            exit 1
          fi
          touch $out
        '';

      apps = {
        # nix run .#run -- launch the game locally with love; the flake is
        # re-evaluated on each run, so edits in game/ are picked up
        run = {
          type = "app";
          program = "${pkgs.writeShellScript "${config.name}-run" ''
            ${src.gpuEnv}
            exec ${pkgs.love}/bin/love ${src.gameSrc} "$@"
          ''}";
          meta.description = "Run ${config.title} from the live game/ source with love";
        };
        # nix run .#serve-web -- serve the web build on http://localhost:8000
        # (custom port: nix run .#serve-web -- 8080)
        serve-web = {
          type = "app";
          program = "${web.webApp}/bin/serve-web";
          meta.description = "Serve the ${config.title} web build on http://localhost:8000 (pass a port to override)";
        };
      };
    };
}
