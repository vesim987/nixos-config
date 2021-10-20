{ pkgs, ... }: {
  home.packages = with pkgs; [ gdb11 ];

  xdg.configFile."gdb/gdbinit".text = ''
    set disassembly-flavor intel
    set history save on
    set print pretty on
  '';
  xdg.configFile."gdb/gdbearlyinit".text = ''
    set startup-quietly on
  '';
}
