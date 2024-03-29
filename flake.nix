{
  description = "Genesis Shell is the next-generation fully featured desktop environment for ExpidusOS.";

  nixConfig = rec {
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    substituters = [ "https://cache.nixos.org" "https://cache.garnix.io" ];
    trusted-substituters = substituters;
    fallback = true;
    http2 = false;
  };

  inputs.expidus-sdk = {
    url = github:ExpidusOS/sdk;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-apple-silicon.url = github:tpwrules/nixos-apple-silicon;

  inputs.nixpkgs.url = github:ExpidusOS/nixpkgs;

  inputs.gokai = {
    url = github:ExpidusOS/gokai;
    inputs = {
      expidus-sdk.follows = "expidus-sdk";
      nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, expidus-sdk, nixos-apple-silicon, nixpkgs, gokai }:
    with expidus-sdk.lib;
    flake-utils.eachSystem flake-utils.allSystems (system:
      let
        pkgs = expidus-sdk.legacyPackages.${system}.appendOverlays ([
          (_: _: {
            gokai = gokai.packages.${system}.sdk;
            gokai-debug = gokai.packages.${system}.sdk-debug;
          })
        ] ++ (optionals (system == "aarch64-linux") [
          nixos-apple-silicon.overlays.default
          (f: p: {
            mesa = f.mesa-asahi-edge;
          })
        ]));
      in {
        packages.default = pkgs.flutter.buildFlutterApplication {
          pname = "genesis-shell";
          version = "1.0.0+git-${self.shortRev or "dirty"}";

          src = cleanSource self;

          depsListFile = ./deps.json;
          vendorHash = "sha256-DC4M7JTiYMZ1PkHs8Y0mUjtfViUZP74KeoA1lSssDoc=";

          flutterBuildFlags = [
            "--local-engine=${pkgs.gokai.flutter-engine}/out/host_release"
            "--local-engine-src-path=${pkgs.gokai.flutter-engine}"
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            pkgs.gokai
          ];

          meta = {
            description = "Next-generation desktop environment for ExpidusOS.";
            homepage = "https://expidusos.com";
            license = licenses.gpl3;
            maintainers = with maintainers; [ RossComputerGuy ];
            platforms = [ "x86_64-linux" "aarch64-linux" ];
            mainProgram = "genesis_shell";
          };
        };

        devShells.default = pkgs.mkShell {
          name = "genesis-shell";

          packages = with pkgs; [
            flutter
            pkg-config
            pkgs.gokai-debug
            gdb
          ];

          LIBGL_DRIVERS_PATH = "${pkgs.mesa.drivers}/lib/dri";
          __EGL_VENDOR_LIBRARY_DIRS = "${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d";
          VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";
          FLUTTER_ENGINE = pkgs.gokai.flutter-engine;
        };
      });
}
