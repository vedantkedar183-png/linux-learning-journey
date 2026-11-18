# Solutions — User and Permission Practice

Compare results, not keystrokes. Where a task asked you to *explain*, a model explanation is given.

---

## Lab 3 — Permissions `rwx` and octal

### Part A answers

4. `rw-r--r--` = 644 · `rwxr-x---` = 750 · `rw-------` = 600 · `r--r--r--` = 444 · `rwxrwxrwx` = 777
5. `750` = `rwxr-x---` · `600` = `rw-------` · `777` = `rwxrwxrwx` · `644` = `rw-r--r--` ·
   `400` = `r--------`

### Commands

```bash
cd ~/linux-lab/practice/perm3

chmod 600 secret.txt                       # 6
chmod 644 public.txt                       # 7
chmod 700 run.sh && ./run.sh               # 8a
chmod 600 run.sh && ./run.sh               # 8b -> "Permission denied": no x bit anywhere
chmod 755 folder                           # 9
chmod 644 folder && cd folder              # 10 -> "Permission denied" (no x = cannot enter)
chmod 755 folder                           # 11
chmod 000 folder/inner/file.txt            # 12a
cat folder/inner/file.txt                  # 12b -> Permission denied
chmod 644 folder/inner/file.txt            # 12c
touch empty.txt && chmod 000 empty.txt     # 13

chmod u+x run.sh                           # 14
chmod g-w public.txt                       # 15
chmod o=r public.txt                       # 16
chmod a+r public.txt                       # 17
chmod u=rwx,g=rx,o= public.txt && ls -l public.txt   # 18 -> 750
chmod --reference=secret.txt public.txt    # 19
chmod o-rwx secret.txt                     # 20
```

### Part D — the key results

```bash
mkdir testdir && chmod 644 testdir         # 21
ls testdir            # works (r on folder = list names)
cd testdir            # Permission denied (no x = cannot enter)

chmod 744 testdir && ls testdir            # 22: ls works
cd testdir            # denied

chmod 711 testdir                          # 23
ls testdir            # Permission denied (no r -> cannot list names)
cd testdir            # works (x -> can traverse)
cat testdir/knownfile # works IF you know the exact filename

cd testdir && chmod 555 . && touch newfile # 24 -> Permission denied (no w)
chmod 755 .

touch ro.txt && chmod 444 ro.txt && rm ro.txt      # 25: rm SUCCEEDS
chmod 555 testdir && touch testdir/x.txt           # 26 -> denied
```

**Task 25 explanation:** removing a file modifies the **directory entry**, not the file's contents.
Write permission on the directory is what matters. This is why a read-only file in a writable folder can
still be deleted, and why "protecting" a file by making it read-only is not protection at all.

### Part E — verification

```bash
mkdir -p safe/shared safe/uploads
touch safe/private.key safe/notes.txt safe/script.sh safe/public.html
chmod 600 safe/private.key
chmod 640 safe/notes.txt
chmod 750 safe/script.sh
chmod 644 safe/public.html
chmod 770 safe/shared
chmod 1777 safe/uploads
ls -l safe; ls -ld safe/shared safe/uploads
```

**29 — two concrete risks of `777` on a web folder:**
- Any other user (or a compromised process) can **replace** your PHP/HTML/JS files with malicious ones,
  and the web server will happily serve them.
- `777` includes `x` on files, so uploads could become executable. Any upload becomes a potential
  webshell.

**30 — model reply:** "`777` fixes the symptom by removing all protection; it means anyone can modify or
replace anything, including scripts the server executes. Instead, set the owner to the service user
(`www-data`) and grant only the bits it needs, e.g. `750` for code and `770` for an uploads folder, with
SGID so new files keep the group." 

### Part F — debugging

```bash
mkdir -p deep/a/b/c && echo secret > deep/a/b/c/secret.txt
chmod 644 deep/a/b/c/secret.txt
chmod 700 deep/a                       # 31: blocks traversal for others
sudo -u nobody cat deep/a/b/c/secret.txt   # Permission denied
namei -l deep/a/b/c/secret.txt         # 32: "deep/a" has drwx------ -> that is the blocker
chmod 755 deep/a
sudo -u nobody cat deep/a/b/c/secret.txt   # works
```

**34 — the 3-command debug sequence:**
```bash
id                      # who am I, and which groups?
namei -l /the/full/path # which folder on the path is blocking?
ls -l /the/target       # do the bits match what I need?
```

---

## Lab 4 — Ownership

