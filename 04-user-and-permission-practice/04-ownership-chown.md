# Lab 4 — Ownership: `chown` and `chgrp`

**Goal:** change who owns a file and which group it belongs to, and know exactly what your powers are as
a normal user.

**You need:** `sudo` for most tasks (changing ownership requires root).

---

## The rules to prove in this lab

1. Every file has exactly one **owner** and one **group**.
2. Only **root** can change the **owner**.
3. A normal user can change the **group** only to a group they belong to, and only on files they own.
4. `chown -R` on the wrong path has broken more servers than any other single command.

---

## Setup

```bash
$ sudo mkdir -p /srv/chownlab
$ sudo chown $USER:$USER /srv/chownlab
$ cd /srv/chownlab
$ echo "alpha" > a.txt
$ echo "beta"  > b.txt
$ mkdir sub && echo "gamma" > sub/c.txt
$ ls -l
```

---

## Part A — Read ownership

1. Run `ls -l`. Who is the owner and group of each file?
2. Run `stat a.txt`. Find the `Uid:` and `Gid:` lines. Which number comes first?
3. Run `ls -ln`. What is different? Why is that useful in scripts?
4. What is the difference between the output of `ls -l` and `ls -ld /srv/chownlab`?

---

## Part B — Change the group

5. Create a test group: `sudo groupadd labteam`.
6. Add yourself: `sudo usermod -aG labteam $USER`.
7. **Log out and back in**, or run `newgrp labteam`. Verify with `id`.
8. Change the group of `a.txt` to `labteam`: `chgrp labteam a.txt`. Does it need `sudo`? Why not?
9. Change the group of `b.txt` with `chown :labteam b.txt`. Same result?
10. Try to change `a.txt` to a group you are **not** in, e.g. `chgrp sudo a.txt`. Read the error.
    What does it prove about rule 3?
11. Create a folder `teamdir`, and change its group to `labteam`. Then create a file inside as yourself.
    What group does the new file get? (Hint: your **primary** group, not `labteam`.)
12. Apply the SGID bit (`chmod g+s teamdir`), create another file inside, and check the group again.
    Now which group?
13. `chgrp -R labteam sub` — what did the `-R` do?

---

## Part C — Change the owner

14. Create a user `labuser1` (`sudo adduser labuser1`) if it does not exist.
15. Try `chown labuser1 a.txt` **without** sudo. Read the error. Which rule does this prove?
16. Now with sudo: `sudo chown labuser1 a.txt`. Verify with `ls -l`.
17. Try to read `a.txt` now. Can you? Why? (Permissions are still `644` → yes, you can read. Ownership
    is not the same as permission.)
18. Try to write to `a.txt`. Read the error. Now who can write?
19. Give it back: `sudo chown $USER a.txt`.
20. Change owner **and** group in one command: `sudo chown labuser1:labteam b.txt`.
21. Change **only** the group through `chown`: `sudo chown :labteam b.txt`.
22. Copy ownership from one file to another: `sudo chown --reference=a.txt b.txt`.

---

## Part D — Recursive ownership (the dangerous one)

23. `sudo chown -R labuser1:labteam /srv/chownlab` — check every entry with
    `ls -lR /srv/chownlab`.
24. Now imagine you had typed `/srv` or `/` instead of `/srv/chownlab`. Why is `-R` on `chown` such a
    high-risk command? Write a one-line safety habit (hint: `pwd`, `ls`, then `chown`).
25. Repair the lab: `sudo chown -R $USER:$USER /srv/chownlab`.
26. Which command can tell you **which files on the system are owned by a deleted UID** (shown as a
    number instead of a name)?
    ```bash
    $ sudo find / -nouser -o -nogroup 2>/dev/null | head
    ```

---

## Part E — Ownership vs permissions (the key insight)

27. Create `shared.txt` owned by you with `664`. Can `labuser1` write to it? Test:
    ```bash
    $ sudo -u labuser1 bash -c 'echo "from labuser1" >> /srv/chownlab/shared.txt'
    ```
    Why does it work or fail? (Check the group membership of `labuser1`.)
28. Add `labuser1` to `labteam` and test again. What changed?
29. Create `locked.txt` with `600` owned by you, and try to read it as `labuser1`. Read the error.
30. Explain in one sentence: **ownership decides *which* permission bits apply; permissions decide
    *what* is allowed.**

---

## Part F — Realistic fix

A colleague exported files from a backup and everything is now owned by `root:root`, and the app
(called `www-data`) cannot write to its upload folder.

31. Reproduce it:
    ```bash
    $ sudo mkdir -p /srv/app/uploads
    $ sudo touch /srv/app/uploads/file.jpg
    $ ls -l /srv/app/uploads
    ```
32. Fix ownership so `www-data` owns the folder and files.
33. Fix permissions so `www-data` can write but others cannot: what octal do you need?
34. Add SGID so new uploads stay in the right group.
35. Verify with `namei -l` and `ls -ld`.

---

## Cleanup

```bash
$ sudo rm -rf /srv/chownlab /srv/app
$ sudo deluser --remove-home labuser1 2>/dev/null
$ sudo groupdel labteam 2>/dev/null
$ true
```

---

## Self-check

- [ ] I know only root changes the owner
- [ ] I know a user can `chgrp` only to groups they belong to
- [ ] I always `ls` a path before running `chown -R` on it
- [ ] I can explain ownership vs permissions in one sentence
- [ ] New group membership needed a re-login (or `newgrp`)

Answers: `solutions.md` → "Lab 4".
