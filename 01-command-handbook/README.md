# 01 — Command Handbook

A quick-reference book for the commands you will actually use. Every page follows the same shape:

1. **What it does** — in plain words.
2. **The commands** — copy-friendly, with a comment on each.
3. **Practice** — small tasks so the command enters your fingers, not just your eyes.

| Page | Topic | Commands covered |
|---|---|---|
| `01-navigation.md` | Finding your way around | `pwd`, `ls`, `cd`, `tree`, `history` |
| `02-files-and-folders.md` | Creating and managing files | `touch`, `mkdir`, `cp`, `mv`, `rm`, `ln`, `file`, `stat` |
| `03-viewing-and-editing.md` | Reading and editing text | `cat`, `less`, `head`, `tail`, `nano`, `vim`, `diff`, `tee` |
| `04-search-and-filter.md` | Finding things and shaping output | `find`, `grep`, `sort`, `uniq`, `cut`, `sed`, `awk`, pipes |
| `05-processes-and-system.md` | Processes, memory, disk, services | `ps`, `top`, `kill`, `free`, `df`, `systemctl`, `journalctl`, `cron` |
| `06-users-and-permissions.md` | Accounts and access | `id`, `useradd`, `usermod`, `chmod`, `chown`, `umask`, `sudo` |
| `07-networking.md` | Network inspection and transfer | `ip`, `ping`, `curl`, `ss`, `dig`, `ssh`, `scp`, `rsync` |
| `08-packages-and-services.md` | Installing software and managing services | `apt`, `dpkg`, `snap`, `systemctl`, `timedatectl` |
| `09-cheatsheet.md` | One-page reminder of everything | all of the above |

---

## How to read a command's syntax

```bash
command -option argument
```
- `command` — the program name: `ls`
- `-option` (or `--option`) — a switch that changes behaviour: `-l` long format
- `argument` — the thing it acts on: `/etc`

Many short options can be combined: `ls -l -a -h` = `ls -lah`.

## Three help tools you must know

```bash
$ man ls          # full manual. Scroll with arrows/space, quit with q
$ ls --help       # short summary of options
$ man -k password # search manuals for a keyword
```

## The single most useful skill: pipes and redirection

```bash
$ command > file.txt      # send output INTO a file (overwrites it)
$ command >> file.txt     # append output to a file
$ command 2> errors.txt   # send only errors into a file
$ command | other         # send output INTO another command
```

Example — the 5 biggest files in the current folder:
```bash
$ du -sh * | sort -h | tail -5
```

Everything else in this handbook is vocabulary. Pipes are grammar.
