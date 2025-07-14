{
  config,
  lib,
  ...
}:
{
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;

      defaultOptions = [
        "--preview='bat --color=always -n {}'"
	"--bind 'ctrl-/:toggle-preview'"
      ];
      defaultCommand = "fd --type f --exclude .git --follow --hidden";
      changeDirWidgetCommand = "fd --type d --exclude .git --follow --hidden";
    };
}
