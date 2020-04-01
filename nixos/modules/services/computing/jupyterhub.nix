{ config, lib, pkgs, ...}:

with lib;

let

  cfg = config.services.jupyterhub;

  # ps = pkgs.python3Packages;

  # penv = ps.python.buildEnv.override {
  #   extraLibs = with ps; [
  #     jupyterhub
  #     jupyterlab
  #     numpy
  #     matplotlib
  #     jupyterhub-systemdspawner
  #   ];
  # };

  # FIXME: Would be nice to get this working with --pure
  spawnJupyterLab = pkgs.writeScript "spawn-jupyterlab" ''
    #!/bin/sh
    set -x
    cd /home/jluttine/Workspace/leanheat/leanheat
    NIX_BUILD_SHELL=${pkgs.bash}/bin/bash exec ${pkgs.nix}/bin/nix-shell -A analyticsEnv --run "exec jupyter-labhub $*"
  '';

  jupyterhubConfig = pkgs.copyPathToStore ./jupyterhub_config.py;
  #jupyterhubConfig = pkgs.writeText (import ./jupyterhub_config.py);

in {

  options.services.jupyterhub = {

    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Salmon, a Python mail server";
    };

  };

  config = mkIf cfg.enable {


    # FIXME:
    #
    # When running JupyterHub as systemd service, there are errors like these in the logs:
    #
    # Apr 04 18:33:25 leevi python3.7[20277]: pam_unix(login:session): session opened for user jluttine by (uid=0)
    # Apr 04 18:33:25 leevi python3.7[20277]: pam_loginuid(login:session): Error writing /proc/self/loginuid: Operation not permitted
    # Apr 04 18:33:25 leevi python3.7[20277]: pam_loginuid(login:session): set_loginuid failed
    #
    # Probably related to JupyterHub PAMAuthenticator using `setuid` to switch
    # from one user to another.
    #
    # Also, when a notebook/lab user server is spawned, the cgroup of the
    # jupyterhub process changes so the process drops out from the cgroup of the
    # service. Thus, nothing goes to journald logs anymore. Otherwise it seems
    # to work, I suppose. Not sure if the PAM errors and this issue are related.
    #
    # You can see this from `systemctl status jupyterhub` that the jupyterhub
    # process is "detached". Also, you can see how the cgroup changes by running
    # `ps -o cgroup $PID` before and after spawning a notebook/lab user server.
    #
    # I'd assume that this is also related to `setuid`. For some reason the
    # jupyterhub process gets its change in cgroup because of that, probably.


    # Jupyter Hub process
    systemd.services.jupyterhub = {
      description = "Jupyter Hub";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3Packages.jupyterhub}/bin/jupyterhub --config=${jupyterhubConfig} --Spawner.cmd='${spawnJupyterLab}'";
      };

    };




    # Blocking Cross Origin API request.  Referer: http://localhost/hub/home, Host: localhost:8000/hub/


    # Reverse proxy so we can have domain name and SSL
    services.nginx = {

      enable = true;
      recommendedProxySettings = true;

      virtualHosts."jupyterhub.leanheat.fi" = {

        #forceSSL = true;
        #sslCertificate = /home/jluttine/Workspace/leanheat/leanheat/nix/leanheat-cert-chain-full.pem;
        #sslCertificateKey = /home/jluttine/Workspace/leanheat/leanheat/nix/leanheat.key;

        locations = {
          "/" = {
            proxyPass = "http://localhost:8000/"; # The / is important!
            # Web sockets are used by the notebooks
            proxyWebsockets = true;
          };
        };
      };
    };

  };

}
