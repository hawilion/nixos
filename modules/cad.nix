{ pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    # Wrapped FreeCAD to fix the disappearing Task Panel on Wayland
    (symlinkJoin {
      name = "freecad-wrapped";
      paths = [ unstable.freecad ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/FreeCAD --set QT_QPA_PLATFORM xcb
      '';
    })

    git
    python312Packages.gitpython
     
    # Standard CAD tools
    openscad
    calculix-ccx
    gmsh
    adwaita-icon-theme
  ];

  environment.sessionVariables = {
    __GLVND_EXPOSE_NATIVE_CONTEXTS = "1";
    QT_X11_NO_MITSHM = "1";
  };
}
