{ pkgs, lib, config, ... }:

let
  cfg = config.services.libreoffice-minimal;
in {
  options.services.libreoffice-minimal.enable = 
    lib.mkEnableOption "a bare-bones Linux LibreOffice installation";

  config = lib.mkIf cfg.enable {
    # 1. Essential: Explicitly disable Java to shrink the dependency tree
    nixpkgs.config.libreoffice.java = false;

    environment.systemPackages = [
      # 2. Wrap the native Linux package
      (pkgs.symlinkJoin {
        name = "libreoffice-minimal";
        # Use 'fresh' for the latest 25.11 features or 'still' for stability
        paths = [ pkgs.libreoffice-fresh ]; 
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/libreoffice \
            --add-flags "--nologo" \
            --add-flags "--nodefault" \
            --add-flags "--norestore"
        '';
      })
      pkgs.liberation_ttf
    ];

    programs.bash.shellAliases = {
      "lo" = "libreoffice";
      "calc" = "libreoffice --calc";
      "writer" = "libreoffice --writer";
    };
  };
}
