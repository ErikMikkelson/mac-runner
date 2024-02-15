{ pkgs, android-nixpkgs, ... }:

let
  android-sdk = android-nixpkgs.sdk.${pkgs.system} (sdkPkgs: with sdkPkgs; [
    # Android SDK tools
    build-tools-32-0-0
    cmdline-tools-latest
    platform-tools
    platforms-android-31
  ]);
in
with pkgs; [
  # General packages for development and system management
  bat
  coreutils
  curl
  wget
  zip

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Node.js development tools
  nodejs
  yarn

  # Text and terminal utilities
  jq
  unzip

  # Python packages
  # python39
  # python39Packages.virtualenv # globally install virtualenv

  android-sdk
]
