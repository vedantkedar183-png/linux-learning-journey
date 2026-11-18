# 01 — Navigation: Where Am I and How Do I Move?

**The idea:** Linux has one big tree of folders. There are no drive letters like `C:`.
The very top of the tree is `/` (called "root", but it means "the top folder", not the root user).
Every file lives somewhere under `/`.

Think of it like a building: `/` is the lobby, `/home` is the apartment wing, and your home folder
`/home/student` is your own apartment.

---

## The commands

### `pwd` — print working directory
"Where am I right now?"
```bash
$ pwd
/home/student/linux-lab
```

### `ls` — list what is here
```bash
$ ls                 # names only
$ ls -l              # long format: permissions, owner, size, date
$ ls -a              # include hidden files (names starting with .)
$ ls -lah            # long + hidden + human-readable sizes
$ ls -lt             # sort by modification time, newest first
$ ls -lS             # sort by size, biggest first
$ ls /etc            # list a different folder without moving there
$ ls -R              # recursive: show subfolders too (can be huge)
```

Reading `ls -l` output:
```
-rw-r--r-- 1 student student 1234 Nov 16 10:30 notes.txt
│└┬┘└┬┘└┬┘   │   │       │    │            └── name
│ │  │  │    │   │       │    └────────────── last modified
│ │  │  └────┘   │       │                    size in bytes
│ │  │  other    │       └──────────────────── group owner
│ │  │  read     └──────────────────────────── user owner
│ │  └── write                 (permissions explained in handbook 06)
│ └───── read
└─────── file type: - file, d directory, l symlink
```

### `cd` — change directory
```bash
$ cd /etc            # go to an absolute path (starts with /)
$ cd projects        # go to a relative path (a folder inside the current one)
$ cd ..              # go up one level (parent folder)
$ cd ../..           # up two levels
$ cd ~               # go home (also just: cd)
$ cd -               # go back to the previous folder you were in
$ cd "my folder"     # quotes needed when the name has a space
```

**Absolute vs relative path** — the most important beginner concept:
| Path | Type | Meaning from `/home/student` |
|---|---|---|
| `/etc/hosts` | absolute | always the same file, wherever you are |
| `notes/todo.txt` | relative | `/home/student/notes/todo.txt` |
| `../practice` | relative | `/home/practice` if you are in `/home/student/notes` |

Two special folder names you will see everywhere:
- `.` = "this folder"
- `..` = "the folder above this one"

### `tree` — see the shape of a folder
```bash
$ tree -L 2 ~/linux-lab     # 2 levels deep
$ tree -d                   # folders only
```
May need installing: `sudo apt install tree`.

### `history` — what have I typed?
```bash
$ history            # numbered list of past commands
$ history 20         # last 20
$ !42                # re-run command number 42
$ !!                 # re-run the last command
$ Ctrl+R             # search history — type part of the command, press Enter
```

### `clear` — clean the screen (`Ctrl+L` does the same)

---

## Practice (do this now)

```bash
$ cd ~/linux-lab
$ mkdir -p practice/nav/alpha/one practice/nav/beta/two practice/nav/gamma
$ cd practice/nav
$ ls
alpha  beta  gamma
$ tree -L 3
```

Now answer without looking at the notes:

1. From `practice/nav`, go into `alpha/one`, then come back to `nav` in **one** command.
2. From `nav`, go to your home folder using `cd` with no arguments. Confirm with `pwd`.
3. From home, go to `~/linux-lab/practice/nav/gamma`. Then go back to your **previous** folder in
   one command.
4. List all files in `/etc` with human-readable sizes, sorted by newest first. Do not `cd` into `/etc`.
5. How many hidden files are directly inside your home folder? (Hint: combine `ls -a` with a pipe
   you'll learn later, or just count them.)
6. Use `Ctrl+R` to find the `tree` command you ran earlier and re-run it.

<details>
<summary>Answers</summary>

```bash
cd ..                 # 1: from alpha/one back to alpha's parent? careful:
# From practice/nav/alpha/one, `cd ../..` lands in practice/nav
cd ../..              # correct answer for task 1
cd                    # 2: home
pwd
cd gamma              # 3a
cd -                  # 3b: back to where you were
ls -lht /etc          # 4
ls -a | wc -l         # 5: count lines (includes . and ..)
# 6: Ctrl+R, type tree, Enter
```
</details>

---

## Common beginner traps

| Trap | What happens | Fix |
|---|---|---|
| `cd /home/student/notes/` with a typo | `No such file or directory` | `ls` the parent folder to see the real name |
| Using `\` instead of `/` | Windows habit — fails on Linux | Always `/`, even in WSL |
| `cd ~student` vs `cd ~` | `~student` means "student's home" | `~` alone = your own home |
| A folder named `My Stuff` | `cd My Stuff` → two arguments error | `cd "My Stuff"` or `cd My\ Stuff` |
| Lost track of where you are | — | `pwd`, then `cd ~/linux-lab` |

**Muscle memory drill (2 minutes):** `cd ~` → `pwd` → `ls -lah` → `cd /etc` → `pwd` → `cd -` → `pwd`.
Repeat 3 times a day for a week and navigation stops requiring thought.
