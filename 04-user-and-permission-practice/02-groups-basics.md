# Lab 2 — Groups: Shared Access Without Sharing Accounts

**Goal:** create a group, put users in it, and make a folder that only that group can use.

**You need:** `sudo`.

**The idea:** instead of granting access to three people one by one, grant it to one group. Add or
remove people from the group and the access follows automatically.

---

## Part A — Create the pieces

```bash
$ sudo groupadd devs
$ sudo adduser labuser1
$ sudo adduser labuser2
```

**Tasks**
1. Verify the group exists: `getent group devs`. What is its GID?
2. Add both users to `devs` with `usermod -aG devs labuser1` and the same for `labuser2`.
3. Verify membership: `getent group devs` and `id labuser1`.
4. **Important experiment:** while logged in as `labuser1` (use `su - labuser1`), run `id`. Does it show
   `devs`? Why or why not? Exit and log in again (`su - labuser1`) and check again. Explain.
5. Remove `labuser2` from the group with `gpasswd -d labuser2 devs` and verify.
6. Add `labuser2` back, but this time using `usermod -aG`. Then deliberately run the **wrong** command:
   `sudo usermod -G devs labuser1` (no `-a`). Run `id labuser1`. What happened to their `sudo` group?
   Restore it: `sudo usermod -aG sudo labuser1`.

**That mistake (dropping `-a`) is one of the most common real-world outages.** It strips every
supplementary group the user had.

---

## Part B — Build the shared folder

```bash
$ sudo mkdir -p /srv/team
$ sudo chgrp devs /srv/team
$ sudo chmod 770 /srv/team
$ sudo chmod g+s /srv/team          # SGID: new files inherit group devs
$ ls -ld /srv/team
drwxrws--- 2 root devs ... /srv/team
```

**Tasks**
7. Explain each character in `drwxrws---`.
8. Create a file **as labuser1** inside the folder and check its owner and group:
   ```bash
   $ sudo -u labuser1 bash -c 'echo "hello team" > /srv/team/note.txt'
   $ ls -l /srv/team/note.txt
   ```
   Whose group is it? Why?
9. Create a file as `labuser2`. Same question.
10. Create a file as a user **not** in `devs` (e.g. your own account, or create `labuser3` and do not add
    them). Can they enter `/srv/team`? Can they list it? Can they read the files?
11. Test properly, with the exact commands:
    ```bash
    $ sudo -u labuser3 ls /srv/team
    $ sudo -u labuser3 cat /srv/team/note.txt
    ```
12. Remove the SGID bit (`sudo chmod g-s /srv/team`), create another file as `labuser1`, and check the
    group. What changed? Put the bit back.

---

## Part C — Why groups beat individual permissions

13. Without SGID, what are the two ways to make sure a new file belongs to group `devs`?
    (Hint: one is changing the user's primary group; the other is running `chgrp` after every save.)
14. Add a third user to `devs`. Do you need to change any file or folder permissions? Why not?
15. Create a subfolder `/srv/team/private` that only `labuser1` can use. What permissions and ownership
    do you need? Test as both users.

---

## Part D — Group hygiene

16. Show every group on the system: `getent group | wc -l`. How many?
17. Show groups with no members (very common for system groups).
18. Which group allows running commands as root on Ubuntu? Confirm with `getent group sudo`.
19. Why is being in the `docker` group effectively equivalent to being root? (Think: a container can
    mount `/`.)
20. List all groups **you** are in, with their GIDs: `id -G` and `getent group`.

---

## Part E — Realistic scenario

Your class project has three teams. Build this:

```
/srv/class/
├── shared/     # everyone in group class can read & write
├── teachers/   # only group teachers can access
└── dropbox/    # everyone can write, but only the owner of a file can delete it
```

**Requirements**
- `/srv/class/shared` → `770`, group `class`, SGID on.
- `/srv/class/teachers` → `770`, group `teachers`, SGID on.
- `/srv/class/dropbox` → `1777` (sticky).
- `labuser1` in `class` + `teachers`; `labuser2` in `class` only.

21. Build it.
22. Prove that `labuser1` can write in `teachers` and `labuser2` cannot.
23. Prove that both can write in `dropbox`, but `labuser2` cannot delete a file created by `labuser1`.
24. Write the 6 commands you would give a new classmate so they join `class` correctly.

---

## Cleanup

```bash
$ sudo rm -rf /srv/class /srv/team
$ sudo deluser labuser1 2>/dev/null; sudo deluser labuser2 2>/dev/null; sudo deluser labuser3 2>/dev/null
$ sudo deluser --remove-home labuser1 2>/dev/null
$ sudo groupdel devs; sudo groupdel class; sudo groupdel teachers 2>/dev/null
$ true
```

(Some deletions may warn that the group is the user's primary group. Remove users first, then groups.)

---

## Grading yourself

- [ ] I can explain primary vs supplementary group
- [ ] I know that group membership needs a fresh login
- [ ] I used `-aG` and I know why `-G` alone is dangerous
- [ ] I can set up an SGID team folder from memory
- [ ] I tested permissions **as the other user**, not just with `ls`

Next: `03-permissions-rwx.md`.
