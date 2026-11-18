# 02 — Kernel, Shell, Terminal, and Desktop: Who Does What?

Beginners mix these four words up constantly. Once you separate them, a lot of confusion disappears.

Think of a restaurant:

| Part | Restaurant analogy | Linux reality |
|---|---|---|
| **Kernel** | the kitchen | talks to hardware, schedules work |
| **Shell** | the waiter | takes your order and brings results |
| **Terminal** | the table and menu | the window where you type |
| **Desktop** | the dining room decor | icons, mouse, windows |

---

## 1. The kernel — the boss of the hardware

The kernel is the first thing loaded by the bootloader. It stays in memory and owns everything:
- decides which process runs on which CPU and for how long
- allocates and protects memory
- reads/writes disks, talks to network cards and USB
- enforces permissions and isolates processes
- exposes the "everything is a file" view in `/proc`, `/sys`, `/dev`

You almost never talk to the kernel directly. You ask it to do things **through system calls**, and
usually through a shell or program that does that for you.

See your kernel version:
```bash
$ uname -r
6.8.0-45-generic
```

## 2. The shell — the translator

A **shell** is a program that reads the text you type and asks the kernel to do it. It is also a small
programming language (that is Bash scripting, module 6).

```bash
$ echo "hello"        # shell parses this line and runs /usr/bin/echo
$ cd /tmp             # "cd" is a shell BUILTIN — it must change the shell's own state
```

Why `cd` is special: if `cd` were a separate program, it would change *its own* working directory and
then exit, leaving your shell unchanged. So `cd` is built into the shell.

Which shell am I using?
```bash
$ echo $SHELL         # your login shell
$ ps -p $$            # the actual shell process running now
```

Common shells:
| Shell | Notes |
|---|---|
| `bash` | default on most Linux; what this course teaches |
| `sh` | the old POSIX shell; scripts should stay compatible with it |
| `zsh` | popular interactive shell, fancy prompts |
| `fish` | friendly syntax, not POSIX compatible |
| `dash` | tiny and fast; `/bin/sh` on Ubuntu is often dash |

## 3. The terminal — the window

Strictly, a **terminal emulator** is a program that shows text and sends your keystrokes to the shell:
GNOME Terminal, Windows Terminal (running WSL), iTerm2, Konsole, xterm, tmux.

"Open a terminal" really means: start a terminal emulator → it starts a shell → you type.

You can run several terminals at once, each with its own shell and its own working directory.

**Multiplexers** like `tmux` run *inside* a terminal but let you have many shells in one window, and
keep them alive after you disconnect:
```bash
$ tmux new -s lab        # create a session
$ tmux ls                # list sessions
$ tmux attach -t lab     # reattach after closing the window
```

## 4. The desktop environment — the optional part

A desktop environment (GNOME, KDE Plasma, XFCE, Cinnamon) draws windows, icons, a dock, and a file
manager. It is a normal program (or a set of them) running on top of the kernel, not part of Linux
itself.

This is why:
- servers have **no desktop at all** and only give you a shell
- the same commands work identically with or without a GUI
- if the GUI crashes, your shell still works (`Ctrl+Alt+F3` drops you to a TTY)

---

## How a single command travels

```bash
$ ls -l /etc
```

1. The **terminal** passes the line to the **shell**.
2. The shell expands things (`~`, `*`), sees `ls`, and searches `PATH` for it.
3. It asks the **kernel** to start `/usr/bin/ls` as a new **process**.
4. `ls` asks the kernel to read the `/etc` directory.
5. The kernel reads the disk and returns names and metadata.
6. `ls` formats the output and writes it to stdout.
7. The terminal shows the text.

Everything in this course lives in step 2–6. Understanding that chain is why error messages such as
`command not found` (step 2), `Permission denied` (step 4, kernel) and `No such file or directory`
(step 4) make sense.

## `PATH` — how the shell finds commands

```bash
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
The shell looks in these folders **left to right** for the program name. That is why:
```bash
$ ./script.sh        # runs a script in the current folder ("." is not in PATH — on purpose)
$ echo $PATH
$ which ls
/usr/bin/ls
```

If you put a new program in a folder not listed in `PATH`, the shell cannot find it by name. Add a
folder for your own scripts:
```bash
$ mkdir -p ~/bin
$ echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
$ source ~/.bashrc
```

---

## Prove you understood

1. Which part talks to the hardware?
2. Which part reads your typing and turns it into actions?
3. Why is `cd` built into the shell instead of being a separate program?
4. Can you have a shell without a desktop? Without a terminal emulator?
5. Why is `.` not in your `PATH` by default?

<details>
<summary>Model answers</summary>

1. The kernel.
2. The shell (bash).
3. Because it must change the state of the shell process itself; a separate program would exit
   immediately and the change would be lost.
4. Yes — servers are exactly that. A shell needs *some* input device; a TTY or an SSH connection
   counts as well as a terminal window.
5. Security: if the current folder were in `PATH`, a malicious `ls` in a downloaded folder would run
   instead of the real one.
</details>
