{
  # top-level flake attrs must be literals (pure eval rejects import here),
  # so this is the one place that repeats the name — all build outputs derive
  # from game/conf.json
  description = "YETI SPIEL";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      imports = [ ./nix ];
    };
}
