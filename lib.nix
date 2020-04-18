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
      filterPluginConfigs = cfg':
        (attrsets.mapAttrs (n: v: mkIf (any (a: a == n) cfg'.plugins) v)
          cfg'.configs);
      # f is on LHS, g is on RHS
      mkUserConfigs = f: g: cfg':
        (attrsets.mapAttrs'
          (n: c: attrsets.nameValuePair (f n c) (mkIf (c.enable) (g n c)))
          cfg');
      mkUserConfigs' = g: cfg': (mkUserConfigs (n: c: n) g cfg');
    };
    icebox.static.lib.configs = cfg.configs;
  };
}
