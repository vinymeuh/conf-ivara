# conf-ivara (Lenovo X270)

## How to use

### Bootstrap

1. Install [Arch Linux](https://github.com/vinymeuh/conf-ivara/blob/master/INSTALL-ARCHLINUX.md)

2. Install **pyenv** using [pyenv installer](https://github.com/pyenv/pyenv-installer)

3. Create Python **virtualenv**:

```shell
pyenv virtualenv system conf-ivara
```

4. Install **conf-ivara**

```shell
cd $HOME
git clone https://github.com/vinymeuh/conf-ivara
cd conf-ivara
pyenv version  # must be conf-ivara, see .python-version
pip install -r requirements.txt
```
