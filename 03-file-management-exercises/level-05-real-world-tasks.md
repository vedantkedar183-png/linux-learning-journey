# Level 5 — Real-World File Management Tasks

These are the tasks you will actually be given at work or in class. No hand-holding: you get a goal and
a hint. Expect to combine 2–4 commands per task.

**Setup:**
```bash
$ cd ~/linux-lab
$ rm -rf practice/level5 && mkdir -p practice/level5 && cd practice/level5
$ mkdir incoming
$ cat > incoming/orders.csv <<'EOF'
id,date,customer,amount,status
1,2026-01-03,acme,1200,paid
2,2026-01-04,globex,300,pending
3,2026-01-05,initech,780,paid
4,2026-01-06,acme,450,refunded
5,2026-01-07,umbrella,2200,paid
EOF
$ echo "server started" > incoming/app.log
$ echo "ERROR db timeout" >> incoming/app.log
$ echo "user login" >> incoming/app.log
$ echo "ERROR disk full" >> incoming/app.log
```

---

## Task 1 — Build a project scaffold
Create this structure in one or two commands:
```
myapp/
├── bin/
├── config/
├── docs/
├── src/
└── tests/
```
Then create empty starter files: `src/main.sh`, `config/app.conf`, `docs/README.md`, `tests/test.sh`.
Finally print the tree.

**Check:** `tree myapp` shows 4 folders and 4 files.

---

## Task 2 — Organise a messy downloads folder
Create 12 files with mixed extensions (`.pdf`, `.jpg`, `.zip`, `.sh`, `.txt`) and names, then sort them
into subfolders by extension (`pdf/`, `images/`, `archives/`, `scripts/`, `text/`) using a loop or a
series of `mv` commands.

**Hint:** `mkdir -p pdf images archives scripts text` then `mv *.pdf pdf/` etc.
**Stretch:** use a `for` loop and a `case` statement — you will learn those in module 6.

---

## Task 3 — Find and report the 5 biggest files
Under `/var/log` (or your `~/linux-lab` if `/var/log` is not readable), report the 5 largest files with
their sizes, biggest first, into a file `big-files.txt`.

**Hint:** `find … -type f -exec du -h {} + | sort -h | tail -5`

---

## Task 4 — Rotate logs like a sysadmin
You have `app.log`. Create `app.log.1`, `app.log.2`, `app.log.3` with sizes increasing, then write a
sequence of commands that "rotates" them: the current log becomes `.1`, `.1` becomes `.2`, `.2` becomes
`.3`, and `.3` is deleted. Do it once manually.

**Hint:** work backwards, `mv` up the chain, then `mv app.log app.log.1` and `touch app.log`.

---

## Task 5 — Deduplicate a folder
Create `file1.txt` and `file2.txt` with **identical content**, and `file3.txt` with different content.
Prove 1 and 2 are the same using `sha256sum` or `md5sum`. Then replace `file2.txt` with a hard link to
`file1.txt` so the data exists only once. Prove the inode numbers match.

**Why it matters:** hard-linking duplicates is a real space-saving technique in backups.

---

## Task 6 — Clean up old junk safely
Create files with old modification dates using `touch -d "40 days ago" old1.tmp`. Create 5 such files
plus 2 recent `.tmp` files. Then delete only `.tmp` files older than 30 days.

**Important:** print the list first, then delete. Write both commands.

---

## Task 7 — Archive a project with a date stamp
Archive `myapp/` into `backups/myapp-2026-11-16.tar.gz` (use `$(date +%F)`). Verify by listing the
archive. Extract to `restore/` and prove it matches with `diff -r`.

---

## Task 8 — Search a CSV like a pro
From `incoming/orders.csv`:

a) How many orders are there (excluding the header)?
b) What is the total amount of all orders?
c) Show only `paid` orders (with header).
d) Which customer ordered the most money in total?
e) List unique customers.

**Hints:** `tail -n +2`, `awk -F, '{sum+=$4} END {print sum}'`, `awk -F, '$5=="paid"'`,
`awk -F, 'NR>1 {t[$3]+=$4} END {for (c in t) print t[c], c}' | sort -rn | head -1`,
`awk -F, 'NR>1 {print $3}' | sort -u`.

---

## Task 9 — Log triage
From `incoming/app.log`:

a) Show only error lines with line numbers.
b) Count errors.
c) Create `errors-only.log` containing only the error lines.
d) Create `summary.txt` containing one line: `errors: <count>`.

---

## Task 10 — Full "handover" package
Simulate handing a project to a colleague:

1. Create `handover/` with `README.md`, `src/`, `config/`.
2. Copy `myapp/` contents into it.
3. Create a manifest file `MANIFEST.txt` listing every file with size and sha256.
4. Archive the whole `handover/` folder as `handover-$(date +%F).tar.gz`.
5. Write a 3-line `INSTALL.txt` explaining how to extract and run it.
6. Verify the archive by listing it.

**Why this matters:** this is exactly how real deployments and code handoffs look.

---

## Grading yourself

| If you… | Level |
|---|---|
| completed tasks 1–3 with help | Beginner |
| completed 1–6 alone | Competent |
| completed 1–8 alone | Confident |
| completed all 10 including bonuses, and verified each result | Ready for the next module |

There is no partial credit for "it probably worked". **Verify every task** — `ls`, `diff`, `sha256sum`,
`wc -l`. Verification is the skill that separates professionals.

Answers: `solutions.md` → "Level 5".
