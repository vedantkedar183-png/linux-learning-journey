# 03 — File Management Exercises

Five levels, from "find your feet" to "do a real sysadmin job". Do them in order — each level assumes
the previous one.

| Level | Title | Skills | Time |
|---|---|---|---|
| 1 | Navigation | `pwd`, `ls`, `cd`, paths | 20 min |
| 2 | Create, copy, move, delete | `touch`, `mkdir`, `cp`, `mv`, `rm` | 30 min |
| 3 | Search and links | `find`, `grep`, `ln`, `stat` | 30 min |
| 4 | Archives and compression | `tar`, `zip`, `gzip`, `rsync` | 30 min |
| 5 | Real-world tasks | everything, plus judgement | 45 min |

**Answers:** `solutions.md` in this folder. Try each task for at least 2 minutes before looking.

---

## Rules for every level

```bash
$ cd ~/linux-lab
$ rm -rf practice/levelX && mkdir -p practice/levelX && cd practice/levelX
pwd
```

1. Work only inside `~/linux-lab/practice/`.
2. Type commands manually the first time. No copy-paste.
3. Before any `rm`, run the same path with `ls`.
4. If a command fails, **read the error** before trying something else. The error usually names the
   exact problem.
5. When you finish a level, tick it in `00-START-HERE/03-progress-tracker.md`.

---

## How to check your own work

You do not need a teacher for most of this. Self-check with:

```bash
$ ls -la            # do the files/folders exist with the right permissions?
$ find . -type f    # is the structure what I intended?
$ cat file          # is the content right?
$ echo $?           # did the last command succeed? 0 = yes
```

If `ls` shows what the task asked for, you are done. That is exactly how a professional verifies work.

---

## If you get stuck

1. Re-read the task. Which of the 5 W's is unclear: what, where, with what name, with what content,
   with what permissions?
2. Run `pwd` — are you in the folder you think you are?
3. Run `ls` — does the thing you are trying to copy/move actually exist here?
4. Run `man <command>` or `<command> --help`.
5. Look at the handbook page for that command in `01-command-handbook/`.
6. Only then open `solutions.md`.

Struggling for 2 minutes is learning. Struggling for 20 is wasting time. Find the line.
