{ config, lib, pkgs, ... }: 

with lib; 

let

  cfg = config.services.xd;
  iniFormat = pkgs.formats.ini {};

in {

  options.services.xd = {
    enable = mkEnableOption "XD service";

    package = mkOption {
      type = types.package;
      default = pkgs.xd;
      defaultText = literalExpression "pkgs.xd";
      description = "The XD package to install";
    };

    settings = mkOption {
      type = iniFormat.type;
      default = {
        i2p = {
          "i2pd.leaseSetEncType" = "4,0";
          address = "127.0.0.1:7656";
          disabled = 0;
        };
        storage = {
          rootdir = "${config.home.homeDirectory}/storage";
          metadata = "${config.home.homeDirectory}/storage/metadata";
          downloads = "${config.home.homeDirectory}/storage/downloads";
          completed = "${config.home.homeDirectory}/storage/seeding";
          workers = 0;
          iop_buffer_size = 0;
        };
        rpc = {
          enable = 1;
          bind = "127.0.0.1:1776";
          host = "127.0.0.1";
        };
        log = {
          level = "info";
          pprof = 0;
        };
        bittorent = {
          pex = 1;
          dht = 0;
          swarms = 1;
          tracker-config = "${config.xdg.configHome}/XD/trackers.ini";
          max-torrents = 0;
        };
        gnutella = {
          enabled = 0;
        };
        lokinet = {
          dns = "127.3.2.1:53";
          disabled = 1;
        };
      };
      description = ''
        Configuration for XD, see
        <link xlink:href="https://xd-torrent.readthedocs.io/en/latest/user-guide/configuration/"/>
        for options
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."XD/torrents.ini" = mkIf (cfg.settings != {}) {
      source = iniFormat.generate "torrents.ini" cfg.settings;
    };

    systemd.user.services.XD = {
      Unit = { Description = "XD"; };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        Restart = "on-failure";
        ExecStart = "${cfg.package}/bin/XD ${config.xdg.configHome}/XD/torrents.ini";
      };
    };
  };
}
