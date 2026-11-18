# Solutions — File Management Exercises

There is more than one correct answer. Compare **results**, not exact keystrokes.
Run these in `~/linux-lab/practice/...`.

---

## Level 1 — Navigation

```bash
# Setup (same as the exercise)
mkdir -p company/{sales,engineering/{frontend,backend},hr,finance}
touch company/README.md company/sales/q1.csv company/sales/q2.csv \
      company/engineering/backend/api.py company/engineering/frontend/app.js \
      company/hr/policy.txt

# A
pwd                                   # 1
ls company                            # 2
cd company && ls -lah                 # 3
cd engineering/backend                # 4
cd ../..                              # 5 -> back to company
cd /etc && cd -                       # 6 (or: cd ~/linux-lab/practice/level1/company)

# B
cd ~/linux-lab/practice/level1/company/hr
ls ../../sales                        # 7 relative
ls /home/$USER/linux-lab/practice/level1/company/sales   # 8 absolute
cd ../../engineering/frontend         # 9
cd ../..                              # 10 -> company/engineering? No: from frontend, ../.. = company
pwd

# C
cd                                    # 11 home
cd -                                  # 12 back
cd / && ls                            # 13 -> /etc holds configuration
# 14: Ctrl+R, type "cd", Enter
# 15: Ctrl+L

# D
ls -l /etc | head -5                  # 16: type "d" for dirs, "-" for files; owner usually root
ls -lt /etc | head -5                 # 17: newest modified first
du -sh company; du -sh company/*      # 18
tree -d company                       # 19: -d shows folders only

# E: the drill
```

**Note on task 10:** from `company/engineering/frontend`, `cd ../..` lands in `company`.
`..` = `engineering`, `../..` = `company`.

---

## Level 2 — Create, copy, move, delete

```bash
# A
touch todo.txt                                   # 1
touch a.txt b.txt c.txt                          # 2
mkdir -p work/reports/2026/november              # 3
mkdir inbox archive temp                         # 4
echo "Linux is a kernel." > notes.txt            # 5
echo "A distro bundles tools." >> notes.txt      # 6
seq 1 50 > numbers.txt                           # 7
mkdir -p project/{src,docs,bin}                  # 8
mkdir -m 700 private                             # 9
touch script.sh && echo 'echo "hi"' > script.sh && chmod +x script.sh && ./script.sh   # 10

# B
cp notes.txt notes-backup.txt                    # 11
cp notes.txt inbox/                              # 12 -> inbox/notes.txt
cp -r work work-copy                             # 13
cp *.txt archive/                                # 14
cp -i numbers.txt archive/numbers-2.txt          # 15 (run twice to see the prompt)
cp -p notes.txt notes-preserved.txt              # 16 (compare `stat` times)
touch work/reports/2026/november/report.md
cp -r work/reports/2026/november work/reports/2026/december   # 17: yes, -r needed

# C
mv todo.txt tasks.txt                            # 18
mv tasks.txt work/                               # 19
mv temp scratch                                  # 20
mv *.txt inbox/                                  # 21 (this also moves notes.txt — intended here)
cp a.txt work/a.txt && mv work/a.txt .           # 22: the copy is gone, file is back as a.txt
mv work-copy archive/                            # 23 -> archive/work-copy

# D
rm b.txt                                         # 24
rmdir inbox                                      # 25: refuses, folder not empty
rm -r scratch                                    # 26
touch 1.log 2.log 3.log 4.log 5.log && rm -i *.log   # 27
touch d.txt keep.txt && rm d*.txt                # 28
# 29: explanation, no command to run
```

**Task 29 model answer:** `rm -rf ./*` expands to the contents of the *current* folder only, because
the shell expands `*` before `rm` sees it. `rm -rf /*` expands to everything directly under `/` — every
top-level system folder. The first is scoped to where you are; the second is scoped to the whole
machine. Cautious version: `rm -rf -- ./*` (the `--` stops `-` filenames being read as options).

```bash
# E
mkdir -p library/{fiction,non-fiction,unread}
touch library/fiction/dune.txt library/fiction/hobbit.txt library/non-fiction/sapiens.txt
mv library/fiction/*.txt library/unread/
cp library/non-fiction/sapiens.txt library/fiction/sapiens-backup.txt
mkdir -p library/trash && mv library/unread/hobbit.txt library/trash/
rm -r library/trash
tree library

# Bonus
touch file{01..10}.txt                           # 36
mkdir -p logs/2026-{01..06}                      # 37
cp -r library "library-$(date +%F)"              # 38: $(...) runs the command and inserts its output
```

**Level 2 common mistakes**
- `cp folder1 folder2` without `-r` → "omitted directory". Use `cp -r`.
- `mv *.txt inbox/` when `inbox` does not exist → all files renamed/squashed into one. Check `ls` after.
- `rm -r` on an empty-ish path with a typo → gone. Always `ls` first.

