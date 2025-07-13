{
  lib,
  vars,
  osConfig,
  config,
  ...
}: 
with lib; let
  cfg = config.features.cli.git;
in {
  options.features.cli.git.enable = mkEnableOption "git";

  config = mkIf cfg.enable {
    home = {
      # inspo: https://jeppesen.io/git-commit-sign-nix-home-manager-ssh/
      file.".ssh/allowed_signers".text = "* ${vars.sshPublicKeyPersonal}";
    };

    programs = {
      git = {
        enable = true;
        userName = vars.fullName;
        inherit (vars) userEmail;
        extraConfig = {
          commit.gpgsign = true;
          gpg.format = "ssh";
          gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          user.signingkey = vars.sshPublicKeyPersonal;
        };
      };
    };
  };
}
