# The 8-Week Study Plan (Day-by-Day)

**Time needed:** about 1 hour a day, 5 days a week. 40 hours total gets you from beginner to
comfortable. You can stretch it to 16 weeks at 30 minutes a day — that still works.

**When you study:** pick a fixed time slot. Linux is learned by repetition, not by long marathons.

---

## Week 1 — Get Linux running and learn to move around

| Day | Do this | Done |
|---|---|---|
| 1 | Read `00-START-HERE/02-setup-linux-environment.md`, install WSL2 or VirtualBox, open a terminal | ☐ |
| 2 | Read `02-fundamentals-notes/01-what-is-linux.md` and `02-kernel-shell-and-desktop.md` | ☐ |
| 3 | Read `02-fundamentals-notes/03-filesystem-hierarchy.md` | ☐ |
| 4 | Handbook `01-navigation.md` — practice every command, then do its practice tasks | ☐ |
| 5 | Review: draw the Linux folder tree from memory. Say out loud what `/etc`, `/home`, `/var` hold | ☐ |

**Week 1 checkpoint:** you can `cd` anywhere, explain `~`, `/`, `.`, `..`, and run `ls -lah`.

---

## Week 2 — Files, folders, and looking inside files

| Day | Do this | Done |
|---|---|---|
| 1 | Handbook `02-files-and-folders.md` (create, copy, move, delete, links) | ☐ |
| 2 | `03-file-management-exercises/level-01-navigation.md` | ☐ |
| 3 | `03-file-management-exercises/level-02-create-copy-move.md` | ☐ |
| 4 | Handbook `03-viewing-and-editing.md` + start `level-03-search-and-links.md` | ☐ |
| 5 | Finish level 3, try `level-04-archive-and-compress.md`, check `solutions.md` | ☐ |

**Week 2 checkpoint:** you can build a folder tree, copy/move files, read a file, and find a file
by name without a GUI.

---

## Week 3 — Users, groups, and permissions

| Day | Do this | Done |
|---|---|---|
| 1 | `02-fundamentals-notes/04-users-groups-and-ownership.md` | ☐ |
| 2 | `02-fundamentals-notes/05-permissions-explained.md` (the `rwx` + number system) | ☐ |
| 3 | `04-user-and-permission-practice/01-users-basics.md` and `02-groups-basics.md` | ☐ |
| 4 | `04-user-and-permission-practice/03-permissions-rwx.md` | ☐ |
| 5 | `04-user-and-permission-practice/04-ownership-chown.md` + `05-special-permissions.md` | ☐ |

**Week 3 checkpoint:** given `-rw-r----- 1 alice devs`, you can explain every character, and you can
`chmod 750` a file and prove who can read it.

---

## Week 4 — Processes, packages, services + review

| Day | Do this | Done |
|---|---|---|
| 1 | `02-fundamentals-notes/06-processes-and-jobs.md` + handbook `05-processes-and-system.md` | ☐ |
| 2 | `02-fundamentals-notes/07-package-management.md` + handbook `08-packages-and-services.md` | ☐ |
| 3 | `04-user-and-permission-practice/06-umask-and-defaults.md` and `07-sudo-and-security.md` | ☐ |
| 4 | Permissions capstone `08-capstone.md` | ☐ |
| 5 | **Review week:** redo 3 exercises from weeks 1–3 without looking anything up | ☐ |

**Week 4 checkpoint:** you can find a process with `ps aux | grep`, kill it, install a package, and
read its logs with `journalctl`.

---

## Week 5 — Networking basics

| Day | Do this | Done |
|---|---|---|
| 1 | `05-network-basics/01-network-fundamentals.md` | ☐ |
| 2 | `05-network-basics/02-ip-addressing.md` | ☐ |
| 3 | `05-network-basics/03-network-commands.md` + `exercises.md` tasks 1–5 | ☐ |
| 4 | `05-network-basics/04-dns.md` + tasks 6–9 | ☐ |
| 5 | `05-network-basics/05-ssh-and-remote-access.md` + `07-troubleshooting-playbook.md` | ☐ |

**Week 5 checkpoint:** you can explain what an IP, a subnet mask, a gateway, a DNS server, and a
port are — and diagnose "why can't I reach this website?" in order.

---

## Week 6 — Bash scripting, part 1

| Day | Do this | Done |
|---|---|---|
| 1 | `06-bash-scripting-exercises/01-first-script.md` (shebang, `chmod +x`, running) | ☐ |
| 2 | `02-variables-and-input.md` (variables, `read`, quoting) | ☐ |
| 3 | `03-conditionals.md` (`if`, `test`, `[[ ]]`, `case`) | ☐ |
| 4 | `04-loops.md` (`for`, `while`, `break`, `continue`) | ☐ |
| 5 | Do exercises 01–05 in `06-bash-scripting-exercises/exercises/` | ☐ |

**Week 6 checkpoint:** you can write a script that asks for input, checks it, and loops over files.

---

## Week 7 — Bash scripting, part 2

| Day | Do this | Done |
|---|---|---|
| 1 | `05-functions-and-arrays.md` | ☐ |
| 2 | `06-text-processing.md` (grep, cut, sort, awk, sed in scripts) | ☐ |
| 3 | `07-error-handling.md` (exit codes, `set -euo pipefail`, traps) | ☐ |
| 4 | `08-common-scripts.md` — read and run each example | ☐ |
| 5 | Do exercises 06–08, then compare with `solutions/` | ☐ |

**Week 7 checkpoint:** you can write an idempotent script that fails loudly instead of silently.

---

## Week 8 — Build the mini projects

| Day | Do this | Done |
|---|---|---|
| 1 | `07-practical-linux-mini-projects/project-01-system-report.md` | ☐ |
| 2 | `project-02-backup-tool.md` | ☐ |
| 3 | `project-03-log-analyzer.md` | ☐ |
| 4 | `project-05-disk-monitor.md` + `project-06-network-checker.md` | ☐ |
| 5 | `project-08-final-capstone.md` — and write your own README for it | ☐ |

**Week 8 checkpoint:** 4+ finished scripts in `~/linux-lab/projects/` that you can demo.

---

## How to study when you feel stuck

1. **Read the error message out loud.** Linux error messages are literal. "No such file or directory"
   means the path is wrong — nothing deeper.
2. **Use `man <command>`** and press `q` to quit. Then try `command --help` (shorter).
3. **Shrink the problem.** Did one command work? Run only that one again.
4. **Break it on purpose** in your sandbox. Understanding the failure is learning.
5. **Explain it to someone** (or to a rubber duck) in one sentence. If you can't, re-read that section.

## Spaced repetition tip

Every Friday, spend 15 minutes doing commands you learned in *previous* weeks, not this week.
That is what makes knowledge stick.
