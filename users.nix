{ config, lib, ... }:

with lib;

let
  cfg = config.icebox.users;
  convertOptions = path:
    (attrsets.mapAttrs (n: v: (lib.attrsets.attrByPath path { } v)) cfg.users);

  usersOpts = {
    options = {
      # We don't need `default` here because attrByPath would automatically return { } if path is not viable.
      regular = mkOption {
        type = types.unspecified;
        description = "Regular system level configurations for users.";
      };
      configs = mkOption {
        type = with types; attrsOf (unspecified);
        description = "Configuration for plugin options.";
      };
    };
  };
in {
  options.icebox = {
    # FIXME: There must be option inside static in order to set `icebox.static....` later.
    static.users.reserved = mkOption {
      type = types.unspecified;
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
        default = { };
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
    icebox.static.users = builtins.listToAttrs
      (map (n: attrsets.nameValuePair (n) (convertOptions [ "configs" n ]))
        cfg.plugins);
  };
}
