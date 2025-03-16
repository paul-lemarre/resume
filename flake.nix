{
  description = "Dev env for node.js and poetry";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs =
    { self
    , flake-utils
    , nixpkgs
    , ...
    } @ inputs:
    flake-utils.lib.eachSystem
      [
        flake-utils.lib.system.x86_64-linux
      ]
      (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          shellBuildInputs = [
            pkgs.poetry
            pkgs.bashInteractive
            pkgs.jq
            pkgs.nodejs
            pkgs.playwright-driver
          ];
          shellInit = ''
            source .envrc 2> /dev/null || true
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc
            ]}
            export POETRY_CACHE_DIR="./.cache/pypoetry"
            export PLAYWRIGHT_NODEJS_PATH="${pkgs.nodejs}/bin/node"
            export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
            export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
          '';
        in
        {
          # Default shell poetry
          devShells = {
            default = pkgs.mkShell {
              buildInputs = shellBuildInputs;
              shellHook = ''
                ${shellInit}
                poetry install
                source $(poetry env info --path)/bin/activate
              '';
            };
          };
        }
      );
}
