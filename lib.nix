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
    };

    lib = {
      fnPlugins = mkOption {
        type = with types; attrsOf unspecified;
        default = { };
        description =
          "A set of plugins for supplementary functions and modules";
      };
      modules = mkOption {
        type = with types; listOf unspecified;
        default = [ ];
      };
      configs = mkOption {
        type = types.submoduleWith {
          modules = cfg.modules;
          shorthandOnlyDefinesConfig = true;
        };
        default = { };
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
  };
}
