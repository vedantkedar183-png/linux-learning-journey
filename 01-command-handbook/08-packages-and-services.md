# 08 — Packages and Services: Installing Software the Linux Way

**The idea:** you do not download `.exe` files from websites. You ask a **package manager** to install
software from trusted repositories. It handles dependencies (the libraries the program needs) and
keeps a database of what is installed.

Ubuntu/Debian use **APT** with `.deb` packages. Fedora/RHEL use **DNF/RPM**. Both are covered here.

---

## APT basics (Ubuntu / Debian / WSL / Mint)

### The daily three
```bash
$ sudo apt update                # refresh the list of available packages
$ sudo apt upgrade               # install newer versions of what you have
$ sudo apt install <package>     # install something new
```
`apt update` does **not** install anything. It only downloads the catalog. Forgetting it is why
`apt install` sometimes says "Unable to locate package".

### Finding and inspecting
```bash
$ apt search nginx               # search names and descriptions
$ apt show nginx                 # details: version, size, dependencies
$ apt list --installed           # everything installed (long!)
$ apt list --upgradable          # what has updates
$ dpkg -l | grep nginx           # installed packages matching nginx
$ dpkg -L nginx                  # every file this package installed
$ apt-cache policy nginx         # installed vs candidate version
```

### Removing
```bash
$ sudo apt remove nginx          # remove the program, keep config files
$ sudo apt purge nginx           # remove program AND config
$ sudo apt autoremove            # clean up unused dependencies
$ sudo apt clean                 # clear the download cache
```

### Installing a local `.deb` file
```bash
$ sudo apt install ./app.deb     # recommended (resolves dependencies)
$ sudo dpkg -i app.deb           # low level; if it fails:
$ sudo apt --fix-broken install
```

### Common packages worth installing for this course
```bash
$ sudo apt install tree htop curl wget vim nano less \
                   net-tools dnsutils iproute2 traceroute \
                   rsync zip unzip tmux git
```

### Held-back updates
Sometimes `apt upgrade` says "the following packages have been kept back". Those need:
```bash
$ sudo apt full-upgrade
```
Read what it will do before pressing `Y`.

---

## Other package managers you will meet

### `snap` — self-contained apps (Ubuntu)
```bash
$ snap find code
$ sudo snap install code --classic
$ snap list
$ sudo snap remove code
```

### `flatpak` — cross-distro apps
```bash
$ sudo apt install flatpak
$ flatpak install flathub org.gimp.GIMP
$ flatpak list
```

### `dnf` / `yum` — Fedora, RHEL, Rocky, Alma
| Task | Debian/Ubuntu | Fedora/RHEL |
|---|---|---|
| refresh catalog | `apt update` | `dnf check-update` |
| upgrade all | `apt upgrade` | `dnf upgrade` |
| install | `apt install pkg` | `dnf install pkg` |
| remove | `apt remove pkg` | `dnf remove pkg` |
| search | `apt search term` | `dnf search term` |
| show info | `apt show pkg` | `dnf info pkg` |
| list installed | `apt list --installed` | `dnf list installed` |
| which file owns this? | `dpkg -S /path` | `rpm -qf /path` |

### `pip`, `npm`, `cargo` — language package managers
Not system packages. Useful, but do not `sudo pip install` on modern systems — use a virtual env:
```bash
$ python3 -m venv .venv && source .venv/bin/activate
$ pip install requests
```

### Building from source (when there is no package)
```bash
$ sudo apt install build-essential
$ ./configure && make && sudo make install
```
Prefer the package manager. Build from source only when you must.

---

## Services with `systemctl`

A **service** is a program that runs in the background and is managed by **systemd** (PID 1).

```bash
$ systemctl status nginx           # state + last log lines + main PID
$ sudo systemctl start nginx       # start now
$ sudo systemctl stop nginx
$ sudo systemctl restart nginx     # stop then start
$ sudo systemctl reload nginx      # re-read config, keep connections
$ sudo systemctl enable nginx      # start at boot
$ sudo systemctl disable nginx
$ systemctl is-active nginx        # active / inactive
$ systemctl is-enabled nginx       # enabled / disabled
$ systemctl list-units --type=service --state=running
$ systemctl --failed               # anything broken?
```

