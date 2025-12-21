{ pkgs, unstable, ... }:

{
  #### CAD / 3D tools ####
  environment.systemPackages = with pkgs; [
    unstable.freecad   # pulled from nixos-unstable
    openscad
    blender
  ];

  #### OpenCASCADE / FreeCAD performance tweaks ####
  environment.sessionVariables = {
    OCC_DISPLAY_DRIVER = "OpenGL";
    OCC_Antialiasing   = "1";
    OCC_Shading        = "Phong";
  };

  #### Fonts (FreeCAD UI stability) ####
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
  ];
}
