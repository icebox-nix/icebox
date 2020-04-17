{ config, lib, ... }:

with lib;

let cfg = config.icebox.devices;
in {
  options.icebox = {
    # FIXME: There must be option inside static in order to set `icebox.static....` later.
    static.devices.reserved = mkOption {
      type = types.unspecified;
      visible = false;
      readOnly = true;
      default = { };
    };

    devices = {
      plugins = mkOption {
        type = with types; listOf str;
        description =
          "Attribute names of plugins that are allowed to use here.";
        default = [ ];
      };

      configs = mkOption {
        type = with types; attrsOf unspecified;
        description = "Configuration for plugins";
        default = { };
      };
    };
  };

  config = {
    icebox.static.devices =
      config.icebox.static.lib.functions.filterPluginConfigs cfg;
  };
}
