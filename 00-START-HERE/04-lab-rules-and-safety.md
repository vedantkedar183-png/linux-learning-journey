# Lab Rules and Safety

Read this once now, and re-read rule 3 whenever you are tired. Most "I destroyed my system" stories
come from a single mistyped character.

---

## The 6 rules

### Rule 1 — Practice in a sandbox, not on a real machine
Use WSL2, a VirtualBox VM, Docker, or a cloud VM. Never run these labs on a computer whose data you
care about. In a VM, take a **snapshot** before starting a lab.

### Rule 2 — Do all work inside `~/linux-lab`
Create it once:
```bash
$ mkdir -p ~/linux-lab && cd ~/linux-lab
```
Then every lab command that creates or deletes files happens below this folder. If you are ever lost:
`cd ~/linux-lab` brings you back to safety.

### Rule 3 — Respect spaces and slashes
These two commands look almost the same. One deletes a folder. The other deletes your entire system's
files, one directory at a time.

```bash
$ rm -rf ~/linux-lab/old-stuff     # safe: one specific folder
$ rm -rf ~ /linux-lab/old-stuff    # ☠️ DELETES / (root) AND /linux-lab/old-stuff
```

**Habits that protect you:**
- Put quotes around paths with spaces: `rm -rf "$HOME/my folder"`.
- Press the **Up arrow**, read the command, then run it. Never run a command you have not read.
- Prefer `rm -i` (ask before delete) while learning. Make it a habit:
  `alias rm='rm -i'` (add to `~/.bashrc` to make it permanent).
- Use `ls` on the target first, then put `rm` in front of the exact same line.

### Rule 4 — Never run these while learning
| Command | Why it is dangerous |
|---|---|
| `rm -rf /` | Deletes the entire filesystem |
| `mkfs.*` on a real device | Formats a disk, erasing everything |
| `dd if=... of=/dev/sda` | Overwrites a raw disk |
| `chmod -R 777 /` | Makes every file world-writable — destroys security |
| `chown -R user:user /` | Breaks system file ownership |
| `systemctl disable ssh` on a cloud VM | Locks you out permanently |
| Anything copied from the internet with `curl ... \| sudo bash` | Runs unknown code as root |

If a lesson ever needs a dangerous-looking command (like formatting a loopback file), it will say so
clearly and we will use a **fake disk file**, never a real device.

### Rule 5 — `sudo` means "for one command", not "stay admin"
```bash
$ sudo apt update          # ✅ one command with admin power, then back to normal
$ sudo -i                  # ⚠️ now you are root until you type exit
```
While you are `root`, the shell stops protecting you. Learn to leave root immediately: `exit`.
The prompt tells you where you are: `$` = normal user, `#` = root.

### Rule 6 — When you break something, stop and read
1. Read the exact error message. Linux errors are literal.
2. Note what you changed in the last 2 commands.
3. If it is a VM: restore the snapshot. There is no shame in it; professionals do this daily.
4. If it is WSL2: in PowerShell run `wsl --shutdown`, reopen Ubuntu. Worst case,
   `wsl --unregister Ubuntu` and reinstall (this **deletes** the distro and its files — ask before
   doing it, and back up anything you need first).

---

## Lab setup template (paste at the start of every exercise)

```bash
$ cd ~/linux-lab
$ rm -rf practice/current && mkdir -p practice/current
$ cd practice/current
$ pwd
/home/student/linux-lab/practice/current
```

This gives every exercise a clean, disposable folder. The `rm -rf` only ever touches
`~/linux-lab/practice/current`, which you just created — that is a safe, deliberate reset.

---

## How to ask for help (in class or online)

A good question gets a good answer. Include:

1. **What you wanted to do:** "I want to give group `devs` write access to `/srv/shared`."
2. **The exact command you ran:** `sudo chmod g+w /srv/shared`
3. **The exact output/error:** `chmod: changing permissions of '/srv/shared': Operation not permitted`
4. **What you already tried.**

Never post screenshots of text — paste the text.

---

## Permission to experiment

You are *supposed* to break things here. That is the method. Make a snapshot, run the weird command,
watch what happens, restore. Curiosity is the skill; the commands are just vocabulary.
