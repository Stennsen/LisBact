# Shell snippet sourced by the dev shell and the `run` app.
# On non-NixOS Linux, nix-built love can't load the host's Mesa (it needs the
# host glibc and pulls in host libgbm/libdrm/...), so point glvnd at nixpkgs'
# own Mesa instead. No host libs are ever put on LD_LIBRARY_PATH.
# ponytail: Mesa only (AMD/Intel/nouveau); NVIDIA proprietary needs nixGL.
pkgs:
pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
  if [[ ! -e /etc/NIXOS ]]; then
    export __EGL_VENDOR_LIBRARY_FILENAMES=${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.mesa pkgs.libglvnd ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
  fi
''
