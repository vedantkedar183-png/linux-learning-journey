# Linux Learning Project — From Absolute Beginner to Confident User

Welcome! This project is a **complete, self-paced Linux course** built from notes, a command
handbook, hands-on labs, and real mini projects.

You do **not** need any Linux experience. Every lesson explains things in plain language first,
then shows commands, then asks you to practice.

---

## 1. What is inside

| Folder | What it is | How you use it |
|---|---|---|
| `00-START-HERE/` | Setup guide, 8-week study plan, progress tracker, lab safety rules | Read this **first** |
| `01-command-handbook/` | Quick-reference handbook of Linux commands, grouped by job | Look things up while practicing |
| `02-fundamentals-notes/` | The "why" — concepts explained slowly with analogies | Read before/while doing labs |
| `03-file-management-exercises/` | 5 levels of file & folder labs | Practice after notes 3 |
| `04-user-and-permission-practice/` | Users, groups, `rwx`, `chown`, special bits, `sudo` | Practice after notes 4 + 5 |
| `05-network-basics/` | IP addresses, DNS, ports, `ssh`, troubleshooting | Practice after notes 6 |
| `06-bash-scripting-exercises/` | Bash scripting from first script to real utilities | Practice after everything above |
| `07-practical-linux-mini-projects/` | 8 portfolio-style projects with rubrics | Do after the modules |

Suggested reading order is simply the folder numbers: `00 → 01 → 02 → 03 → 04 → 05 → 06 → 07`.

---

## 2. How to use this project (the 5-step loop)

For every lesson, follow the same loop. It is the fastest way to actually learn Linux:

1. **Read** the concept in `02-fundamentals-notes/` (5–10 minutes).
2. **Look up** the exact commands in `01-command-handbook/`.
3. **Practice** in the matching exercises folder. *Type every command yourself* — never copy-paste
   at first. Muscle memory is the whole point.
4. **Check** your work against the `solutions.md` file (only after trying).
5. **Tick it off** in `00-START-HERE/03-progress-tracker.md`.

> Rule of thumb: for every 10 minutes of reading, spend 30 minutes typing commands.

---

## 3. The 8-week study plan (about 1 hour a day)

| Week | Focus | Files to work through |
|---|---|---|
| 1 | Get Linux running + basic navigation | `00-START-HERE/*`, notes 01–03, handbook 01 |
| 2 | Files, folders, viewing & editing | notes 03, handbook 02–03, exercises levels 1–2 |
| 3 | Users, groups, permissions | notes 04–05, handbook 06, permissions labs 1–4 |
| 4 | Processes, packages, services + review | notes 06–07, handbook 05 & 08, permissions labs 5–8 |
| 5 | Networking basics | notes 08 + `05-network-basics/` |
| 6 | Bash: variables, input, conditionals, loops | bash chapters 01–04 |
| 7 | Bash: functions, text processing, error handling | bash chapters 05–08 |
| 8 | Mini projects + capstone | `07-practical-linux-mini-projects/` |

Short on time? Do the plan at half speed (16 weeks). Slow and steady beats rushing.

---

## 4. Before you type anything: safety rules

Linux gives you the power to delete your whole system with one command. That is why:

1. **Never practice on your main computer.** Use WSL, a virtual machine, or a free cloud server
   (see `00-START-HERE/02-setup-linux-environment.md`).
2. **Never run unknown commands as `root`.** In labs you will use `sudo`, which is a *controlled*
   "become admin for one command" tool.
3. **Be scared of space characters.** `rm -rf / home/user` (with a space) is a disaster.
   `rm -rf /home/user` is not. Read twice, press Enter once.
4. **Never run `rm -rf /`**, `mkfs`, `dd` on a real disk, or `chmod -R 777 /`. Ever.
5. **Work inside your sandbox folder** (`~/linux-lab`) for all exercises.
6. If something breaks in a VM: **revert the snapshot**. That is what snapshots are for.

Read `00-START-HERE/04-lab-rules-and-safety.md` before your first lab.

---

## 5. Conventions used in this project

```bash
$ whoami          # lines starting with $ are commands YOU type (do not type the $)
student           # lines without $ are example OUTPUT from Linux
```

- `something-in-angle-brackets` → replace it with your own value, e.g. `<username>` → `alex`.
- `#` at the start of a line inside a code block is a **comment** explaining the command.
- `~` means your home folder, e.g. `/home/student`.
- `sudo` means "run this one command with administrator power".
- Every lab file starts with a **Lab setup** section. Run those commands first.

---

## 6. What you will be able to do at the end

- Move around the Linux filesystem confidently and manage files without fear.
- Explain and fix file permissions, add users and groups, and use `sudo` correctly.
- Read processes, stop runaway programs, install software, and manage services.
- Understand IP addresses, DNS, ports, and connect to a server over SSH.
- Write Bash scripts that take input, make decisions, loop, and handle errors.
- Show 8 finished mini projects as proof of skill (great for a class or portfolio).

---

## 7. Your very next step

Open `00-START-HERE/02-setup-linux-environment.md`, get a Linux terminal running, then open
`00-START-HERE/01-study-plan.md` and start Week 1.

Happy learning — and remember: the terminal is only scary until the day it becomes faster than a mouse.
