# 03 — Viewing and Editing Text

**The idea:** in Linux, config files, logs, and scripts are all plain text. Reading and editing text
is the core daily skill. Terminals are text-only, so we need text tools.

---

## Reading files

### `cat` — print the whole file
```bash
$ cat notes.txt
$ cat -n notes.txt          # with line numbers
$ cat a.txt b.txt           # print several files in a row
$ cat > new.txt             # type text, finish with Ctrl+D (create by typing)
```
Use `cat` only for **short** files. For long ones it floods your screen.

### `less` — scroll through a long file (the professional way)
```bash
$ less /var/log/syslog
```
| Key | Action |
|---|---|
| `Space` / `b` | page down / page up |
| `g` / `G` | top / bottom |
| `/word` | search forward; `n` = next match |
| `q` | quit |

`less` does not load the whole file and does not change it. Use it instead of `cat` for anything
longer than a screen.

### `head` and `tail` — the start and the end
```bash
$ head -n 20 file.txt        # first 20 lines (default 10)
$ tail -n 20 file.txt        # last 20 lines
$ tail -f /var/log/syslog    # FOLLOW: new lines appear live. Ctrl+C to stop
$ tail -n +2 file.csv        # everything except the header
```
`tail -f` is how you watch a log while you break and fix a service.

### `wc` — count things
```bash
$ wc -l file.txt             # lines
$ wc -w file.txt             # words
$ wc -c file.txt             # bytes
$ wc -l *.log                # count lines in each log
```

### `nl` — number lines
```bash
$ nl file.txt                # numbers non-empty lines
```

### `grep` for reading logs
```bash
$ grep -i "error" /var/log/syslog        # case-insensitive
$ grep -n "failed" app.log               # show line numbers
```
More in `04-search-and-filter.md`.

---

## Editors

### `nano` — the beginner editor (recommended at first)
```bash
$ nano myfile.txt
```
- Type normally.
- **Save:** `Ctrl+O`, then `Enter`.
- **Exit:** `Ctrl+X` (it asks to save if you changed something).
- **Cut line:** `Ctrl+K`. **Paste:** `Ctrl+U`. **Search:** `Ctrl+W`.

### `vim` — fast, everywhere, and confusing at first
It has modes. You start in **normal mode**, where keys are commands, not letters.
```bash
$ vim myfile.txt
```
| Step | Keys |
|---|---|
| Start typing text | press `i` (insert mode) |
| Stop typing | press `Esc` |
| Save and quit | `:wq` then `Enter` |
| Quit without saving | `:q!` then `Enter` |
| Delete a line | `dd` |
| Undo | `u` |
| Search | `/word` then `Enter`, `n` for next |

If you get lost in vim: press `Esc` several times, type `:q!`, press Enter. You are out. Nothing broke.

### `vi` vs `vim` vs `nano`
`vi` is the old standard, `vim` is "vi improved", `nano` is the friendly one. Use `nano` to learn,
learn `vim` basics because every server has it.

---

## Comparing and redirecting

### `diff` — what changed between two files?
```bash
$ diff old.conf new.conf
2c2
< port=8080
---
> port=9090
```
`2c2` = line 2 changed. `<` is the first file, `>` is the second.

```bash
$ diff -u old.conf new.conf     # unified format, like git shows
$ diff -r folder1 folder2       # compare two folder trees
```

### `tee` — write to a file AND see it on screen
```bash
$ ls -l | tee listing.txt              # save a copy while you look
$ echo "log line" | sudo tee -a /etc/config    # append as root, without sudo-wrapping echo
```

### Redirection recap
```bash
$ command > out.txt          # stdout to file (overwrite)
$ command >> out.txt         # append
$ command 2> err.txt         # stderr to file
$ command &> all.txt         # both stdout and stderr
$ command > out.txt 2>&1     # same thing, the classic syntax
$ command < input.txt        # feed a file as stdin
```
Why it matters: `sudo echo x > /etc/file` fails, because the **redirection** happens as *you*, not
as root. `echo x | sudo tee /etc/file` works.

---

## Practice lab

```bash
$ cd ~/linux-lab
$ rm -rf practice/text && mkdir -p practice/text && cd practice/text
$ seq 1 500 > big.txt
$ echo "ERROR disk full" > app.log
$ echo "info started" >> app.log
$ echo "ERROR timeout" >> app.log
```

1. Print the first 5 lines and the last 5 lines of `big.txt`. Without displaying the middle.
2. Count how many lines `big.txt` has.
3. Use `less` to find the line containing `250`. Which key sequence found it?
4. Copy `app.log` to `app.bak`, then change `timeout` to `shutdown` in `app.bak` using `nano`.
   Use `diff` to prove what changed.
5. Show only the `ERROR` lines of `app.log`, with line numbers.
6. Save the output of `ls -lah /etc` into `etc-list.txt` while also seeing it on screen.
7. Run `tail -f app.log` in one terminal, then in another run `echo "new event" >> app.log`.
   Watch the new line appear. Stop the follower with `Ctrl+C`.
8. Append a line to a root-owned file without using `sudo bash`: use `tee`.

<details>
<summary>Answers</summary>

```bash
head -5 big.txt; tail -5 big.txt        # 1
wc -l big.txt                           # 2 -> 500
less big.txt                            # 3: /250 then Enter, q
cp app.log app.bak
nano app.bak                            # 4: edit timeout -> shutdown, Ctrl+O Enter Ctrl+X
diff app.log app.bak
grep -n "ERROR" app.log                 # 5
ls -lah /etc | tee etc-list.txt         # 6
tail -f app.log                         # 7 (second terminal: echo ...)
echo "hello" | sudo tee -a /etc/motd    # 8
```
</details>

---

## Mini reference: which tool do I need?

| I want to… | Use |
|---|---|
| read a short file | `cat` |
| read a long file | `less` |
| see the newest log entries | `tail` |
| watch a log live | `tail -f` |
| edit a config file | `nano` (or `vim`) |
| find a word in a file | `grep` |
| count lines | `wc -l` |
| see what changed | `diff -u` |
| save output AND see it | `tee` |
