# 07 — Networking: Command Reference

**The idea:** your computer talks to other computers using addresses (IP), names (DNS), and doors
(ports). These commands let you look at that traffic, test it, and fix it.

Concept explanations are in `05-network-basics/`. This is the toolbox.

---

## My own network

```bash
$ ip a                        # all interfaces and IP addresses
$ ip -br a                    # brief, one line per interface
$ ip r                        # routing table + default gateway
$ ip route get 8.8.8.8        # which interface would carry this traffic?
$ hostname -I                 # my IP addresses, space separated
$ hostname -f                 # my fully qualified name
$ cat /etc/resolv.conf        # my DNS servers
$ ip link                     # interface states (UP/DOWN)
```

Reading `ip a` (the important parts):
```
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.1.42/24 brd 192.168.1.255 scope global dynamic eth0
```
- `UP` — interface is enabled
- `inet 192.168.1.42/24` — my address and subnet size
- `/24` means the first 24 bits are the network → `255.255.255.0`

```bash
$ sudo ip link set eth0 down     # disable (you will lose network!)
$ sudo ip link set eth0 up       # re-enable
$ sudo ip addr add 10.0.0.5/24 dev eth0   # temporary extra IP
```

---

## Testing connectivity

```bash
$ ping -c 4 8.8.8.8           # 4 pings. Ctrl+C stops a running ping
$ ping -c 4 google.com        # tests DNS + routing together
$ ping -c 4 192.168.1.1       # my router
```
Reading ping output:
- `time=12.3 ms` → latency. Under 50 ms locally is fine.
- `100% packet loss` → no answer at all
- `Destination Host Unreachable` → routing problem, not the remote host

`ping` may be blocked by firewalls even when the service works. Do not treat a failed ping as proof
that a website is down — try `curl` too.

### `traceroute` — the path
```bash
$ traceroute google.com              # may need: sudo apt install traceroute
$ tracepath google.com               # usually pre-installed
$ mtr -rw google.com                 # combine ping + traceroute (apt install mtr)
```
Where the `* * *` starts is roughly where the path breaks.

### `nc` — netcat, test a specific port
```bash
$ nc -zv 192.168.1.10 22        # can I open port 22?
$ nc -zv example.com 443
$ nc -l 9000                    # listen on 9000 (in another terminal: nc localhost 9000)
```

---

## Ports and listening services

```bash
$ ss -tulpn            # TCP+UDP listening sockets with process names (-p needs sudo)
$ ss -tunap            # all connections (not just listening)
$ ss -tlnp | grep :22  # who is on port 22?
$ sudo lsof -i :8080   # which process owns port 8080
```

Reading `ss -tulpn`:
```
Netid State  Local Address:Port   Process
tcp   LISTEN 0.0.0.0:22            users:(("sshd",pid=812,fd=3))
tcp   LISTEN 127.0.0.1:5432        users:(("postgres",pid=1200,fd=5))
```
- `0.0.0.0` means **all** interfaces → reachable from outside
- `127.0.0.1` means **only this machine** → not reachable from outside

That difference answers half of all "why can't I connect?" questions.

### Common ports to memorize
| Port | Service |
|---|---|
| 22 | SSH |
| 80 | HTTP |
| 443 | HTTPS |
| 53 | DNS |
| 21 | FTP (old, avoid) |
| 25 / 587 | SMTP mail |
| 3306 | MySQL/MariaDB |
| 5432 | PostgreSQL |
| 6379 | Redis |
| 8080 | common alternate HTTP / app server |
| 27017 | MongoDB |

---

## Names: DNS tools

```bash
$ dig example.com                 # full DNS answer
$ dig example.com +short          # just the IP
$ dig example.com MX +short       # mail servers
$ dig @8.8.8.8 example.com        # ask a specific DNS server
$ nslookup example.com            # simpler tool (may need dnsutils)
$ host example.com
$ cat /etc/hosts                  # local overrides, checked BEFORE DNS
$ getent hosts example.com        # respects /etc/hosts + DNS
```

`dig` sections:
- `ANSWER SECTION` — the records you want
- `SERVER:` — which DNS server answered
- `status: NXDOMAIN` — the name does not exist
- `status: SERVFAIL` — the server had a problem

---

## Fetching things: `curl` and `wget`