---

## Level 3 — Search, inspect, links

```bash
# A
find data -name "*.log"                              # 1
find data/2026 -name "*.txt"                         # 2
find data -type d -name logs                          # 3
find data -size +1M -exec ls -lh {} +                 # 4
find data -mtime -1                                   # 5
find data -empty                                      # 6
find data -name ".*"                                  # 7 (hidden files need an explicit pattern)
find data -type f -not -name "*.log"                  # 8

# B
grep -rn "ERROR" data                                 # 9
grep -rc "ERROR" data/*/logs/*.log                    # 10 (or: grep -r "ERROR" data | wc -l)
grep -rv "ERROR" data/2026/logs/                      # 11
grep -rl "Report" data                                # 12
grep -rin "error" data                                # 13
grep -rn "errors=0" data                              # 14
grep -rn --include="*.log" "status=ok" data           # 15

# C
file data/2026/reports/big.bin                        # 16 -> data
stat data/2026/logs/app-01.log                        # 17
du -sh data/* data/*/* | sort -h                      # 18
find data -type f | wc -l                             # 19
du -sh data; du -sh --apparent-size data              # 20 (apparent = sum of file sizes)

# D
ln data/2026/logs/app-01.log hard-link.log            # 21
ls -li data/2026/logs/app-01.log hard-link.log        # same inode number
ln -s "$PWD/data/2026/logs/app-01.log" soft-link.log  # 22
ls -l hard-link.log soft-link.log
echo "extra" >> hard-link.log && cat data/2026/logs/app-01.log     # 23: yes, same data
echo "extra2" >> soft-link.log && cat data/2026/logs/app-01.log    # 24: yes, via the link
rm data/2026/logs/app-01.log                          # 25
cat hard-link.log        # still works (data has another name)
cat soft-link.log        # No such file or directory (link is broken)
ln data/2026 hard-link-dir                            # 26 -> "hard link not allowed for directory"
cd latest && pwd -P                                   # 27

# E
find data -type f -exec du -h {} + | sort -h | tail -3      # 28
find data -name "*.log" -exec wc -l {} +                    # 29
find data -type f -exec grep -l "full" {} +                 # 30a list
find data -type f -exec grep -l "full" {} + | xargs rm      # 30b delete
find data/2026/reports -name "*[0-9]*"                       # 31
find data -type f -exec du -h {} + | sort -h > audit.txt    # 32

# Bonus
find . -maxdepth 2 -type f -perm 644                       # 33
find . -type f -mtime +30                                  # 34
locate report-01.txt                                       # 35: needs sudo updatedb first
grep -rn "ERROR" data | awk -F: '{print $1":"$2}'          # 36
```

**Why `find` beats `ls -R | grep`:** `ls -R` prints headers that pollute the output, follows no rules
about file type/size/time, and fails on huge trees. `find` filters with the kernel's own metadata.

**Hard vs soft, one sentence each:** a hard link is a second name for the same inode (same data, no
"original"); a soft link is a small file that stores a path, so it breaks if the target moves or is
deleted.

---

## Level 4 — Archives and compression

```bash
# A
cp project/docs/numbers.txt numbers-copy.txt                 # 1
gzip numbers-copy.txt                                        # 2 -> numbers-copy.txt.gz
ls -lh numbers-copy.txt.gz                                   # 3
gunzip numbers-copy.txt.gz                                   # 4
gzip -k project/docs/random.bin && ls -lh project/docs/random.bin*   # 5: random data is incompressible
gzip -k numbers-copy.txt                                     # 6: -k keeps the original
cp numbers-copy.txt n1.txt && gzip -1 -k n1.txt
cp numbers-copy.txt n9.txt && gzip -9 -k n9.txt
ls -l n1.txt.gz n9.txt.gz                                    # 7
bzip2 -k n1.txt; xz -k n1.txt; ls -l n1.txt.*                # 8

# B
tar -cf project.tar project                                  # 9
tar -tf project.tar                                          # 10 list contents
tar -czf project.tar.gz project                              # 11
tar -cJf project.tar.xz project                              # 12 (capital J = xz)
mkdir restore && tar -xzf project.tar.gz -C restore          # 13
diff -r project restore/project
tar -xzf project.tar.gz project/docs/README.md -C restore    # 14 single member
tar -rf project.tar project/docs/CHANGELOG.md                # 15 (uncompressed tar only)
tar -czf project-hidden.tar.gz project                       # 16: tar includes dotfiles (unlike shell globs)
tar -czf "backup-$(date +%F).tar.gz" project                 # 17

# C
zip -r project.zip project                                   # 18
unzip -l project.zip                                         # 19
mkdir unzipped && unzip project.zip -d unzipped              # 20
zip project.zip project/docs/CHANGELOG.md                    # 21
# 22: .zip — Windows opens it natively; .tar.gz needs an extra tool there.

# D
mkdir mirror && rsync -av project/ mirror/                   # 23 (note trailing slashes)
echo "new" > project/docs/new.txt && rsync -av project/ mirror/   # 24: only new.txt transfers
rm project/docs/old.py && rsync -av --delete project/ mirror/     # 25: removes it from mirror too
rsync -av --dry-run --delete project/ mirror/                # 26
rsync -av --exclude='build/' project/ mirror/                # 27
# 28: -z helps over slow networks; skip it on fast LAN/loopback.
rsync -av project/ localhost:/tmp/project-sync/               # 29

# E
tar -tzf project.tar.gz > /dev/null && echo OK               # 30
find project -type f -exec sha256sum {} \; | sort -k2 > a.sums
find restore/project -type f -exec sha256sum {} \; | sort -k2 > b.sums
diff a.sums b.sums                                           # 31: identical hashes = identical bytes
# 32 checklist:
#   1. tar -tzf archive  (can it be read?)
#   2. extract to a temp dir and diff / compare hashes
#   3. store the archive somewhere else (not the same disk)

# Bonus
dd if=/dev/zero of=disk.img bs=1M count=10
sudo mkfs.ext4 disk.img
sudo mkdir -p /mnt/testdisk && sudo mount -o loop disk.img /mnt/testdisk
df -h /mnt/testdisk
sudo umount /mnt/testdisk                                    # 33
split -b 1M project.tar.gz part- && cat part-* > rejoined.tar.gz   # 34
# 35: archiving / recursively pulls in /proc, /sys, /dev (infinite/virtual), sockets, and would take
#     forever or error out; it also captures stale system state. Back up specific paths instead.
```

