zls_flake: self: super: {
  zls = super.zls.overrideAttrs (old: {
    src = zls_flake;
    nativeBuildInputs = [ super.pkgs.zig ];
  });
}

