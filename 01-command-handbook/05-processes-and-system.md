# 05 — Processes, Memory, Disk, and Services

**The idea:** a **process** is a running program. Every command you type becomes a process for a
moment. Every web server, database, and background task is a process too. In this page you learn to
see them, measure them, and stop them.

A **service** (also called a daemon) is just a long-running process that the system manages for you
(`ssh`, `nginx`, `cron`).

---

## Seeing processes

### `ps` — a snapshot
```bash
$ ps                      # processes in THIS terminal
$ ps aux                  # ALL processes, every user, with CPU and memory
$ ps -ef                  # full format, parent/child view
$ ps aux | grep nginx     # find a specific one
$ ps aux --sort=-%mem | head -6    # top memory users
$ ps aux --sort=-%cpu | head -6    # top CPU users
```

Reading `ps aux`:
```
USER   PID  %CPU %MEM   VSZ   RSS  TTY   STAT  START  TIME  COMMAND
root     1   0.0  0.1 16800 11000  ?    Ss    10:01  0:02  /sbin/init
student 4123 12.4  2.1 900123 81234 pts/0 R    10:30  0:05  python3 train.py
```
- `PID` — process ID, the number you need to control it
- `%CPU` / `%MEM` — current CPU and memory usage
- `STAT` — `R` running, `S` sleeping, `Z` zombie, `T` stopped
- `TIME` — total CPU time consumed

### `pgrep` and `pidof` — get the PID directly
```bash
$ pgrep -a nginx         # PID + command line
$ pgrep -u student       # all my processes
$ pidof bash
```

### `top` — live view
```bash
$ top
```
- `P` sort by CPU (default), `M` sort by memory
- `k` kill a process (then type the PID)
- `q` quit

Key header lines: `load average` (1, 5, 15 minutes), `%Cpu(s)` idle, `MiB Mem` free.
A load average higher than your CPU count means the system is overloaded.

### `htop` — friendlier `top`
```bash
$ sudo apt install htop && htop
```
Arrow keys to move, `F9` to kill, `F6` to sort, `q` to quit. Colors and bars make it obvious what is
busy. Use this if available.

---

## Controlling processes

```bash
$ kill 4123            # politely ask PID 4123 to stop (SIGTERM)
$ kill -9 4123         # force kill (SIGKILL). Last resort — data may be lost
$ killall firefox      # kill every process with this name
$ pkill -f "python3 train.py"   # kill by command-line pattern
$ kill -l              # list all signal names
```

Signal cheat sheet:
| Signal | Number | Meaning |
|---|---|---|
| `SIGTERM` | 15 | "please exit cleanly" (default) |
| `SIGKILL` | 9 | "die now, no cleanup" |
| `SIGHUP` | 1 | often "reload config" |
| `SIGINT` | 2 | what `Ctrl+C` sends |
| `SIGSTOP` | 19 | pause; `SIGCONT` (18) resumes |

### Jobs: `&`, `jobs`, `fg`, `bg`, `Ctrl+Z`
```bash
$ sleep 100 &          # start in the background, get a job number [1]
$ jobs                 # list background jobs
$ fg %1                # bring job 1 to the foreground
$ Ctrl+Z               # PAUSE the foreground job (does not kill it)
$ bg %1                # resume the paused job in the background
$ disown %1            # detach so it survives closing the terminal
$ nohup ./long-task.sh > out.log 2>&1 &    # survive logout properly
```

The professional way to keep something running after you disconnect:
```bash
$ tmux new -s work      # start a session; Ctrl+B then D to detach
$ tmux attach -t work   # come back later
```
(`screen` is the older equivalent.)

---

## System resources

```bash
$ uptime                # how long up + load average
$ free -h               # RAM and swap
$ df -h                 # disk space per filesystem
$ df -i                 # inode usage (yes, you can run out of inodes)
$ du -sh /var/log       # what is eating space
$ vmstat 2 5            # 5 samples, every 2s
$ iostat -x 2           # disk I/O (package: sysstat)
```

