{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ".." = "cd ..";
      cat = "bat --style=plain --theme=base16 --paging=never";
      v = "neovim";
      microfetch="microfetch && echo";
    };
    # inspo: https://discourse.nixos.org/t/brew-not-on-path-on-m1-mac/26770/4
    initContent = ''
      fortune

      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" &> /dev/null
        ssh-add ~/.ssh/id_ed25519 &> /dev/null
      fi

      if [ -z "$TMUX" ] && [ -n "$DISPLAY" ]; then
        tmux attach-session -t default || tmux new-session -s default
      fi
    '';
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      # inspo: https://discourse.nixos.org/t/zsh-zplug-powerlevel10k-zshrc-is-readonly/30333/3
      {
        name = "powerlevel10k-config";
        src = ./_p10k;
        file = "p10k.zsh";
      }
    ];
  };
}
