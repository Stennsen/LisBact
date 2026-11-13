{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells.default = pkgs.mkShell rec {
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
        LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [pkgs.glibc]}:/run/current-system/sw/lib:/usr/lib64:/usr/lib:${pkgs.lib.makeLibraryPath packages}";
      };
    };
}
