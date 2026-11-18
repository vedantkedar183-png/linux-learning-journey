# 06 — Users, Groups, and Permissions: Command Reference

**The idea:** Linux is multi-user. Every file has an owner and a group, and three permission bits for
each: read, write, execute. That is the whole model.

This page is the *command list*. The concepts are explained slowly in
`02-fundamentals-notes/04-users-groups-and-ownership.md` and `05-permissions-explained.md`, and you
practice them in `04-user-and-permission-practice/`.

---

## Who am I?

```bash
$ whoami                  # my username
$ id                      # my uid, gid, and all my groups
uid=1000(student) gid=1000(student) groups=1000(student),27(sudo),1001(devs)
$ id alice                # someone else's
$ groups                  # group names only
$ who                     # who is logged in right now
$ w                       # who + what they are doing
$ last | head             # recent logins
$ echo $SHELL             # my shell
```

---

## Managing users (`sudo` required)

### Ubuntu/Debian friendly commands
```bash
$ sudo adduser alice                # interactive: creates home, asks for password (recommended)
$ sudo adduser alice sudo           # add to the sudo group
$ sudo deluser alice                # remove user (keeps files unless --remove-home)
$ sudo deluser --remove-home alice  # remove user AND home folder
```

### Universal low-level commands
```bash
$ sudo useradd -m -s /bin/bash alice   # -m create home, -s login shell
$ sudo useradd -m -G devs,developers -s /bin/bash bob   # with groups
$ sudo passwd alice                    # set/change password
$ sudo usermod -aG sudo alice          # append to group (note the -a! see warning)
$ sudo usermod -s /bin/bash alice      # change shell
$ sudo usermod -l newname oldname      # rename user
$ sudo usermod -L alice                # lock account
$ sudo usermod -U alice                # unlock
$ sudo userdel -r alice                # delete user and home
```

⚠️ **The `usermod -aG` trap:** `sudo usermod -G sudo alice` *replaces* all of alice's groups with
just `sudo`. Always use `-aG` to **append**. This has locked many people out of their own sudo rights.

### Switching users
```bash
$ su - alice             # become alice (asks alice's password); "-" loads her environment
$ sudo -i                # become root with root's environment
$ sudo -u alice whoami   # run one command as alice
$ exit                   # go back to previous user
```

### Where user info lives
```bash
$ cat /etc/passwd        # username:x:uid:gid:comment:home:shell
$ sudo cat /etc/shadow   # password hashes (root only)
$ cat /etc/group         # groupname:x:gid:members
$ ls -l /etc/skel        # template files copied to every new home folder
```

---

## Managing groups

```bash
$ groupadd devs                  # create
$ groupdel devs                  # delete (must have no members? remove members first)
$ groupmod -n newname oldname    # rename
$ sudo usermod -aG devs alice    # add alice to devs
$ sudo gpasswd -d alice devs     # remove alice from devs
$ getent group devs              # show a group and its members
```

New group membership applies to **new logins**. To use it in your current shell:
```bash
$ newgrp devs        # start a subshell with the new group
```
or simply log out and back in.

---

## Permissions: `chmod`

The 9 permission bits, in order: **user (u), group (g), other (o)** × **read (r), write (w),
execute (x)**.

### Numeric (octal) mode — fastest
| Number | Permission | Meaning on a file | Meaning on a folder |
|---|---|---|---|
| 4 | `r` | read contents | list contents |
| 2 | `w` | change contents | create/delete files inside |
| 1 | `x` | run as a program | enter the folder (`cd`) |
| 0 | `-` | nothing | nothing |

Add them up per role:

| Octal | Symbolic | Typical use |
|---|---|---|
| `777` | `rwxrwxrwx` | everything for everyone — **avoid** |
| `755` | `rwxr-xr-x` | programs, public folders |
| `750` | `rwxr-x---` | private folder shared with a group |
| `700` | `rwx------` | private to owner only |
| `644` | `rw-r--r--` | normal document |
| `640` | `rw-r-----` | document for owner + group |
| `600` | `rw-------` | secrets (SSH keys, passwords) |
| `400` | `r--------` | read-only secret |

```bash
$ chmod 644 notes.txt
$ chmod 755 script.sh
$ chmod 600 ~/.ssh/id_rsa
$ chmod -R 750 shared/          # recursive — be careful
```

### Symbolic mode — clearer for small changes
```bash
$ chmod u+x script.sh           # add execute for the owner
$ chmod g-w notes.txt           # remove write for the group
$ chmod o=r file.txt            # set other to read only (removes w and x)
$ chmod a+r file.txt            # all: add read
$ chmod u=rwx,g=rx,o= file.txt  # exact spec: 750
$ chmod -R g+r shared/          # recursive add group read
```
Letters: `u` user, `g` group, `o` other, `a` all. Operators: `+` add, `-` remove, `=` set exactly.

