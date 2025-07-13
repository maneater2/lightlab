default:
  just --list

deploy machine='' ip='':
  @if [ -z "{{ machine }}" ] && [ -z "{{ ip }}" ]; then \
    nixos-rebuild switch --use-remote-sudo --flake .; \
  elif [ -z "{{ ip }}" ]; then \
    nixos-rebuild switch --use-remote-sudo --flake".#{{ machine }}"; \
  else \
    nixos-rebuild switch --fast --flake ".#{{ machine }}" --use-remote-sudo --target-host "light@{{ ip }}" --build-host "light@{{ ip }}"; \
  fi

up:
  nix flake update

lint:
  statix check .

fmt:
  nix fmt .

gc:
  sudo nix-collect-garbage -d && nix-collect-garbage -d

repair:
  sudo nix-store --verify --check-contents --repair

sops-edit:
  sops secrets/secrets.yml

sops-rotate:
  for file in secrets/*; do sops --rotate --in-place "$file"; done

sops-update:
  for file in secrets/*; do sops updatekeys "$file"; done

build-iso:
  nix build .#nixosConfigurations.zeppelin.config.system.build.isoImage
