{
  description = "Next generation mobile/desktop shell";

  inputs = {
    nixpkgs.url = "github:ExpidusOS/nixpkgs/feat/flutter-3-26-pre";
    systems.url = "github:nix-systems/default-linux";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, systems, flake-utils }:
    let
      inherit (nixpkgs) lib;
    in
    flake-utils.lib.eachSystem (import systems) (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        deps = builtins.fromJSON (lib.readFile ./deps.json);
        shortRev = self.shortRev or (lib.substring 7 7 lib.fakeHash);
        shortRevCodes = lib.map lib.strings.charToInt (lib.stringToCharacters shortRev);
        buildCode = lib.foldr (a: b: "${toString a}${toString b}") "" shortRevCodes;

        shortVersion = "1.0.0";
        version = "${shortVersion}+${buildCode}";
      in {
        packages.default = pkgs.flutter326.buildFlutterApplication {
          pname = "genesis-shell";
          version = "${shortVersion}+git-${shortRev}";

          src = lib.cleanSource self;

          flutterBuildFlags = [
            "--dart-define=COMMIT_HASH=${shortRev}"
          ];

          buildInputs = with pkgs; [
            gtk-layer-shell
          ];

          pubspecLock = lib.importJSON ./pubspec.lock.json;

          gitHashes = {
            expidus = "sha256-8SYiY9O0nivTOaYihOr3LcsGTnNRuvRRs9tjR3EPdCA=";
          };

          meta = {
            description = "Next generation mobile/desktop shell.";
            homepage = "https://expidusos.com";
            license = lib.licenses.gpl3;
            maintainers = with lib.maintainers; [ RossComputerGuy ];
            platforms = [ "x86_64-linux" "aarch64-linux" ];
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.packages.${system}.default) pname version name;

          packages = with pkgs; [
            flutter326
            pkg-config
            gtk3
            gtk-layer-shell
            yq
          ];
        };
      });
}
