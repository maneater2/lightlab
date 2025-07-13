{
  pkgs,
  osConfig,
  ...
}: {
  home = {
    packages = with pkgs;
      [
        asciinema
        asciiquarium
        bind
        cbonsai
        clolcat
        cmatrix
        croc
        curl
        dig
        du-dust
        dua
        duf
        figlet
        fortune-kind
        gdu
        genact
        gti
        hyperfine
        imagemagick
        openssl
        jdupes
        jq
        kopia
        neo-cowsay
        pandoc
        pipes-rs
        poppler_utils
        qrencode
        tree
        wget
        microfetch
      ]
      ++ (
        if osConfig.networking.hostName != "carrotcake"
        then [
          # Below packages are for personal machines only; excluded from servers
          # inspo: https://discourse.nixos.org/t/how-to-use-hostname-in-a-path/42612/3
          alejandra
          bun
          doppler
          just
          gnupg1
          nil
          nodejs
          sops
          statix
          stripe-cli
          zola
          nix-prefetch-scripts
          ranger
          ffmpeg
          ffmpegthumbnailer
          fzf
          playerctl
          udisks
        ]
        else [
          # Below packages are for servers only; excluded from personal machines
        ]
      );
  };
}
