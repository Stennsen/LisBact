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

    in
    {
      devShells.default = pkgs.mkShell {
        inherit packages;
        # Nix libs only. Never add the nix glibc here: on non-NixOS hosts,
        # system binaries launched in the shell would load it under the system
        # loader and crash ("GLIBC_2.xx not found" / segfaults). Nix-built
        # binaries resolve their own libc via interpreter + rpath.
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;
        shellHook = ''
          # On non-NixOS Linux (Ubuntu etc.) let nix-built GUI apps (love) find
          # the host's GPU drivers. Host dirs go LAST in LD_LIBRARY_PATH so the
          # nix libs above always win; the host only supplies vendor libraries
          # nix does not ship (libEGL_nvidia, libGLX_mesa, ...).
          if [[ "$(uname -s)" == "Linux" && ! -e /etc/NIXOS ]]; then
            hostDirs=""
            for d in /usr/lib/*-linux-gnu /usr/lib64 /usr/lib /run/current-system/sw/lib; do
              [[ -d "$d" ]] && hostDirs="$hostDirs:$d"
            done
            [[ -n "$hostDirs" ]] && export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:-}$hostDirs"
            # the nix libglvnd's compiled-in vendor-config paths point into the
            # nix store; point them at the host's so EGL picks the right vendor
            export __EGL_VENDOR_LIBRARY_DIRS="/usr/share/glvnd/egl_vendor.d:/etc/glvnd/egl_vendor.d:$HOME/.local/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"
            for d in /usr/lib/*-linux-gnu /usr/lib64; do
              [[ -e "$d/libGLX_nvidia.so.0" ]] && export __GLX_VENDOR_LIBRARY_NAME=nvidia
            done
            icds=$(ls /usr/share/vulkan/icd.d/*.json /etc/vulkan/icd.d/*.json 2>/dev/null | paste -sd: -)
            [[ -n "$icds" ]] && export VK_ICD_FILENAMES="$icds''${VK_ICD_FILENAMES:+:$VK_ICD_FILENAMES}"
          fi
        '';
      };
    };
}
