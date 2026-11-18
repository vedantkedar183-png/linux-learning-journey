# 05 — Permissions Explained (rwx, Numbers, and the Weird Ones)

This is the note people re-read most. Take it slowly.

---

## Start with one line

```bash
$ ls -l report.txt
-rw-r----- 1 alice devs 2048 Nov 16 12:00 report.txt
```

Break the first column into **four groups of characters**:

```
-  rw-  r--  ---
│   │    │    │
│   │    │    └── OTHER: everyone who is not alice and not in devs → no rights
│   │    └─────── GROUP: members of devs → read only
│   └──────────── USER (owner): alice → read and write
└──────────────── TYPE: "-" regular file
```

That is the **entire** permission system. Three roles × three rights.

---

## The three roles

| Role | Symbol | Who it is |
|---|---|---|
| User / owner | `u` | the single owner of the file |
| Group | `g` | members of the file's group |
| Other | `o` | everybody else |

The kernel checks **in this order** and stops at the first match:
1. Are you the owner? → use the `u` bits.
2. Are you in the file's group? → use the `g` bits.
3. Otherwise → use the `o` bits.

Consequence: if the owner has no read permission, **the owner cannot read the file**, even if `other`
can. The first matching rule wins; permissions are not added together.

Hard link to real life: a building with a residents' key, a staff key, and a visitor key. You use the
key you are issued, not the best key available.

---

## The three rights (and they mean different things for folders!)

### On a file
| Right | Symbol | Allows |
|---|---|---|
| read | `r` | see the contents (`cat`, `less`) |
| write | `w` | change the contents (`echo >>`, editors) |
| execute | `x` | run it as a program (`./script.sh`) |

### On a folder (directory)
| Right | Symbol | Allows |
|---|---|---|
| read | `r` | **list** the names inside (`ls`) |
| write | `w` | **create/rename/delete** entries inside |
| execute | `x` | **enter** the folder (`cd`) and access known names |

This is the single biggest beginner trap. For folders:
- `r` without `x` → you can see names but cannot open anything ("Permission denied")
- `x` without `r` → you can access a file if you know its exact name, but `ls` fails
- `w` without `x` → you can create files but not list or remove them properly

**Practical rule:** folders normally need `755` (or `770` for shared) — always including `x`.
`chmod 640` on a folder is a classic self-inflicted bug.

---

## The three ways to change permissions

### 1. Numeric (octal) — add up `r=4`, `w=2`, `x=1`

| Sum | Symbolic | Meaning |
|---|---|---|
| 7 | `rwx` | all |
| 6 | `rw-` | read + write |
| 5 | `r-x` | read + execute |
| 4 | `r--` | read |
| 3 | `-wx` | write + execute (rare) |
| 2 | `-w-` | write only (rare) |
| 1 | `--x` | execute only |
| 0 | `---` | none |

Three digits, one per role:
```bash
$ chmod 754 file
# 7 = rwx (owner)
# 5 = r-x (group)
# 4 = r-- (other)
```

Common values to memorise:
| Value | Symbolic | Use |
|---|---|---|
| `755` | `rwxr-xr-x` | executables, public folders |
| `644` | `rw-r--r--` | normal files |
| `700` | `rwx------` | truly private folder |
| `600` | `rw-------` | private file, SSH keys |
| `770` | `rwxrwx---` | team folder |
| `664` | `rw-rw-r--` | group-editable file |
| `777` | `rwxrwxrwx` | **never** on anything real |

### 2. Symbolic — say what you want
```bash
$ chmod u+x script.sh           # owner: add execute
$ chmod g-w notes.txt           # group: remove write
$ chmod o=r file                 # other: exactly read
$ chmod a+r public.txt           # all: add read
$ chmod u=rwx,g=rx,o= dir        # exact = 750
```
Operators: `+` add, `-` remove, `=` set exactly.

### 3. Reference another file
```bash
$ chmod --reference=template.txt target.txt
```

---

## `umask`: why new files are `644`

New **files** start at `666` and new **folders** at `777` — the most permissive sane values. Then the
**umask** removes bits.

```
default 666          666
umask   022    →     022
                 and
result  644 (rw-r--r--)   → 666 AND NOT 022
```

It is a **subtraction** in practice (bitwise AND NOT), not the same as "666 - 022". Notice:
```
file default 666, umask 077 → 600   (right)
folder default 777, umask 077 → 700
```

```bash
$ umask           # 0002 on Ubuntu desktop, 0022 on servers
$ umask 077       # for this shell only
```
Put `umask 077` in `~/.bashrc` for private-by-default files.

