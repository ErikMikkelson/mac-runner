{ pkgs, android-nixpkgs, ... }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs android-nixpkgs; }; in
shared-packages ++ [
]
