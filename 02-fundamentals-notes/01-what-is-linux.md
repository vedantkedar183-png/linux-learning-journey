# 01 — What Is Linux?

## The short answer

Linux is an **operating system**: the software that sits between you and the computer's hardware.
It decides which program gets the CPU, hands out memory, reads and writes files, and talks to the
network.

"Operating system" is a bit like "building manager":
- Tenants (programs) want rooms (memory), doors (devices), and mail (network).
- The manager decides who gets what, keeps people from stealing each other's stuff, and cleans up.

---

## The long answer: Linux is a family, not one thing

Strictly speaking, **Linux is only the kernel** — the core of the system, created by Linus Torvalds
in 1991 and released under a free licence.

Everything else you see (the tools, the installer, the desktop, the package manager) comes from other
projects. That is why people actually run **"distributions"** (distros):

| Distro | Based on | Package manager | Known for |
|---|---|---|---|
| **Ubuntu** | Debian | `apt` | Friendliest, biggest community, great for beginners |
| **Debian** | — | `apt` | Rock solid, server favourite |
| **Linux Mint** | Ubuntu | `apt` | Windows-like desktop |
| **Fedora** | — | `dnf` | Modern, upstream-first |
| **Rocky / Alma** | RHEL | `dnf` | Enterprise, server jobs |
| **Arch** | — | `pacman` | Build-it-yourself, for tinkerers |
| **Alpine** | — | `apk` | Tiny, used in containers |

When a tutorial says "Linux", it usually means "Ubuntu or similar, using a shell". The commands in
this project work on any Debian/Ubuntu system; differences for RHEL are noted where they matter.

## GNU + Linux

Many of the commands you will type (`ls`, `cp`, `grep`, `bash`) come from the **GNU project**, started
by Richard Stallman in 1983. That is why purists say **GNU/Linux**. In everyday speech, "Linux" is
fine.

---

## What makes Linux different (the four ideas worth knowing)

### 1. Everything is a file
Files, folders, hard disks, keyboards, even network sockets are represented as files or file-like
objects under `/dev` and `/proc`. That means the same tools (`cat`, `ls`, `echo`) can inspect very
different things:
```bash
$ cat /proc/cpuinfo      # the CPU, exposed as a text file
$ cat /dev/urandom | head -c 16 | xxd    # random bytes from the kernel
```

### 2. Small tools, combined
Instead of one giant program, Linux gives you many small programs that each do one job well. You
combine them with pipes:
```bash
$ ps aux | grep nginx | awk '{print $2}'    # three tools, one answer
```
This is why Linux feels hard at first and fast forever after: you are not memorising features, you
are learning to assemble parts.

### 3. Multi-user by design
Linux was built for many people sharing one machine. Every file has an owner, every process runs as
some user, and permissions are enforced by the kernel. Even on your laptop, dozens of system users
exist and are sandboxed from you.

### 4. Configuration is text
Settings live in plain text files under `/etc`. You can read them, diff them, version them with git,
and copy them to another machine. No hidden registry.

---

## Free software, in one paragraph

"Free" here means **freedom**, not price: you may run it, study it, change it, and share it. That is
why Linux runs most of the internet, all of Android, every top-500 supercomputer, and most cloud
servers. You can read the source code of anything you run, which is also why fixing problems is
possible without waiting for a company.

---

## Where Linux actually is (so you know why it matters)

- **Servers / cloud:** the majority of web servers, AWS, Google Cloud, Azure backends.
- **Android:** the kernel under every Android phone.
- **Containers:** Docker images are Linux filesystems; Kubernetes nodes are Linux.
- **Embedded:** routers, TVs, cars, Raspberry Pi, smart devices.
- **Supercomputers:** 100% of the TOP500 list.
- **Your desktop:** optional, but excellent (Ubuntu, Fedora, Mint).

Learning Linux is not learning one app. It is learning the environment where modern software lives.

---

## Prove you understood

Answer without looking:

1. What exactly is "Linux" vs a "distribution"?
2. Name three distros and their package managers.
3. What does "everything is a file" let you do that Windows tools cannot easily do?
4. Why does Linux care so much about file ownership?
5. In one sentence, why is Linux used on servers more than desktops?

<details>
<summary>Model answers</summary>

1. Linux is the kernel; a distribution is the kernel plus tools, installer, package manager, and
   defaults (Ubuntu = Linux kernel + GNU tools + apt + Ubuntu defaults).
2. Ubuntu→apt, Fedora→dnf, Arch→pacman (also Debian→apt, Alpine→apk).
3. Inspect and control hardware and kernel state with normal text tools, e.g. `cat /proc/cpuinfo`.
4. Because many users share one machine; the kernel must stop one user reading or changing another's
   data.
5. It is free, stable, scriptable, and remotely manageable — ideal for machines nobody sits in front of.
</details>
