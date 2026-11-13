{
  perSystem =
    { pkgs, self', ... }:
    let
      packages = with pkgs; [
        nixd
        nil

        cmake
        zip

        love
        luaPackages.fennel

        self'.packages.fennel-ls
        fnlfmt
        lua-language-server

        libglvnd
        wayland
      ];

    in
    {
      devShells.default = pkgs.mkShell {
        inherit packages;
        # Nix libs only. Never add the nix glibc here: on non-NixOS hosts,
        # system binaries launched in the shell would load it under the system
        # loader and crash ("GLIBC_2.xx not found" / segfaults). Nix-built
        # binaries resolve their own libc via interpreter + rpath.
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;
        shellHook = import ./gpu-env.nix pkgs;
      };
    };
}
