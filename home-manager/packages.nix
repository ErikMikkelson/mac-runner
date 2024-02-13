{ pkgs }:

let
  basic = with pkgs; [
    coreutils
    findutils
    tree
    unzip
    wget
    zstd
  ];

  buildTools = with pkgs; [
    cmake
  ];

  jsTools = (with pkgs; [
    bun
    deno
  ] ++ (with nodePackages; [
    pnpm
  ]));

  macTools = with pkgs.darwin.apple_sdk.frameworks; [
    CoreServices
    Foundation
    Security
  ];

  nixTools = with pkgs; [
    fh
    flake-checker
    nixfmt
    nixpkgs-fmt
  ];

  pythonTools = with pkgs; [ python311 ] ++ (with pkgs.python311Packages; [
    httpie
  ]);

  scripts = with pkgs; [
    (writeScriptBin "pk" ''
      if [ $# -eq 0 ]; then
        echo "No search term supplied"
      fi

      pgrep -f $1 | xargs kill -9
    '')
  ];

in
basic
++ buildTools
++ jsTools
++ macTools
++ nixTools
++ pythonTools
++ scripts
