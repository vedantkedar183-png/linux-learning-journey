# Lab 3 — Permissions: `rwx` and Octal

**Goal:** read any `ls -l` line fluently, change permissions confidently, and know what each bit does
to files vs folders.

**You need:** no `sudo`. This lab is entirely in your own folder.

---

## Setup

```bash
$ cd ~/linux-lab
$ rm -rf practice/perm3 && mkdir -p practice/perm3 && cd practice/perm3
$ echo "secret data" > secret.txt
$ echo "public data" > public.txt
$ echo 'echo "I ran!"' > run.sh
$ mkdir folder
$ mkdir -p folder/inner && echo "inside" > folder/inner/file.txt
$ ls -l
```

---

## Part A — Read the bits (no commands, just eyes)

1. Run `ls -l` and write down, for each entry, the 9 permission characters.
2. For `secret.txt`, answer: who can read? who can write? who can execute?
3. What is the **type** character for `folder`? What does it mean?
4. Convert these symbolic permissions to octal:
   - `rw-r--r--` → ____
   - `rwxr-x---` → ____
   - `rw-------` → ____
   - `r--r--r--` → ____
   - `rwxrwxrwx` → ____
5. Convert these octal to symbolic:
   - `750` → ____
   - `600` → ____
   - `777` → ____
   - `644` → ____
   - `400` → ____

---

## Part B — Change bits with numbers

6. Make `secret.txt` private to you: `chmod 600 secret.txt`. Verify with `ls -l`.
7. Make `public.txt` readable by everyone: `chmod 644 public.txt`.
8. Make `run.sh` executable by you only: `chmod 700 run.sh`. Run it with `./run.sh`. Now try
   `chmod 600 run.sh` and run it again. Read the error. Why? (Hint: the kernel needs at least one `x`.)
9. Set `folder` to `755`. Can you still `cd folder`? (`x` present.)
10. Set `folder` to `644`. Try to `cd folder`. Read the error. What is missing?
11. Set `folder` back to `755`.
12. Set `folder/inner/file.txt` to `000`. Try to `cat` it. Then restore with `chmod 644`.
13. Create a file with permissions `000` in one command (`touch` creates `644`; you must `chmod` after).

---

## Part C — Change bits with symbols

14. Add execute for the owner on `run.sh` without touching the other bits: `chmod u+x run.sh`.
15. Remove write for the group on `public.txt`: `chmod g-w public.txt`.
16. Set "other" to exactly read, removing write and execute: `chmod o=r public.txt`.
17. Add read for everyone: `chmod a+r public.txt`.
18. Set an exact combination: `chmod u=rwx,g=rx,o= public.txt` → what octal is that?
19. Copy permissions from one file to another:
    `chmod --reference=secret.txt public.txt`, then `ls -l`.
20. Remove all permissions for other on `secret.txt` using symbolic syntax.

---

## Part D — File vs folder: prove the difference

This is the most important part of the lab. Do all of it.

21. Maked a folder `testdir` with `chmod 644`. Can you `ls testdir`? Can you `cd testdir`?
22. Make `testdir` `744`. `ls` works; can you `cd`?
23. Make `testdir` `711`. Can you `ls`? Can you `cd`? Can you `cat testdir/knownfile` (create the file
    first as root of the folder)? Explain what `x` alone gives you.
24. Make `testdir` `755`, `cd` into it, and try to create a file while write is **off** for you:
    `chmod 555 .` then `touch newfile`. Read the error. Restore `chmod 755 .`.
25. Create a **read-only file** (`chmod 444 file.txt`) inside a writable folder. Try `rm file.txt`. It
    works! Explain why: deleting a file needs **write on the folder**, not on the file.
26. Now make the folder read-only (`chmod 555`) and try to delete the file inside it. Read the error.

---

## Part E — Realistic permission sets

27. Create this and set the stated permissions, then verify each with `ls -l`:

| Path | Octal | Why |
|---|---|---|
| `safe/private.key` | `600` | only the owner may read the key |
| `safe/notes.txt` | `640` | owner writes, group reads |
| `safe/script.sh` | `750` | owner runs, group reads/runs, others nothing |
| `safe/public.html` | `644` | everyone reads |
| `safe/shared/` | `770` | team folder |
| `safe/uploads/` | `1777` | anyone writes, only owner deletes |

28. Verify your answers by:
    ```bash
    $ ls -l safe/
    $ ls -ld safe/shared safe/uploads
    ```
29. Why is `chmod 777` on a web folder a bad idea even if "it makes it work"? Give two concrete risks.
30. A colleague says "just `chmod -R 777` the problem away". Write a 3-sentence reply explaining why
    that is wrong and what to do instead.

---

## Part F — Debugging permissions

31. Create `deep/a/b/c/secret.txt` with `644` on the file. Set `deep/a` to `700` and try to `cat
    deep/a/b/c/secret.txt` as another user with `sudo -u nobody cat ...`. What error?
32. Run `namei -l deep/a/b/c/secret.txt`. Which folder blocks access?
33. Fix it and confirm access as `nobody`.
34. Write the **3-command debugging sequence** you will use whenever someone says "permission denied":
    ```bash
    $ id
    $ namei -l <path>
    $ ls -l <path>
    ```

---

## Self-check

- [ ] I can convert symbolic ↔ octal without a table
- [ ] I know `x` on a folder means "traverse", not "execute"
- [ ] I know deleting needs write on the **folder**
- [ ] I can debug "permission denied" in under a minute with `namei`
- [ ] I never use `777` "to make it work"

Answers: `solutions.md` → "Lab 3".
