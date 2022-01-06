zig_flake: self: super: {
  zig = super.zig.overrideAttrs (old: {
    src = zig_flake;
    nativeBuildInputs = with super.pkgs; [ cmake llvmPackages_13.llvm.dev ];
    buildInputs = with super.pkgs;
      [ libxml2 zlib ]
      ++ (with super.pkgs.llvmPackages_13; [ libclang lld llvm ]);
    doCheck = false;
  });
}

