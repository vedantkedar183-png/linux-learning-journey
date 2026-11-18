# 03 — Network Commands in Practice

Run every command in this lesson as you read. They are all read-only and safe.

---

## 1. What is my network?

```bash
$ ip -br a
lo        UNKNOWN  127.0.0.1/8
eth0      UP       192.168.1.42/24
```

```bash
$ ip a                       # detailed: MAC, MTU, state, addresses
$ ip r                       # routes: find the "default via" line
$ ip route get 8.8.8.8       # which interface/source will be used?
8.8.8.8 via 192.168.1.1 dev eth0 src 192.168.1.42 uid 1000
$ cat /etc/resolv.conf       # DNS servers
nameserver 192.168.1.1
$ hostname -I                # all my IPv4 addresses on one line
$ curl -s ifconfig.me; echo # my public IP as the internet sees me
```

**Exercise:** in one sentence, describe your network: "I am `192.168.1.42` on a `/24`, my gateway is
`192.168.1.1`, my DNS is `192.168.1.1`."

---

## 2. Can I reach it? (`ping`)

```bash
$ ping -c 4 127.0.0.1        # loopback: proves the stack works at all
$ ping -c 4 192.168.1.1      # gateway: proves the LAN works
$ ping -c 4 8.8.8.8          # internet by IP: proves routing works
$ ping -c 4 google.com       # internet by name: proves DNS works
```

Reading the output:
```
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=12.4 ms
```
- `time` — round-trip latency. `< 50 ms` is fine; `> 200 ms` feels slow.
- `ttl` — remaining hop budget. Rough OS guess: 64 Linux, 128 Windows.
- `4 packets transmitted, 4 received, 0% packet loss` — the summary that matters.
- `Destination Host Unreachable` — a routing/ARP problem, not the remote host.
- `Request timeout` — something is dropping packets (firewall, offline host).

**Important:** many servers and networks block ICMP. A failed ping does **not** prove the service is down.
Always confirm with `curl` or `nc`.

---

## 3. What path does traffic take? (`tracepath`, `traceroute`)

```bash
$ tracepath -m 10 1.1.1.1
 1?: [LOCALHOST]    pmtu 1500
 1:  192.168.1.1      0.512ms
 2:  10.20.0.1        8.221ms
 3:  ...
```

```bash
$ traceroute google.com          # needs: sudo apt install traceroute
$ mtr -rw -c 5 google.com        # combined ping + trace, best for diagnosis
```
Where `* * *` begins is roughly where the path stops responding. It can also mean "this router does not
reply to TTL expiry" — not necessarily a failure.

---

## 4. What is listening? (`ss`, `lsof`)

```bash
$ ss -tulpn
Netid State  Local Address:Port   Process
tcp   LISTEN 0.0.0.0:22            users:(("sshd",pid=812,fd=3))
tcp   LISTEN 127.0.0.1:5432        users:(("postgres",pid=1200,fd=5))
udp   UNCONN 127.0.0.53:53         users:(("systemd-resolve",pid=700,fd=13))
```

Flags: `-t` TCP, `-u` UDP, `-l` listening, `-p` process (needs sudo for other users), `-n` numeric (no
DNS lookups — much faster).

**The most important distinction in this whole module:**

| You see | Meaning |
|---|---|
| `0.0.0.0:8080` or `[::]:8080` | listening on **all** interfaces → reachable from other machines |
| `127.0.0.1:8080` | listening on **localhost only** → only this machine can connect |

If a service "works locally but not from another machine", it is almost always bound to `127.0.0.1`.

```bash
$ sudo lsof -i :8080        # who owns this port?
$ sudo ss -tlnp | grep :80
$ ss -tan | head -20        # current TCP connections and states
```

### TCP states you will see
| State | Meaning |
|---|---|
| `LISTEN` | waiting for connections |
| `ESTAB` | connected and active |
| `TIME-WAIT` | closed, waiting briefly to catch late packets |
| `CLOSE-WAIT` | the app has not closed its side (a bug/leak if it accumulates) |
| `SYN-SENT` | we asked, no reply yet (firewall or dead host) |

---

## 5. Is a specific port open? (`nc`, `curl`)

```bash
$ nc -zv 192.168.1.10 22
Connection to 192.168.1.10 22 port [tcp/ssh] succeeded!

$ nc -zv example.com 443
$ nc -zv -w 3 example.com 8080     # 3 second timeout
```

Different failures mean different things:
| Message | Meaning |
|---|---|
| `succeeded` | something is listening and reachable |
| `Connection refused` | host is up, nothing listening on that port (fast failure) |
| `timed out` | packets dropped by a firewall, or host offline |
| `No route to host` | routing problem |

`Connection refused` is **good news** in disguise: the network path works, the service is just not running.

---

## 6. Fetching and testing HTTP (`curl`, `wget`)

```bash
$ curl -I https://example.com
HTTP/2 200
content-type: text/html; charset=UTF-8
cache-control: max-age=86000
```

```bash
$ curl -s https://example.com | head -20        # page source
$ curl -L https://example.com                   # follow redirects
$ curl -o page.html https://example.com         # save
$ curl -s -o /dev/null -w "%{http_code}\n" https://example.com   # just the status code
$ curl -v https://example.com 2>&1 | head -20   # verbose: DNS, connect, TLS, request
$ curl --connect-timeout 5 --max-time 10 https://slow.example.com
$ curl -s ifconfig.me                            # your public IP
$ curl -s https://api.github.com | head -20      # JSON API
```

`curl -v` output is the single best debugging tool for web problems. Read it top to bottom:
```
* Trying 93.184.216.34:443...      ← DNS resolved, connecting
* Connected to example.com         ← TCP works
* SSL certificate verify ok.       ← TLS works
> GET / HTTP/2                     ← request sent
< HTTP/2 200                       ← response received
```

```bash
$ wget https://example.com/file.zip      # download with progress bar
$ wget -c https://example.com/big.iso    # resume
$ wget -q -O - https://example.com | head
```

---

## 7. Logs and traffic counts

```bash
$ ip -s link show eth0        # packets/bytes in and out, plus errors
$ nstat -az | head            # kernel network counters
$ sudo tcpdump -i any -c 10 port 80     # capture 10 packets (needs sudo)
$ sudo tcpdump -i any -nn -c 5 'icmp'   # watch pings
```
`tcpdump` proves whether packets are actually arriving. If you see `SYN` going out and nothing coming
back, the problem is upstream, not in your app.

---

## 8. Common commands, one table

| Question | Command |
|---|---|
| What is my IP? | `ip -br a` |
| What is my gateway? | `ip r` |
| What is my DNS? | `cat /etc/resolv.conf` |
| Is the host up? | `ping -c 4 <host>` |
| Where does the path break? | `tracepath <host>` |
| Is the port open? | `nc -zv <host> <port>` |
| Who is listening? | `ss -tulpn` |
| Who owns this port? | `sudo lsof -i :<port>` |
| Does the web app answer? | `curl -I <url>` |
| Why is it failing? | `curl -v <url>` |
| What is being sent? | `sudo tcpdump -i any -nn` |

---

## Practice sequence (do it now)

```bash
ip -br a
ip r | head -3
cat /etc/resolv.conf
ping -c 3 127.0.0.1
ping -c 3 $(ip r | awk '/default/ {print $3}')
ping -c 3 1.1.1.1
ping -c 3 example.com
ss -tulpn
curl -I https://example.com
curl -s -o /dev/null -w "status=%{http_code} time=%{time_total}s\n" https://example.com
```

Write down, for each command, **what it proved**. If you can do that, you can debug a network.

More practice: `exercises.md`.
