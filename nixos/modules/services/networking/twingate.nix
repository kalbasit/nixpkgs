{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.twingate;

  config_json = builtins.JSON({
    sdwan = {
      loglevel = 7;
      loglevel_console = 7;
    };
  });

in {
  meta.maintainers = with maintainers; [ danderson mbaillie ];

  options.services.twingate = {
    enable = mkEnableOption "Twingate client daemon";

    port = mkOption {
      type = types.port;
      default = 41641;
      description = "The port to listen on for tunnel traffic (0=autoselect).";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.twingate;
      defaultText = "pkgs.twingate";
      description = "The package to use for twingate";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ]; # for the CLI
    systemd.packages = [ cfg.package ];
    systemd.services.twingated = {
      description = "Twingate Remote Access Client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "5s";
        RuntimeDirectory = "twingate";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "twingate";
        StateDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/twingate";

        ExecStart = "${cfg.package}/bin/twingated ${config_json}";

        ProtectSystem = "full";
        ProtectHome = "yes";
        PrivateTmp = "yes";
        NoNewPrivileges = "yes";
        ProtectControlGroups = "yes";
        RestrictSUIDSGID = "yes";
        ProtectKernelLogs = "yes";
        ProtectKernelModules = "yes";
        ProtectHostname = "yes";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_RAW";
        RestrictAddressFamilies = "AF_UNIX AF_NETLINK AF_INET AF_INET6";
        RestrictNamespaces = "~user";
        SystemCallArchitectures = "native";
        LockPersonality = "yes";
        MemoryDenyWriteExecute = "yes";
        RestrictRealtime = "yes";
      };
    };

    systemd.user.services.twingate = {
      description = "Desktop notifications for Twingate Client";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/twingate-notifier";
      };
    };
  };
}
