# Shared game source and build inputs. The game's identity (name, version,
# title, loveVersion) lives in game/conf.json via config.nix.
{ pkgs, ... }:
let
  config = import ./config.nix;

  # only what goes into the .love: lua/fennel sources in any directory,
  # conf.json (read by the game at runtime), plus everything in lib/ and
  # assets/; dev-only scripts/ is excluded
  gameSrc = builtins.path {
    path = ../../../game;
    name = "${config.name}-src";
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
          rel == "conf.json"
          || pkgs.lib.hasSuffix ".lua" rel
          || pkgs.lib.hasSuffix ".fnl" rel
          || pkgs.lib.hasSuffix ".fnlm" rel
          || pkgs.lib.hasPrefix "lib/" rel
          || pkgs.lib.hasPrefix "assets/" rel
        )
      );
  };

  # packaged builds ship precompiled lua, not fennel sources: compile every
  # .fnl to a sibling .lua, then drop .fnl/.fnlm (macros are compile-time
  # only). lib/fennel.lua stays: main.lua bootstraps the runtime searcher
  # and core/utils uses fennel.view for pprint.
  gameCompiled = pkgs.runCommand "${config.name}-compiled-${config.version}"
    { nativeBuildInputs = [ pkgs.luaPackages.fennel ]; }
    ''
      cp -r ${gameSrc} game
      chmod -R u+w game
      cd game
      find . -name '*.fnl' | LC_ALL=C sort | while read -r f; do
        fennel --compile "$f" > "''${f%.fnl}.lua"
      done
      find . \( -name '*.fnl' -o -name '*.fnlm' \) -delete
      cd ..
      mv game $out
    '';
in
{
  inherit
    config
    gameSrc
    gameCompiled
    ;
  # love version the game targets; keep in sync with game/conf.lua t.version
  # (both should eventually come from conf.json's loveVersion)
  loveVersion = config.loveVersion;
  webMemory = 67108864; # wasm heap for the love.js runtime, in bytes (64 MiB)

  # On non-NixOS hosts the nix-built love binary cannot see the system GPU
  # drivers; point glvnd at nixpkgs' Mesa instead. See nix/gpu-env.nix.
  gpuEnv = import ../../gpu-env.nix pkgs;
}
