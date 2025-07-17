{ config, pkgs, lib, ... }:

{
  sops.secrets."keycloak-pass" = {};

  services.postgresql = {
    enable = true;

    # Set a specific PostgreSQL version
    package = pkgs.postgresql_15;

    # Automatically initialize a DB cluster if none exists
    initialScript = pkgs.writeText "init-keycloak-db.sql" ''
      CREATE ROLE keycloak WITH LOGIN PASSWORD 'dummy'; -- will be overridden
      CREATE DATABASE keycloak OWNER keycloak;
    '';

    ensureDatabases = [ "keycloak" ];

    ensureUsers = [
      {
        name = "keycloak";
        ensureDBOwnership = true;
      }
    ];

    authentication = ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     peer
      host    keycloak        keycloak        127.0.0.1/32            md5
      host    keycloak        keycloak        ::1/128                 md5
    '';

    # Set data directory to persistent location
    dataDir = "/var/lib/postgresql/data";
  };

  environment.persistence."/nix/persist" = {
    directories = [ "/var/lib/postgresql" ];
  };

  # One-shot systemd service to set the password from the SOPS secret
  systemd.services."set-keycloak-db-password" = {
    description = "Set Keycloak DB password from SOPS secret";
    after = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = pkgs.writeShellScript "set-keycloak-db-password" ''
        psql -tAc "ALTER USER keycloak WITH PASSWORD '$(cat ${config.sops.secrets."keycloak-db-pass".path})';"
      '';
    };
  };
}
