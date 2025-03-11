{
  description = "Jinko Cookbook Documentation";
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

            # Add interactive bash to support `poetry shell`
            pkgs.bashInteractive
            pkgs.jq
            pkgs.nodejs
          ];
          shellInit = ''
            source .envrc 2> /dev/null || true
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc
            ]}
            export POETRY_CACHE_DIR="./.cache/pypoetry"
          '';
        in
        {
          # Default shell with only poetry installed
          devShells = {
            default = pkgs.mkShell {
              name = "default";
              buildInputs = shellBuildInputs;
              shellHook = ''
                ${shellInit}
              '';
            };

            # Install and load a poetry shell
            poetry = pkgs.mkShell {
              buildInputs = shellBuildInputs;
              shellHook = ''
                ${shellInit}
                poetry install
                poetry shell
              '';
            };

          };
        }
      );
}
