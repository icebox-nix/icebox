{ config, lib, ... }:

with lib;

let cfg = config.icebox.system;
in {
  options.icebox = {
    # FIXME: There must be option inside static in order to set `icebox.static....` later.
    static.system.reserved = mkOption {
      type =
        types.unspecified; # Using unspecified simply because this should never be filled in!
      visible = false;
      readOnly = true;
      default = { };
    };

    system = {
      plugins = mkOption {
        type = with types; listOf str;
        description =
          "Attribute names of plugins that are allowed to use here.";
        default = [ ];
      };

      configs = mkOption {
        type = with types;
          attrsOf unspecified; # attrset like { pluginsA = { its configs}; }
        description = "Configuration for plugins";
        default = { };
      };

      stateVersion = mkOption {
        type = types.str;
        description = "value of <option>system.stateVersion</option>.";
      };
    };
  };

  config = {
    system.stateVersion = cfg.stateVersion;
    icebox.static.system =
      config.icebox.static.lib.functions.filterPluginConfigs cfg;
  };
}
