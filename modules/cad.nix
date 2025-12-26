{ pkgs, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    unstable.freecad
    git
    python312Packages.gitpython
    
    # Standard CAD tools (no extra fluff to break the build)
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
