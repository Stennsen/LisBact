# Single source of truth for the game's identity: game/conf.json, which the
# game itself also reads at runtime (see game/conf.lua). Nix reads it with
# builtins.fromJSON; only nix-side metadata (homepage for package meta) is
# added here.
let
  conf = builtins.fromJSON (builtins.readFile ../../../game/conf.json);
in
conf // {
  homepage = "https://github.com/Stennsen/lisbee";
}
