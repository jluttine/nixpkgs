{ config, lib, pkgs, ... }:

let
  cfg     = config.services.monero;

  listToConf = option: list:
    lib.concatMapStrings (value: "${option}=${value}\n") list;

  login = (cfg.rpc.user != null && cfg.rpc.password != null);

  configFile = with cfg; pkgs.writeText "monero.conf" ''
    log-file=/dev/stdout
    data-dir=${dataDir}

    ${lib.optionalString mining.enable ''
      start-mining=${mining.address}
      mining-threads=${toString mining.threads}
    ''}

    rpc-bind-ip=${rpc.address}
    rpc-bind-port=${toString rpc.port}
    ${lib.optionalString login ''
      rpc-login=${rpc.user}:${rpc.password}
    ''}
    ${lib.optionalString rpc.restricted ''
      restricted-rpc=1
    ''}

    limit-rate-up=${toString limits.upload}
    limit-rate-down=${toString limits.download}
    max-concurrency=${toString limits.threads}
    block-sync-size=${toString limits.syncSize}

    ${listToConf "add-peer" extraNodes}
    ${listToConf "add-priority-node" priorityNodes}
    ${listToConf "add-exclusive-node" exclusiveNodes}

    ${extraConfig}
  '';

in

{

  ###### interface

  options = {

    services.monero = {

      enable = lib.mkEnableOption "Monero node daemon";

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/monero";
        description = ''
          The directory where Monero stores its data files.
        '';
      };

      mining.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to mine monero.
        '';
      };

      mining.address = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = ''
          Monero address where to send mining rewards.
        '';
      };

      mining.threads = lib.mkOption {
        type = lib.types.addCheck lib.types.int (x: x>=0);
        default = 0;
        description = ''
          Number of threads used for mining.
          Set to `0` to use all available.
        '';
      };

      rpc.user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          User name for RPC connections.
        '';
      };

      rpc.password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Password for RPC connections.
        '';
      };

      rpc.address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = ''
          IP address the RPC server will bind to.
        '';
      };

      rpc.port = lib.mkOption {
        type = lib.types.port;
        default = 18081;
        description = ''
          Port the RPC server will bind to.
        '';
      };

      rpc.restricted = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to restrict RPC to view only commands.
        '';
      };

      rpc.ssl = {

        enable = lib.mkEnableOption "SSL for Monero RPC";

        key = lib.mkOption {
          type = lib.types.path;
          default = "${cfg.dataDir}/ssl-key.pem";
          defaultText = "foobar";
          description = ''
            Key file for securing RPC connections.

            If the key or certificate file does not exist, they are both created
            automatically.
          '';
        };

        certificate = lib.mkOption {
          type = lib.types.path;
          default = "${cfg.dataDir}/ssl-certificate.pem";
          defaultText = "foobar";
          description = ''
            Certificate file for securing RPC connections.

            If the key or certificate file does not exist, they are both created
            automatically.
          '';
        };

      };

      limits.upload = lib.mkOption {
        type = lib.types.addCheck lib.types.int (x: x>=-1);
        default = -1;
        description = ''
          Limit of the upload rate in kB/s.
          Set to `-1` to leave unlimited.
        '';
      };

      limits.download = lib.mkOption {
        type = lib.types.addCheck lib.types.int (x: x>=-1);
        default = -1;
        description = ''
          Limit of the download rate in kB/s.
          Set to `-1` to leave unlimited.
        '';
      };

      limits.threads = lib.mkOption {
        type = lib.types.addCheck lib.types.int (x: x>=0);
        default = 0;
        description = ''
          Maximum number of threads used for a parallel job.
          Set to `0` to leave unlimited.
        '';
      };

      limits.syncSize = lib.mkOption {
        type = lib.types.addCheck lib.types.int (x: x>=0);
        default = 0;
        description = ''
          Maximum number of blocks to sync at once.
          Set to `0` for adaptive.
        '';
      };

      extraNodes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of additional peer IP addresses to add to the local list.
        '';
      };

      priorityNodes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of peer IP addresses to connect to and
          attempt to keep the connection open.
        '';
      };

      exclusiveNodes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of peer IP addresses to connect to *only*.
          If given the other peer options will be ignored.
        '';
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Extra lines to be added verbatim to monerod configuration.
        '';
      };

    };

  };


  ###### implementation

  config = lib.mkIf cfg.enable {

    users.users.monero = {
      isSystemUser = true;
      group = "monero";
      description = "Monero daemon user";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.monero = { };

    systemd.services.monero = {
      description = "monero daemon";
      after    = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User  = "monero";
        Group = "monero";
        ExecStart = let
          sslFlags = lib.optionalString cfg.rpc.ssl.enable "--rpc-ssl=enabled --rpc-ssl-private-key=${cfg.rpc.ssl.key} --rpc-ssl-certificate=${cfg.rpc.ssl.certificate}";
        in "${pkgs.monero-cli}/bin/monerod --config-file=${configFile} --non-interactive ${sslFlags}";
        #ExecStart = "${pkgs.monero-cli}/bin/monerod --config-file=${configFile} --non-interactive";
        Restart = "always";
        SuccessExitStatus = [ 0 1 ];
      };

      # Create SSL key and certificate if they don't exist yet
      #
      # Fingerprint with sudo openssl x509 -in /var/lib/monero/ssl-certificate.pem -fingerprint -sha256:
      # 73:F6:99:3A:0F:B8:CF:21:29:74:26:A8:89:DC:4A:79:54:37:1F:CC:90:0E:12:22:16:7A:B0:CE:7B:15:05:5C
      preStart = lib.mkIf cfg.rpc.ssl.enable ''
        if [[ ! -f ${cfg.rpc.ssl.key} || ! -f ${cfg.rpc.ssl.certificate} ]]
        then
          ${pkgs.monero-cli}/bin/monero-gen-ssl-cert \
            --private-key-filename ${cfg.rpc.ssl.key} \
            --certificate-filename ${cfg.rpc.ssl.certificate}
        fi
      '';
    };

    assertions = lib.singleton {
      assertion = cfg.mining.enable -> cfg.mining.address != "";
      message   = ''
       You need a Monero address to receive mining rewards:
       specify one using option monero.mining.address.
      '';
    };

  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
