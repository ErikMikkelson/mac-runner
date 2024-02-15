{ config, pkgs, lib, ... }:

let user = "%USER%";
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    plugins = [
    ];

    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi
    '';
  };

  git = {
    enable = true;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  ssh = {
    enable = true;

    extraConfig = lib.mkMerge [
      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          IdentityFile /Users/${user}/.ssh/id_github
        '')
    ];
  };
}
