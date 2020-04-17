![icebox logo](./logo.svg)
<central># icebox<central>
A simple and generic NixOS configuration framework (*currently only on unstable channel*)
## What it is
- A plugin toolkit
- A system configuration setup framework
## What it is not
- A plugin/package manager. (It could not handle version and dependencies yet. And I have no intention currently to do it).
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
