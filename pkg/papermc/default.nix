{ lib, stdenv, fetchurl, bash, jre, mcVer, buildNo, sha256 }:
stdenv.mkDerivation {
  pname = "papermc";
  version = "${mcVer}r${buildNo}";

  preferLocalBuild = true;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    cat > minecraft-server << EOF
    #!${bash}/bin/sh
    exec ${jre}/bin/java \$@ -jar $out/share/papermc/papermc.jar nogui
  '';

  installPhase = ''
    install -Dm444 ${ fetchurl {
      url = "https://papermc.io/api/v2/projects/paper/versions/${mcVer}/builds/${buildNo}/downloads/paper-${mcVer}-${buildNo}.jar";
    sha256 = sha256;
    }} $out/share/papermc/papermc.jar
    install -Dm555 -t $out/bin minecraft-server
  '';

  meta = {
    description = "High-performance Minecraft Server";
    homepage    = "https://papermc.io/";
    license     = lib.licenses.gpl3Only;
    platforms   = lib.platforms.unix;
    maintainers = with lib.maintainers; [ aaronjanse neonfuz ];
  };
}
