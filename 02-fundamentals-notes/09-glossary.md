# 09 — Glossary

Alphabetical. Skim it now, come back whenever a word feels fuzzy.

**ACL** — Access Control List. Extra per-user/per-group permissions beyond owner/group/other.

**apt** — Debian/Ubuntu package manager. Front end to `dpkg`.

**Argument** — the thing a command acts on: in `cp a.txt b.txt`, both filenames are arguments.

**Background job** — a command started with `&` so the shell prompt returns immediately. See `jobs`.

**bash** — "Bourne Again SHell". The default interactive shell on most Linux systems.

**Bootloader** — program (GRUB) that loads the kernel.

**cgroup** — control group. Kernel feature that limits CPU/memory/IO for a set of processes.

**cron** — scheduler that runs commands at set times. Edited with `crontab -e`.

**daemon** — a background service with no terminal, e.g. `sshd`.

**dependency** — a package required by another package.

**device file** — a file in `/dev` representing hardware (`/dev/sda`, `/dev/null`).

**directory** — a folder. In Linux, folders are a kind of file that maps names to inodes.

**distro (distribution)** — a complete Linux system: kernel + tools + package manager + defaults.

**DNS** — Domain Name System. Turns names (`example.com`) into IP addresses.

**dpkg** — low-level Debian package tool; registers what is installed.

**environment variable** — a named value passed to programs, e.g. `PATH`, `HOME`.

**exit code** — number a process returns: `0` success, non-zero failure. Stored in `$?`.

**ext4 / xfs / btrfs** — filesystem types (how data is organised on disk).

**filesystem** — the structure that stores files on a device.

**filter** — a command that reads stdin and writes stdout, e.g. `grep`, `sort`.

**foreground** — the job currently attached to your terminal.

**fstab** — `/etc/fstab`. Table of filesystems mounted at boot.

**GID** — group ID number.

**GRUB** — the bootloader used by most Linux systems.

**grep** — search text with patterns (regular expressions).

**hard link** — a second name for the same inode/data on disk.

**home directory** — your personal folder, `/home/<user>`, written `~`.

**hostname** — the machine's name on the network.

**inode** — metadata record for a file: owner, permissions, size, timestamps, data location. One inode
per file; hard links share it.

**init / systemd** — PID 1, the first user-space process, which starts everything else.

**IP address** — numeric network address, e.g. `192.168.1.42`.

**journald** — systemd's logging service; read with `journalctl`.

**kernel** — the core of the OS; manages CPU, memory, devices, permissions.

**load average** — average number of runnable/uninterruptible processes over 1/5/15 minutes.

**login shell** — the shell started when you log in; reads `~/.profile` / `~/.bash_profile`.

**mount** — attach a filesystem to a folder in the tree.

**nice** — scheduling priority, −20 (highest) to 19 (lowest).

**octal** — base-8 number used for permissions, e.g. `755`.

**package** — installable software archive plus metadata.

**parent process** — the process that started another; see PPID.

**PATH** — list of folders the shell searches for commands.

**permission bits** — `rwx` for user, group, other.

**PID** — process ID.

**pipe (`|`)** — connects one command's output to another's input.

**PPID** — parent process ID.

**process** — a running program instance.

**protocol** — agreed rules for communication, e.g. TCP, UDP, HTTP, SSH.

**redirect** — send output to a file (`>`, `>>`) or read input from one (`<`).

**repository** — online catalogue of packages.

**root** — (1) the top folder `/`; (2) the superuser with UID 0. Context tells you which.

**rootfs** — the root filesystem mounted at `/`.

**rsync** — efficient file-copy/sync tool that transfers only differences.

**runlevel / target** — boot state grouping services. Modern: `multi-user.target`,
`graphical.target`.

**scp** — copy files over SSH (older, simpler than `rsync`).

**service / unit** — a background program managed by systemd.

**setgid (SGID)** — bit that makes new files inherit a folder's group, or runs a program as its group.

**setuid (SUID)** — bit that makes a program run with its owner's rights.

**shell** — program that reads commands and runs them.

**shebang** — the `#!/usr/bin/env bash` first line of a script, telling the kernel which interpreter
to use.

**signal** — short message sent to a process (`SIGTERM`, `SIGKILL`, `SIGHUP`).

**snapshot** — saved state of a VM/disk you can restore.

**SSH** — Secure Shell. Encrypted remote login, port 22.

**stderr** — standard error stream (fd 2). Errors go here.

**stdin** — standard input stream (fd 0).

**stdout** — standard output stream (fd 1). Normal output goes here.

**sticky bit** — folder bit so only a file's owner can delete it (e.g. `/tmp`).

**sudo** — run one command with another user's rights (usually root).

**swap** — disk space used as overflow RAM.

**symlink (soft link)** — a shortcut file pointing to another path.

**systemd** — init system and service manager.

**tar** — archive tool ("tape archive"), often with gzip: `.tar.gz`.

**TCP / UDP** — transport protocols. TCP is reliable and ordered; UDP is fast and connectionless.

**terminal** — the window/app where you type; a *terminal emulator*.

**TTY** — a text terminal, physical or virtual (`Ctrl+Alt+F3`).

**UID** — user ID number. Root = 0.

**umask** — mask subtracted from default permissions for new files/folders.

**unit file** — systemd configuration file for a service/timer/etc.

**user** — an account identified by a UID.

**virtualenv** — isolated Python environment for project-specific packages.

**WSL** — Windows Subsystem for Linux; runs real Linux inside Windows.

**X / Wayland** — display server protocols for GUIs.

**yum / dnf** — RHEL-family package managers.

**zombie** — a finished process whose parent has not collected its exit status.
