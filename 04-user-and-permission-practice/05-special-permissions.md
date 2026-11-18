# Lab 5 — Special Bits: SUID, SGID, Sticky

**Goal:** understand the three "extra" permission bits that show up as `s`, `S`, and `t`, and use them
deliberately instead of accidentally.

**You need:** `sudo` for parts of this lab.

---

## The one-line summary

| Bit | Octal | On a file | On a folder |
|---|---|---|---|
| SUID | `4000` | runs as the **file owner** | ignored |
| SGID | `2000` | runs as the **file group** | new files inherit the **folder group** |
| Sticky | `1000` | ignored (legacy) | only the **file owner** can delete |

You have already met SGID in lab 2. Now you will see all three in action.

---

## Setup

```bash
$ cd ~/linux-lab
$ rm -rf practice/perm5 && mkdir -p practice/perm5 && cd practice/perm5
$ sudo mkdir -p /srv/special
$ sudo chown $USER:$USER /srv/special
$ cd /srv/special
```

---

## Part A — See them in the wild (no sudo)

1. Look at `passwd`: `ls -l /usr/bin/passwd`. Which special bit is set? How do you know (look at the
   **user** position)?
2. Try `ls -ld /tmp`. Which bit is set? In which position?
3. Run `find / -perm -4000 -type f 2>/dev/null | wc -l`. How many SUID binaries exist?
4. Show the first 10 SUID binaries. Which ones do you recognise?
5. Run `find / -perm -2000 -type f 2>/dev/null | head`. What are these?
6. Run `find / -perm -1000 -type d 2>/dev/null | head`. Which folders have the sticky bit?

---

## Part B — SUID: a program that runs as its owner

7. Create a script and a small C program option. First the simple, safe demonstration:
    ```bash
    $ echo '#!/bin/bash' > who.sh
    $ echo 'id' >> who.sh
    $ chmod 755 who.sh
    $ ./who.sh
    ```
    Note: you see **your** uid.
8. Now try `chmod u+s who.sh` and run it again. Do you become root? **No.** Explain why (hint: Linux
    ignores SUID on scripts, and `/bin/bash` drops privileges).
9. Set SUID on a **binary** instead:
    ```bash
    $ cp /usr/bin/id ./myid
    $ chmod u+s ./myid
    $ ls -l myid        # note the "s"
    $ ./myid            # still your uid, because you own the copy
    ```
10. Now make root the owner:
    ```bash
    $ sudo chown root:root ./myid
    $ ./myid
    ```
    You now see `uid=1000` but with **euid=0** if the binary supports it... run `./myid` and compare
    with `id`. Explain what SUID actually changed.
11. **Why this matters:** a SUID-root program that lets you run arbitrary commands = instant root.
    Explain why `vim`, `nmap`, or `bash` must never be SUID root.
12. Remove the bit: `chmod u-s ./myid` or `chmod 0755 ./myid`. Verify.

---

## Part C — SGID: group inheritance

13. Create group `project` and user `labuser1` (if missing):
    ```bash
    $ sudo groupadd project
    $ sudo adduser labuser1
    $ sudo usermod -aG project labuser1
    ```
14. Make a folder with SGID:
    ```bash
    $ sudo mkdir -p /srv/special/projects
    $ sudo chgrp project /srv/special/projects
    $ sudo chmod 2775 /srv/special/projects
    $ ls -ld /srv/special/projects
    ```
    Which character changed, and in which position?
15. Create a file there as `labuser1`:
    ```bash
    $ sudo -u labuser1 bash -c 'echo hi > /srv/special/projects/from-labuser1.txt'
    $ ls -l /srv/special/projects/
    ```
    What group does the file have? Why?
16. Remove SGID, create another file, and compare.
    ```bash
    $ sudo chmod g-s /srv/special/projects
    $ sudo -u labuser1 bash -c 'echo hi2 > /srv/special/projects/no-sgid.txt'
    $ ls -l /srv/special/projects/
    ```
17. What happens to **subfolders** created inside an SGID folder? (Create one and check with `ls -ld`.)
18. Restore the SGID bit.

---

## Part D — Sticky bit: shared write, protected delete

19. Create a dropbox:
    ```bash
    $ sudo mkdir -p /srv/special/dropbox
    $ sudo chmod 1777 /srv/special/dropbox
    $ ls -ld /srv/special/dropbox
    ```
20. Create a file as `labuser1`, then try to delete it as your own user:
    ```bash
    $ sudo -u labuser1 bash -c 'echo dropped > /srv/special/dropbox/labuser1-file.txt'
    $ rm /srv/special/dropbox/labuser1-file.txt
    ```
    Read the error. Who is allowed to delete it?
21. Delete it properly: `sudo -u labuser1 rm /srv/special/dropbox/labuser1-file.txt`.
22. Remove the sticky bit (`chmod 0777`) and repeat. Can you delete another user's file now? This is
    why `/tmp` has `t`.
23. What is the risk of a `1777` folder with **symlinks** in it? (Search the web for "sticky bit symlink
    attack" if you are curious — do not try it on a real system.)

---

## Part E — Setting the bits three ways

24. Set SUID, SGID, and sticky with octal:
    - `chmod 4755 file` → what does `ls -l` show?
    - `chmod 2775 dir` → what does `ls -l` show?
    - `chmod 1777 dir` → what does `ls -l` show?
25. Set the same with symbolic syntax: `u+s`, `g+s`, `+t`.
26. Remove each one: `u-s`, `g-s`, `-t`.
27. What does an **uppercase** `S` or `T` mean (`-rwSr--r--`)? (Hint: the execute bit is missing, so it
    does nothing.)

---

## Part F — Audit like a security person

28. Produce a report of all SUID binaries on the system, with sizes, into `suid-report.txt`.
29. Produce a report of all world-writable **directories** (a common security finding):
    ```bash
    $ sudo find / -type d -perm -0002 2>/dev/null | head -20
    ```
30. Run `find / -type f -perm -0002 2>/dev/null` — world-writable **files**. Why is this more dangerous
    than world-writable directories with the sticky bit?
31. Write down three findings you would report to an administrator, and why each matters.

---

## Cleanup

```bash
$ sudo rm -rf /srv/special
$ sudo deluser --remove-home labuser1 2>/dev/null
$ sudo groupdel project 2>/dev/null
$ true
```

---

## Self-check

- [ ] I can spot SUID/SGID/sticky in `ls -l` instantly
- [ ] I know SUID on scripts is ignored by Linux
- [ ] I know SGID on a folder makes files inherit the group
- [ ] I know the sticky bit protects files in shared writable folders
- [ ] I can explain why `chmod 777` and SUID programs are security risks

Answers: `solutions.md` → "Lab 5".
