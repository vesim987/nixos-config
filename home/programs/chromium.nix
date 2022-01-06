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
  createChromiumExtension =
    createChromiumExtensionFor (lib.versions.major pkgs.chromium.version);
in {
  programs.chromium = {
    enable = true;
    package = (pkgs.chromium.override {
      #commandLineArgs = [
      #  "--enable-features=UseOzonePlatform"
      #  "--ozone-platform=wayland"
      #];
    });

    #extensions = [
    #  (createChromiumExtension {
    #    # ublock origin
    #    id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
    #    sha256 = "sha256:0w9hp8dx4l4lyy4wfl1s8wif3s1kvz88wlvkh8g68y7hkqgpk3i6";
    #    version = "1.38.6";
    #  })
    #  (createChromiumExtension {
    #    # enpass
    #    id = "kmcfomidfpdkfieipokbalgegidffkal";
    #    sha256 = "sha256:1jc66j6sbpbrbaf7f8plzqrqdgds23rdjky9cz62cx1mnrhdsqdb";
    #    version = "6.6.2";
    #  })
    #];
  };

}
