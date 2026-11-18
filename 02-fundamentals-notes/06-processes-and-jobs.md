# 06 — Processes, Jobs, and Services

## What is a process?

A **program** is a file on disk. A **process** is that program *running* — loaded into memory, with a
PID, an owner, and state. Open the same program twice and you have two processes.

Analogy: a recipe is a program; cooking it is a process. You can cook the same recipe in two pans at
once.

Each process has:
| Property | Meaning |
|---|---|
| **PID** | process ID, unique number |
| **PPID** | parent process ID |
| **User** | who it runs as (decides its permissions) |
| **State** | R running, S sleeping, D uninterruptible sleep, Z zombie, T stopped |
| **Nice value** | scheduling priority (-20 highest, 19 lowest) |
| **Environment** | variables it inherited (`PATH`, `HOME`, …) |

```bash
$ ps aux
$ ps -ef --forest       # show the parent/child tree
$ ps -p 1 -o pid,ppid,user,cmd
```

## Everything descends from PID 1

At boot the kernel starts one process, PID 1. Every other process is its descendant. On modern Linux
PID 1 is **systemd** (`/sbin/init`).

```
systemd(1)
├── systemd-journald
├── sshd
│   └── sshd (your login)
│       └── bash
│           └── ps aux      ← you are here
├── nginx
└── cron
```
`pstree -p` draws this for you. It explains "orphan" and "zombie":
- **Orphan**: parent died; process is re-parented to PID 1, which reaps it.
- **Zombie**: child finished but the parent never collected its exit status. It holds a PID slot only.
  You cannot `kill -9` a zombie; you must fix or kill its parent.

## Foreground, background, jobs

Normally a command runs in the **foreground**: the shell waits for it and your prompt is blocked.

```bash
$ sleep 60              # foreground: no prompt until it ends
$ Ctrl+C                # send SIGINT: stop it
```

**Background** it with `&`:
```bash
$ sleep 60 &
[1] 4210                # job number 1, PID 4210
$ jobs
[1]+  Running   sleep 60 &
```

**Pause** the foreground job with `Ctrl+Z`, then decide:
```bash
$ Ctrl+Z                # job is now Stopped (T state)
$ bg %1                 # resume it in the background
$ fg %1                 # bring it back to the foreground
$ kill %1               # kill by job number
```

Key distinction:
- **Job** = a process the *current shell* is tracking (job numbers `%1`).
- **Process** = anything on the system (PIDs).
- `jobs` only shows this shell's jobs. `ps` shows everything.

### Surviving logout
When you close the terminal, the shell sends `SIGHUP` to its jobs, and they die.
```bash
$ nohup ./long.sh > out.log 2>&1 &     # ignore SIGHUP, keep running
$ disown %1                            # remove from job table
$ tmux                                 # better: a session that outlives the terminal
```

## Signals

A **signal** is a short message to a process. It is not a command — it is an interrupt.

```bash
$ kill -l               # list signals
$ kill 4210             # SIGTERM (15): polite request
$ kill -9 4210          # SIGKILL: immediate, no cleanup possible
$ kill -HUP 4210        # SIGHUP: many daemons reload config
$ killall nginx
$ pkill -f "node server.js"
```

| Signal | # | Default behaviour | Typical use |
|---|---|---|---|
| SIGTERM | 15 | terminate cleanly | normal stop |
| SIGKILL | 9 | terminate now (uncatchable) | stuck process |
| SIGINT | 2 | terminate | `Ctrl+C` |
| SIGQUIT | 3 | terminate + core dump | `Ctrl+\` |
| SIGHUP | 1 | terminate (for most) / reload (for daemons) | reload config |
| SIGSTOP/SIGCONT | 19/18 | pause / resume | debugging |
| SIGSEGV | 11 | crash | a bug in the program |

**Order of escalation:** try `SIGTERM` first, wait a few seconds, only then `-9`. `-9` prevents the
program from flushing buffers and closing files cleanly — data loss is possible.

## Nice values and CPU priority

```bash
$ nice -n 10 ./backup.sh        # start with lower priority
$ renice -n 5 -p 4210           # change a running process
$ ps -o pid,ni,cmd -p 4210
```
Range −20 (highest priority, root only) to 19 (lowest). Default 0.
Use `nice` for long background jobs so interactive work stays responsive.

## Monitoring: what is actually happening?

```bash
$ top                      # live list; P=CPU sort, M=memory sort, q=quit
$ htop                     # prettier, arrow keys, F9 to kill
$ free -h                  # RAM: look at "available", not "free"
$ uptime                   # load average 1/5/15 min
$ vmstat 1 5               # CPU, memory, IO every second
$ iostat -x 1              # per-disk IO (sysstat package)
$ pidstat -p 4210 1        # per-process stats
```

**Load average** = roughly the number of processes wanting CPU (running + waiting). Compare it with
your core count (`nproc`):
- 4 cores, load 3.5 → busy but healthy
- 4 cores, load 12 → overloaded, things will feel slow

CPU at 100% is not automatically bad. High load *plus* high iowait usually means disk problems.

## Services (daemons)

A **service** is a background process managed by systemd, with a name, a config file, and a lifecycle.

```bash
$ systemctl status ssh
$ sudo systemctl restart ssh
$ journalctl -u ssh -n 30
```
Difference from a plain background job: systemd supervises it, restarts it if configured, starts it at
boot, captures its output in the journal, and gives it consistent logging.

```bash
$ systemctl list-units --type=service --state=running
$ systemctl --failed
```

## Cgroups and "why is my process slow?"

Modern Linux groups processes into **cgroups** for resource limits (CPU, memory, IO). Docker and
systemd use them. That is how one container cannot eat all your RAM. You rarely touch cgroups directly,
but `systemd-run --scope -p MemoryMax=500M ./app` is a neat trick to cap a process.

## Prove you understood

1. What is the difference between a program and a process?
2. What is PID 1, and why does every process trace back to it?
3. `Ctrl+Z` vs `Ctrl+C` — what does each do?
4. Why is `kill -9` a last resort?
5. What does load average 8 on a 4-core machine tell you?
6. How is a systemd service different from `./script.sh &`?

<details>
<summary>Model answers</summary>

1. A program is a file; a process is a running instance with its own PID, memory, and state.
2. systemd (or init); the kernel starts it at boot and it starts everything else, so the process tree
   is rooted there. Orphans are re-parented to it so they get cleaned up.
3. `Ctrl+Z` pauses (SIGTSTP) and returns you to the prompt; `Ctrl+C` terminates (SIGINT).
4. SIGKILL cannot be caught, so the program cannot save data, close files, or clean up; corrupt state
   is possible.
5. There are about twice as many runnable processes as cores; the machine is overloaded and latency
   will be high.
6. systemd supervises it: restarts on failure, starts at boot, logs to the journal, and can apply
   resource limits.
</details>
