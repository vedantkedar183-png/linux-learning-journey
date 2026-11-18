# Level 1 — Navigation

**Goal:** move anywhere in the filesystem without guessing, and know where you are at all times.

**Setup:**
```bash
$ cd ~/linux-lab
$ rm -rf practice/level1 && mkdir -p practice/level1 && cd practice/level1
$ mkdir -p company/{sales,engineering/{frontend,backend},hr,finance}
$ touch company/README.md
$ touch company/sales/q1.csv company/sales/q2.csv
$ touch company/engineering/backend/api.py company/engineering/frontend/app.js
$ touch company/hr/policy.txt
$ tree company
```
Expected shape:
```
company
├── README.md
├── engineering
│   ├── backend
│   │   └── api.py
│   └── frontend
│       └── app.js
├── finance
├── hr
│   └── policy.txt
└── sales
    ├── q1.csv
    └── q2.csv
```

---

## Tasks

### Part A — Know where you are
1. Print your current directory. Confirm it is `.../practice/level1`.
2. List the contents of `company` **without** changing directory.
3. Move into `company`, then list everything including hidden files, in long format with
   human-readable sizes.
4. From `company`, go into `engineering/backend` using a **relative** path in one command.
5. From `backend`, go back to `company` in one command.
6. From `company`, go to `/etc` using an absolute path. Then come back to `company` in one command
   without typing the full path.

### Part B — Absolute vs relative
7. While inside `company/hr`, list the contents of `company/sales` using a **relative** path.
8. While inside `company/hr`, list `company/sales` using an **absolute** path. Which one is longer?
9. From `company/sales`, go to `company/engineering/frontend` in one relative command.
10. From `company/engineering/frontend`, go up **two** levels in one command. Where are you?

### Part C — Managing your position
11. Go to your home folder in the shortest possible command. Prove it with `pwd`.
12. Go back to your previous folder (the one before home) with one command.
13. Go to `/` and list the top-level folders. Identify which one holds configuration files.
14. Use `Ctrl+R`, search for a previous `cd` command, and run it.
15. Clear your screen using the keyboard only (no `clear` command).

### Part D — Reading the view
16. Run `ls -l /etc | head -5`. What is the file type of the first entry? Who is the owner?
17. Run `ls -lt /etc | head -5`. What is different about the order?
18. Run `du -sh company` then `du -sh company/*`. Which subfolder is biggest?
19. Run `tree -d company`. Why is `README.md` missing from the output?

### Part E — Speed drill (do 3 times, time yourself)
From `~/linux-lab/practice/level1`:
```bash
cd company/engineering/backend
pwd
cd ../frontend
pwd
cd ../../..
ls
cd ~
ls -a | head -5
cd -
```
Record your times: ______ , ______ , ______

---

## Self-check

- [ ] Every `pwd` output matched what you expected before you typed it
- [ ] You used `cd -` at least once successfully
- [ ] You can explain `.` vs `..` vs `~` vs `/`
- [ ] You can build an absolute path for any file in `company` without looking

**Done?** Move to `level-02-create-copy-move.md`. Check answers in `solutions.md` only if a task failed.
