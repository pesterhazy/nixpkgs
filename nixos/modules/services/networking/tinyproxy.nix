{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs) tinyproxy;

  cfg = config.services.tinyproxy;

  confFile = pkgs.writeText "tinyproxy.conf" ''
    User nobody
    Group nobody
    Port 8888
    Timeout 600
    DefaultErrorFile "@pkgdatadir@/default.html"
    StatFile "@pkgdatadir@/stats.html"
    LogLevel Info
    MaxClients 100
    MinSpareServers 5
    MaxSpareServers 20
    StartServers 10
    MaxRequestsPerChild 0
    Allow 127.0.0.1
    ViaProxyName "tinyproxy"
    ConnectPort 443
    ConnectPort 563

    ${cfg.extraConfig}
  '';

in

{

  options = {

    services.tinyproxy = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable tinyproxy.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "" ;
        description = ''
          Extra configuration. Contents will be added verbatim to the configuration file.
        '';
      };
    };

  };

  config = mkIf cfg.enable {
    systemd.services.tinyproxy = {
      description = "Tinyproxy";
      after = [ "network.target" "nss-lookup.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${tinyproxy}/bin/tinyproxy -c ${confFile}";
    };
  };
  
}