---

## Ownership: `chown` and `chgrp`

```bash
$ sudo chown alice file.txt              # change owner
$ sudo chown alice:devs file.txt         # owner and group
$ sudo chown :devs file.txt              # group only
$ sudo chown -R alice:devs /srv/app      # recursive
$ sudo chgrp devs file.txt               # group only (alternative)
$ chown --reference=other.txt file.txt   # copy ownership from another file
```
As a normal user you can only change group ownership to a group **you belong to**, and only for files
you own.

---

## Default permissions: `umask`

New files/folders get default permissions minus the umask.
```bash
$ umask                 # e.g. 022
$ umask -S              # symbolic view: u=rwx,g=rx,o=rx
```
- Files start from `666` → with umask `022` you get `644`.
- Folders start from `777` → with umask `022` you get `755`.
- umask `077` → files `600`, folders `700` (private, good for home dirs).

Set it temporarily: `umask 077`. Permanently: add `umask 077` to `~/.bashrc` (user) or
`/etc/profile` (system-wide).

---

## Special permission bits (the +s and +t you see)

```bash
$ ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root ... /usr/bin/passwd      # lowercase s = SUID
$ ls -ld /tmp
drwxrwxrwt 1 root root ... /tmp                 # t = sticky bit
$ ls -l shared/
drwxr-sr-x 2 root devs ...                      # S = SGID on a folder
```

| Bit | Octal | On a file | On a folder |
|---|---|---|---|
| **SUID** | `4000` | program runs with the **owner's** rights | (no normal use) |
| **SGID** | `2000` | program runs with the **group's** rights | new files inherit the **folder's group** |
| **Sticky** | `1000` | (no normal use) | only the **owner** can delete their files |

```bash
$ chmod u+s program              # SUID
$ chmod g+s shared/              # SGID on a folder (great for team folders)
$ chmod +t /shared/uploads       # sticky
$ chmod 2775 shared/             # SGID + rwxrwxr-x
```
Find the risky ones:
```bash
$ find / -perm -4000 -type f 2>/dev/null     # all SUID programs
$ find / -perm -2000 -type f 2>/dev/null     # all SGID programs
```
SUID on `passwd` is normal. SUID on `nmap` or `vim` is a red flag.

---

## `sudo` and sudoers

```bash
$ sudo command              # run one command as root
$ sudo -l                   # what am I allowed to run?
$ sudo -v                   # refresh the password timeout
$ sudo -k                   # forget the cached password
$ sudo visudo               # SAFE way to edit /etc/sudoers (validates syntax)
```
Example sudoers line: `alice ALL=(ALL:ALL) ALL` means alice may run anything as anyone.
Never edit `/etc/sudoers` with a normal editor — one syntax error and nobody can use `sudo` again.
Always `visudo`, which refuses to save broken files.

---

## Practice lab (short version)

```bash
$ cd ~/linux-lab
$ rm -rf practice/perm && mkdir -p practice/perm && cd practice/perm
$ echo secret > private.txt
$ echo public > public.txt
$ echo "echo hello" > run.sh
```

1. Show your uid and groups.
2. Set `private.txt` to `600` and prove with `ls -l`.
3. Set `public.txt` to `644`.
4. Make `run.sh` executable and run it with `./run.sh`.
5. Create a folder `team` with permissions `770` and explain who can enter it.
6. Change the group of `team` to one of your groups (use `id` to find a valid one).
7. Create a folder `share` with the sticky bit and full access, then read the `t` in `ls -ld`.
8. Show your current `umask` and explain what a new file would get.
9. Find all SUID programs on the system and count them.
10. Create a user with `sudo adduser` (if you have sudo) or skip and describe the steps.

<details>
<summary>Answers</summary>

```bash
id                                              # 1
chmod 600 private.txt && ls -l private.txt      # 2
chmod 644 public.txt                            # 3
chmod +x run.sh && ./run.sh                     # 4
mkdir team && chmod 770 team                    # 5: owner + group only
sudo chgrp $(id -gn) team                       # 6 (or use an existing group)
mkdir share && chmod 1777 share                 # 7: drwxrwxrwt
umask                                           # 8: e.g. 022 -> new file 644
find / -perm -4000 -type f 2>/dev/null | wc -l  # 9
sudo adduser alice                              # 10
```
</details>

---

## The 30-second permission check

```bash
$ namei -l /srv/team/report.txt
```
It prints every folder in the path with permissions, so you can see exactly where access breaks.
If you get `Permission denied` and cannot figure out why, `namei -l` is the answer.
