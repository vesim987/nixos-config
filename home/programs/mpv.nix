{ config, pkgs, lib, ... }: {
  programs.mpv = {
    enable = true;
    config = {
      gpu-context = "waylandvk";
      hwdec = "vaapi";
      ytdl-format = "bestvideo[vcodec!=vp9]+bestaudio/best";
    };
  };

}
