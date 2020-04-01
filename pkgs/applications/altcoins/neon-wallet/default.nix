{lib, pkgs, ...}:

#with (import <nixpkgs> {});
with (import /home/jluttine/Workspace/yarn2nix { inherit pkgs; });
let
  pname = "neon-wallet";
  version = "0.0.7";
  yarnComponents = mkYarnPackage rec {
    src = pkgs.fetchFromGitHub {
      owner = "CityOfZion";
      repo = "${pname}";
      rev = "${version}";
      sha256 = "1hzjfy7l0ykh3504xfpa6zxc9gwyfi7s9074r50zyn09l3az30r1";
    };
    # packageJson = /home/jluttine/Workspace/daedalus/package.json;
    # yarnLock = /home/jluttine/Workspace/daedalus/yarn.lock;
    # # NOTE: this is optional and generated dynamically if omitted
    yarnNix = /home/jluttine/Workspace/neon-wallet/yarn.nix;
  };
in pkgs.stdenv.mkDerivation rec {

  name = "${pname}-${version}";
  src = yarnComponents.src;

  buildInputs = with pkgs; [
electron nodejs-6_x nodePackages.bower nodePackages.node-gyp nodePackages.node-pre-gyp
  which yarn nodejs nodePackages.gulp ];

  buildPhase = ''
    #yarn install --frozen-lockfile --offline --non-interactive --modules_folder ${yarnComponents}/node_modules
    ln -s ${yarnComponents}/node_modules
    ls -l node_modules
    npm install
  '';

  installPhase = ''
    true
  '';
}
# let

#   version = "1.5.6";
#   pname = "calendar";

#   source = pkgs.srcOnly {
#     stdenv = pkgs.stdenv;
#     name = pname;
#     src = pkgs.fetchzip {
#       url = "https://github.com/nextcloud/${pname}/archive/v${version}.tar.gz";
#       sha256 = "0ap7nqrl5yi300j27k5l76zf3z6b8n0wvn6bcn6j3p0cmn8xs6s2";
#     };
#     patches = [ ./package.patch ];
#   };

#   yarnComponents = mkYarnPackage rec {
#     src = source + "/js";
#   };

# in pkgs.stdenv.mkDerivation rec {

#   name = "${pname}-${version}";
#   pname = "nextcloud-calendar";
#   version = "1.5.6";
#   src = source;

#   buildInputs = with pkgs; [ which yarn nodejs nodePackages.gulp ];

#   buildPhase = ''
#     cp --reflink=auto --no-preserve=mode -R ${yarnComponents}/node_modules ./
#     export HOME=$(pwd)
#   '';

#   installPhase = ''
#     mkdir -p $out/calendar
#     cp -R build/appstore/calendar/* $out/calendar/
#   '';
# }
# rec {
#   weave-front-end = mkYarnPackage {
#     name = "weave-front-end";
#     src = ./.;
#     packageJson = ./package.json;
#     yarnLock = ./yarn.lock;
#     # NOTE: this is optional and generated dynamically if omitted
#     yarnNix = ./yarn.nix;
#   };
# }

# {lib, pkgs, ...}:

# # Some notes on how this was set up:
# #
# # Checkout the contacts repo locally. Modify package.json so that all
# # devDependencies are moved under dependencies. Run node2nix in the repo. Copy
# # node-env.nix, node-packages.nix and packages.nix here. Also, copy default.nix
# # as contacts.nix here.

# let
#   shell = (import ./daedalus.nix {}).shell;
# in pkgs.stdenv.mkDerivation rec {
#   name = "${pname}-${version}";
#   pname = "daedalus";
#   version = "0.8.0";
#   # NOTE: Don't use 2.0.0 release because they dropped Bower after that. Let's
#   # use a real release whenever that comes without Bower.
#   src = pkgs.fetchFromGitHub {
#     owner = "input-output-hk";
#     repo = "${pname}";
#     rev = "${version}";
#     sha256 = "01jxdzprhyr15nb6qhz25210jngqybisp2d0nivsdc77b4qikx88";
#   };
#   # src = pkgs.fetchzip {
#   #   url = "https://github.com/nextcloud/${pname}/archive/${version}.tar.gz";
#   #   sha256 = "02a27iwf3jp8cw0x81k782m4jq6d79knpwflc0phyawnvs8zp3n6";
#   # };

#   #patches = [ ./package.patch ];

#   buildInputs = with pkgs; [
#     which nodejs nodePackages.npm #nodePackages.gulp
#     #nextcloud
#   ];

#   buildPhase = ''
#     ln -s ${shell.nodeDependencies}/lib/node_modules
#     npm install
#   '';

#   # buildPhase = ''
#   #   ln -s ${shell.nodeDependencies}/lib/node_modules
#   #   mkdir -p build/css
#   #   cp ${pkgs.nextcloud}/core/css/variables.scss build/css/
#   #   make build
#   #   make appstore
#   # '';

#   # installPhase = ''
#   #   mkdir $out
#   #   tar xvzf build/artifacts/appstore/contacts-*.tar.gz -C $out/
#   #   mv $out/contacts* $out/contacts
#   # '';

# }
