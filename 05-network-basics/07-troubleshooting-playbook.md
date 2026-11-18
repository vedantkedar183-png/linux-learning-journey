# 07 — The Network Troubleshooting Playbook

The professional skill is not knowing many commands. It is **checking things in the right order**, so you
find the broken layer in 2 minutes instead of 2 hours.

Always go **bottom-up**. Stop at the first failing step. Everything above it is innocent.

---

## The 8 steps

```bash
# 1. Is the interface up and does it have an IP?
ip -br a

# 2. Is there a default gateway?
ip r | grep default

# 3. Can I reach the gateway?
ping -c 2 $(ip r | awk '/default/ {print $3}')

# 4. Can I reach the internet by IP?
ping -c 2 8.8.8.8

# 5. Does DNS work?
ping -c 2 example.com
dig example.com +short

# 6. Is the port open?
nc -zv <host> <port>

# 7. Is a local service listening, and where?
ss -tulpn | grep <port>

# 8. Does the application answer?
curl -v <url>
```

---

## What each failure means

| Fails at | Meaning | Next actions |
|---|---|---|
| 1 | No link / no IP | Wi-Fi connected? `ip link` shows DOWN? DHCP failed? Try `sudo dhclient -v` |
| 2 | No route | no default gateway; static config wrong |
| 3 | Cannot reach gateway | cable/Wi-Fi/VLAN problem; wrong subnet mask; router off |
| 4 | Gateway OK, internet not | ISP/router issue; check another device; check router WAN |
| 5 | IP works, names fail | **DNS problem** — see `04-dns.md` |
| 6 | Name resolves, port closed | firewall, wrong port, or service bound to `127.0.0.1` |
| 7 | Nothing listening locally | service not started; wrong config; wrong port |
| 8 | Port open, app errors | app bug, bad config, upstream down → read the app log |

---

## The one question that solves half of them

> **"Does it work from the machine itself?"**

```bash
# on the server
$ curl -I http://localhost:8080
```

| Result | Conclusion |
|---|---|
| Works locally, fails remotely | **network path**: firewall, binding address, NAT, security group |
| Fails locally too | **the service itself**: not running, wrong config, crashed |

That single test splits the entire problem space in two. Do it first when someone says "the site is
down".

---

## Real-world scenarios

### "I can't reach the website"
```bash
$ ping -c2 1.1.1.1              # internet at all?
$ dig example.com +short        # DNS?
$ nc -zv example.com 443        # port?
$ curl -vI https://example.com  # app/TLS?
```

### "The site is slow"
```bash
$ curl -s -o /dev/null -w "dns=%{time_namelookup} connect=%{time_connect} tls=%{time_appconnect} total=%{time_total}\n" https://example.com
$ mtr -rw -c 10 example.com     # where are the delays?
$ ping -c 10 example.com        # latency and loss
```
- high `time_namelookup` → DNS is slow
- high `time_connect` → network path is slow
- high `time_appconnect` → TLS handshake is slow
- high `time_total` but low others → the server/application is slow

### "Connection refused"
Fast failure, host is up. Nothing is listening on that port.
```bash
$ ss -tulpn | grep :8080        # on the server
$ sudo systemctl status <app>
$ sudo journalctl -u <app> -n 50
```
Check the **bind address**: `127.0.0.1:8080` cannot be reached from another machine.

### "Connection timed out"
Slow failure. Packets are being dropped, not rejected.
```bash
$ nc -zv host 22                # times out
$ sudo ufw status               # local firewall
$ tracepath host                # where do packets stop?
$ ping -c 4 host                # ICMP blocked is common — not conclusive
```
Typical causes: cloud security group without an inbound rule, ISP blocking, server firewall `DROP`.

### "Permission denied (publickey)" over SSH
```bash
$ ssh -v user@host              # read which key is offered/rejected
$ ls -ld ~/.ssh; ls -l ~/.ssh/authorized_keys   # 700 / 600
$ tail -n 20 /var/log/auth.log                   # on the server
```

### "It worked yesterday"
```bash
$ history | tail -30            # what did I change?
$ journalctl --since yesterday -p err
$ systemctl --failed
$ df -h                         # disk full breaks everything
$ free -h                       # OOM kills look like random failures
```
The most common cause of "it worked yesterday" is a change you made. The second most common is a full
disk.

---

## Command cheat map

| Symptom | First command |
|---|---|
| nothing works | `ip -br a` |
| can't reach anything outside | `ip r` |
| names fail | `dig example.com +short` |
| port closed | `ss -tulpn` (server), `nc -zv` (client) |
| web error | `curl -v` and the server's `error.log` |
| slow | `curl -w` timings, `mtr` |
| service crashed | `journalctl -u <svc> -n 50` |
| disk/RAM | `df -h`, `free -h` |
| who changed what | `history`, `journalctl`, `/var/log/auth.log` |

---

## Five habits of good network debuggers

1. **Change one thing at a time.** Two changes = no information.
2. **Test from both ends.** Client and server.
3. **Read the error literally.** "Connection refused" is not "host unreachable".
4. **Write down what you tried.** Memory lies under stress.
5. **Say the layer out loud.** "I am testing layer 3 now." It keeps you from jumping to DNS when the cable
   is unplugged.

---

## Practice

Set up a failure and diagnose it. In a VM (never on your only connection):

1. Stop a service (`sudo systemctl stop nginx` or your test server) and diagnose with the 8 steps. Which
   step fails and with which message?
2. Bind a test server to `127.0.0.1` only, then try to reach it from another machine. Which step fails?
   What does `ss` show?
3. Break DNS: temporarily set a bogus nameserver. Which steps still pass? Which fail?
4. Fill a small filesystem (in a VM) and observe which services fail. Why do full disks look like network
   problems?
5. Explain why `ping` failing while `nc` succeeds is possible.

<details>
<summary>Answers</summary>

1. Steps 1–5 pass; step 6/7 fails. `nc` reports "Connection refused" (fast, host up). Locally, step 7
   shows nothing listening.
2. `ss` shows `127.0.0.1:<port>`; from another machine `nc` times out or is refused. The binding address is
   the culprit.
3. Steps 1–4 pass; step 5 fails with "Temporary failure in name resolution" or `SERVFAIL`.
4. Logs cannot be written, sockets cannot be created, databases cannot write temp files → services crash
   or hang, which looks exactly like network failure. Always check `df -h`.
5. ICMP (`ping`) is often blocked by firewalls while TCP ports are open. `ping` failing is not proof of a
   network problem.
</details>
