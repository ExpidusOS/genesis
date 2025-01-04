{
  description = "Next generation mobile/desktop shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    systems.url = "github:nix-systems/default-linux";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon/release-2024-12-25";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shoyu = {
      url = "github:MidstallSoftware/shoyu?ref=pull/5/head";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-utils.follows = "flake-utils";
        nixos-apple-silicon.follows = "nixos-apple-silicon";
      };
    };
  };

  nixConfig = {
    substituters = ["https://cache.garnix.io"];
    trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      flake-utils,
      nixos-apple-silicon,
      shoyu,
      ...
    }:
    let
      inherit (nixpkgs) lib;
    in
    flake-utils.lib.eachSystem (import systems) (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [
          (
            pkgs: prev: with pkgs; {
              pkgsAsahi = (
                if stdenv.hostPlatform.isAarch64 then
                  pkgs.appendOverlays [
                    nixos-apple-silicon.overlays.default
                    (pkgsAsahi: prev: {
                      mesa = pkgsAsahi.mesa-asahi-edge.overrideAttrs (
                        f: p: {
                          meta.platforms = prev.mesa.meta.platforms;
                        }
                      );
                    })
                  ]
                else
                  null
              );

              genesis-shell = pkgs.flutter327.buildFlutterApplication {
                pname = "genesis-shell";
                version = "${shortVersion}+git-${shortRev}";

                src = lib.cleanSource self;

                flutterBuildFlags = [
                  "--dart-define=COMMIT_HASH=${shortRev}"
                ];

                buildInputs = with pkgs; [
                  pkgs.shoyu
                ];

                pubspecLock = lib.importJSON ./pubspec.lock.json;

                gitHashes = {
                  expidus = "sha256-ptTj+si4jUr9Eg5x6Rd2iUtACAVEpWG4p/1FqZnFSvM=";
                  miso = "sha256-EznEUokD0nSON/4XRHe/HT+ybPAdNtoUwXCPEla6i1Y=";
                };

                meta = {
                  description = "Next generation mobile/desktop shell.";
                  homepage = "https://expidusos.com";
                  license = lib.licenses.gpl3;
                  maintainers = with lib.maintainers; [ RossComputerGuy ];
                  platforms = [
                    "x86_64-linux"
                    "aarch64-linux"
                  ];
                };
              };
            }
          )
          shoyu.overlays.default
        ];

        deps = builtins.fromJSON (lib.readFile ./deps.json);
        shortRev = self.shortRev or (lib.substring 7 7 lib.fakeHash);
        shortRevCodes = lib.map lib.strings.charToInt (lib.stringToCharacters shortRev);
        buildCode = lib.foldr (a: b: "${toString a}${toString b}") "" shortRevCodes;

        shortVersion = "1.0.0";
        version = "${shortVersion}+${buildCode}";

        mkDevShell =
          pkgs:
          pkgs.mkShell {
            packages = with pkgs; [
              flutter327
              pkg-config
              gtk3
              yq
              pkgs.shoyu
            ];
          };
      in
      (
        {
          packages =
            {
              default = pkgs.genesis-shell;
            }
            // lib.optionalAttrs (pkgs.pkgsAsahi != null) {
              asahi = pkgs.pkgsAsahi.genesis-shell;
            };

          devShells =
            {
              default = mkDevShell pkgs;
            }
            // lib.optionalAttrs (pkgs.pkgsAsahi != null) {
              asahi = mkDevShell pkgs.pkgsAsahi;
            };

          legacyPackages = pkgs;
        }
        // lib.optionalAttrs pkgs.hostPlatform.isLinux {
          nixosConfigurations = lib.nixosSystem {
            inherit system pkgs;
            modules = [
              "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
              (
                { config, lib, pkgs, ... }:
                {
                  config = lib.mkMerge [
                    (import "${nixpkgs}/nixos/modules/programs/wayland/wayland-session.nix" {
                      inherit lib pkgs;
                    })
                    {
                      hardware.graphics.enable = true;

                      services.greetd = {
                        enable = true;
                        settings.default_session = {
                          command = "${pkgs.shoyu}/bin/shoyu-compositor-runner ${pkgs.genesis-shell}/bin/genesis_shell";
                        };
                      };

                      security.sudo = {
                        enable = true;
                        wheelNeedsPassword = false;
                      };

                      boot.initrd.kernelModules = [ "virtio_gpu" "virtio_pci" ];

                      virtualisation.qemu.options = [
                        "-vga none"
                        "-display default,gl=on"
                      ];

                      users.users.demo = {
                        isNormalUser = true;
                        password = "demo";
                        createHome = true;
                        group = "wheel";
                        extraGroups = [
                          "users"
                          "video"
                          "input"
                        ];
                      };
                    }
                  ];
                }
              )
            ];
          };
        }
      )
    );
}
