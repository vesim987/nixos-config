{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    zig = {
      url = "github:ziglang/zig";
      flake = false;
    };
    zls = {
      url = "https://github.com/zigtools/zls.git";
      flake = false;
      type = "git";
      submodules = true;
    };

  };
  outputs = { home-manager, nixpkgs, neovim-nightly-overlay, zig, zls, ... }:
    let
      overlays = [
        neovim-nightly-overlay.overlay
        ((import ./overlays/zig.nix) zig)
        ((import ./overlays/zls.nix) zls)
      ];
    in {
      nixosConfigurations = {
        storm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.overlays = overlays; }
            ./hosts/storm.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.vesim = import ./home/default.nix;
            }
          ];
        };
        hurricine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ { nixpkgs.overlays = overlays; } ./hosts/hurricane.nix ];
        };
      };
    };
}