```bash
sudo mkdir -p /srv/chownlab && sudo chown $USER:$USER /srv/chownlab
cd /srv/chownlab
echo alpha > a.txt; echo beta > b.txt
ls -ln                                  # 3: numeric uid/gid — useful in scripts
stat a.txt                              # 2: Uid/Gid lines

sudo groupadd labteam                   # 5
sudo usermod -aG labteam $USER          # 6
newgrp labteam                          # 7 (or log out/in)
id                                      # confirm labteam is listed

chgrp labteam a.txt                     # 8: no sudo needed — you own it, you're in the group
chown :labteam b.txt                    # 9: same effect
chgrp sudo a.txt                        # 10 -> "Operation not permitted" (not your group)

mkdir teamdir && chgrp labteam teamdir
touch teamdir/f1 && ls -l teamdir/f1    # 11: group = your PRIMARY group
chmod g+s teamdir
touch teamdir/f2 && ls -l teamdir/f2    # 12: group = labteam (SGID inheritance)
chgrp -R labteam sub                    # 13: recursive

sudo adduser labuser1                   # 14
chown labuser1 a.txt                    # 15 -> "Operation not permitted"
sudo chown labuser1 a.txt               # 16
cat a.txt                               # 17: works — 644 allows read for others
echo x >> a.txt                         # 18: Permission denied (others have no w)
sudo chown $USER a.txt                  # 19
sudo chown labuser1:labteam b.txt       # 20
sudo chown :labteam b.txt               # 21
sudo chown --reference=a.txt b.txt      # 22
sudo chown -R labuser1:labteam /srv/chownlab   # 23
sudo chown -R $USER:$USER /srv/chownlab        # 25
sudo find / -nouser -o -nogroup 2>/dev/null | head   # 26
```

**27/28:** `labuser1` could write to `shared.txt` only if the file's group is `labteam` **and**
`labuser1` is in `labteam` (and the file is `664`). Adding them to the group is what changes the result —
and they need a fresh login for it to apply.

**30 — one sentence:** ownership chooses which of the three permission triples the kernel applies;
permissions say what that triple allows.

**Part F — the fix:**
```bash
sudo mkdir -p /srv/app/uploads
sudo touch /srv/app/uploads/file.jpg
sudo chown -R www-data:www-data /srv/app/uploads   # 32
sudo chmod 2770 /srv/app/uploads                   # 33 + 34 (SGID keeps group)
namei -l /srv/app/uploads/file.jpg                  # 35
sudo -u www-data touch /srv/app/uploads/test.txt    # verify as the real user
```

---

## Lab 5 — Special bits

```bash
ls -l /usr/bin/passwd        # 1: -rwsr-xr-x -> SUID (s in user position)
ls -ld /tmp                  # 2: drwxrwxrwt -> sticky (t in other position)
find / -perm -4000 -type f 2>/dev/null | wc -l     # 3
find / -perm -4000 -type f 2>/dev/null | head      # 4
find / -perm -2000 -type f 2>/dev/null | head      # 5
find / -perm -1000 -type d 2>/dev/null | head      # 6
```

8. **SUID on a shell script does nothing.** The kernel ignores setuid on interpreted scripts (the
   `#!` line would let any interpreter be used as an escalation path), and bash drops privileges when
   `euid != uid`. This is why SUID must be set on a **compiled binary** that is written carefully.

```bash
cp /usr/bin/id ./myid && chmod u+s ./myid
ls -l myid            # 9: -rwsr-xr-x
./myid                # 9: still your uid — you own it, so "owner" == you
sudo chown root:root ./myid
./myid                # 10: uid=1000(...) euid=0(root) — the process gained root's effective ID
chmod 0755 ./myid      # 12: removes SUID
```

**11 — why SUID-root `vim`/`bash`/`nmap` is fatal:** each of them can execute arbitrary commands or open
a shell. If the program runs as root, those commands run as root, so any user can become root in one
step.

### SGID

```bash
sudo groupadd project
sudo adduser labuser1
sudo usermod -aG project labuser1

sudo mkdir -p /srv/special/projects
sudo chgrp project /srv/special/projects
sudo chmod 2775 /srv/special/projects
ls -ld /srv/special/projects          # 14: drwxrwsr-x -> s in group position

sudo -u labuser1 bash -c 'echo hi > /srv/special/projects/from-labuser1.txt'
ls -l /srv/special/projects/          # 15: group = project, not labuser1's primary group

sudo chmod g-s /srv/special/projects
sudo -u labuser1 bash -c 'echo hi2 > /srv/special/projects/no-sgid.txt'
ls -l /srv/special/projects/          # 16: group = labuser1's primary group
sudo chmod g+s /srv/special/projects
sudo -u labuser1 mkdir /srv/special/projects/sub
ls -ld /srv/special/projects/sub      # 17: subfolder also gets SGID (inherited)
```

