{
  description = "Description for the project";

  inputs = {
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        devshells.default.devshell.packages = with pkgs; [
          nodejs
          yarn
          yarn2nix
        ];
        packages.matrix-js-sdk = with pkgs;
          mkYarnPackage rec {
            pname = "matrix-js-sdk";
            version = inputs.self.lastModifiedDate;
            src = ./.;
            packageJSON = ./package.json;
            yarnLock = ./yarn.lock;
            yarnNix = ./yarn.nix;

            configurePhase = "cp -r $node_modules node_modules";

            distPhase = "true";

            buildPhase = ''
              yarn build:compile
            '';
            installPhase = "cp -r lib $out";
          };
        formatter = pkgs.alejandra;
      };
      flake = {
        hydraJobs = {
          inherit (inputs.self) devShells packages formatter;
        };
      };
    };
}
