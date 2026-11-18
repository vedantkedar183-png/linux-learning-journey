# Level 2 — Create, Copy, Move, Delete

**Goal:** build and rearrange a folder tree, rename things safely, and delete only what you mean to
delete.

**Setup:**
```bash
$ cd ~/linux-lab
$ rm -rf practice/level2 && mkdir -p practice/level2 && cd practice/level2
```

---

## Part A — Create

1. Create an empty file called `todo.txt`.
2. Create three empty files at once: `a.txt`, `b.txt`, `c.txt`.
3. Create the nested structure `work/reports/2026/november` in **one** command.
4. Create three sibling folders: `inbox`, `archive`, `temp`.
5. Create `notes.txt` containing the single line `Linux is a kernel.` using `echo`.
6. Append the line `A distro bundles tools.` to `notes.txt`. Show the file.
7. Create `numbers.txt` containing the numbers 1 to 50, one per line, in one command.
8. Create `project` and inside it `src`, `docs`, `bin`, using a single `mkdir` command.
9. Create a folder `private` with permissions `700` at creation time (one command).
10. Create an empty file `script.sh`, then add the line `echo "hi"` to it and make it executable.
    Run it.

**Hints:** `touch`, `mkdir -p`, `mkdir -m`, `echo >` vs `echo >>`, `seq`, `chmod +x`, `./script.sh`.

---

## Part B — Copy

11. Copy `notes.txt` to `notes-backup.txt`. Prove both exist.
12. Copy `notes.txt` into `inbox/`. What is the new path?
13. Copy the whole `work` folder to `work-copy`. Use `ls -R` to confirm.
14. Copy all `.txt` files into `archive/` in one command (use a wildcard).
15. Copy `numbers.txt` to `archive/numbers-2.txt` and **ask before overwriting** if it already exists.
    (Try running it twice to see the prompt.)
16. Copy `notes.txt` preserving its timestamp — check with `stat` before and after.
17. Create a file inside `work/reports/2026/november/report.md`, then copy the folder `november` to
    `2026/december` (which does not exist yet). Does it work, or do you need `cp -r`?

---

## Part C — Move and rename

18. Rename `todo.txt` to `tasks.txt`.
19. Move `tasks.txt` into `work/`.
20. Rename the folder `temp` to `scratch`.
21. Move **all** `.txt` files from the current folder into `inbox/` in one command.
22. Copy `a.txt` to `work/a.txt`, then move `work/a.txt` back to the current folder. What happened to
    the copy?
23. Move `work-copy` into `archive/`. What is the resulting path?

---

## Part D — Delete (carefully!)

24. Delete `b.txt`. Then confirm it is gone with `ls`.
25. Try `rmdir inbox`. Read the error. Why did it refuse?
26. Delete the folder `scratch`, including its contents.
27. Create five `.log` files, then delete only the `.log` files in one command, using `-i` so Linux
    asks each time.
28. Create `d.txt` and `keep.txt`. Delete only `d.txt` using a wildcard that cannot possibly match
    `keep.txt`. (Hint: `d*.txt` — why is that safe here?)
29. **Danger drill (read first):** type the following but do **not** press Enter until you have read
    it three times, and confirm you are in `practice/level2`:
    ```bash
    ls -la
    ```
    Now type `rm -rf` and **stop**. In your own words, explain why `rm -rf ./*` is safer than
    `rm -rf /*`. Do not run either. Write the explanation in a comment at the bottom of `notes.txt`.

---

## Part E — Realistic tidy-up

30. Build this tree:
```
library/
├── fiction/
│   ├── dune.txt
│   └── hobbit.txt
├── non-fiction/
│   └── sapiens.txt
└── unread/
```
31. Move both fiction files into `unread/`.
32. Copy `sapiens.txt` into `fiction/` and rename it `sapiens-backup.txt`.
33. Create an empty folder `library/trash` and move `hobbit.txt` into it.
34. Delete `library/trash` with its contents.
35. Print a tree of the final result and confirm it matches what you intended.

---

## Bonus challenges

36. Create 10 numbered files (`file01.txt` … `file10.txt`) in one loop-free command. (Hint: `touch`
    with brace expansion: `{01..10}`.)
37. Create `logs/2026-01` through `logs/2026-06` with one command.
38. Make a copy of the whole `library` folder named `library-$(date +%F)` and explain what the
    substitution did.

---

## Self-check

- [ ] You never ran `rm -rf` without first running `ls` on the same path
- [ ] You know when `cp` needs `-r` and when it does not
- [ ] You can explain the difference between `mv` and `cp`
- [ ] You can create a 3-level folder tree in one command

Answers: `solutions.md` → "Level 2".
