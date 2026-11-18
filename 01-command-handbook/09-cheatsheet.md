# 09 — One-Page Cheatsheet

Print this. Tape it near your screen for the first month.

---

## Navigation
```bash
pwd                     # where am I
ls -lah                 # list all, long, human sizes
ls -lt                  # newest first
cd /path                # go to absolute path
cd ..                   # up one
cd ~                    # home
cd -                    # previous folder
tree -L 2               # folder shape, 2 levels
```

## Files
```bash
touch f                 # create empty file
mkdir -p a/b/c          # create nested folders
cp f1 f2                # copy
cp -r dir1 dir2         # copy folder
cp -a src/ dst/         # copy preserving everything
mv old new              # rename
mv f dir/               # move
rm f                    # delete file
rm -r dir               # delete folder
rm -rf dir              # force (NO undo)
ln -s target link       # symlink
ln target link          # hard link
file f                  # what type is it
stat f                  # all metadata
du -sh dir              # folder size
df -h                   # free disk space
```

## Reading text
```bash
cat f                   # whole short file
less f                  # scroll long file (q to quit)
head -20 f              # first 20 lines
tail -20 f              # last 20 lines
tail -f log             # watch live
wc -l f                 # count lines
diff -u a b             # what changed
cmd | tee out.txt       # save + display
cmd > f                 # write (overwrite)
cmd >> f                # append
cmd 2>&1 | tee log      # stdout+stderr to file and screen
```

## Search
```bash
find . -name "*.log"              # by name
find . -type f -size +10M         # big files
find . -mtime -7                  # changed in last 7 days
find . -name "*.tmp" -delete      # delete matches
grep -rin "error" .               # recursive, case-insensitive, line numbers
grep -v "debug" log               # exclude
grep -c "x" f                     # count
grep -E "a|b" f                   # OR
which cmd                         # where is the binary
```

## Text shaping
```bash
sort f                  # alphabetical
sort -n / -h / -r       # numeric / human / reverse
sort f | uniq -c        # count duplicates
cut -d: -f1 /etc/passwd # column 1
awk '{print $2}' f      # column 2
awk -F, '$3>10' f       # filter rows
sed 's/a/b/g' f         # replace all
sed -i 's/a/b/g' f      # replace in place
tr 'a-z' 'A-Z'          # uppercase
xargs                   # lines -> arguments
```

## Processes
```bash
ps aux                  # all processes
ps aux --sort=-%mem | head    # top memory
pgrep -a name           # find PID
top / htop              # live view
kill PID                # polite stop
kill -9 PID             # force
killall name            # all matching
cmd &                   # background
jobs / fg %1 / bg %1    # job control
Ctrl+C / Ctrl+Z         # interrupt / pause
nohup cmd > out.log 2>&1 &    # survive logout
tmux new -s work        # persistent session
```

## System
```bash
uptime                  # load average
free -h                 # RAM
df -h / df -i           # disk / inodes
uname -a                # kernel
hostnamectl             # OS + host info
lscpu / lsblk / nproc   # CPU / disks / cores
systemctl status svc    # service state
sudo systemctl restart svc
systemctl --failed
journalctl -u svc -n 50
journalctl -xe
crontab -e / -l         # scheduled jobs
```

## Users & permissions
```bash
whoami / id / groups
sudo adduser alice
sudo usermod -aG devs alice     # -a is critical
sudo deluser --remove-home alice
passwd                          # change my password
sudo passwd alice
chmod 644 f      # rw-r--r--
chmod 755 f      # rwxr-xr-x
chmod 600 f      # rw-------
chmod +x script
chmod g+w f
sudo chown alice:devs f
sudo chown -R alice:devs dir
umask                   # default permission mask
chmod g+s dir           # SGID: inherit group
chmod +t dir            # sticky: only owner deletes
sudo -l                 # my sudo rights
namei -l /path          # trace permission of every folder
```

## Networking
```bash
ip -br a                # my IPs
ip r                    # routes / gateway
cat /etc/resolv.conf    # DNS servers
ping -c4 host           # reachability
tracepath host          # path
ss -tulpn               # listening ports
sudo lsof -i :8080      # who owns a port
dig host +short         # resolve
curl -I url             # headers / status
curl -s url | head
wget url
ssh user@host
ssh-keygen -t ed25519
ssh-copy-id user@host
scp file user@host:/path
rsync -av --dry-run src/ user@host:/dst/
sudo ufw status
sudo ufw allow 22/tcp
```

## Packages
```bash
sudo apt update
sudo apt upgrade
sudo apt install pkg
sudo apt remove pkg
sudo apt purge pkg
apt search term
apt show pkg
dpkg -l | grep pkg
dpkg -L pkg             # files of a package
dpkg -S /path           # package owning a file
sudo apt autoremove
```

## Bash scripting
```bash
#!/usr/bin/env bash
set -euo pipefail        # fail fast
name="value"             # no spaces around =
echo "$name"
read -rp "Name: " name
if [[ -f "$f" ]]; then ... fi
for f in *.txt; do ...; done
while read -r line; do ...; done < file
case "$1" in start) ...;; esac
func() { local x=1; echo "$x"; }
$?                       # last exit code
exit 1                   # fail
chmod +x script.sh
bash -n script.sh        # syntax check only
shellcheck script.sh     # best practice linter
```

## Keyboard shortcuts
```bash
Ctrl+C      # stop the running command
Ctrl+Z      # pause it (then bg / fg)
Ctrl+D      # end input / logout
Ctrl+L      # clear screen
Ctrl+R      # search history
Ctrl+A / E  # start / end of line
Ctrl+U / K  # delete to start / end of line
Ctrl+W      # delete previous word
Tab         # autocomplete — use it constantly
!!          # last command
!$          # last argument of last command
```

## The 10 commands that solve most problems
```bash
ls -lah | pwd | cd | cat | less | grep | find | chmod | ps aux | df -h
```
Master these ten and you can already do 80% of daily Linux work.
