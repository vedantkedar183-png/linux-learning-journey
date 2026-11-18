# Lab 8 — Capstone: Build a Secure Team Workspace

**Goal:** combine everything from labs 1–7 into one realistic build. This is the kind of task you get in
a first sysadmin job or a class practical exam.

**You need:** `sudo`. Time: 45–60 minutes.

**Deliverables:** a working `/srv/workspace` tree, a test log proving each rule, and a short report
(`report.md`) you write yourself.

---

## The brief

A small team of 4 people needs a shared workspace on a Linux server:

| Group | Members | Needs |
|---|---|---|
| `staff` | `alice`, `bob` | read & write in the shared area |
| `managers` | `alice` | exclusive access to the confidential folder |
| `interns` | `carol` | read-only in shared, write-only dropbox |
| — | `dave` | no access at all except the public folder |

Folder requirements:

```
/srv/workspace/
├── public/        # everyone can read; only staff can write        (755 or 775 + group)
├── shared/        # staff read & write; interns read only          (770, group staff, SGID)
├── confidential/  # managers only                                  (770, group managers, SGID)
├── dropbox/       # interns can write, cannot read others' files   (1733 or 1777)
└── archive/       # staff read & write, not deletable by non-owners(1770 + sticky)
```

---

## Step 1 — Plan before typing (do not skip)

Write down, **before** running commands:

1. Which **groups** you need and who belongs to each.
2. The **owner** and **group** for each folder.
3. The **octal mode** for each folder, and why.
4. Which special bits you need, and where.
5. What `umask` each user should have, and why it matters here.
6. How you will **prove** each rule (which user, which command, expected result).

A plan like this turns a confusing task into a checklist. Real admins write it first.

---

## Step 2 — Create users and groups

Suggested commands (adapt, do not blindly paste):

```bash
for u in alice bob carol dave; do sudo adduser --disabled-password --gecos "" $u; done
sudo groupadd staff
sudo groupadd managers
sudo groupadd interns
sudo usermod -aG staff alice
sudo usermod -aG staff bob
sudo usermod -aG managers alice
sudo usermod -aG interns carol
```

Tasks:
1. Create the users and groups.
2. Verify with `id alice`, `id bob`, `id carol`, `id dave`, and `getent group`.
3. Set a password for each user (or use `--disabled-password` and test with `sudo -u`).
4. Why did we use `--disabled-password`? (Hint: these are test accounts; you do not need to log in.)

---

## Step 3 — Build the tree with correct ownership and modes

```bash
sudo mkdir -p /srv/workspace/{public,shared,confidential,dropbox,archive}
sudo chown root:staff     /srv/workspace/public
sudo chown root:staff     /srv/workspace/shared
sudo chown root:managers  /srv/workspace/confidential
sudo chown root:interns   /srv/workspace/dropbox
sudo chown root:staff     /srv/workspace/archive

sudo chmod 2775 /srv/workspace/public
sudo chmod 2770 /srv/workspace/shared
sudo chmod 2770 /srv/workspace/confidential
sudo chmod 1773 /srv/workspace/dropbox
sudo chmod 1770 /srv/workspace/archive
```

5. Explain why the **group** owner of each folder is what it is.
6. Explain every digit of `2775`, `2770`, `1773`, `1770`.
7. Why is `dropbox` `1773` and not `1777`? What does the `3` restrict?
8. Verify the result with `ls -ld /srv/workspace/*`.

> **Why `/srv`?** It is the conventional place for data served or shared by this machine. Never put
> shared team data in `/tmp` (wiped) or in `/etc` (config).

---

## Step 4 — Create test files as different users

```bash
sudo -u alice bash -c 'echo "alice shared"   > /srv/workspace/shared/alice.txt'
sudo -u bob   bash -c 'echo "bob shared"     > /srv/workspace/shared/bob.txt'
sudo -u alice bash -c 'echo "top secret"     > /srv/workspace/confidential/plan.txt'
sudo -u carol bash -c 'echo "intern upload"  > /srv/workspace/dropbox/carol.txt'
```

