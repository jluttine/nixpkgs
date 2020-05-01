{ stdenv
, fetchurl
, lib
, unzip
, symlinkJoin
# To select only certain fonts, put a list of strings to `fonts`: every key in
# ./shas.nix is an optional font
, fonts ? []
}:

let
  # both of these files are generated via ./update.sh
  version = import ./version.nix;
  fontsShas = import ./shas.nix;
  knownFonts = builtins.attrNames fontsShas;
  selectedFonts = if (fonts == []) then
    knownFonts
  else
    let unknown = lib.subtractLists knownFonts fonts; in
    if (unknown != []) then
      throw "Unknown font(s): ${lib.concatStringsSep " " unknown}"
    else
      fonts
  ;
  selectedFontsShas = lib.attrsets.genAttrs selectedFonts (
    fName:
    fontsShas."${fName}"
  );
  # Create a separate derivation for each individual font so that a font doesn't
  # need to be rebuilt when used in different selection fonts. Reduces
  # unnecessary rebuilds and disk usage.
  fontPkgs = lib.attrsets.mapAttrsToList (
    fName:
    fSha:
    stdenv.mkDerivation rec {
      inherit version;
      pname = "nerdfonts-${fName}";
      src = fetchurl {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${fName}.zip";
        sha256 = fSha;
      };
      nativeBuildInputs = [
        unzip
      ];
      sourceRoot = ".";
      installPhase = ''
        find -name \*.otf -exec mkdir -p $out/share/fonts/opentype/NerdFonts \; -exec mv {} $out/share/fonts/opentype/NerdFonts \;
        find -name \*.ttf -exec mkdir -p $out/share/fonts/truetype/NerdFonts \; -exec mv {} $out/share/fonts/truetype/NerdFonts \;
      '';
      meta = with stdenv.lib; {
        description = "${fName} font in Nerdfonts collection";
        homepage = "https://nerdfonts.com/";
        maintainers = with maintainers; [ doronbehar ];
        hydraPlatforms = []; # 'Output limit exceeded' on Hydra
      };
    }
  ) selectedFontsShas;
in symlinkJoin {
  # This package is just a thin symlink join which wraps the separate font
  # packages under the same store path.
  name = "nerdfonts-${version}";
  paths = fontPkgs;
  meta = with stdenv.lib; {
    description = "Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts";
    longDescription = ''
      Nerd Fonts is a project that attempts to patch as many developer targeted
      and/or used fonts as possible. The patch is to specifically add a high
      number of additional glyphs from popular 'iconic fonts' such as Font
      Awesome, Devicons, Octicons, and others.
    '';
    homepage = "https://nerdfonts.com/";
    license = licenses.mit;
    maintainers = with maintainers; [ doronbehar ];
    hydraPlatforms = []; # 'Output limit exceeded' on Hydra
  };
}
