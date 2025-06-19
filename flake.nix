{
  description = "Next generation mobile/desktop shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default-linux";
  };

  nixConfig = {
    substituters = ["https://cache.garnix.io" "https://cache.nixos.org" ];
    trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    systems,
    ...
  }@inputs:
  let
    inherit (nixpkgs) lib;

    shortRev = self.shortRev or (lib.substring 7 7 lib.fakeHash);
    shortRevCodes = lib.map lib.strings.charToInt (lib.stringToCharacters shortRev);
    buildCode = lib.foldr (a: b: "${toString a}${toString b}") "" shortRevCodes;

    shortVersion = "1.0.0";
    version = "${shortVersion}+${buildCode}";
  in flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;

    perSystem = { pkgs, ... }: {
      packages.default = pkgs.flutter.buildFlutterApplication {
        pname = "genesis-shell";
        version = "${shortVersion}+git-${shortRev}";

        src = lib.cleanSource inputs.self;

        flutterBuildFlags = [
          "--dart-define=COMMIT_HASH=${shortRev}"
        ];

        nativeBuildInputs = with pkgs; [
          accountsservice
        ];

        buildInputs = with pkgs; [
          gtk-layer-shell
        ];

        preBuild = ''
          find .dart_tool
          patchShebangs scripts/gen-dbus.sh
          while IFS= read -r line; do
            packageRunCustom dbus dart_dbus bin $line
          done <<< $(DRY_RUN=1 ./scripts/gen-dbus.sh)
        '';

        pubspecLock = lib.importJSON ./pubspec.lock.json;

        gitHashes = {
          expidus = "sha256-Fkwal9pihGS/u/itfsivW9crjuHFHH2YsGLXEOLub3I=";
          adwaita = "sha256-o8z6YRPaJfW/vkmJMw2k8Sk0Dhbm3Zgoa0vPRsuWty0=";
          provider = "sha256-f0HQbiRVuvm0av2oL7tohsBx/vEm0SFi/uQcxycLR28=";
        };

        extraWrapProgramArgs = "--prefix LD_LIBRARY_PATH : ${placeholder "out"}/app/genesis-shell/lib";

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

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          accountsservice
          flutter
          pkg-config
          gtk3
          yq
          gtk-layer-shell
        ];
      };
    };
  };
}
