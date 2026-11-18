# Network Exercises — Solutions

Outputs vary by machine. What matters is **what each command proves**.

---

## Part 1 — Your network

```bash
ip -br a                                    # 1
# lo UNKNOWN 127.0.0.1/8 ; eth0 UP 192.168.1.42/24

ip a show lo | grep inet                    # 2: 127.0.0.1/8 — "this machine", never leaves it

ip r | grep default                         # 3: default via 192.168.1.1  -> your router

cat /etc/resolv.conf                        # 4
# nameserver 192.168.1.1  (or 127.0.0.53 with systemd-resolved)
resolvectl status | head -20                #    the modern place to look

ip r | grep default                         # 5: "proto dhcp" -> DHCP; "proto static" -> static
ip -4 addr show eth0 | grep -o 'dynamic\|static'

ip route get 8.8.8.8                        # 6: "... dev eth0 src 192.168.1.42"
ip link show eth0 | grep link/ether         #    MAC address

curl -s ifconfig.me                         # 7
# 203.0.113.7   (your public IP — likely shared with your whole household via NAT)

echo "I am $(hostname -I | awk '{print $1}') on the subnet shown by /24, gateway $(ip r | awk '/default/{print $3}'), DNS $(awk '/nameserver/{print $2; exit}' /etc/resolv.conf)."   # 8
```

---

## Part 2 — Reachability

```bash
ping -c 3 127.0.0.1        # 9: loopback works -> the TCP/IP stack itself is fine
ping -c 3 192.168.1.1      # 10: gateway reachable -> your LAN/link works
ping -c 3 1.1.1.1          # 11: internet by IP -> routing + NAT + upstream work
ping -c 3 example.com      # 12: DNS works too (name -> IP)
```

13. Usually the DNS name has slightly higher latency because resolution happens first; or a further
    geographic host has higher RTT.
14. `192.0.2.1` is TEST-NET-1, guaranteed not to be routed:
```
From ... icmp_seq=1 Destination Host Unreachable
```
or it hangs until timeout. Either way, **no reply = no conclusion about the host** — only that packets
are not coming back.

**What each ping proves:**
| Ping | Proves |
|---|---|
| `127.0.0.1` | kernel network stack is up |
| gateway | local link, ARP/DHCP, subnet config correct |
| `8.8.8.8` | default route, NAT, ISP uplink |
| `example.com` | all of the above **plus** DNS |

---

## Part 3 — Routes

```bash
tracepath -m 10 1.1.1.1                     # 15
# 1: 192.168.1.1    0.5ms      <- your router (hop 1 = your LAN)
# 2: 10.20.0.1      8ms        <- ISP CPE
# 3: ...
```
16. Hop 1 is your own network; hop 2–3 is usually the ISP edge. Private addresses (`10.x`, `100.64.x`) in
    the first hops are normal (carrier NAT).

```bash
ip route get 8.8.8.8                        # 17
# 8.8.8.8 via 192.168.1.1 dev eth0 src 192.168.1.42 uid 1000
```

18. A `/24` route says "this network is directly attached, deliver locally"; the default route says "I do
    not know where this goes, hand it to the gateway".

---

## Part 4 — Ports

```bash
ss -tulpn                                   # 19
sudo ss -tulpn | grep '0.0.0.0'             # 20: reachable from any interface
sudo ss -tulpn | grep '127.0.0.1'           # 21: only from this machine
sudo ss -tlnp | grep ':22'                  # 22: usually sshd
```

23/24:
```bash
cd /tmp && python3 -m http.server 8000 &
ss -tlnp | grep 8000        # 0.0.0.0:8000 -> other machines can connect
kill %1

python3 -m http.server 8001 --bind 127.0.0.1 &
ss -tlnp | grep 8001        # 127.0.0.1:8001 -> local only
kill %1
```

25.
```bash
nc -zv github.com 443
# Connection to github.com 443 port [tcp/https] succeeded!
```

26. **Yes, the host is reachable.** "Connection refused" is an immediate, active rejection: the OS
    received the SYN and replied "nothing is listening here". So network is fine; the **service is not
    running** (or is on a different port).

---

## Part 5 — DNS

