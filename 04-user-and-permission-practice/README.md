# 04 — User and Permission Practice

Eight labs that take you from "who am I?" to running a shared team folder like a sysadmin.

| Lab | Topic | Needs `sudo`? | Time |
|---|---|---|---|
| 1 | Users: identity, creation, switching | partly | 25 min |
| 2 | Groups: shared access | yes | 25 min |
| 3 | Permissions: `rwx` and octal | no | 30 min |
| 4 | Ownership: `chown`, `chgrp` | partly | 20 min |
| 5 | Special bits: SUID, SGID, sticky | yes | 30 min |
| 6 | `umask` and default permissions | no | 20 min |
| 7 | `sudo`, security, and auditing | yes | 25 min |
| 8 | Capstone: team share + audit | yes | 45 min |

**No sudo?** You almost certainly have it if you installed Ubuntu yourself (WSL or VM). Check:
```bash
$ sudo -l
```
If it says "not allowed", do the no-sudo tasks (labs 3, 6, and the parts marked *optional*) — they
cover 80% of the learning. Or run the sudo labs in a VM.

**Answers:** `solutions.md`.

---

## Ground rules

1. **Never** change permissions on system paths (`/`, `/etc`, `/usr`, `/var`) in these labs.
2. All lab folders live in `~/linux-lab/practice/perm/`.
3. Use `sudo` for one command at a time. Do not run `sudo -i` and stay root.
4. Create test users with names like `labuser1`, `labuser2` so they are obvious and easy to remove.
5. **Clean up at the end of each lab.** Delete test users:
   ```bash
   $ sudo deluser --remove-home labuser1
   ```
   Leaving stray users and groups makes the capstone confusing.

---

## The mental model, in 3 lines

- Every **process** runs as a user (and a group).
- Every **file** has an owner, a group, and 9 permission bits.
- The kernel checks: *are you the owner? → use user bits. In the group? → group bits. Otherwise → other
  bits.* First match wins.

You will prove each of these lines in the labs.

---

## How to verify permission work (the professional habit)

Never say "I think it worked". Prove it:

```bash
# As the target user, try the action:
$ sudo -u labuser1 cat /srv/team/secret.txt
cat: /srv/team/secret.txt: Permission denied      # expected if the task is "deny"

# Or check the bits directly:
$ ls -ld /srv/team
$ namei -l /srv/team/secret.txt
$ getfacl /srv/team/secret.txt 2>/dev/null
```

A permission change is only done when you have **tested it as the right user**.
