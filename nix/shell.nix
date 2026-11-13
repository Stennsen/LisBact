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

        libglvnd
        wayland
      ];

      hostLibDirs = pkgs.lib.concatStringsSep ":" (
        pkgs.lib.filter builtins.pathExists [
          "/run/current-system/sw/lib"
          "/usr/lib/x86_64-linux-gnu"
          "/usr/lib64"
          "/usr/lib"
        ]
      );
    in
    {
      devShells.default = pkgs.mkShell {
        inherit packages;
        LD_LIBRARY_PATH =
          pkgs.lib.makeLibraryPath packages
          + pkgs.lib.optionalString (pkgs.stdenv.hostPlatform.isLinux && hostLibDirs != "")
            ":${hostLibDirs}";
      };
    };
}
