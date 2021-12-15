{
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in rec {
          defaultPackage = packages.tuber;
          packages.tuber = with pkgs; stdenv.mkDerivation {
            pname = "tuber";
            version = "0.0.1";
            src = ./.;

            buildInputs = [ bash ];
            nativeBuildInputs = [ makeWrapper ];

            buildPhase = false;
            installPhase = ''
              mkdir -p $out/bin
              cp $src/tuber.sh $out/bin/tuber
              wrapProgram $out/bin/tuber \
                --prefix PATH : ${lib.makeBinPath [ jq htmlq curl ]}
            '';
          };
        }
      );
}
