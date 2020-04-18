{ config, lib, ... }:

with lib;

{
  imports = [ ./system.nix ./users.nix ./devices.nix ./lib.nix ];
  options.icebox.overlays = mkOption {
    type = with types; listOf unspecified;
    default = [ ];
    description =
      "Set overlays. This option simply passes its value to <option>config.nixpkgs.overlays</option>.";
    example = [
      (self: super: {
        ir_toggle = (super.callPackage ./packages/ir_toggle.nix { });
      })
    ];
  };
  config.nixpkgs.overlays = config.icebox.overlays;
}