Reading `free -h`:
```
               total        used        free      shared  buff/cache   available
Mem:            7.8Gi       2.1Gi       1.2Gi       0.1Gi       4.5Gi       5.2Gi
Swap:           2.0Gi          0B       2.0Gi
```
Look at **available**, not `free`. Linux deliberately uses spare RAM as cache.

### System identity
```bash
$ uname -a              # kernel + architecture
$ hostnamectl           # OS, kernel, hostname, virtualization
$ lscpu                 # CPU details
$ lsblk                 # block devices (disks and partitions)
$ uptime -p             # "up 3 days, 2 hours"
$ nproc                 # number of CPUs
```

---

## Services with `systemctl`

```bash
$ systemctl status ssh              # is it running? recent log lines?
$ sudo systemctl start ssh          # start now
$ sudo systemctl stop ssh           # stop now
$ sudo systemctl restart nginx      # stop + start
$ sudo systemctl reload nginx       # re-read config without dropping connections
$ sudo systemctl enable ssh         # start automatically at boot
$ sudo systemctl disable ssh        # do not start at boot
$ systemctl list-units --type=service --state=running
$ systemctl is-enabled ssh
```

`start` vs `enable` — the classic confusion:
- `start` = now (until reboot)
- `enable` = every boot (but not now)
- most setups want **both**.

## Logs with `journalctl`

```bash
$ journalctl -u ssh                 # this service's logs
$ journalctl -u ssh -f              # follow live
$ journalctl -b                     # this boot only
$ journalctl --since "1 hour ago"
$ journalctl -p err -b              # only errors this boot
$ journalctl -xe                    # last entries + explanation
$ sudo journalctl --disk-usage
```

## Scheduled tasks with `cron`

```bash
$ crontab -l                        # my jobs
$ crontab -e                        # edit mine
```
Format: `minute hour day-of-month month day-of-week command`
```bash
# every day at 02:30
30 2 * * * /home/student/backup.sh >> /home/student/backup.log 2>&1
# every 5 minutes
*/5 * * * * /usr/bin/date >> /tmp/clock.log
```
Check that it ran: look at the log file, or `journalctl -u cron`.

---

## Practice lab

1. List the 5 processes using the most memory. Which is first?
2. Start a background job: `sleep 300 &`. Show it with `jobs`. Then stop it with `kill`.
3. Pause a foreground job with `Ctrl+Z`, then resume it in the background with `bg`.
4. Find the PID of your shell (`pgrep bash` or `echo $$`) and confirm it with `ps -p <PID>`.
5. Show total RAM, used RAM, and available RAM.
6. Show disk usage of `/var/log`, then list the 5 biggest files inside it (use `sudo`).
7. Check whether `ssh` is running and whether it is enabled at boot.
8. Show the last 20 log lines of the `cron` service.
9. Display your boot time and current uptime.
10. Write a `crontab` line that appends the date to `~/linux-lab/clock.log` every 10 minutes.
    (Add it, verify with `crontab -l`, then remove it — do not leave stray jobs.)

<details>
<summary>Answers</summary>

```bash
ps aux --sort=-%mem | head -6                  # 1
sleep 300 &                                    # 2
jobs
kill %1
sleep 300                                      # 3
# press Ctrl+Z, then:
bg
ps -p $$                                       # 4
free -h                                        # 5
sudo du -sh /var/log                           # 6
sudo du -ah /var/log | sort -h | tail -5
systemctl status ssh; systemctl is-enabled ssh # 7
journalctl -u cron -n 20                       # 8
uptime; who -b                                  # 9
# 10:
crontab -e
# */10 * * * * date >> /home/student/linux-lab/clock.log
crontab -l
crontab -e   # delete the line, save
```
</details>

---

## Troubleshooting order (remember this sequence)

1. `ps aux | grep <name>` — is it even running?
2. `systemctl status <name>` — does the service manager think so?
3. `journalctl -u <name> -n 50` — why did it exit?
4. `df -h` and `free -h` — is the system out of disk or RAM?
5. `ss -tulpn` — is it listening on the port you expect?
6. Only then start changing config files.
