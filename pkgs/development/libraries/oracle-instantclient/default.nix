{ stdenv, requireFile, libelf, gcc, glibc, patchelf, unzip, rpmextract, libaio }:

stdenv.mkDerivation rec {
  name = "oracle-instantclient-12.1.0.2.0-1";

  srcBinary = requireFile {
    name = "oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm";
    message = ''
      This nix expression requires that ${name} is
      already part of the store. Download the file
      manally at

      http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    url = "http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html";
    sha256 = "f0e51e247cc3f210b950fd939ab1f696de9ca678d1eb179ba49ac73acb9a20ed";
  };

  srcDevel = requireFile {
    name = "oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm";
    message = ''
      This nix expression requires that ${name} is
      already part of the store. Download the file
      manually at

      http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    url = "http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html";
    sha256 = "13b638882f07d6cfc06c85dc6b9eb5cac37064d3d594194b6b09d33483a08296";
  };

  srcSqlplus = requireFile {
    name = "oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm";
    message = ''
      This nix expression requires that ${name} is
      already part of the store. Download the file
      manually at

      http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    url = "http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html";
    sha256 = "16d87w1lii0ag47c8srnr7v4wfm9q4hy6gka8m3v6gp9cc065vam";
  };

  buildInputs = [ glibc patchelf rpmextract ];

  buildCommand = ''
    mkdir -p "${name}"
    cd "${name}"
    ${rpmextract}/bin/rpmextract "${srcBinary}"
    ${rpmextract}/bin/rpmextract "${srcDevel}"
    ${rpmextract}/bin/rpmextract "${srcSqlplus}"

    mkdir -p "$out/"{bin,include,lib,demo}
    mv "usr/share/oracle/12.1/client64/demo/"* "$out/demo/"
    mv "usr/include/oracle/12.1/client64/"* "$out/include/"
    mv "usr/lib/oracle/12.1/client64/lib/"* "$out/lib/"
    mv "usr/lib/oracle/12.1/client64/bin/"* "$out/bin/"
    ln -s "$out/bin/sqlplus" "$out/bin/sqlplus64"

    for lib in $out/lib/lib*.so; do
      test -f $lib || continue
      chmod +x $lib
      patchelf --force-rpath --set-rpath "$out/lib:${libaio}/lib" \
               $lib
    done

    for exe in $out/bin/sqlplus; do
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
               --force-rpath --set-rpath "$out/lib:${libaio}/lib" \
               $exe
    done
  '';

  meta = with stdenv.lib; {
    description = "Oracle instant client libraries for connecting to Oracle databases (OCI, OCCI, Pro*C, ODBC or JDBC). Includes the SQLPlus command line SQL client";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ pesterhazy ];
  };
}
