# Level 3 — Search, Inspect, and Links

**Goal:** find any file fast, inspect what it really is, and understand hard links vs symlinks.

**Setup:**
```bash
$ cd ~/linux-lab
$ rm -rf practice/level3 && mkdir -p practice/level3 && cd practice/level3
$ mkdir -p data/{2025,2026}/{logs,reports}
$ for y in 2025 2026; do
    for m in 01 02 03; do
      echo "date=$y-$m-01 status=ok errors=0" > data/$y/logs/app-$m.log
      echo "Report for $y month $m" > data/$y/reports/report-$m.txt
    done
  done
$ echo "ERROR database timeout" >> data/2026/logs/app-02.log
$ echo "ERROR disk full"        >> data/2026/logs/app-03.log
$ touch data/2026/.hidden-config
$ dd if=/dev/zero of=data/2026/reports/big.bin bs=1M count=5 status=none
$ find data -type f | sort
```
You now have 18 small files, 1 hidden file, and one 5 MB file.

---

## Part A — Find by name, type, size, time

1. List every `.log` file under `data`, with full paths.
2. List every `.txt` file under `data/2026` only.
3. Find all **folders** named `logs`.
4. Find the file larger than 1 MB. What is its size with `-ls` or `du -h`?
5. Find all files modified in the last 1 day.
6. Find all **empty** files and folders under `data`.
7. Find the hidden file (plain `find data -name "*"` will not show it — why?).
8. Find all files **not** ending in `.log`.

**Hints:** `find path -name`, `-type f`, `-type d`, `-size +1M`, `-mtime -1`, `-empty`, `-not -name`.

---

## Part B — Search inside files

9. Show all lines containing `ERROR` under `data`, with filenames and line numbers.
10. Count how many lines match `ERROR` in total.
11. Show lines that do **not** contain `ERROR`.
12. Show all files that contain the word `Report` (filenames only).
13. Search case-insensitively for `error`.
14. Show lines containing `errors=0`.
15. Search only `.log` files for `status=ok` (combine `find` with `grep`, or use `grep -r
    --include`).

---

## Part C — Inspect

16. What type of file is `data/2026/reports/big.bin`? Use `file`.
17. Show the inode number, permissions, owner, and size of `data/2026/logs/app-01.log` with `stat`.
18. Show the sizes of every subfolder of `data` with one command, sorted smallest to largest.
19. How many inodes (files) are under `data` in total?
20. What is the difference between `du -sh data` and `du -sh --apparent-size data`? Run both.

---

## Part D — Links

21. Create a hard link `hard-link.log` to `data/2026/logs/app-01.log`. Compare inode numbers with
    `ls -li`.
22. Create a symbolic link `soft-link.log` to the same file. Compare `ls -l` output for both links.
23. Append a line to `hard-link.log`. Does `app-01.log` change? Why?
24. Append a line to `soft-link.log`. Does `app-01.log` change? Why?
25. Delete `data/2026/logs/app-01.log`. What happens to `hard-link.log`? To `soft-link.log`?
    Try `cat` on each.
26. Try to create a hard link to a **folder**. Read the error and explain it.
27. Create a symlink `latest` pointing to `data/2026`. Then `cd latest`. Where are you? (`pwd -P`
    shows the real path.)

---

## Part E — Practical search tasks

28. Find the 3 largest files under `data` and show them sorted by size.
29. Find all `.log` files and print the number of lines in each, in one command.
30. Find every file under `data` containing the word `full`, then delete those files (list first!).
31. Find all files whose name contains a digit and are in `reports`.
32. Make a report `audit.txt` listing every file under `data` with its size, sorted by size, using
    `find` + `sort`.

---

## Bonus

33. Find all files owned by you with permission `644` exactly.
34. Find files modified more than 30 days ago (`-mtime +30`). You may have none — say so.
35. Use `locate report-01.txt`. If it finds nothing, explain why (`updatedb` database).
36. Write a one-line command that shows any file under `data` with the word `ERROR`, formatted as
    `filename:line`.

---

## Self-check

- [ ] You can distinguish `-name` from `-iname`
- [ ] You know why `find` is preferred over `ls -R | grep`
- [ ] You can explain hard vs soft links in one sentence each
- [ ] You always list matches before deleting matches

Answers: `solutions.md` → "Level 3".
