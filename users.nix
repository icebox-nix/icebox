{ config, lib, ... }:

with lib;

let
  cfg = config.icebox.users;
  # We should not let it throw error if path is not viable since users could just use the default settings.
  # If path doesn't exist, default value `{ }` would be returned.
  convertOptions = path:
    (attrsets.mapAttrs (n: v: (lib.attrsets.attrByPath path { } v)) cfg.users);

  usersOpts = {
    options = {
      # We don't need `default` here because attrByPath would automatically return { } if path is not viable.
      regular = mkOption {
        type =
          types.unspecified; # Ultimately would be passed into `users.users` and get checked.
        description = "Regular system level configurations for users.";
      };
      configs = mkOption {
        type = with types;
          attrsOf (unspecified); # attrset like { pluginsA = { its configs}; }
        description = "Configuration for plugin options.";
      };
    };
  };
in {
  options.icebox = {
    # FIXME: There must be option inside static in order to set `icebox.static....` later.
    static.users.reserved = mkOption {
      type =
        types.unspecified; # Using unspecified simply because this should never be filled in!
      visible = false;
      readOnly = true;
      default = { };
    };

    users = {
      plugins = mkOption {
        type = with types; listOf str;
        description =
          "Attribute names of plugins that are allowed to use here.";
        default = [ ];
      };
      users = mkOption {
        type = with types; attrsOf (submodule usersOpts);
        description =
          "Module for settings of either options in user profiles or options of user management in system-level.";
        default = { }; # Else error would be thrown in `convertOptions`.
      };
      groups = mkOption {
        type = types.unspecified;
        default = { };
        description = "Regular system level configurations for groups.";
      };
    };
  };

  config = {
    users.mutableUsers = false;
    users.groups = cfg.groups;
    users.users = convertOptions [ "regular" ];

    # Pass configuration to plugins
    icebox.static.users = config.icebox.static.lib.functions.genPluginConfigs
      (n: { configs = (convertOptions [ "configs" n ]); }) cfg;
  };
}
