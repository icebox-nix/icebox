<h1 align="center">
	<a href="https://github.com/LEXUGE/icebox"><img src="./logo.svg" alt="icebox logo" width="256" height="256"/></a><br>
	icebox
</h1>

A simple and generic NixOS configuration framework written in pure Nix. (**currently only on unstable channel**)

## What it is
- A plugin toolkit
- A system configuration setup framework
- A set of simple Nix expressions
## What it is not
- A plugin/package manager. (It could not handle version and dependencies yet since it is really simple. And I have no intention currently to do it).
- flake
## Installation
Simply use following in your `/etc/nixos/configuration.nix`:

``` nix
let
  icebox = builtins.fetchTarball
    "https://github.com/LEXUGE/icebox/archive/master.tar.gz";
in {
  imports = [
    "${icebox}"
    # Other imports
  ];
  # Other settings
}
```

## What are "plugins"
Plugins could be any Nix modules! icebox provides plugins tools to configure per user stuff and abilities of sharing "interface" inter-pluginly, providing functions to other plugins. Also it endows users with uniform experience and ability of doing less. Some typical stuff a plugin could do would be:
- Provide user a hot fix which could be applied in a multi-user way. [Example](https://github.com/LEXUGE/nixos/blob/master/plugins/users/hm-fix.nix)
- Provide a configuration pack with overlays for new packages. [Example](https://github.com/icebox-nix/netkit.nix/tree/master/plugins/clash)

## Writing plugin is easy
Here is an example of a hacky hotfix towards home-manager issue #948. It would be automatically applied to every user defined in `icebox.users.users` (if it is listed in `icebox.users.plugins`.
``` nix
{ config, lib, pkgs, ... }:
let
  iceLib = config.icebox.static.lib;
  cfg = config.icebox.static.users.hm-fix;
in {
  options.icebox.static.users.hm-fix = with lib;
    mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption
            "the Desktop Environment falovored by ash"; # If this is off, nothing should be configured at all.

          configs = mkOption {
            type = with types;
              attrsOf (submodule {
                options.enable = mkOption {
                  type = types.bool;
                  default = true;
                  description =
                    "Whether to enable a (hacky) patch plugin for home-manager issue #948.";
                };
              });
            default = { };
          };
        };
      };
      default = { };
    };
  config.systemd.services =
    iceLib.functions.mkUserConfigs (n: c: "home-manager-${n}") (n: c: {
      # Hacky workaround of issue 948 of home-manager
      preStart = ''
        ${pkgs.nix}/bin/nix-env -i -E
      '';
    }) cfg;
}
```

# Security
Plugins are like packages and **should go under scrutiny**. icebox ensures that if plugin is using functions provided (like `iceLib.functions.mkUserConfigs`), and
it does nothing under `enable = false`, then this plugin would only take effect if you list it explicitly in the respective `plugins` option.

# Related stuff
- [netkit.nix](https://github.com/icebox-nix/netkit.nix). Verstile icebox plugins for advanced networking scenarios in NixOS. (I use it heavily, and it works out-of-box!)
- [std](https://github.com/icebox-nix/std). Standard library for icebox.
- [nixos](https://github.com/LEXUGE/nixos). My personal nixos configuration consisting of icebox plugins only.
