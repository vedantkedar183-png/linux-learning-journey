# 05 — SSH and Remote Access

## What SSH is

**SSH (Secure Shell)** gives you an encrypted terminal on another machine. It is *the* way you administer
Linux servers. Every cloud VM you ever launch will be reached with `ssh`.

What it protects: your password or key, every keystroke, and all output — encrypted end to end. An
unencrypted equivalent (`telnet`, `rlogin`) is unsafe and obsolete.

```
your laptop  ── encrypted tunnel (TCP 22) ──▶  server
   ssh client                                    sshd daemon
```

---

## Your first connection

```bash
$ ssh student@192.168.1.50
The authenticity of host '192.168.1.50' can't be established.
ED25519 key fingerprint is SHA256:abc123...
Are you sure you want to continue connecting (yes/no)?
```

- Type **yes** the first time. That fingerprint is stored in `~/.ssh/known_hosts` so you notice if it ever
  changes (a possible man-in-the-middle).
- If it changes legitimately (you reinstalled the server), remove the old entry:
  ```bash
  $ ssh-keygen -R 192.168.1.50
  ```

```bash
$ ssh student@host              # log in
$ ssh -p 2222 student@host      # non-default port
$ ssh student@host "uptime"     # run one command, no interactive shell
$ ssh -v student@host           # verbose: shows exactly where connection fails
$ exit                          # leave
```

---

## SSH keys: better than passwords

A key pair is two files:
- **private key** (`id_ed25519`) — stays on your machine, permissions `600`, never copied anywhere.
- **public key** (`id_ed25519.pub`) — safe to share; you paste it into the server's
  `~/.ssh/authorized_keys`.

The server challenges you; your private key answers mathematically. The private key never crosses the
network.

```bash
$ ssh-keygen -t ed25519 -C "student@laptop"
$ ls -l ~/.ssh/
-rw-------  id_ed25519        # private — 600
-rw-r--r--  id_ed25519.pub    # public  — 644

$ ssh-copy-id student@192.168.1.50     # install the public key on the server
$ ssh student@192.168.1.50             # now no password prompt
```

Manual equivalent (when `ssh-copy-id` is unavailable):
```bash
$ cat ~/.ssh/id_ed25519.pub | ssh student@host \
    'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

### Permissions SSH enforces
| Path | Must be |
|---|---|
| `~/.ssh` | `700` |
| `~/.ssh/authorized_keys` | `600` |
| private key | `600` |

Wrong permissions → "UNPROTECTED PRIVATE KEY FILE" → SSH refuses to use the key. This is a feature: it
stops other users from reading or swapping your key.

---

## `~/.ssh/config`: the productivity multiplier

Instead of `ssh -p 2222 -i ~/.ssh/workkey alice@203.0.113.45`, write:

```
# ~/.ssh/config
Host work
    HostName 203.0.113.45
    User alice
    Port 2222
    IdentityFile ~/.ssh/workkey
    ServerAliveInterval 60

Host lab
    HostName 192.168.1.50
    User student
```

Then just:
```bash
$ ssh work
$ scp file.txt work:/tmp/
```
`chmod 600 ~/.ssh/config` is recommended. This file is the single biggest quality-of-life upgrade for
anyone managing more than one server.

---

## Copying files: `scp` and `rsync`

```bash
$ scp file.txt alice@host:/home/alice/          # upload
$ scp alice@host:/var/log/app.log .             # download to current dir
$ scp -r folder/ alice@host:/tmp/               # upload a folder
$ scp -P 2222 file.txt alice@host:/tmp/         # note: capital -P for scp
```

```bash
$ rsync -av folder/ alice@host:/backup/         # archive, verbose (best for sync)
$ rsync -avz --progress folder/ host:/backup/   # compress + progress
$ rsync -av --delete folder/ host:/backup/      # make destination match exactly
$ rsync -av --dry-run --delete folder/ host:/backup/   # DRY RUN FIRST. Always.
```

**Trailing slash rule:** `rsync -a src/ dst/` copies the *contents*; `rsync -a src dst/` creates
`dst/src`. This one character has confused everyone at least once.

Why `rsync` beats `scp` for real work: it transfers only changed blocks, can resume, can exclude patterns,
and can verify. For anything more than a few files, use `rsync`.

---

## Port forwarding: reach services you cannot reach directly

### Local forward: my port → remote service
```bash
$ ssh -L 8080:localhost:80 alice@host
```
Now `http://localhost:8080` on **your** machine talks to port 80 on the **server**. Great for:
- accessing a database bound to `127.0.0.1` on the server,
- testing an internal web app through a bastion host.