---

## Level 5 — Real-world tasks

```bash
# 1
mkdir -p myapp/{bin,config,docs,src,tests}
touch myapp/src/main.sh myapp/config/app.conf myapp/docs/README.md myapp/tests/test.sh
tree myapp

# 2
mkdir -p pdf images archives scripts text
touch a.pdf b.pdf c.jpg d.jpg e.zip f.zip g.sh h.sh i.txt j.txt
mv *.pdf pdf/; mv *.jpg images/; mv *.zip archives/; mv *.sh scripts/; mv *.txt text/

# 3
sudo find /var/log -type f -exec du -h {} + 2>/dev/null | sort -h | tail -5 > big-files.txt
# (or on your own folder: find ~/linux-lab -type f -exec du -h {} + | sort -h | tail -5)

# 4
touch app.log.1 app.log.2 app.log.3
rm -f app.log.3
mv app.log.2 app.log.3
mv app.log.1 app.log.2
mv app.log app.log.1
touch app.log

# 5
echo "same content" > file1.txt
cp file1.txt file2.txt
echo "different" > file3.txt
sha256sum file1.txt file2.txt        # identical hashes
rm file2.txt && ln file1.txt file2.txt
ls -li file1.txt file2.txt           # identical inode

# 6
touch -d "40 days ago" old{1..5}.tmp
touch recent1.tmp recent2.tmp
find . -name "*.tmp" -mtime +30      # review first
find . -name "*.tmp" -mtime +30 -delete

# 7
mkdir -p backups
tar -czf "backups/myapp-$(date +%F).tar.gz" myapp
tar -tzf backups/myapp-*.tar.gz
mkdir -p restore && tar -xzf backups/myapp-*.tar.gz -C restore
diff -r myapp restore/myapp

# 8 (in incoming/)
tail -n +2 orders.csv | wc -l                                          # a) 5
awk -F, 'NR>1 {sum+=$4} END {print sum}' orders.csv                    # b) 4950
head -1 orders.csv; awk -F, '$5=="paid"' orders.csv                     # c)
awk -F, 'NR>1 {t[$3]+=$4} END {for (c in t) print t[c], c}' orders.csv | sort -rn | head -1   # d) acme 1650
awk -F, 'NR>1 {print $3}' orders.csv | sort -u                          # e) acme, globex, initech, umbrella

# 9
grep -n ERROR app.log                                    # a
grep -c ERROR app.log                                    # b
grep ERROR app.log > errors-only.log                     # c
echo "errors: $(grep -c ERROR app.log)" > summary.txt    # d

# 10
mkdir -p handover/{src,config}
cp -r myapp/. handover/
find handover -type f -exec sha256sum {} + > handover/MANIFEST.txt
tar -czf "handover-$(date +%F).tar.gz" handover
printf 'Extract: tar -xzf handover-*.tar.gz\nRun: bash handover/src/main.sh\nSee: handover/MANIFEST.txt\n' > INSTALL.txt
tar -tzf handover-*.tar.gz > /dev/null && echo "archive OK"
```

**What "good" looks like at this level:** you never delete without listing first, you verify every
archive, and you can explain *why* each command works — not just that it did.
