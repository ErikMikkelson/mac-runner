{ pkgs }:

{
  # Configure HM itself
  home-manager = {
    enable = true;
  };

  # My fav shell
  zsh = import ./zsh.nix {
    inherit pkgs;
  };
}