### Remote forward: server port → my service
```bash
$ ssh -R 9000:localhost:3000 alice@host
```
The server's `localhost:9000` now reaches port 3000 on your laptop. Useful for receiving webhooks during
development.

### Dynamic (SOCKS proxy)
```bash
$ ssh -D 1080 alice@host
```
Then configure your browser to use `localhost:1080` as a SOCKS proxy — traffic egresses from the server.

---

## Keeping sessions alive

SSH sessions die when the network blips or your laptop sleeps. Solutions:

```bash
# 1. Client keepalive (in ~/.ssh/config)
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3

# 2. tmux on the server — the real answer
$ tmux new -s work
$ # ... do work; if disconnected:
$ tmux attach -t work
```
`tmux` survives disconnects because the shell keeps running on the server. Use it for anything longer than
a minute.

---

## Hardening `sshd` (server side)

```bash
$ sudo nano /etc/ssh/sshd_config
```
Recommended changes, in order of value:
```ini
PermitRootLogin no                 # never allow direct root login
PasswordAuthentication no          # keys only (do this AFTER keys work!)
PubkeyAuthentication yes
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no                   # unless you need GUI apps
AllowUsers alice bob               # optional allow-list
```

```bash
$ sudo sshd -t                     # validate the config before restarting
$ sudo systemctl reload ssh         # apply
```

⚠️ **The order matters:** install your key and verify a key login in a second terminal **before**
disabling password auth. Otherwise you lock yourself out. Never close your working session until the new
one is confirmed.

### Fail2ban (blocks brute force)
```bash
$ sudo apt install fail2ban
$ sudo systemctl enable --now fail2ban
$ sudo fail2ban-client status sshd
```

### Firewall
```bash
$ sudo ufw allow 22/tcp
$ sudo ufw enable
$ sudo ufw status verbose
```

---

## SSH troubleshooting table

| Symptom | Likely cause | Check |
|---|---|---|
| `Connection refused` | sshd not running / wrong port | `systemctl status ssh`, `ss -tlnp \| grep :22` |
| `Connection timed out` | firewall or wrong IP | `nc -zv host 22`, cloud security group |
| `Permission denied (publickey)` | key not in `authorized_keys`, wrong user, bad permissions | `ssh -v`, check `~/.ssh` perms |
| `UNPROTECTED PRIVATE KEY FILE` | key is `644` | `chmod 600 key` |
| `Host key verification failed` | server reinstalled | `ssh-keygen -R host` |
| Prompts for password despite key | `PasswordAuthentication` order, or key rejected | `ssh -vv` and read which key is offered |
| `Too many authentication failures` | too many keys offered | `ssh -i ~/.ssh/thekey -o IdentitiesOnly=yes` |

**The universal first step: `ssh -v user@host`** and read the last 10 lines. It tells you exactly which
stage failed: DNS, TCP, key exchange, authentication.

---

## Practice

Without a second machine, use `localhost` (if `sshd` is installed) or your VM's IP.

1. Check whether SSH is running: `systemctl status ssh` and `ss -tlnp | grep :22`.
2. If not installed: `sudo apt install openssh-server`.
3. Generate a key pair with `ssh-keygen -t ed25519`.
4. Copy it to `localhost`: `ssh-copy-id $USER@localhost`.
5. Log in to `localhost` without a password.
6. Create `~/.ssh/config` with a `Host lab` entry for `localhost`, then `ssh lab`.
7. Copy a file to `localhost` with `scp` and with `rsync`.
8. Open a local port forward and fetch something through it with `curl`.
9. Set up `tmux`, start a `sleep 600`, detach, list sessions, reattach, kill it.
10. Explain why `PasswordAuthentication no` should only be set after testing key login.

<details>
<summary>Answers / key points</summary>

3–5. `ssh-keygen -t ed25519 -C "lab"`, then `ssh-copy-id localhost`; test with
   `ssh -i ~/.ssh/id_ed25519 localhost whoami`.
8. `ssh -L 8080:localhost:22 localhost` then `nc -zv localhost 8080` should succeed.
9. `tmux new -s t`, `sleep 600`, `Ctrl+B` then `D`, `tmux ls`, `tmux attach -t t`, `Ctrl+C`, `exit`.
10. Because if key auth is not actually working, disabling passwords removes your only way in — you would
    need console/rescue access to fix it.
</details>