```bash
$ curl https://example.com                    # print the page to the screen
$ curl -I https://example.com                 # HEADERS only (status code, content type)
$ curl -o page.html https://example.com       # save to file
$ curl -L https://example.com                 # follow redirects
$ curl -s https://api.github.com | head       # silent mode, good for APIs
$ curl -X POST -d '{"name":"alice"}' -H 'Content-Type: application/json' http://localhost:3000/users
$ curl -u user:pass http://localhost:8080     # basic auth
$ curl --connect-timeout 5 http://host        # do not hang forever

$ wget https://example.com/file.zip           # download to disk, shows progress
$ wget -c https://example.com/big.iso         # resume a partial download
```

`curl -I` is the fastest way to test "is this URL alive?" — look for `HTTP/2 200`.

---

## Remote access

### `ssh` — secure shell
```bash
$ ssh alice@192.168.1.10              # log in
$ ssh -p 2222 alice@host              # non-default port
$ ssh -i ~/.ssh/mykey alice@host      # specific private key
$ ssh -v alice@host                   # verbose: debug why login fails
$ ssh alice@host "df -h"              # run one remote command and return
$ ssh -L 8080:localhost:80 alice@host # port forward: local 8080 -> remote 80
```

### SSH keys (do this once, save hours)
```bash
$ ssh-keygen -t ed25519 -C "student@laptop"    # create a key pair
$ ssh-copy-id alice@192.168.1.10               # install the public key on the server
$ ssh alice@192.168.1.10                       # now no password needed
```
Your keys live in `~/.ssh/`: `id_ed25519` (private, `600`, **never share**) and `id_ed25519.pub`
(public, safe to share).

### `scp` and `rsync` — copy over the network
```bash
$ scp file.txt alice@host:/home/alice/         # upload a file
$ scp alice@host:/var/log/app.log .            # download a file
$ scp -r folder/ alice@host:/tmp/              # upload a folder

$ rsync -av folder/ alice@host:/backup/        # archive + verbose (best for sync)
$ rsync -avz --delete folder/ host:/backup/    # compress, and delete extras on target
$ rsync -av --dry-run folder/ host:/backup/    # SEE what would happen — always try this first
$ rsync -av --progress big.iso host:/data/     # show progress
```
`rsync` is better than `scp` for anything bigger than a few files: it only transfers differences.

---

## Firewall (Ubuntu: `ufw`)

```bash
$ sudo ufw status verbose        # current rules
$ sudo ufw enable                # turn on
$ sudo ufw allow 22/tcp          # allow SSH (do this BEFORE enabling, or you lock yourself out)
$ sudo ufw allow 80,443/tcp
$ sudo ufw deny 3306/tcp
$ sudo ufw delete allow 80/tcp
$ sudo ufw allow from 192.168.1.0/24 to any port 22
```

⚠️ On a **remote** server: always `sudo ufw allow 22/tcp` and verify SSH still works in a second
terminal **before** you close the first one.

---

## Practice lab (safe, read-only tasks)

1. Show all your interfaces with their IP addresses in brief form.
2. What is your default gateway? What is your DNS server?
3. Ping `8.8.8.8` four times. Then ping `google.com` four times. Which proves DNS works?
4. Trace the route to `1.1.1.1` (first 10 hops).
5. List all listening TCP ports on your machine.
6. Find the process listening on port 22, if any.
7. Resolve `github.com` and show only the IP.
8. Fetch the headers of `https://example.com`. What status code came back?
9. Test whether `github.com:443` is reachable with `nc -zv`.
10. Show what `/etc/hosts` currently contains and explain when it wins over DNS.

<details>
<summary>Answers</summary>

```bash
ip -br a                                        # 1
ip r | grep default                             # 2a
cat /etc/resolv.conf                            # 2b
ping -c 4 8.8.8.8; ping -c 4 google.com         # 3: google.com tests DNS
tracepath -m 10 1.1.1.1                         # 4
ss -tlnp                                        # 5
sudo ss -tlnp | grep :22                        # 6
dig github.com +short                           # 7
curl -I https://example.com                     # 8: HTTP/2 200
nc -zv github.com 443                           # 9
cat /etc/hosts                                  # 10: checked before DNS
```
</details>

---

## Debugging order for "I can't reach it"

Always go up the layers. Stop at the first step that fails.

```bash
ip a                        # 1. Do I have an IP?
ip r                        # 2. Do I have a default gateway?
ping -c2 192.168.1.1        # 3. Can I reach the gateway?
ping -c2 8.8.8.8            # 4. Can I reach the internet by IP?
ping -c2 google.com         # 5. Does DNS work?
nc -zv host 443             # 6. Is the port open?
curl -v https://host        # 7. Does the application answer?
```

More in `05-network-basics/07-troubleshooting-playbook.md`.