### Sticky

```bash
sudo mkdir -p /srv/special/dropbox && sudo chmod 1777 /srv/special/dropbox
sudo -u labuser1 bash -c 'echo dropped > /srv/special/dropbox/labuser1-file.txt'
rm /srv/special/dropbox/labuser1-file.txt      # 20 -> "Operation not permitted"
sudo -u labuser1 rm /srv/special/dropbox/labuser1-file.txt   # 21: allowed (owner)
sudo chmod 0777 /srv/special/dropbox
rm /srv/special/dropbox/labuser1-file.txt 2>/dev/null || true   # 22: now deletable by anyone
```

23. **Symlink risk in a 1777 folder:** an attacker can pre-create a symlink whose name your script will
    later write to, redirecting the write to a file you can write but they cannot (e.g. `~/.bashrc`).
    That is why scripts use `mktemp` and open files with `O_NOFOLLOW`/`noclobber`.

### Part F — audit

```bash
sudo find / -perm -4000 -type f -exec ls -lh {} + 2>/dev/null > suid-report.txt   # 28
sudo find / -type d -perm -0002 2>/dev/null | head -20                          # 29
sudo find / -type f -perm -0002 2>/dev/null | head -20                          # 30
```

**30:** a world-writable **file** means anyone can rewrite its content — code, config, or data — with no
protection at all. A world-writable directory with the sticky bit still stops others from deleting your
files; without the sticky bit it is just as bad, plus it allows symlink tricks.

---

## Lab 6 — umask

```bash
umask            # 1: typically 022 (servers) or 002 (desktop Ubuntu)
umask -S         # 2: u=rwx,g=rx,o=rx for 022
grep -rn umask /etc/profile ~/.profile ~/.bashrc 2>/dev/null   # 3
```

### Part C — the completed table

| umask | file | folder |
|---|---|---|
| `022` | `644` | `755` |
| `027` | `640` | `750` |
| `077` | `600` | `700` |
| `002` | `664` | `775` |
| `777` | `000` | `000` |

9. **Laptop with private data:** `077` — new files `600`, folders `700`. Nothing is accidentally
   readable by anyone else on the machine.
10. **Shared project server:** `002` (or `007`) with all users sharing a primary group, so teammates can
    edit each other's files. Combine with SGID folders.

```bash
cp ~/.bashrc ~/.bashrc.backup     # 11: ALWAYS back up shell config first
echo 'umask 077' >> ~/.bashrc
source ~/.bashrc
umask
# new terminal -> also 077
cp ~/.bashrc.backup ~/.bashrc && source ~/.bashrc    # 13: restore
```

15/16: `chmod 600 f` wins **now**; delete and recreate, and the umask decides again — because `chmod`
changes an existing inode, while `umask` applies at creation time.
17: **umask** sets what new files/folders start with; **chmod** changes an existing file's bits.

18. Add `umask 077` to their `~/.bashrc` so every file their shell creates starts private.
19. `umask 002` **and** every build user must have `build` as their primary group (or use SGID on the
    build folder) — one without the other gives inconsistent groups.
20. Put `umask 077` **at the top of the script** — never depend on the caller's environment, especially in
    a cron job or systemd unit where the umask is whatever the service manager set.

---

## Lab 7 — sudo and security

```bash
sudo -l                                  # 1
sudo whoami                              # 2: root — the command runs as root
sudo -v; sudo whoami                     # 3: no second prompt (cached ~15 min)
sudo -k; sudo whoami                     # 4: -k clears the cache -> password again
sudo cat /etc/sudoers | grep -v '^#' | grep -v '^$'   # 5
```

6. `%sudo ALL=(ALL:ALL) ALL` = "every member of group `sudo` may run any command, as any user, from any
   host."
7. `visudo` locks the file and **validates syntax before saving**. A typo in `/etc/sudoers` saved with a
   normal editor locks everyone out of sudo — often requiring a rescue boot.

8. `sudo cat /etc/shadow` is safer: one command, logged, then back to normal rights. `sudo -i` gives a
   persistent root shell where a typo can do anything, and you may forget you are root.

10/11: `auth.log` lines show timestamp, hostname, the invoking user, the target user, the terminal, and
the command (`COMMAND=/usr/bin/cat /etc/shadow`). That is your audit trail.

12/13/14: `777` means **any user or process** can rewrite the file. For config or code that root or a
service later runs, that is remote code execution. Worse for directories: anyone can add or replace files
inside — including files with names your service executes.

