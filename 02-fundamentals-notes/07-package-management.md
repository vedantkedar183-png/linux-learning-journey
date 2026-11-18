# 07 — Package Management: How Software Arrives on Linux

## The problem it solves

In the Windows world you find a website, download an `.exe`, click Next-Next-Finish, and hope the
installer also brought the libraries it needs. Twenty apps, twenty updaters, twenty trust decisions.

Linux does it differently: **one trusted catalogue, one installer, one updater, one database of what is
installed.** That is a package manager.

| Term | Meaning |
|---|---|
| **Package** | a compressed archive of files + metadata (`.deb` for Debian/Ubuntu, `.rpm` for RHEL) |
| **Repository** ("repo") | an online catalogue of packages, with signatures |
| **Dependency** | another package this one needs to work |
| **Package manager** | the tool that resolves dependencies and installs/removes packages |
| **Index** | the local list of what the repos offer |

## The mental model

```
   [ Ubuntu repo servers ]
              │  apt update        (download the catalogue)
              ▼
   /var/lib/apt/lists/   ── apt install ──▶  downloads .deb from the repo
              │                                   │
              ▼                                   ▼
        dpkg database                      unpacks files to /usr, /etc, /lib
      (what is installed)                 runs post-install scripts
              │
              ▼
        apt upgrade   (installs newer versions)
```

Key insight: **`apt` decides *what* to install; `dpkg` does the mechanical unpacking.** That is why
`dpkg -l` can list packages and `apt` can solve dependencies.

## `apt update` vs `apt upgrade` — the classic mix-up

```bash
$ sudo apt update        # ONLY refreshes the catalogue. Installs nothing.
$ sudo apt upgrade       # installs newer versions of ALREADY installed packages
$ sudo apt install vim   # installs a NEW package
```
"Unable to locate package" almost always means you skipped `apt update`, or the name is wrong.

## Why repositories matter (supply chain)

When you `apt install`, you are trusting:
1. the repo's **GPG signature** (Ubuntu signs its package lists),
2. the package maintainer,
3. the **pinning/priority** rules that decide which repo wins.

That is a very different trust model from "run this script from a random website as root".
Adding a third-party repo (PPA) means trusting one more party. Fine when it is the project's official
PPA; risky otherwise.

## Dependencies, or "why did 200 packages install?"

Programs share libraries. Install a desktop app and it may pull in GTK, fonts, image codecs, etc. The
package manager computes the closure of needed packages. This is why `apt install` output can look scary
but is actually the feature that prevents "missing DLL" errors forever.

Conflict possibility: two packages both need different major versions of the same library. Good package
management prevents this. `snap`/`flatpak`/Docker solve it differently by **bundling** dependencies into
isolated packages, trading disk space for isolation.

## The three modern delivery styles

| Style | Example | Pros | Cons |
|---|---|---|---|
| **Distro packages** | `apt install nginx` | small, integrated, security-updated | older versions |
| **Snap / Flatpak** | `snap install code` | isolated, self-updating, newer | bigger, slower start, sandbox quirks |
| **Containers** | `docker run nginx` | fully reproducible, isolated | another layer to learn |
| **Language packages** | `pip`, `npm`, `cargo` | newest libraries for devs | not system-managed, can conflict |

Rule of thumb: **system tools and services → distro packages. Desktop apps → snap/flatpak is fine.
Your project's libraries → language package manager, inside a virtualenv.**

## Versions, pins, and reproducibility

```bash
$ apt policy nginx            # installed vs candidate version
$ apt install nginx=1.24.0-1ubuntu1   # pin an exact version (if in the repo)
$ apt-mark hold nginx         # stop this package upgrading
$ apt-mark unhold nginx
```
For real reproducibility (servers, teams), write down the exact versions you installed:
```bash
$ dpkg --get-selections > packages.txt      # snapshot
$ sudo dpkg --set-selections < packages.txt # restore (then apt-get dselect-upgrade)
```

## Where installed files go

| Path | Contents |
|---|---|
| `/usr/bin`, `/bin` | executables |
| `/usr/lib` | libraries |
| `/etc/<pkg>/` | configuration (**your edits live here**) |
| `/usr/share/doc/<pkg>/` | docs, README, changelog |
| `/var/lib/<pkg>/` | package state/data |
| `/var/log/<pkg>/` | logs |

Find out what a package owns:
```bash
$ dpkg -L nginx           # files installed by nginx
$ dpkg -S /usr/sbin/nginx # which package owns this file
```
That second command is how you answer "where did this binary come from?".

## Upgrading safely (the habit that prevents disasters)

1. Read the screen before pressing `Y`. Especially `The following packages will be REMOVED:`.
2. Prefer `apt upgrade` normally; use `full-upgrade` when it wants to add/remove packages, and read
   carefully.
3. On a server: on a VM, **snapshot first**. On real hardware, at least back up configs in `/etc`.
4. Reboot when the kernel or systemd updates (`/var/run/reboot-required` appears).
5. Never mix repos from different distro versions.

## Automatic updates (Ubuntu)

```bash
$ sudo apt install unattended-upgrades
$ sudo dpkg-reconfigure --priority=low unattended-upgrades
$ cat /etc/apt/apt.conf.d/50unattended-upgrades
```
Security patches install themselves; feature upgrades do not. That is the sane default for servers.

## Prove you understood

1. What exactly does `apt update` change on your system?
2. Why does `apt install` sometimes want to install 50 other packages?
3. What is the difference between `remove` and `purge`?
4. Where should you look for a service's config after installing it?
5. Why might a distro ship an older version of a program on purpose?
6. Which command tells you what package installed `/usr/bin/tree`?

<details>
<summary>Model answers</summary>

1. It updates the package **index** (`/var/lib/apt/lists/`) — the catalogue. No software changes.
2. Those are dependencies (libraries and support packages) required for the program to run.
3. `remove` deletes the program but keeps config files; `purge` deletes config too.
4. `/etc/<package-name>/` (e.g. `/etc/nginx/`).
5. Stability and security: maintainers backport patches rather than changing behaviour, so production
   systems do not break.
6. `dpkg -S /usr/bin/tree`.
</details>
