{ stdenv, fetchurl, asciidoc, libxslt }:

stdenv.mkDerivation rec {
  version = "1.8.3";
  name = "tinyproxy-${version}";

  src = fetchurl {
    url = "https://download.banu.com/tinyproxy/1.8/tinyproxy-${version}.tar.bz2";
    sha256 = "0vl9igw7vm924rs6d6bkib7zfclxnlf9s8rmml1sfwj7xda9nmdy";
  };

  buildInputs = [ asciidoc libxslt ];

  patchFlags = "-p0";
  patches = stdenv.lib.optionals stdenv.isDarwin [ ./darwin-patch-configure.patch  ];

  postPatch = ''
    substituteInPlace docs/man5/Makefile.in --replace \
      "-f manpage" "-f manpage -L";
    substituteInPlace docs/man8/Makefile.in --replace \
      "-f manpage" "-f manpage -L";
    '';

  configureFlags = "--disable-regexcheck";

  meta = {
    description = "Light-weight HTTP/HTTPS proxy daemon";
    longDescription = ''
      Tinyproxy is a light-weight HTTP/HTTPS proxy daemon for POSIX operating systems. Designed from the ground up to be fast and yet small, it is an ideal solution for use cases such as embedded deployments where a full featured HTTP proxy is required, but the system resources for a larger proxy are unavailable.
    '';
    homepage = https://banu.com/tinyproxy/;
    maintainers = [ stdenv.lib.maintainers.pesterhazy ];
    platforms = stdenv.lib.platforms.darwin;
    license = stdenv.lib.licenses.gpl2;
  };
}