**Every time you edit a service config:** `sudo systemctl reload <svc>` (or `restart`), then
`systemctl status` and `journalctl -u <svc>` to check it worked.

### Unit files (where service definitions live)
```bash
$ systemctl cat nginx                  # show the unit file(s)
$ ls /etc/systemd/system/              # your custom units
$ ls /lib/systemd/system/              # package-provided units
$ sudo systemctl daemon-reload         # after editing any unit file
```

Minimal custom service, `/etc/systemd/system/hello.service`:
```ini
[Unit]
Description=Hello service
After=network.target

[Service]
User=student
ExecStart=/home/student/hello.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
Then:
```bash
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now hello
$ systemctl status hello
```

---

## Logs with `journalctl`

```bash
$ journalctl -u nginx              # this service
$ journalctl -u nginx -f           # follow live
$ journalctl -b                    # this boot
$ journalctl --since "10 min ago"
$ journalctl -p err -b             # errors only
$ journalctl -xe                   # recent + explanation (great for beginners)
$ sudo journalctl --vacuum-time=7d # free space, keep a week
```
Traditional log files still exist too: `/var/log/syslog`, `/var/log/auth.log`,
`/var/log/nginx/access.log`, `/var/log/nginx/error.log`.

---

## System settings

```bash
$ timedatectl                      # time, timezone, NTP status
$ sudo timedatectl set-timezone Asia/Kolkata
$ hostnamectl                      # hostname and OS info
$ sudo hostnamectl set-hostname lab-server
$ localectl                        # keyboard/locale
$ sudo reboot                      # restart
$ sudo shutdown -h now             # power off
$ sudo shutdown -r +5              # restart in 5 minutes
```

---

## Practice lab

1. Refresh the package catalog and show how many packages are upgradable.
2. Search for `htop` and show its description and installed size.
3. Install `tree` (if not installed), then find where its binary lives.
4. Which package owns the file `/usr/bin/tree`?
5. Show all files installed by the `tree` package.
6. Check whether `cron` is running and enabled.
7. Show the last 15 log lines for `cron`.
8. Check your timezone and NTP sync status.
9. Remove `tree`, then confirm it is gone with `dpkg -l | grep tree`.
10. (Stretch) Create the `hello.service` above that runs a tiny script every boot, start it, verify
    with `status`, then disable and remove it.

<details>
<summary>Answers</summary>

```bash
sudo apt update && apt list --upgradable        # 1
apt show htop                                   # 2
sudo apt install tree && which tree             # 3
dpkg -S /usr/bin/tree                           # 4
dpkg -L tree                                    # 5
systemctl is-active cron; systemctl is-enabled cron   # 6
journalctl -u cron -n 15                        # 7
timedatectl                                     # 8
sudo apt remove tree && dpkg -l | grep tree     # 9
# 10: create script, then:
sudo systemctl daemon-reload
sudo systemctl enable --now hello
systemctl status hello
sudo systemctl disable --now hello
sudo rm /etc/systemd/system/hello.service
sudo systemctl daemon-reload
```
</details>

---

## If a package install fails

| Error | Cause | Fix |
|---|---|---|
| `Unable to locate package` | stale catalog or wrong name | `sudo apt update`, check spelling |
| `Could not get lock /var/lib/dpkg/lock` | another APT is running | wait, or find it: `ps aux \| grep apt` |
| `Unmet dependencies` | broken state | `sudo apt --fix-broken install` |
| `404 Not Found` on a repo | old release / changed repo | check `ls /etc/apt/sources.list.d/` |
| `Permission denied` | forgot `sudo` | add `sudo` |
| `dpkg was interrupted` | a previous install died | `sudo dpkg --configure -a` |
