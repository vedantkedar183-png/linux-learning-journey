# 04 — Users, Groups, and Ownership

## Why this exists

Linux was designed for many people sharing one computer. The kernel must answer, for every single
action: **"Is this user allowed to do that?"** To answer, it needs to know *who* is asking and *what
rules apply to the file*.

Two facts do all the work:
1. Every **process** runs as a user (and a group).
2. Every **file** has an owner, a group, and permissions.

---

## Types of users

### 1. The root user (UID 0)
The superuser. Bypasses permission checks entirely. Can read, change, and delete anything.
- UID is always **0**.
- Home is `/root` (not `/home/root`).
- Prompt usually ends with `#` instead of `$`.
- On Ubuntu, direct root login is disabled; you use `sudo` instead.

### 2. Regular user accounts (UID 1000 and up)
Real people. First user created on Ubuntu gets UID 1000. Cannot touch system files without `sudo`.

### 3. System / service accounts (UID 1–999)
Not for humans. Created by packages for daemons: `www-data` runs nginx, `sshd` runs SSH,
`systemd-network` handles networking. Their shells are usually `/usr/sbin/nologin` so nobody can log
in as them.

```bash
$ grep -E "nologin|false" /etc/passwd | head
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
```
"Run as a limited user" is a security feature: if nginx is hacked, the attacker gets `www-data`
rights, not root.

### 4. `nobody`
A deliberately powerless account, used when a service should have almost no rights at all.

---

## Users are really just numbers

The kernel knows nothing about names. It uses **UIDs** and **GIDs** (numbers). Names are a convenience
mapping stored in files:

| File | Contents | Who can read |
|---|---|---|
| `/etc/passwd` | user name, UID, GID, home, shell | everyone |
| `/etc/shadow` | password **hashes**, expiry rules | root only |
| `/etc/group` | group name, GID, member list | everyone |

A line in `/etc/passwd`:
```
student:x:1000:1000:Student User:/home/student:/bin/bash
   │    │  │    │        │             │            └── login shell
   │    │  │    │        │             └── home folder
   │    │  │    │        └── comment / full name
   │    │  │    └── primary group GID
   │    │  └── UID
   │    └── password placeholder ("x" = the real hash is in /etc/shadow)
   └── username
```
The `x` is why nobody can read your password from `/etc/passwd` any more (old systems stored it there).

Passwords in `/etc/shadow` are **hashes** (one-way). Modern Ubuntu uses yescrypt. You can verify a
password against a hash, but you cannot reverse it. That is why "reset" is the only recovery, and why
weak passwords are still dangerous: attackers hash guesses and compare.

---

## Groups: shared access without sharing accounts

A **group** is a named set of users. Instead of granting access to five people individually, grant it
to one group.

Every user has:
- **one primary group** (recorded in `/etc/passwd`) — used for new files you create
- **any number of supplementary groups** (recorded in `/etc/group`) — extra rights

```bash
$ id
uid=1000(student) gid=1000(student) groups=1000(student),27(sudo),1001(devs)
                          │                    │              │
                          primary         supplementary   supplementary
```

Why this matters: create a file, and its **group is your primary group**. If you want files to belong
to a project group instead, you either change your primary group or use the **SGID bit** on the folder
(see note 05).

### Common groups worth knowing

| Group | What it grants |
|---|---|
| `sudo` (Ubuntu) / `wheel` (RHEL) | may run commands as root via `sudo` |
| `adm` | read many logs in `/var/log` |
| `docker` | full control of the Docker daemon — effectively root. Treat with care |
| `www-data` | owns web content |
| `sudo`/`adm` are the only ones you normally juggle as a beginner |

⚠️ `docker` group membership is root-equivalent. Anyone in it can mount the host filesystem inside a
container. Never grant it casually.

---

## Ownership of files

Every file has exactly one **owner** (user) and one **group**:
```bash
$ ls -l report.txt
-rw-r----- 1 alice devs 2048 Nov 16 12:00 report.txt
            │     │
            │     └── group owner: devs
            └── user owner: alice
```

Rules the kernel enforces:
- Only **root** can change a file's owner.
- A normal user can change a file's **group** only to a group they belong to, and only for files they
  own.
- Deleting a file is controlled by the **folder's** write permission, not the file's. This surprises
  everybody: you can delete a read-only file if you can write to its folder.

That last rule is why "protected" folders matter more than read-only files.

---

## Changing identity

```bash
$ whoami                 # effective username
$ id                     # uid, gid, all groups
$ groups                 # just group names
$ su - alice             # become alice (needs alice's password)
$ sudo -i                # become root (needs YOUR password + sudo rights)
$ sudo -u www-data whoami    # one command as another user
$ exit                   # leave that identity
```

**Difference between `su` and `sudo`:**
| | `su` | `sudo` |
|---|---|---|
| Password needed | the **target** user's | **your** password |
| Duration | until you `exit` | one command (cached ~15 min) |
| Logged | weakly | every use is logged with your name |
| Typical use | switch to a user | perform one admin task |

`sudo` is preferred because it is auditable and temporary. You can see who did what in
`/var/log/auth.log`.

---

## How new users are created

```bash
$ sudo adduser alice
```
Behind the scenes this:
1. picks the next free UID (usually 1001, 1002, …)
2. creates a group `alice` with the same GID (Ubuntu's "user private group" scheme)
3. creates `/home/alice` with `700` permissions
4. copies files from `/etc/skel` (`.bashrc`, `.profile`) into it
5. adds the entry to `/etc/passwd` and `/etc/shadow`
6. sets the password

`/etc/skel` is why every new user gets a working shell configuration. Add a file there and every
future user gets it too.

Deleting:
```bash
$ sudo deluser --remove-home alice
```
Without `--remove-home`, the home folder stays. Be deliberate: a deleted user's UID may later be
reused by a *different* person, who would then own the leftover files.

---

## Prove you understood

1. What UID does root have, and why is that number special?
2. What is the difference between a primary and a supplementary group?
3. Why are service accounts given `/usr/sbin/nologin`?
4. Why can you delete a file you cannot write to?
5. When would you use `su` instead of `sudo`?
6. Where are password hashes stored, and why not in `/etc/passwd`?

<details>
<summary>Model answers</summary>

1. UID 0; the kernel's permission check short-circuits for UID 0, granting everything.
2. Primary is recorded in `/etc/passwd` and becomes the group of files you create; supplementary are
   extra groups in `/etc/group` that grant additional access.
3. So nobody can log in as that account, limiting damage if the service is compromised.
4. Deleting modifies the **directory** (removing an entry), and that requires write permission on the
   directory itself.
5. When you need a full shell as another user, or when sudo is not configured and you have the target
   password (e.g. legacy systems).
6. `/etc/shadow`, readable only by root, because hashes are crackable offline if leaked; `/etc/passwd`
   must be world-readable for name lookups.
</details>
