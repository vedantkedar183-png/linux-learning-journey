# 03 — The Linux Filesystem Hierarchy

## The big idea

There is exactly **one tree**. It starts at `/` (called "root" — the top folder, not the root user)
and every file and device hangs somewhere below it.

Windows separates things by drive (`C:\`, `D:\`). Linux does not. A second disk is *mounted* — glued
into the tree at some folder, e.g. `/mnt/data`. Nothing has a letter.

```bash
$ ls /
bin   boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

**Paths are read left to right, from general to specific.** `/home/student/notes/todo.txt` means:
root → `home` → user `student` → folder `notes` → file `todo.txt`.

---

## What lives where (and why you care)

| Folder | Holds | Why you care |
|---|---|---|
| `/` | the top of everything | a full `/` breaks the whole system |
| `/bin`, `/usr/bin` | user programs (`ls`, `cp`, `python3`) | `which` points here |
| `/sbin`, `/usr/sbin` | admin programs (`fdisk`, `useradd`) | usually need `sudo` |
| `/etc` | **configuration files** (text) | every service setting lives here |
| `/home/<user>` | each user's personal files | your `~`, your `linux-lab` |
| `/root` | the root user's home | not `/home/root` — a classic mistake |
| `/var` | **variable data**: logs, caches, databases, mail | `/var/log` is where you debug |
| `/var/log` | log files | `syslog`, `auth.log`, `nginx/` |
| `/tmp` | temporary files, cleared on reboot | OK for scratch, never for real data |
| `/dev` | device files (`/dev/sda`, `/dev/null`) | "everything is a file" |
| `/proc` | live kernel/process info, fake files | `cat /proc/cpuinfo` |
| `/sys` | kernel/device settings | advanced tuning |
| `/usr` | the big software collection | `/usr/share` docs, `/usr/local` your installs |
| `/opt` | third-party software bundles | some apps install here |
| `/srv` | data served by this machine (web, ftp) | good place for a website |
| `/mnt` | temporary mounts | `/mnt/c` in WSL is your Windows C: |
| `/media` | auto-mounted removable drives | USB sticks appear here |
| `/boot` | kernel and bootloader | don't touch unless you mean it |
| `/lib`, `/lib64` | shared libraries (.so) | the "DLLs" of Linux |
| `/run` | runtime state since boot | PIDs, sockets |

### Memory hooks
- **ETC** = "Editable Text Configuration" (the real origin is disputed, but the mnemonic works).
- **VAR** = "variable" — things that *change* while running: logs grow, spools fill.
- **USR** = "Unix System Resources" on modern systems; historically "user" programs.
- **PROC** = processes, but it is a window into the kernel, not a folder on disk.

---

## Absolute vs relative paths

| Path | Type | Meaning |
|---|---|---|
| `/etc/hosts` | absolute | always the same file |
| `hosts` | relative | `./hosts` — in the current folder |
| `../hosts` | relative | one folder up, then `hosts` |
| `~/notes` | relative to home | `/home/student/notes` |

If a path starts with `/` it is absolute. Otherwise it depends on where you currently are — which is
why `pwd` exists.

## Special path shortcuts

| Symbol | Means |
|---|---|
| `.` | current folder |
| `..` | parent folder |
| `~` | my home folder |
| `~alice` | alice's home folder |
| `-` | previous folder (with `cd`) |
| `/` | the top |

## Hidden files

Any name starting with `.` is hidden from plain `ls` — it is a naming convention, not a security
feature.
```bash
$ ls -a ~
.bashrc  .profile  .ssh  .cache  ...
```
Most config for your user lives in hidden files in your home folder:
- `~/.bashrc` — shell settings, aliases, `PATH`
- `~/.profile` — login-time settings
- `~/.ssh/` — keys and known hosts
- `~/.config/` — modern app configs

## Where should *my* stuff go?

| Data | Good location |
|---|---|
| Personal experiments | `~/linux-lab` |
| Your own scripts | `~/bin` (add to `PATH`) |
| Real project files | `~/projects/<name>` |
| System-wide shared data | `/srv/<name>` or `/opt/<name>` |
| Config you change | `/etc/<service>/` (copy the original first!) |
| Logs | `/var/log/` (read-only for you) |
| Scratch | `/tmp` (never for anything you want to keep) |

**Never put your own files in `/usr/bin` or `/bin`.** Those belong to the package manager, and your
files will be silently overwritten on upgrade.

---

## Mounting: how a second disk joins the tree

```bash
$ lsblk                     # list block devices
$ df -h                     # what is mounted where
$ mount | head              # current mounts
$ findmnt /                  # what device backs / ?
```
Temporary mount:
```bash
$ sudo mkdir -p /mnt/data
$ sudo mount /dev/sdb1 /mnt/data
$ ls /mnt/data
$ sudo umount /mnt/data     # note: "umount", not "unmount"
```
Permanent mounts go in `/etc/fstab`. A broken `fstab` can stop the machine from booting, so always
test with `sudo mount -a` before rebooting.

## Inodes and disk space (the thing that confuses everyone)

Files have two parts: **the data blocks** and an **inode** (the metadata: owner, permissions, size,
timestamps, where the data is). A filesystem has a fixed number of inodes.

If you run out of inodes you get "No space left on device" **even with free space**:
```bash
$ df -i
Filesystem      Inodes  IUsed   IFree IUse% Mounted on
/dev/sda1      6553600 6553600       0  100% /
```
Common cause: millions of tiny files (session files, mail queue, cache). Fix by finding and clearing
the offender, not by adding disk.

---

## Practice: read the tree

```bash
$ ls -l /
$ ls /etc | head -20
$ ls /var/log | head
$ cat /etc/hostname
$ echo $HOME
$ df -h
$ ls -a ~ | head -15
```

Then answer:

1. Where would you look for nginx's configuration? Its access log?
2. Where is your home folder? Where is root's home folder?
3. What is the difference between `/mnt` and `/media`?
4. Which folder would you use for a website served by this machine?
5. Why is `/tmp` a bad place for a backup?

<details>
<summary>Answers</summary>

1. Config in `/etc/nginx/`; access log in `/var/log/nginx/access.log`.
2. `/home/<you>`; root's home is `/root`.
3. `/mnt` is for manual/temporary mounts; `/media` is where the desktop auto-mounts removable drives.
4. `/srv/www` or `/var/www` (both common; Debian uses `/var/www` by default).
5. It can be wiped on reboot, and it is often world-writable and size-limited.
</details>