15/16: e.g. `/usr/bin/passwd` — justified (needs to write `/etc/shadow`); `/usr/bin/sudo` — justified;
`/usr/bin/mount` — justified for removable media but historically exploitable. A SUID `bash` gives an
instant root shell to anyone who runs it.

17/18: `.` in `PATH` means "run the program from the current folder if found there". You download a zip,
`cd` into it, run `ls`, and an attacker's `ls` runs as you — and if that script calls sudo, as root.
`echo $PATH` should not contain `.`; use `./script` explicitly.

20/21: chmod `644` gives the "UNPROTECTED PRIVATE KEY FILE" warning and SSH refuses to use it, because any
other user could replace or copy the key. `600` fixes it. `~/.ssh` must be `700` so nobody can add a
`authorized_keys` entry or swap a `known_hosts` file.

### Part D — hardened uploads

```bash
sudo mkdir -p /srv/appdata/uploads
sudo chown www-data:www-data /srv/appdata/uploads
sudo chmod 2770 /srv/appdata/uploads
# verify
ls -ld /srv/appdata/uploads
sudo -u www-data touch /srv/appdata/uploads/ok.txt
sudo -u nobody ls /srv/appdata/uploads        # denied
```

`2770` = owner (www-data) rwx, group rwx, other nothing, plus SGID so new files keep the group.
`777` "works" but lets every user on the box write into the app's upload directory — a direct path to
code execution if the app ever serves or includes those files.

### Part E — the cron incident

26. `/etc/cron.d/backup` runs `root /home/student/x.sh` every minute. `x.sh` lives in a user-writable
    home folder, so any compromise of `student` (or anyone who can write there) gets code execution as
    root within 60 seconds. The file being root-owned only means the **cron entry** is protected, not
    the script it calls.
28. Cron file: `root:root 644`. Script: `root:root 755`, located in `/usr/local/sbin` or `/opt`, not in a
    user's home.
29. Five steps: (1) disable the cron entry (`sudo mv` it out of `/etc/cron.d/`), (2) inspect the script
    and `auth.log` for what ran, (3) move the script to a root-owned location with correct permissions,
    (4) re-enable and verify the job runs and the user can no longer edit it, (5) document the finding
    and add an audit check (`find /etc/cron.* -writable`).

---

## Lab 8 — Capstone: reference design

| Folder | Owner:Group | Mode | Why |
|---|---|---|---|
| `public` | root:staff | `2775` | everyone reads; staff writes; SGID keeps group |
| `shared` | root:staff | `2770` | staff rwx; interns have no group access at all |
| `confidential` | root:managers | `2770` | only alice (managers) |
| `dropbox` | root:interns | `1773` | write + execute but no read (cannot list); sticky protects files |
| `archive` | root:staff | `1770` | staff rwx, sticky stops non-owners deleting |

**A subtlety the exercise expects you to notice:** `shared` is `2770` (group `staff`), so `carol` (only in
`interns`) gets **no** access — but the brief says interns should have **read-only** access. You cannot
express "staff rwx, interns r-x, others nothing" with only three triples. Two valid solutions:

1. Put interns in a second group and use **ACLs**:
   ```bash
   sudo setfacl -m g:interns:rx /srv/workspace/shared
   sudo setfacl -d -m g:interns:rx /srv/workspace/shared   # default ACL for new files
   sudo setfacl -m g:interns:rx /srv/workspace            # x on each parent folder!
   getfacl /srv/workspace/shared
   ```
2. Give `shared` mode `2754` and put both staff and interns in one group, then rely on the group bit for
   read — but then interns can write, which is wrong. **So ACLs are the correct answer here.**

This is the lesson of the capstone: **the classic three-role model has limits, and ACLs are how real
systems extend it.** Note it in your report.

**12 — why dave needs `x` on `/srv/workspace`:** to reach `/srv/workspace/public/x.txt`, the kernel must
traverse **every** folder on the path. Without `x` on `/srv/workspace`, the path is blocked regardless of
the child folder's permissions. `755` on the workspace root gives traversal without listing.

**15 — changes to suggest for 50 users:** ACLs + default ACLs for per-team access; central identity
(LDAP/AD); `umask 002` with SGID everywhere; automated permission drift checks; backups with restore
tests; `auditd` rules on `/srv/workspace`.

---

## Cleanup verification

```bash
getent group staff managers interns || echo "groups gone"
id alice 2>&1 | head -1     # should say "no such user"
ls /srv/workspace 2>&1 | head -1
```

If any test user or group remains, remove it now. Leaving them behind is exactly the kind of mess that
causes a security finding later.
