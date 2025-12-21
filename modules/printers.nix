{ config, pkgs, lib, ... }:

{
  services.printing = {
    enable = true;

    drivers = [
      pkgs.brgenml1lpr
      pkgs.brgenml1cupswrapper
    ];

    # Allow auto-discovery via IPP
    browsed.enable = true;
  };

  # Optional: If IPP autodiscovery fails, specify manually
  hardware.printers.ensurePrinters = [
    {
      name = "Brother-MFC-L2710DW";
      deviceUri = "ipp://192.168.79.190/ipp/print";  # your printer's IP
      model = "everywhere";  # use IPP Everywhere PPD
    }
  ];
}
