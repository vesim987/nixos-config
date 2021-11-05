{ config, pkgs, lib, ... }:
let
  createChromiumExtensionFor = browserVersion:
    { id, sha256, version }: {
      inherit id;
      crxPath = builtins.fetchurl {
        url =
          "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
        name = "${id}.crx";
        inherit sha256;
      };
      inherit version;
    };
  createChromiumExtension = createChromiumExtensionFor
    (lib.versions.major pkgs.ungoogled-chromium.version);
in {
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;

    extensions = [
      (createChromiumExtension {
        # ublock origin
        id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
        sha256 = "sha256:12ps948lg91bbjxjmwb3d8590q8rf4mv7bkhzrjnnd210gbl5wxn";
        version = "1.38.6";
      })
      (createChromiumExtension {
        # enpass
        id = "kmcfomidfpdkfieipokbalgegidffkal";
        sha256 = "sha256:1gf1ycjqgky5z5x3jlhjkdhyylnxrwal1yqwln5mr0gznks37j7d";
        version = "6.6.2";
      })
    ];
  };

}
