# Sourced by nix/shell.nix (shellHook) and by the `run` app wrapper in
# nix/packages/game/default.nix.
#
# On non-NixOS Linux (Ubuntu etc.), let nix-built GUI binaries (love) find the
# host's GPU vendor libraries. ONLY vendor libs are exposed, via a symlink
# farm in a temp dir. Never put the host multiarch dir itself on
# LD_LIBRARY_PATH: it contains libc/libm, and LD_LIBRARY_PATH is searched
# before the binary's RUNPATH, so the older host glibc would be loaded into
# the nix process and every nix lib would fail with "GLIBC_2.xx not found".
# (Conversely the nix glibc must never be on LD_LIBRARY_PATH either, or system
# binaries crash — see nix/shell.nix.)
if [[ "$(uname -s)" == "Linux" && ! -e /etc/NIXOS ]]; then
  gpuDir="$(mktemp -d /tmp/nix-gpu-libs.XXXXXX)"
  for d in /usr/lib/*-linux-gnu /usr/lib64 /usr/lib; do
    [[ -d $d ]] || continue
    for f in "$d"/libEGL_*.so.* "$d"/libGLX_*.so.* "$d"/libGLES*.so.* \
             "$d"/libnvidia-*.so.* "$d"/libvulkan_*.so.* "$d"/libvk_*.so.*; do
      [[ -e $f ]] && ln -sf "$f" "$gpuDir/"
    done
  done
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$gpuDir"
  # the nix libglvnd's compiled-in vendor-config paths point into the nix
  # store; point them at the host's so EGL picks the right vendor (the vendor
  # lib itself is found via the symlink farm above)
  export __EGL_VENDOR_LIBRARY_DIRS="/usr/share/glvnd/egl_vendor.d:/etc/glvnd/egl_vendor.d:$HOME/.local/share/glvnd/egl_vendor.d${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"
  for d in /usr/lib/*-linux-gnu /usr/lib64; do
    [[ -e "$d/libGLX_nvidia.so.0" ]] && export __GLX_VENDOR_LIBRARY_NAME=nvidia
  done
  icds=$(ls /usr/share/vulkan/icd.d/*.json /etc/vulkan/icd.d/*.json 2>/dev/null | paste -sd: -)
  [[ -n "$icds" ]] && export VK_ICD_FILENAMES="$icds${VK_ICD_FILENAMES:+:$VK_ICD_FILENAMES}"
fi
