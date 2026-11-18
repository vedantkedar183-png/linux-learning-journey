# Lab 6 — `umask` and Default Permissions

**Goal:** understand why a new file is `644` and not `666`, control it, and stop accidentally publishing
private files.

**You need:** no `sudo`.

---

## The formula

```
FILE default    666 (rw-rw-rw-)   minus umask → 644 (rw-r--r--)
FOLDER default  777 (rwxrwxrwx)   minus umask → 755 (rwxr-xr-x)
```

It is not ordinary subtraction — it is **bitwise AND NOT**. The umask clears the bits you list.

| umask | New file | New folder | Typical use |
|---|---|---|---|
| `022` | `644` | `755` | shared machine, standard |
| `002` | `664` | `775` | team machine with a common group |
| `077` | `600` | `700` | private by default |
| `027` | `640` | `750` | owner + group only |

---

## Part A — Find your umask

1. Run `umask`. What value do you have?
2. Run `umask -S`. Write the symbolic form.
3. Where is your umask set? Look in `/etc/profile`, `~/.profile`, `~/.bashrc`:
   ```bash
   grep -rn umask /etc/profile ~/.profile ~/.bashrc 2>/dev/null
   ```

---

## Part B — Watch it work

4. Create a file and a folder and check permissions:
   ```bash
   $ cd ~/linux-lab/practice
   $ rm -rf umask-test && mkdir umask-test && cd umask-test
   $ touch f1 && mkdir d1
   $ ls -ld f1 d1
   ```
   What did you get? Relate it to your umask.
5. Change the umask in this shell only:
   ```bash
   $ umask 077
   $ touch f2 && mkdir d2
   $ ls -ld f2 d2
   ```
6. Change it to `002`, create `f3`/`d3`, and check. Which bit is different from `022`, and who benefits?
7. Open a **new terminal** and run `umask`. Is it 077 or your original value? Why? (This proves it is a
   per-shell setting.)

---

## Part C — Predict before you test

For each umask, write down what a new file and folder will get, then verify with `touch`/`mkdir`/`ls`:

| umask | file (predicted) | folder (predicted) | file (actual) | folder (actual) |
|---|---|---|---|---|
| `022` | | | | |
| `027` | | | | |
| `077` | | | | |
| `002` | | | | |
| `777` | | | | |

8. Fill the table.
9. Which umask would you set on a laptop that holds SSH keys and personal notes? Why?
10. Which umask would you set on a shared project server where everyone is in one group? Why?

---

## Part D — Make it permanent (safely)

11. Add a private umask to your shell config **without breaking anything**:
    ```bash
    $ cp ~/.bashrc ~/.bashrc.backup
    $ echo 'umask 077' >> ~/.bashrc
    $ source ~/.bashrc
    $ umask
    ```
12. Open a new terminal and confirm it is `077`.
13. Now remove it again (restore from the backup or edit the file):
    ```bash
    $ cp ~/.bashrc.backup ~/.bashrc && source ~/.bashrc
    ```
14. Why did we copy `.bashrc` first? (Hint: editing shell config wrongly can break your login shell.)

---

## Part E — `umask` vs `chmod`: which wins?

15. Create a file with `touch` (gets `644`), then `chmod 600` it. Which value is in effect?
16. Delete and recreate the same file. What permissions does it have now? Why did `chmod` not "stick"?
17. Explain in one sentence: what does `umask` control, and what does `chmod` control?

---

## Part F — Realistic scenario

18. A colleague's script leaks secrets because the log file it creates is world-readable. You cannot
    change their code today. What can you do **their shell** by adding one line to `.bashrc`?
19. A shared build server needs all build outputs writable by the `build` group. What umask fits?
    What else must be true (hint: primary group of the users)?
20. A backup script creates a folder for a nightly dump. The folder must be private. What umask should
    the **script** set at its start, and why is setting it inside the script better than relying on the
    user's shell?

---

## Self-check

- [ ] I can predict new file/folder permissions from any umask
- [ ] I know umask is per-shell and applied at creation time
- [ ] I know `chmod` overrides once, `umask` applies to every new file
- [ ] I made a backup before editing `.bashrc`

Answers: `solutions.md` → "Lab 6".
