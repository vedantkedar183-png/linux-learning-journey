# Setup: Get a Linux Terminal on Your Computer

You are on **Windows** right now. That is fine — you have four good options. Pick **one**, get it
working, and only then move on. Do not skip this: you cannot learn Linux by reading.

| Option | Best for | Difficulty | Cost |
|---|---|---|---|
| A. WSL2 (Windows Subsystem for Linux) | Fastest start, real Ubuntu inside Windows | Easy | Free |
| B. VirtualBox + Ubuntu | Full desktop Linux, safest sandbox, snapshots | Easy–Medium | Free |
| C. Docker container | Quick throwaway Linux, no install of Ubuntu | Medium | Free |
| D. Free cloud server (e.g. Oracle/AWS free tier) | Real remote server + SSH practice | Medium | Free tier |

**Recommendation for a beginner class: do A (WSL2) first.** It takes ~10 minutes and gives you a real
Ubuntu terminal. Later, add B for GUI and snapshot practice.

---

## Option A — WSL2 (recommended)

### Step 1: Open PowerShell as Administrator
Press the Windows key, type `PowerShell`, right-click **Windows PowerShell** → **Run as administrator**.

### Step 2: Install WSL (one command)
```powershell
wsl --install
```
This installs WSL2 plus Ubuntu. When it finishes, **restart your computer**.

### Step 3: Finish Ubuntu setup
After restart, Ubuntu opens by itself (or search "Ubuntu" in the Start menu). It asks you to create a
Linux username and password.

- Use a simple lowercase username, e.g. `student`.
- The password is **invisible while you type** — no stars appear. That is normal. Type and press Enter.

### Step 4: Verify
```bash
$ whoami
student
$ cat /etc/os-release
NAME="Ubuntu"
VERSION="24.04.x LTS (Noble Numbat)"
```

You are now inside Linux. Windows drives are available at `/mnt/c/`.

### Useful WSL facts
- Open the Ubuntu terminal any time from the Start menu, or type `wsl` in PowerShell.
- Your Linux home folder is `/home/<yourname>`. Windows Explorer shows it as
  `\\wsl$\Ubuntu\home\<yourname>`.
- **Keep lab files inside Linux** (`~/linux-lab`), not on `/mnt/c/`. Working on `/mnt/c` is slow and
  breaks file permissions practice.
- Restart WSL if it misbehaves: in PowerShell run `wsl --shutdown`, then open Ubuntu again.

---

## Option B — VirtualBox + Ubuntu (full desktop, snapshot safety)

This is the classic classroom setup and the best one for "break it and restore it" experiments.

### Steps
1. Download **VirtualBox** from `virtualbox.org` → install with default options.
2. Download the **Ubuntu Desktop LTS ISO** from `ubuntu.com/download/desktop` (~5 GB). Choose the
   latest LTS release.
3. In VirtualBox: **New** → Name `Ubuntu-Practice`, Type Linux, Version Ubuntu (64-bit).
4. Give it: **4 GB RAM** (2 GB minimum), **2 CPUs**, **25 GB disk** (dynamically allocated).
5. Start the VM, select the ISO, choose **Install Ubuntu**, use the default "Erase disk and install"
   (this only touches the virtual disk), make a user `student`.
6. When the desktop loads, open **Terminal** (`Ctrl+Alt+T`).

### Take a snapshot immediately (very important)
In VirtualBox menu: **Machine → Take Snapshot** → name it `clean-install`.
Now no mistake is permanent. If you wreck the system: **Machine → Restore Snapshot**.

### Quality-of-life settings
- **Devices → Insert Guest Additions CD** → run the installer → reboot. This gives you a resizable
  window, shared clipboard, and shared folders.
- Take a new snapshot after each week of setup changes, named `week-1`, `week-2`, etc.

---

## Option C — Docker (quick, throwaway)

Only do this if Docker Desktop is already installed.

```powershell
docker run -it --name linux-lab ubuntu:24.04 bash
```
You are now root inside a minimal Ubuntu. To practice users, install a few basics first:
```bash
$ apt update && apt install -y sudo vim less curl iproute2 procps
```
Type `exit` to leave, and `docker start -ai linux-lab` to come back. Delete with
`docker rm -f linux-lab` when done.

**Limitation:** Docker containers have no systemd, so `systemctl` will not work. Do service labs on
WSL2 or VirtualBox instead.

---

## Option D — Free cloud server

Good for realism: you get a public IP, SSH, and firewall practice.
1. Sign up for a free-tier VPS (Oracle Cloud "Always Free" is generous, or a small AWS/Azure VM).
2. Choose **Ubuntu 24.04 LTS**, smallest size, and download the SSH key.
3. Connect from PowerShell: `ssh -i key.pem ubuntu@<public-ip>`.
4. Always run `sudo apt update && sudo apt upgrade -y` first.
5. Lock it down before you sleep: add your SSH key, disable password login, enable `ufw`.
   (You will learn all of this in `05-network-basics/05-ssh-and-remote-access.md`.)

⚠️ Never expose a cloud VM with a weak password and SSH open to the world. It will be attacked
within hours. Prefer key-only login.

---

## First 10 commands after installation (do them now)

Run these one at a time. Do not worry if you don't understand yet — you will in Week 1.

```bash
$ whoami                # which user am I?
$ pwd                   # which folder am I in?
$ ls -lah               # what is in this folder? (long list, all files, human sizes)
$ cat /etc/os-release   # which Linux version is this?
$ uname -a              # kernel version and architecture
$ df -h                 # how full are my disks?
$ free -h               # how much RAM is free?
$ ip a                  # what is my IP address?
$ date                  # what time does the system think it is?
$ echo "Hello Linux"    # print something to the screen
```

Then set up your practice sandbox:
```bash
$ mkdir -p ~/linux-lab
$ cd ~/linux-lab
$ mkdir -p notes practice projects
$ ls
notes  practice  projects
```

**You are ready.** Everything in this course happens inside `~/linux-lab`.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `wsl --install` says virtualization is disabled | Enable "Virtualization Technology / SVM" in BIOS/UEFI, then retry |
| Ubuntu asks for a password but nothing appears | That is normal — type blind, press Enter |
| `Permission denied` when running a script | You forgot `chmod +x script.sh` |
| `command not found` | Package not installed: `sudo apt install <package>` |
| `sudo: command not found` in Docker | Run `apt update && apt install sudo` as root |
| VirtualBox VM is very slow | Enable VT-x/AMD-V, give 2+ CPUs, install Guest Additions |
| My prompt shows `#` instead of `$` | You are `root`. Type `exit` to return to your normal user |