---

## Special bits: SUID, SGID, sticky

You will see these in `ls -l` as letters where `x` would be.

### SUID (`s` in the **user** position) — octal `4000`
```bash
$ ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 68208 /usr/bin/passwd
   ▲
```
The program runs with the **owner's** privileges, not yours. `passwd` is SUID root so a normal user can
change their own password (which requires writing to `/etc/shadow`).

Why it is dangerous: a SUID-root program with a bug is a privilege-escalation hole. Audit them:
```bash
$ find / -perm -4000 -type f 2>/dev/null
```
Never SUID shell scripts or editors.

### SGID (`s` in the **group** position) — octal `2000`
On a **program**: runs with the group's rights (rare).
On a **folder**: new files inherit the folder's group. This is the correct tool for shared team folders:
```bash
$ sudo chgrp devs /srv/shared
$ sudo chmod 2775 /srv/shared     # rwxrwsr-x
$ ls -ld /srv/shared
drwxrwsr-x 2 root devs 4096 /srv/shared
      ▲ s = SGID
```
Now every file created inside belongs to group `devs` automatically, whatever the creator's primary
group is. Without SGID you would need `chgrp` after every save.

### Sticky bit (`t` in the **other** position) — octal `1000`
On a **folder**: anyone can create files, but only the file's owner (or root) can delete their own.
`/tmp` is the classic case:
```bash
$ ls -ld /tmp
drwxrwxrwt 1 root root 4096 /tmp
         ▲ t
```
Without the sticky bit, a world-writable folder lets any user delete anyone's files. Use it for upload
folders and shared drop boxes.

| Bit | Octal | On folders | On files |
|---|---|---|---|
| SUID | 4000 | ignored | run as owner |
| SGID | 2000 | inherit group | run as group |
| Sticky | 1000 | only owner deletes | (legacy) |

Set them:
```bash
$ chmod 4755 program      # SUID
$ chmod 2775 shared/      # SGID
$ chmod 1777 uploads/     # sticky
$ chmod u+s / g+s / +t    # symbolic equivalents
```

---

## Reading a permission in 4 seconds

```bash
$ ls -l /srv/shared/report.txt
-rw-rw---- 1 alice devs ...
```

1. Type: `-` file (`d` folder, `l` link).
2. Owner `alice`: `rw-` → read + write.
3. Group `devs`: `rw-` → read + write.
4. Other: `---` → nothing.
5. Who can read it? alice, and any member of `devs`. Nobody else — including root? **Root can**,
   root bypasses the check (except for `x` on executables, where root needs at least one `x` bit).

## "Permission denied" — debug in 3 steps

```bash
$ namei -l /srv/shared/report.txt
```
Shows permissions of **every** folder on the path. 90% of the time the file itself is fine and one
parent folder lacks `x` for you.

Then check:
1. `id` — am I really in the group I think I am? (group changes need a new login)
2. `namei -l` — does every folder in the path have `x` for me?
3. `ls -l` — do the bits match what I need (`r` for read, `w` for write)?

```bash
$ id
$ namei -l /path/to/file
$ ls -l /path/to/file
$ getfacl file 2>/dev/null    # ACLs (advanced; see below)
```

## ACLs: when three roles are not enough

Sometimes you need to give *one extra person* access without adding them to the group. ACLs do that:
```bash
$ setfacl -m u:bob:r report.txt     # let bob read this one file
$ getfacl report.txt                # show ACLs
$ setfacl -x u:bob report.txt       # remove
```
`ls -l` then shows a `+` after the permissions: `-rw-r-----+`.

---

## Prove you understood

1. What can the owner do with `-r--r--r--`?
2. Why does a folder need `x`?
3. Which number means `rwxr-x---`?
4. What does `chmod 2775` add compared to `775`?
5. Why does root bypass file permissions, and what is the one exception?
6. A user says "I can't read `/srv/team/report` even though it is `644`". What is your first command?

<details>
<summary>Model answers</summary>

1. Only read — `w` and `x` are absent for the owner. Being the owner does not grant extra rights.
2. `x` on a folder means "traverse": you can enter it and access files by name. Without it, the path
   is blocked even if the file itself is readable.
3. 750.
4. SGID: new files and folders inside inherit the folder's group instead of the creator's primary
   group.
5. Permission checks short-circuit for UID 0 by design, so admins can always repair the system. The
   exception is executing a file: root still needs at least one `x` bit set.
6. `namei -l /srv/team/report` — check every parent folder for `x`; then `id` to verify group
   membership.
</details>
