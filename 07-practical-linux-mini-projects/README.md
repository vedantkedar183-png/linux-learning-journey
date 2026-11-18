# 07 — Practical Linux Mini Projects

Eight projects. Each one turns a chapter into something you can **show**: a script, a report, a working
service. Together they form a portfolio you can demo in class or mention in an interview.

| # | Project | Skills | Difficulty | Time |
|---|---|---|---|---|
| 01 | System report generator | text processing, `awk`, `df` | ⭐ | 45 min |
| 02 | Backup tool | `tar`, verification, `trap`, retention | ⭐⭐ | 1.5 h |
| 03 | Log analyzer | `grep`, `sed`, `awk`, sorting | ⭐⭐ | 1.5 h |
| 04 | User onboarding script | users, groups, `chpasswd`, idempotence | ⭐⭐⭐ | 1.5 h |
| 05 | Disk & memory monitor | loops, thresholds, cron, exit codes | ⭐⭐⭐ | 1 h |
| 06 | Network health checker | `ip`, `ping`, `nc`, `curl`, retries | ⭐⭐⭐ | 1.5 h |
| 07 | Web server deployment | `apt`, `systemctl`, nginx, firewall | ⭐⭐⭐⭐ | 2 h |
| 08 | Final capstone: ops toolkit | everything | ⭐⭐⭐⭐⭐ | 3 h |

**Do them in order.** Each project reuses code from the previous ones. By 08 you will have a small
toolkit, not eight unrelated scripts.

---

## The rules for every project

1. **One folder per project**: `~/linux-lab/projects/01-system-report/`.
2. Inside, always: the script, a `README.md`, and a `test.sh` (or test notes).
3. **Every script starts with** the shebang, `set -euo pipefail`, and a comment block (name, usage,
   description).
4. **Verify, do not assume.** Every project has a "Proof it works" section. Do it.
5. **Commit your progress.** If you have `git`, run `git init` in `~/linux-lab` and commit after each
   project. Your history is part of the portfolio.
6. **Break it deliberately once.** Then fix it. That is where understanding comes from.

---

## Suggested folder layout

```
~/linux-lab/projects/
├── 01-system-report/
│   ├── sysreport.sh
│   └── README.md
├── 02-backup-tool/
│   ├── backup.sh
│   ├── test.sh
│   └── README.md
...
└── 08-ops-toolkit/
    ├── bin/
    ├── lib/
    └── README.md
```

---

## How to write the README for each project

Use this template — it is also how professional projects document themselves:

```markdown
# Project 02 — Backup Tool

## What it does
Creates a verified, dated tar.gz of a directory and keeps the last 3.

## Requirements
- Ubuntu 22.04+ / WSL2
- tar, gzip

## Usage
./backup.sh <source-dir> [dest-dir]

## Example
$ ./backup.sh ~/linux-lab
[10:30:01] creating /home/student/backups/linux-lab-2026-11-16.tar.gz
[10:30:02] verifying archive
[10:30:02] ok: 1.2M

## How it works
1. Validates arguments and dependencies.
2. Archives with paths relative to the source's parent.
3. Verifies with `tar -tzf`.
4. Rotates old archives.

## Edge cases handled
- missing source, missing tar, unwritable destination, partial archive on failure

## What I learned
...

## Known limitations
- no incremental backups, no remote destination
```

Writing that `README` is 20% of the project's value. It forces you to understand what you built.

---

## Self-assessment scale

For each project, score 1–5:

| Score | Meaning |
|---|---|
| 1 | I copied the solution and it ran |
| 2 | I wrote it with the notes open |
| 3 | I wrote it alone, checked the notes when stuck |
| 4 | I wrote it alone AND handled the edge cases |
| 5 | I could explain every line and extend it on request |

Aim for 4+ before moving on. A project you cannot explain is not a skill yet.

Start here: `project-01-system-report.md`.
