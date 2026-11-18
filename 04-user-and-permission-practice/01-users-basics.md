# Lab 1 — Users: Identity, Creation, Switching

**Goal:** understand what a user account actually is, create one, switch to it, and see how the kernel
identifies you.

**You need:** `sudo` for parts C and D.

---

## Part A — Your identity (no sudo)

```bash
$ whoami
student

$ id
uid=1000(student) gid=1000(student) groups=1000(student),27(sudo)

$ groups
student sudo

$ echo $USER $HOME $SHELL
student /home/student /bin/bash
```

**Tasks**
1. List your UID and every group you belong to.
2. Find your username's line in `/etc/passwd`. Identify all 7 fields.
3. Find your line in `/etc/group` for your primary group.
4. Try `cat /etc/shadow`. Read the error. Why can't you read it? Confirm the file's permissions with
   `ls -l /etc/shadow`.
5. How many user accounts exist on this system in total? (`wc -l /etc/passwd`)
6. How many of them have a real login shell (not `nologin`/`false`)?
7. List users currently logged in (`who`), then with more detail (`w`).
8. Show the last 5 logins (`last -n 5`).

**Checkpoint:** you can explain the difference between `uid`, `gid`, and `groups`.

---

## Part B — Anatomy of `/etc/passwd`

```
student:x:1000:1000:Student User:/home/student:/bin/bash
```

9. Write down, in your own words, what each of the 7 colon-separated fields means.
10. Find all accounts with UID below 1000. What kind of accounts are they?
11. Find your own UID and GID numbers. Are they the same? Why might that be?
12. Look at `/etc/skel`. What files are there, and what are they for?

---

## Part C — Create a user

```bash
$ sudo adduser labuser1
```
Answer the prompts. Use a simple password like `Training123!` **on your lab VM only**.

**Tasks**
13. What folder was created for `labuser1`? Check with `ls -ld /home/labuser1` and note the
    permissions.
14. Look at `/etc/passwd` and `/etc/group` — what changed?
15. Check the new user's password entry: `sudo grep labuser1 /etc/shadow`. Is the password readable?
    What does the `$y$` prefix mean (hint: it is a hashing scheme name)?
16. What groups does `labuser1` belong to by default? (`id labuser1`)
17. Compare `/home/labuser1` contents with `/etc/skel`.
18. Change the user's shell to `/bin/sh` with `usermod`, verify with `grep`, then change it back to
    `/bin/bash`.

---

## Part D — Switch users

19. From your account, become `labuser1`: `su - labuser1`. Which password did it ask for?
20. As `labuser1`, run `whoami`, `id`, and `pwd`. Where is home?
21. As `labuser1`, try to read a file in your own home folder:
    `cat /home/student/linux-lab/README.md`? (Use a real file you created.) What error appears, and why?
22. Exit back to your account. Then run one command as `labuser1` without switching:
    `sudo -u labuser1 whoami`.
23. What is the difference between `sudo -i` and `sudo -u labuser1 -i`? Try both, run `whoami`, then
    `exit` each time.

---

## Part E — Lock, unlock, delete

24. Lock the account: `sudo usermod -L labuser1`. Try to `su - labuser1` — what happens?
25. Unlock it: `sudo usermod -U labuser1`.
26. Set an expiry date on the account: `sudo chage -E 2026-12-31 labuser1`. View with
    `sudo chage -l labuser1`.
27. Delete the user **and** the home folder: `sudo deluser --remove-home labuser1`.
28. Verify: user gone from `/etc/passwd`, `/home/labuser1` gone.

---

## Part F — Think about it

29. Why does Ubuntu give each user a *private group* with the same name?
30. What would happen if a deleted user's UID (1001) were reused by a new user, and the old user's files
    still existed?
31. Why are service accounts given `/usr/sbin/nologin`?

<details>
<summary>Quick self-check answers</summary>

1. `id` prints `uid=… gid=… groups=…`.
2. `passwd` fields: name, password placeholder, UID, GID, comment, home, shell.
3. `grep student /etc/group` shows `student:x:1000:`.
4. `/etc/shadow` is `640 root:shadow` → not readable by you.
5–8. Commands: `wc -l /etc/passwd`, `grep -vc nologin /etc/passwd` (approx), `who`, `w`, `last -n 5`.
10. System/service accounts (daemons).
13. `/home/labuser1`, usually `drwxr-x---` (750), owned `labuser1:labuser1`.
15. The hash is readable only by root; `$y$` = yescrypt.
19. `su - labuser1` asks for **labuser1's** password (root/sudo not required if you know it).
21. `Permission denied` — `/home/student` is 750, so other users cannot traverse it.
24. Locked accounts cannot authenticate: `su: Authentication failure`.
29. It keeps each user's default file group private, so files are not group-readable by strangers.
30. The new user would **own** the leftover files, because ownership is by UID, not name. This is a real
    security bug; that is why `--remove-home` and UID hygiene matter.
31. So nobody can obtain an interactive shell as that service if it is compromised.
</details>

---

## Cleanup

```bash
$ sudo deluser --remove-home labuser1 2>/dev/null
$ id labuser1
id: 'labuser1': no such user
```

Next: `02-groups-basics.md`.
