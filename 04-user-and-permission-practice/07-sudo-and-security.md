# Lab 7 — `sudo`, Security, and Auditing

**Goal:** use `sudo` correctly, understand why it is safer than root, read the audit trail, and recognise
the classic permission-related security holes.

**You need:** `sudo`.

---

## Why `sudo` exists

Before `sudo`, admins logged in as root all day. One typo, one malicious script, one forgotten terminal =
disaster, and no record of who did what.

`sudo` fixes three things:
1. **Least privilege** — admin power for one command, not for the session.
2. **Accountability** — every use is logged with *your* name, even though the command runs as root.
3. **No shared root password** — users authenticate with their own password.

---

## Part A — Explore your own sudo rights

1. Run `sudo -l`. What are you allowed to run?
2. Run `sudo whoami`. What does it print? Why not your name?
3. Run `sudo -v`, then immediately `sudo whoami` again. Did it ask for a password the second time? How
   long does the cache last?
4. Run `sudo -k` then `sudo whoami`. What happened? What does `-k` do?
5. Where is the sudo policy file? Look at it **without editing**:
   ```bash
   $ sudo cat /etc/sudoers | grep -v '^#' | grep -v '^$'
   ```
6. Explain the line `%sudo ALL=(ALL:ALL) ALL` in plain English.
7. Why must you use `sudo visudo` instead of `nano /etc/sudoers`? (Hint: one syntax error = no sudo
   ever again.)

---

## Part B — Least privilege in practice

8. Compare these two:
   ```bash
   $ sudo cat /etc/shadow | head -3
   $ sudo -i        # then: cat /etc/shadow | head -3 ; exit
   ```
   Both show the file. Which is safer, and why?
9. Run a **single** command as another user: `sudo -u www-data whoami`. When is this useful?
10. Find out which commands were run with sudo recently:
    ```bash
    $ sudo grep sudo /var/log/auth.log | tail -20
    # or:
    $ journalctl -t sudo --since today | tail -20
    ```
11. What information does each log line contain? List the fields you can identify.

---

## Part C — The classic security holes

### 1. World-writable everything (`777`)
12. Create `danger.txt` with `777`. Why is it a security problem, not just a permissions problem?
13. Find world-writable files on the system:
    ```bash
    $ sudo find / -type f -perm -0002 2>/dev/null | head -20
    ```
14. Why are world-writable **directories** usually a bigger risk than world-writable files?

### 2. SUID root programs
15. List SUID binaries and pick three. For each, say what it does and whether SUID is justified.
16. Why is a SUID-root `bash` equivalent to handing out the root password?

### 3. `.` in `PATH`
17. Explain why having `.` in `PATH` is dangerous. (You `cd` into a downloaded folder, run `ls`, and a
    malicious `ls` in that folder runs as you.)
18. Check your own: `echo $PATH`. Is `.` there? It should not be.

### 4. Predictable temp files
19. Why should scripts use `mktemp` instead of `/tmp/myfile`? (Hint: another user could pre-create a
    symlink at that path.)

### 5. SSH key permissions
20. Create a fake key and set it to `644`:
    ```bash
    $ mkdir -p ~/.ssh && touch ~/.ssh/testkey && chmod 644 ~/.ssh/testkey
    $ ssh -i ~/.ssh/testkey localhost    # read the warning
    ```
21. Set it to `600` and try again. What warning disappeared? Why does SSH enforce this?
22. What permissions should `~/.ssh` itself have (`700`) and why?

---

## Part D — Harden a folder (practical)

Your app writes uploads to `/srv/appdata/uploads`. Requirements:
- only the app user `www-data` can write
- the web server group can read
- nobody else can even list it
- new files inherit the right group

23. Write the exact commands to achieve all four.
24. Verify with `ls -ld`, `namei -l`, and by testing as another user.
25. Why is `chmod -R 777` the wrong answer here, even though it "works"?

---

## Part E — A short incident response drill

Scenario: you find `/etc/cron.d/backup` is owned by `student` and contains `* * * * * root /home/student/x.sh`.

26. Why is this **critical**? (Anyone who can edit `/home/student/x.sh` runs code as root every minute.)
27. Which commands show you the current state?
    ```bash
    $ ls -l /etc/cron.d/
    $ cat /etc/cron.d/backup
    $ ls -l /home/student/x.sh
    ```
28. What are the correct permissions for a root-run cron file and its script? (Hint: `root:root`,
    not writable by others.)
29. Write the 5 steps you would take: stop the bleeding, investigate, fix, verify, document.

---

## Self-check

- [ ] I use `sudo <command>`, not `sudo -i`, by default
- [ ] I know `sudo -l` shows my rights and that the password is cached briefly
- [ ] I check `/var/log/auth.log` (or `journalctl -t sudo`) for an audit trail
- [ ] I can name four classic permission mistakes
- [ ] I never set `777` to "make it work"

Answers: `solutions.md` → "Lab 7".

Next: the capstone, `08-capstone.md`.
