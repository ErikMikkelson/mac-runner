switch:
  darwin-rebuild switch --flake .#default

apply:
  nix develop --command reload .#default
