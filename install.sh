#!/usr/bin/env bash

# Check if this is a VM
virtualization=$(systemd-detect-virt)

set -euo pipefail

output () {
  printf '\e[1;35m%-6s\e[m\n' "${@}"
}

luks_prompt () {
  if [ "${virtualization}" != 'none' ]; then
    output "Virtual machine detected. Do you want to setup LUKS encryption?"
    output '1) No'
    output '2) Yes'
    read -r choice
    case $choice in
      1 ) use_luks='0'
        ;;
      2 ) use_Luks='1'
        ;;
      * ) output 'You did not enter a valid selection.'
        luks_prompt
    esac
  else
    use_luks='1'
  fi
}

luks_passphrase_prompt () {
  if [ "${use_luks}" = '1' ]; then
    output 'Enter your encryption passphrase (no echo):'
    read -r -s luks_passphrase


    if [ -z "${luks_passphrase}" ]; then
      output 'To use encryption, you need to enter a passphrase.'
      luks_passphrase_prompt
    fi

    output 'Confirm your encryption passphrase (no echo):'
    read -r -s luks_passphrase2
    if [ "${luks_passphrase}" != "${luks_passphrase2}" ]; then
      output 'Passphrases do not match, please try again.'
      unset luks_passphrase{,2}
      luks_passphrase_prompt
    fi
    unset luks_passphrase2
  fi
}

disk_prompt () {
   fdisk -l || lsblk
  output 'Please select the number of the corresponding disk (e.g. 1):'
  select entry in $(lsblk -dpnoNAME|grep -P "/dev/nvme|sd|mmcblk|vd");
  do
    disk="${entry}"
    output "NixOS will be installed on the following disk: ${disk}"
    break
  done
}

# Set hardcoded variables
locale=en_US
kblayout=us

# Display warning and wait for confirmation to proceed
output '**Warning:** This script is irreversible and will prepare system for NixOS installation.'
read -n 1 -s -r -p "Press any key to continue or Ctrl+C to abort..."

clear

# Initial prompts
disk_prompt
luks_prompt
luks_passphrase_prompt

# Wipe the disk
sgdisk --zap-all "${disk}"

# Partition the disk
output "Creating new partition scheme on ${disk}."
sgdisk -g "${disk}"
sgdisk -I -n 1:0:+512M -t 1:ef00 -c 1:'boot' "${disk}"
sgdisk -I -n 2:0:0 -c 2:'Nix' "${disk}"

ESP='/dev/disk/by-partlabel/boot'

if [ "${use_luks}" = '1' ]; then
  cryptroot='/dev/disk/by-partlabel/Nix'
fi

output 'Informing the Kernel about the disk changes.'
partprobe "${disk}"

output 'Formatting the EFI Partition as FAT32.'
mkfs.fat -F 32 -s 2 "${ESP}"

# Create a LUKS Container for the root partition
if [ "${use_luks}" = '1' ]; then
  output 'Creating a LUKS Container for the root partition.'
  echo -n "${luks_passphrase}" |  cryptsetup luksFormat -s 512 -h sha512 "${cryptroot}" -d -
  echo -n "${luks_passphrase}" |  cryptsetup open "${cryptroot}" cryptroot -d -
  ROOT='/dev/mapper/cryptroot'
else
  ROOT='/dev/disk/by-partlabel/Nix'
fi

output 'Formatting the root partition as EXT4.'
mkfs.ext4 -F -L nix -m 0 "${ROOT}"

output 'Mounting filesystems.'
mount -t tmpfs none /mnt
mkdir -pv /mnt/{boot,nix,etc/ssh,var/{lib,log}}
mount "${ESP}" /mnt/boot
mount "${ROOT}" /mnt/nix
mkdir -pv /mnt/nix/{secret,initrd,persist/{etc/ssh,var/{lib,log}}}
chmod 0700 /mnt/nix/secret
mount -o bind /mnt/nix/persist/var/log /mnt/var/log

output 'Generating initrd SSH host key.'
ssh-keygen -t ed25519 -N "" -C "" -f /mnt/nix/secret/initrd/ssh_host_ed25519_key

output 'Converting initrd public SSH host key into public age key for sops-nix.'
nix-shell --extra-experimental-features flakes -p ssh-to-age --run 'cat /mnt/nix/secret/initrd/ssh_host_ed25519_key.pub | ssh-to-age'

output 'All steps completed successfully. NixOS is now ready to be installed.'
output "Remember to commit and push the new server's public host key to sops-nix and update all sops secrets before installing!"
output 'To install the NixOS configuration for hostname, run the following command'
output ' nixos-install --no-root-passwd --root /mnt --flake github:maneater2/lightlab#hostname'