```bash
dig example.com +short                       # 27
dig example.com | grep -A1 "ANSWER SECTION"  # 28: the number before IN is the TTL in seconds
dig @8.8.8.8 example.com +short              # 29
dig gmail.com MX +short                      # 30
dig wikipedia.org NS +short                  # 31
dig -x 1.1.1.1 +short                        # 32: one.one.one.one
dig thisdoesnotexist-12345.com +short        # 33: empty + status: NXDOMAIN
```

28. TTL = how many seconds a resolver may cache this answer. Low TTL = changes propagate fast; high TTL =
    fewer lookups, slower propagation.

34. `/etc/nsswitch.conf` contains a line like `hosts: files dns`. `files` is first, so **`/etc/hosts` is
    checked before DNS**.

---

## Part 6 — HTTP

```bash
curl -I https://example.com                          # 35: HTTP/2 200
curl -s -o /dev/null -w "%{http_code}\n" https://example.com    # 36: 200

curl -s -o /dev/null -w "dns=%{time_namelookup} connect=%{time_connect} tls=%{time_appconnect} total=%{time_total}\n" https://example.com   # 37
# dns=0.002 connect=0.010 tls=0.030 total=0.040  -> TLS or connect usually dominate; total includes the app

curl -s -o /dev/null -w "%{http_code}\n" https://httpbin.org/status/403   # 38: 403
curl -s -o /dev/null -w "%{http_code}\n" https://httpbin.org/status/404   #     404

curl -s https://httpbin.org/json | head -15          # 39: keys like "slideshow", "author", "title"
```

40. **403 Forbidden** — the server understood you and refuses (permissions, IP allow-list). **404 Not
    Found** — there is no resource at that path (or the server hides its existence).

41. Local server: `/missing` returns `404`; the request line appears in the terminal running
    `http.server` — that is an access log being written in real time.

42.
```
* SSL certificate verify ok.
```
(or `* TLSv1.3 (IN), TLS handshake, Finished`). That line means the certificate chain and hostname checked
out; everything after is encrypted.

---

## Part 7 — Troubleshooting reasoning

**43.** Step 5 (DNS) is broken. First two commands:
```bash
dig example.com +short
dig @1.1.1.1 example.com +short     # isolates "my resolver" vs "the domain"
```

**44.** Two most likely causes:
1. The service is listening on `127.0.0.1` only (`ss -tlnp` shows that), not `0.0.0.0`.
2. A firewall is dropping inbound 8080 — local `ufw`, or a cloud security group.

**45.** `refused` = host replied instantly, nothing on that port → **service down, network fine**.
`timed out` = no reply at all → **packets dropped** (firewall, wrong host, host offline). Refused is
usually a much easier fix.

**46.**
```bash
history | tail -30            # what changed?
journalctl --since yesterday -p err
df -h                         # full disk breaks services
systemctl --failed
```

**47.** Try:
```bash
dig @1.1.1.1 example.com +short     # is it my resolver or the domain?
resolvectl flush-caches             # stale/broken cache
```
Also check `resolvectl status` for a reachable upstream, and try a different resolver. `SERVFAIL` often
means DNSSEC validation failed or the authoritative servers are down.

**48.**
```
1 ip -br a          2 ip r (default)      3 ping gateway
4 ping 8.8.8.8      5 ping + dig name     6 nc -zv host port
7 ss -tulpn         8 curl -v url
```

---

## Part 8 — Stretch

49. `dig` comes from the **`dnsutils`** package (on newer Debian/Ubuntu it may be `bind9-dnsutils`).
    ```bash
    dpkg -S $(which dig)
    ```
50.
```bash
sudo tcpdump -i any -nn icmp -c 5
# in another terminal: ping -c 5 1.1.1.1
# you see "echo request" and "echo reply" pairs
```
51/52. See `05-ssh-and-remote-access.md`, "Practice" section.

---

## The three things to remember

1. **Ping by IP, then by name.** That single pair separates routing from DNS.
2. **`ss -tulpn` shows `0.0.0.0` vs `127.0.0.1`.** That single distinction explains "works locally, not
   remotely".
3. **"Refused" and "timed out" are different diagnoses.** Read the error literally.