9. Check the **group** on each file. Did SGID work everywhere it should?
10. Confirm `alice.txt` and `bob.txt` are owned by their creators and belong to group `staff`.

---

## Step 5 — Prove every rule (the important part)

Run each test as the correct user. Record **expected vs actual**. Write the results into `report.md`.

| # | Test | Command | Expected |
|---|---|---|---|
| 1 | alice writes in shared | `sudo -u alice touch /srv/workspace/shared/a2.txt` | success |
| 2 | bob reads alice's file | `sudo -u bob cat /srv/workspace/shared/alice.txt` | success |
| 3 | carol reads shared | `sudo -u carol cat /srv/workspace/shared/alice.txt` | success |
| 4 | carol writes in shared | `sudo -u carol touch /srv/workspace/shared/c.txt` | denied |
| 5 | bob reads confidential | `sudo -u bob cat /srv/workspace/confidential/plan.txt` | denied |
| 6 | alice reads confidential | `sudo -u alice cat /srv/workspace/confidential/plan.txt` | success |
| 7 | carol writes dropbox | `sudo -u carol touch /srv/workspace/dropbox/c2.txt` | success |
| 8 | carol lists dropbox | `sudo -u carol ls /srv/workspace/dropbox` | denied (mode 1773) |
| 9 | dave reads public | `sudo -u dave cat /srv/workspace/public/*` | success |
| 10 | dave writes public | `sudo -u dave touch /srv/workspace/public/d.txt` | denied |
| 11 | bob deletes alice's file in archive | set up a file, then `sudo -u bob rm ...` | denied (sticky) |
| 12 | dave enters workspace | `sudo -u dave ls /srv/workspace` | success (needs `x` on the parent) |

11. Run all 12 tests. For each, note the exact error or success.
12. For any test that failed unexpectedly, debug with `namei -l <path>` and `id <user>`, fix the
    permission, and record what was wrong. **Debugging is the actual skill.**

---

## Step 6 — Audit your own work

```bash
# any world-writable folders inside the workspace?
sudo find /srv/workspace -type d -perm -0002 -exec ls -ld {} \;

# anything owned by a numeric UID (deleted user)?
sudo find /srv/workspace -nouser -o -nogroup

# who can access each folder?
for d in /srv/workspace/*; do echo "== $d"; ls -ld "$d"; done

# trace one path end-to-end
namei -l /srv/workspace/confidential/plan.txt
```

13. Run each audit command. Are there any surprises?
14. Explain why `/srv/workspace` itself must have `x` for `dave` even though he has no group access.

---

## Step 7 — The report

Create `/srv/workspace/report.md` (or `~/linux-lab/report.md`) containing:

1. **Design table** — folder, group, mode, and one-line justification.
2. **Test results table** — the 12 tests, expected vs actual.
3. **Two problems you hit and how you fixed them.**
4. **Three things you would change** if this were a real server with 50 users (hints: ACLs, default
   ACLs, a `setgid` + `umask 002` combination, central user management, backups, auditd).

15. Write the report. This is the deliverable you show in class.

---

## Grading rubric (score yourself honestly)

| Criteria | Points |
|---|---|
| Users and groups created correctly, no stray accounts | 10 |
| All 5 folders exist with correct owner, group, mode | 20 |
| SGID working on shared and confidential | 10 |
| Sticky bit working in archive/dropbox | 10 |
| All 12 access tests behave as expected | 25 |
| Debugging notes show real reasoning (not just "it worked") | 10 |
| Report is clear, with justifications not just commands | 10 |
| Cleanup instructions included and correct | 5 |

**45+ = ready to move on.** Under 45: re-run the failing parts before starting module 5.

---

## Cleanup (after grading)

```bash
sudo rm -rf /srv/workspace
for u in alice bob carol dave; do sudo deluser --remove-home $u 2>/dev/null; done
sudo groupdel staff 2>/dev/null
sudo groupdel managers 2>/dev/null
sudo groupdel interns 2>/dev/null
getent group staff || echo "cleaned up"
```

**Write down your cleanup steps in the report.** A sysadmin who leaves test users and groups behind is a
future incident.
