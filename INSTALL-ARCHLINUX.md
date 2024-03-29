# Arch Linux installation for ivara (2022.12)

Reference: [Arch Linux install guide](https://wiki.archlinux.org/index.php/Installation_guide)

## BIOS

Version: **R0IET68W (1.46) 2022-07-04**

Config:

- Intel (R) AMT / Intel (R) AM Control set to **Disabled**
- Display / Total Graphics Memory set to **512MB**

Security:

- Security Chip / Security Chip set to **Enabled** (TPM 2.0)
- Memory Protection / Execution Prevention set to **Enabled**
- Virtualization / Intel (R) Virtualization Technology set to **Disabled**
- Anti-Theft / Computrace set to **Permanently Disabled**
- Security / Secure Boot set to **Disabled**
- Intel (R) SGX set to **Software Controlled**
- Device Guard set to **Disabled**

Startup / Boot

1. USB HDD
2. Windows Boot Manager
3. ATA HDD0

Startup

- UEFI/Legacy Boot set to **UEFI Only**
- CSM Support set to **No**
- Boot device List F12 Option set to **Enabled**

## Basic install

* Boot on a USB key with [Arch Linux ISO](https://archlinux.org/download/) (not netinstall)

```
loadkeys fr
```

* Wi-Fi connection

```
iwctl
[iwd]# device list
[iwd]# station wlan0 get-neworks
[iwd]# station wlan0 connect <SSID>
```

* Create disk layout

```
Disk /dev/sda: 238.47 GiB, 256060514304 bytes, 500118192 sectors
Disk model: SAMSUNG MZ7LN256
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 624A75F3-F987-40B5-988F-6E5BA0CED4EE

Device         Start       End   Sectors   Size Type
/dev/sda1       2048   1128447   1126400   550M EFI System
/dev/sda2    1128448  43071487  41943040    20G Linux swap
/dev/sda3   43071488 210843647 167772160    80G Linux root (x86-64)
/dev/sda4  210843648 500117503 289273856 137.9G Linux user's home
```

* Create filesystems

```
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
```

* Bootstrap Arch Linux

```
mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux-lts linux-firmware intel-ucode networkmanager neovim
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt
```

* Set time zone

```
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
```

* Generate locale

In **/etc/locale.gen**, uncomment:

```
en_US.UTF-8
fr_FR.UTF-8
```

```
locale-gen
```

* Set the keyboard layout  

```
echo "KEYMAP=fr" > /etc/vconsole.conf
```

* Set hostname

```
echo "ivara" > /etc/hostname
```

Bootstrap **/etc/hosts**

```
127.0.0.1   localhost
::1		    localhost
127.0.1.1	ivara.localdomain	ivara
```

* Set root password

```
passwd
```

* Setup systemd-boot with Intel microcode

```
bootctl install
cp /usr/share/systemd/bootctl/arch.conf /boot/efi/loader/entries/arch-lts.conf
```

Adapt **/boot/efi/loader/entries/arch-lts.conf**

```
title   Arch Linux LTS
linux   /vmlinuz-linux-lts
initrd  /intel-ucode.img
initrd  /initramfs-linux-lts.img
options root=UUID=7036bf75-ca61-4ff7-b0db-513143bb6edc rootfstype=ext4 add_efi_memmap
```

**Note**: find UUID with ```blkid```.

Edit **/boot/efi/loader/loader.conf**:

```
timeout 3
console-mode max
default arch-lts.conf
```

Check configuration with ```bootctl list```

* Reboot

```
exit
reboot
```

## Network connection

Login as **root** and setup network

```
systemctl enable NetworkManager
systemctl start NetworkManager
nmcli device wifi list
nmcli device wifi connect <SSID> password 'xxxxxx'
```

**Note**: this configuration will be change later to avoid passwords in clear text in the NetworkManager connection files (see ```/etc/NetworkManager/system-connections```).

## User creation

```
pacman -S zsh sudo base-devel git python3
groupadd -g 1000 viny
useradd -m -G wheel -u 1000 -g 1000 -s /bin/zsh viny
passwd viny
```

In **/etc/sudoers** uncomment:

```text
%wheel ALL=(ALL:ALL) ALL
```

## Setup encrypted partition for user home

```text
cryptsetup luksFormat /dev/sda4
cryptsetup open /dev/sda4 home-viny
mkfs.ext4 /dev/mapper/hom-viny
```

```text
mkdir /home/viny
mount -t ext4 /dev/mapper/home-viny /home/viny
chown viny:viny /home/viny
chmod 700 /home/viny
```

Edit **/etc/pam.d/system-login**

```text
...
auth       include    system-auth
auth       optional   pam_exec.so expose_authtok /etc/pam_cryptsetup.sh

account    required   pam_access.so
...
```

Create executable script **/etc/pam_cryptsetup.sh**:

```shell
#!/bin/sh

CRYPT_USER=viny"
PARTITION="/dev/sda4"
NAME="home-$CRYPT_USER"

if [ "$PAM_USER" == "$CRYPT_USER" ] && [ ! -e "/dev/mapper/$NAME" ]; then
    /usr/bin/cryptsetup open $PARTITION $NAME
fi
```

Create **/etc/systemd/system/home-viny.mount**:

```text
[Unit]
Requires=user@1000.service
Before=user@1000.service

[Mount]
Where=/home/viny
What=/dev/mapper/home-viny
Type=ext4
Options=defaults

[Install]
RequiredBy=user@1000.service
```

**Note**: locking after unmout will be setup later with Ansible.
