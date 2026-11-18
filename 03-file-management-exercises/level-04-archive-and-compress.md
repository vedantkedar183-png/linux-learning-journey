# Level 4 — Archives, Compression, and Sync

**Goal:** pack files into one archive, compress them, unpack them somewhere else, and keep two folders in
sync. This is what backups are made of.

**Setup:**
```bash
$ cd ~/linux-lab
$ rm -rf practice/level4 && mkdir -p practice/level4 && cd practice/level4
$ mkdir -p project/{src,docs,build}
$ echo 'print("hello")' > project/src/main.py
$ echo 'print("bye")'   > project/src/old.py
$ echo "Project docs"   > project/docs/README.md
$ seq 1 1000            > project/docs/numbers.txt
$ head -c 2M /dev/urandom > project/docs/random.bin
$ du -sh project
```

---

## Part A — Quick compression with gzip

1. Copy `project/docs/numbers.txt` to `numbers-copy.txt`.
2. Compress the copy with `gzip`. What is the new filename? What happened to the original?
3. Look at the size difference with `ls -lh`.
4. Decompress it again with `gunzip`. Confirm the size returns.
5. Compress `random.bin` with `gzip`. Why does it barely shrink?
6. What does `gzip -k` do differently?
7. Compress `numbers-copy.txt` with `gzip -9` (maximum) and with `gzip -1` (fastest). Compare sizes.
8. Try `bzip2 -k` and `xz -k` on the same file. Which is smallest? Which was slowest?

**Key idea:** compression works by finding patterns. Text compresses well; already-compressed or random
data does not.

---

## Part B — tar archives (the standard)

Think of `tar` as "put many files into one box", and compression as "squeeze the box".

**Memory hook:** `tar -c**z**f archive.tar.gz folder/` →
**c**reate, g**z**ip, **f**ile.

9. Create `project.tar` from the folder `project` (no compression). Check its size.
10. List the **contents** of `project.tar` without extracting (`-t`).
11. Create `project.tar.gz` (gzip). Compare the size with the uncompressed one.
12. Create `project.tar.xz`. Compare all three sizes.
13. Extract `project.tar.gz` into a new folder `restore/` (create it first, then extract inside).
    Verify with `diff -r project restore/project`.
14. Extract only `project/docs/README.md` from the archive. (Hint: pass the exact member path after
    the archive name.)
15. Add a new file `project/docs/CHANGELOG.md` to the **existing** `.tar.gz` (use `-r` for plain tar;
    explain why it cannot be done to a compressed archive without re-creating it).
16. Create an archive that includes hidden files. Why do people forget them?
17. Create a **backup with a date** in the filename using `$(date +%F)`.

---

## Part C — zip (cross-platform, Windows-friendly)

18. Create `project.zip` from the `project` folder (`zip -r`).
19. List its contents (`unzip -l`).
20. Extract into `unzipped/`.
21. Add one file to an existing zip without re-creating it.
22. Which is better for sharing with a Windows user: `.tar.gz` or `.zip`? Why?

---

## Part D — `rsync` (the professional sync tool)

23. Create `mirror/` and sync `project/` into it with `rsync -av`.
24. Add a file to `project/docs/`, then run the same rsync. What got transferred?
25. Delete a file from `project/docs/`, then sync with `--delete`. What happens in `mirror/`?
26. Run `rsync -av --dry-run` after making a change. What is the value of a dry run?
27. Exclude `build/` from the sync (`--exclude`). Confirm with `--dry-run`.
28. Compare `rsync -a` with `rsync -avz`. When would you add `-z`? When would you not?
29. Sync over SSH to `localhost` (works if SSH is running):
    `rsync -av project/ localhost:/tmp/project-sync/`. What is different from local sync?

---

## Part E — Verify your backup (the part people skip)

30. After creating `project.tar.gz`, verify it is intact by listing it (`tar -tzf`).
31. Extract into a temp folder and compare content hashes:
```bash
find project -type f -exec sha256sum {} \; | sort -k2 > a.sums
find restore/project -type f -exec sha256sum {} \; | sort -k2 > b.sums
diff a.sums b.sums
```
    Why is comparing hashes stronger than comparing `ls` output?
32. Write the three-line "backup checklist" you will use from now on.

---

## Bonus

33. Create a 10 MB **loopback file**, format it as ext4, mount it, copy files in, and unmount.
    (Requires `sudo`. This is the safe way to practise `mkfs`.)
```bash
dd if=/dev/zero of=disk.img bs=1M count=10
sudo mkfs.ext4 disk.img
sudo mkdir -p /mnt/testdisk && sudo mount -o loop disk.img /mnt/testdisk
df -h /mnt/testdisk
# copy something in, then:
sudo umount /mnt/testdisk
```
34. Split a large file into 1 MB chunks with `split -b 1M`, then rejoin with `cat`.
35. Explain why `tar -czf backup.tar.gz /` would be a bad idea even if you have the space.

---

## Self-check

- [ ] You can create, list, and extract a `.tar.gz` without looking at the man page
- [ ] You know that `gzip` **replaces** the original file unless you use `-k`
- [ ] You always `--dry-run` before `rsync --delete`
- [ ] You verify backups instead of assuming they worked

Answers: `solutions.md` → "Level 4".
