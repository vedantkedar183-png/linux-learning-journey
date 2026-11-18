# 08 — Boot, Services, and Logs

## What happens when you press power

1. **Firmware (BIOS/UEFI)** runs a self-test, finds a bootable disk.
2. **Bootloader (GRUB)** shows the menu, loads the kernel and an initramfs into memory.
3. **Kernel** initialises hardware, mounts the root filesystem (via initramfs help), starts PID 1.
4. **init / systemd (PID 1)** takes over: reads its configuration and starts **units** — services,
   sockets, mounts, timers — in dependency order.
5. **Target** is reached (`multi-user.target` for servers, `graphical.target` for desktops).
6. **getty / display manager** gives you a login prompt or a GUI.

That is why "the service didn't start at boot" is usually a systemd question, not a program question.

```bash
$ systemd-analyze                 # total boot time
$ systemd-analyze blame           # which units took longest
$ systemd-analyze critical-chain  # the slow path
$ journalctl -b                   # this boot's log
$ journalctl -b -1                # previous boot (great after a crash)
```

## systemd in one page

| Concept | Meaning |
|---|---|
| **unit** | a thing systemd manages (`.service`, `.socket`, `.timer`, `.mount`, `.target`) |
| **target** | a group of units = a boot state (`multi-user.target` ≈ old runlevel 3) |
| **enable** | create a symlink so the unit starts at boot |
| **start** | run it now |
| **`WantedBy=`** | which target pulls this unit in |

```bash
$ systemctl status nginx
$ sudo systemctl start|stop|restart|reload nginx
$ sudo systemctl enable|disable nginx
$ sudo systemctl enable --now nginx      # enable AND start in one go
$ systemctl list-dependencies multi-user.target | head -30
$ systemctl get-default
```

`start` vs `enable` — the single most common beginner error:
- `start` → running **now**, gone after reboot
- `enable` → starts at **next boot**, not running now
- most of the time you want `enable --now`

`restart` vs `reload`:
- `restart` → stop process, start it again. Connections drop. Use after changing code or unit files.
- `reload` → ask the process to re-read config. Connections stay. Use after config-only changes.
- Not all services support reload; `systemctl reload` fails if they don't.

### Where unit files live
```
/lib/systemd/system/      ← shipped by packages (do not edit)
/etc/systemd/system/      ← your overrides and custom units (this wins)
~/.config/systemd/user/   ← user services (systemctl --user)
```
Override a packaged unit safely:
```bash
$ sudo systemctl edit nginx     # creates a drop-in in /etc/systemd/system/nginx.service.d/
$ sudo systemctl daemon-reload  # after ANY unit change
```

### Timers instead of cron
systemd can schedule jobs without cron:
```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Nightly backup
[Timer]
OnCalendar=daily
Persistent=true
[Install]
WantedBy=timers.target
```
```bash
$ sudo systemctl enable --now backup.timer
$ systemctl list-timers
```
`Persistent=true` means "if the machine was off, run it when it comes back". Cron cannot do that.

## Logs: journald and classic files

Two systems coexist:

### journald (binary, indexed, queryable)
```bash
$ journalctl                        # everything, newest last
$ journalctl -f                     # follow live
$ journalctl -u nginx               # one unit
$ journalctl -u nginx --since today
$ journalctl -b -p err              # errors since boot
$ journalctl -xe                    # recent entries + explanations (best for beginners)
$ journalctl _PID=4210              # by PID
$ journalctl --disk-usage
$ sudo journalctl --vacuum-size=200M
```
Journald stores logs in `/var/log/journal/` (persistent) or `/run/log/journal/` (cleared on reboot).
If your logs vanish after reboot, enable persistence:
```bash
$ sudo mkdir -p /var/log/journal
$ sudo systemctl restart systemd-journald
```

### Classic text files
| File | Contains |
|---|---|
| `/var/log/syslog` | general system messages (Debian/Ubuntu) |
| `/var/log/auth.log` | logins, `sudo`, SSH (Debian/Ubuntu) |
| `/var/log/kern.log` | kernel messages |
| `/var/log/dpkg.log` | package installs/removals |
| `/var/log/nginx/` | per-service logs |
| `/var/log/secure`, `/var/log/messages` | RHEL equivalents |

### Log rotation
Logs would fill the disk, so `logrotate` renames and compresses them:
```bash
$ cat /etc/logrotate.conf
$ ls /etc/logrotate.d/
$ sudo logrotate -d /etc/logrotate.conf     # dry run
```
Typical result: `syslog`, `syslog.1`, `syslog.2.gz`, … and old ones deleted.

## Reading a log like a detective

```bash
$ journalctl -u nginx --since "10 min ago" --no-pager
$ grep -i "fail\|error\|denied" /var/log/auth.log | tail -20
$ awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head
```
Approach: **filter by time, then by service, then by keyword.** Never read a log from the top.

## Boot problems: quick triage

| Symptom | First thing to check |
|---|---|
| Boots to emergency shell | `journalctl -xb`, usually a broken `/etc/fstab` |
| Service not running after reboot | `systemctl is-enabled <svc>`, `systemctl status` |
| Service fails immediately | `journalctl -u <svc> -n 50` — config error or wrong path |
| "Unit not found" | `systemctl list-unit-files \| grep name` — wrong name or not installed |
| Root filesystem read-only | disk error: `dmesg \| tail`, `df -h`, `mount \| grep ' / '` |
| Out of disk at boot | boot a rescue image, clear logs, `journalctl --vacuum-size` |

`systemd` rescue mode: at the GRUB menu press `e`, add `systemd.unit=rescue.target` to the `linux`
line, boot. You get a root shell without most services.

## Prove you understood

1. Which PID does systemd have, and what starts it?
2. If you `systemctl start nginx` but not `enable`, what happens after reboot?
3. What is the difference between `restart` and `reload`?
4. Why would journald logs disappear after a reboot?
5. You edited a unit file. What command must you run before your change takes effect?
6. Where would you look for failed SSH login attempts on Ubuntu?

<details>
<summary>Model answers</summary>

1. PID 1; the kernel starts it after mounting the root filesystem.
2. nginx stops running — it was never enabled for boot.
3. `restart` stops and starts the process (drops connections); `reload` asks it to re-read config
   without stopping.
4. The journal is only in `/run/log/journal` (tmpfs) unless `/var/log/journal` exists.
5. `sudo systemctl daemon-reload`.
6. `journalctl -u ssh` or `/var/log/auth.log`.
</details>
