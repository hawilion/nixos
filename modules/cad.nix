{ pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    freecad      # comes from overlay (pinned unstable)
    openscad
    blender
  ];

  environment.sessionVariables = {
    OCC_DISPLAY_DRIVER = "OpenGL";
    OCC_Antialiasing   = "1";
    OCC_Shading        = "Phong";
  };

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
  ];
}
