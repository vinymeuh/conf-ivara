# conf-ivara (Lenovo X270)

## How to use

### Bootstrap

1. Install [Arch Linux](https://github.com/vinymeuh/conf-ivara/blob/master/INSTALL-ARCHLINUX.md)

2. Install **pyenv** using [pyenv installer](https://github.com/pyenv/pyenv-installer)

3. Download **conf-ivara**

```shell
cd $HOME
git clone https://github.com/vinymeuh/conf-ivara
```

4. Setup virtualenv for Ansible:

```shell
source $HOME/conf-ivara/bootstrap_env.sh
pyenv virtualenv system conf-ivara
cd conf-ivara
pyenv version  # must be conf-ivara, see .python-version
pip install -r requirements.txt
...
ansible --version
```

### Ansible playbooks

* **System setup** ```setup-system.yml```, run with become_user root
* **User setup** ```setup-user.yml```, run as user

```shell
cd ~/conf-nyx
ansible-playbook setup-system.yml -K [--check] 
ansible-playbook setup-user.yml [--check]
```

## Notes & tips

### nmcli

```shell
nmcli device status
nmcli -p con show <SSID>
```

```shell
nmcli dev wifi list
```

### firewalld

```shell
firewall-cmd --get-default-zone
```

```shell
firewall-cmd --get-active-zones
firewall-cmd --zone=home --change-interface=...
```

```shell
firewall-cmd --zone=home --list-all
```

### Systemd user timers

See:

```shell
systemctl --user list-timers --all
journalctl -u --user-unit
```
