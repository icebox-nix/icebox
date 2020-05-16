{ lib, config, ... }:

with lib;

let cfg = config.icebox.lib;
in {
  options.icebox = {
    static.lib = {
      functions = mkOption {
        type = with types; attrsOf unspecified;
        visible = false;
        default = { };
      };
      configs = mkOption {
        type = types.submoduleWith {
          modules = cfg.modules;
          shorthandOnlyDefinesConfig = true;
        };
        visible = false;
      };
    };

    lib = {
      fnPlugins = mkOption {
        type = with types; attrsOf unspecified;
        default = { };
        description =
          "A set of plugins for supplementary functions and modules";
        example = {
          filterPluginConfigs = cfg':
            (attrsets.mapAttrs (n: v: mkIf (any (a: a == n) cfg'.plugins) v)
              cfg'.configs);
        };
      };
      modules = mkOption {
        type = with types; listOf unspecified;
        default = [ ];
        description = "A list of modules to add.";
        example = [ (import ./path/to/foo.nix { lib = lib; }) ];
      };
      configs = mkOption {
        # If we use the same `submoduleWith` type like it uses in static.lib.configs, some options would be counted as setted twice, which is not what we want.
        type = types.unspecified;
        default = { };
        description =
          "Configs for options in modules defined in <option>config.icebox.lib.modules</option>";
      };
    };
  };

  config = {
    icebox.static.lib.functions = cfg.fnPlugins // rec {
      # Default functions

      # Generate configs with all plugins in `plugins` list set to enable and merge with value yielded by customized function.
      # We should not let it throw error if path is not viable since users could just use the default settings.
      # If path doesn't exist, default value `{ }` would be returned.
      genPluginConfigs = f: cfg':
        builtins.listToAttrs
        (map (n: attrsets.nameValuePair (n) ({ enable = true; } // (f n)))
          cfg'.plugins);
      # A shorthanded version for `genPluginConfigs` with user-set settings automatically from cfg'.configs.
      # Example:
      # > genPluginConfigs' { plugins = [ "a" ]; configs = { bar =1; }; }
      # { a = { enable = true; }; }
      genPluginConfigs' = cfg':
        genPluginConfigs (n: attrsets.attrByPath [ n ] { } cfg'.configs) cfg';

      # f is on LHS, g is on RHS
      # cfg' = { enable = true; configs = { userFoo = { some stuff here }; }; };
      mkUserConfigs = f: g: cfg':
        (mkIf (cfg'.enable) (attrsets.mapAttrs'
          (n: c: attrsets.nameValuePair (f n c) (mkIf (c.enable) (g n c)))
          cfg'.configs));
      # A shorthanded version of `mkUserConfigs` with LHS as "${name}".
      mkUserConfigs' = g: cfg': (mkUserConfigs (n: c: n) g cfg');
      # DEPRECATED! Probably would be removed in future versions.
      # If there is one or more of the users enable(s) the plugin, it would return true, else false.
      anyEnabled = cfg':
        (s: if (s != { }) then true else false)
        (filterAttrs (n: c: c.enable) cfg');
    };
    icebox.static.lib.configs = cfg.configs;
  };
}
