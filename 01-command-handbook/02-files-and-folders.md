# 02 — Files and Folders: Create, Copy, Move, Delete

**The idea:** everything in Linux is either a file or a folder (directory). You manage them with
a handful of commands. The tricky part is not the commands — it is being careful with paths.

**Golden rule:** run `ls` (or `pwd`) first, then construct your command from the exact path you saw.

---

## Creating

### `touch` — create an empty file (or update its timestamp)
```bash
$ touch notes.txt                 # create empty file if missing
$ touch file1 file2 file3         # create several at once
$ touch -c existing.txt           # do NOT create; only update time
```

### `mkdir` — make a folder
```bash
$ mkdir projects                  # one folder
$ mkdir -p a/b/c/d                # create all missing parents (this is the useful one)
$ mkdir -m 700 private            # create with specific permissions
$ mkdir -v newdir                 # verbose: say what it did
```

### Generating text quickly (for practice)
```bash
$ echo "hello" > a.txt            # create/overwrite file with one line
$ echo "second line" >> a.txt     # append a line
$ seq 1 100 > numbers.txt         # numbers 1..100, one per line
$ printf "a\nb\nc\n" > letters.txt
```

---

## Copying and moving

### `cp` — copy (original stays)
```bash
$ cp file.txt backup.txt          # copy within current folder
$ cp file.txt ~/linux-lab/        # copy into another folder
$ cp -r src-folder/ dest-folder/  # recursive: copy a whole folder
$ cp -i file.txt dest.txt         # ask before overwriting
$ cp -v *.txt backups/            # verbose; copy all .txt files
$ cp -p file.txt copy.txt         # preserve timestamps and permissions
$ cp -a src/ dest/                # archive mode: -r + -p + keep links (best for backups)
```

If `dest-folder` **does not exist**, `cp -r src dest` creates `dest` as a copy of `src`.
If it **does exist**, you get `dest/src`. This surprises everyone once — test it.

### `mv` — move or rename (original is gone from the old place)
```bash
$ mv oldname.txt newname.txt      # rename
$ mv file.txt ~/linux-lab/        # move into a folder
$ mv -i a.txt b.txt               # ask before overwriting
$ mv -v *.log archive/            # verbose moves
$ mv folder/ newname/             # rename a folder
```
`mv` does **not** need `-r` for folders. It moves the whole thing.

---

## Deleting

### `rm` — remove files
```bash
$ rm file.txt                     # one file
$ rm -i file.txt                  # ask first (recommended while learning)
$ rm -r folder/                   # recursive: delete folder and contents
$ rm -rf folder/                  # recursive + force, no questions
$ rm *.tmp                        # wildcard: every .tmp file
```
There is **no trash bin** in the terminal. `rm` is forever. Some systems have `trash-cli`
(`sudo apt install trash-cli`, then `trash-put file`).

### `rmdir` — remove only empty folders (safe)
```bash
$ rmdir empty-folder              # fails if it has anything inside — that's the point
```

### `du` and `df` — how much space is used
```bash
$ du -sh folder/                  # size of one folder
$ du -h --max-depth=1 .           # sizes of subfolders, one level
$ du -sh * | sort -h              # biggest things first
$ df -h                           # free space per filesystem
```

---

## Inspecting files

### `file` — what *is* this? (it reads the content, not the extension)
```bash
$ file photo.jpg
photo.jpg: JPEG image data, JFIF standard 1.01
$ file script.sh
script.sh: Bourne-Again shell script, ASCII text executable
```

### `stat` — everything about a file
```bash
$ stat notes.txt
  File: notes.txt
  Size: 120       Blocks: 8     IO Block: 4096  regular file
Access: (0644/-rw-r--r--)  Uid: (1000/student)  Gid: (1000/student)
Access: 2026-11-16 10:30:00   Modify: 2026-11-16 10:28:00  Change: ...
```

### `ln` — links (two kinds)

**Hard link** — a second name for the same data on disk:
```bash
$ ln original.txt hardlink.txt
```
Delete one, the data survives in the other. Cannot cross filesystems, cannot link folders.

**Symbolic (soft) link** — a shortcut that points to a path:
```bash
$ ln -s /var/log/syslog ~/syslog-link     # like a Windows shortcut
$ ls -l ~/syslog-link
lrwxrwxrwx ... syslog-link -> /var/log/syslog
```
If the target is deleted, a symlink becomes "broken". Use absolute paths for symlinks you keep.

---

## Full practice lab

```bash
$ cd ~/linux-lab
$ rm -rf practice/files && mkdir -p practice/files && cd practice/files
```

1. Create a folder structure `project/{docs,src,tests}` in one command.
2. Inside `project/docs`, create `readme.md` containing the single line `# My Project`.
3. Copy `readme.md` to `project/src/readme-copy.md`. Check that both still exist.
4. Rename `readme-copy.md` to `notes.md`.
5. Move `notes.md` into `project/tests/`.
6. Copy the whole `project` folder to `project-backup`. Compare with `ls -R`.
7. Create 5 empty `.tmp` files in the current folder, then delete only the `.tmp` files.
8. Create a hard link `hard.txt` to `project/docs/readme.md`. Delete `readme.md`. Does `hard.txt`
   still show the content?
9. Create a symlink `docs-link` pointing to `project/docs`. Run `ls -l` and read the arrow.
10. Delete `docs-link` only (not the folder it points to). What command is safe for that?
11. Show the size of `project-backup` and the free space on your disk.

<details>
<summary>One possible solution</summary>

```bash
mkdir -p project/{docs,src,tests}                       # 1
echo "# My Project" > project/docs/readme.md            # 2
cp project/docs/readme.md project/src/readme-copy.md    # 3
mv project/src/readme-copy.md project/src/notes.md      # 4
mv project/src/notes.md project/tests/                  # 5
cp -r project project-backup                            # 6
touch a.tmp b.tmp c.tmp d.tmp e.tmp                     # 7
rm -i *.tmp
ln project/docs/readme.md hard.txt                       # 8
rm project/docs/readme.md
cat hard.txt        # still prints "# My Project" — data has two names
ln -s "$PWD/project/docs" docs-link                      # 9
rm docs-link                                             # 10: removes the LINK only
du -sh project-backup && df -h                           # 11
```
</details>

---

## The cheat-code for "I am afraid of rm"

1. Type `ls -la <the exact thing you plan to delete>` and press Enter.
2. Read the list. Are those really the files you mean?
3. Press Up arrow, change `ls -la` to `rm -ri`, press Enter.

You just turned a destructive command into a verified one, with 3 keystrokes of extra work.
