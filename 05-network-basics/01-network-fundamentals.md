# 01 — Network Fundamentals

## The problem networking solves

Your computer needs to send data to another computer it has never met, over wires and radios owned by
strangers, and have it arrive intact. Networking is the set of agreements that make that possible.

Three questions must always be answered:
1. **Where is the destination?** → addressing (IP)
2. **How do I get there?** → routing
3. **Which program should receive it?** → ports

---

## Hosts, clients, servers

- **Host** — any device with an IP address: laptop, phone, server, printer, smart bulb.
- **Client** — the host that *asks*: your browser.
- **Server** — the host that *answers*: the web server.

These are roles, not machines. The same laptop is a client when browsing and a server when you run
`python3 -m http.server`.

```
CLIENT                                SERVER
browser  ──request──▶  network  ──▶  nginx :443
         ◀──response──         ◀──
```

## Packets: everything travels in pieces

Data is chopped into **packets** (small chunks with an address label). Packets from many applications
share the same cable. This is why:
- a download does not block your SSH session,
- one lost packet does not destroy the whole transfer (TCP retransmits it),
- your network usage is "bursty" rather than continuous.

A packet's header carries: source IP, destination IP, protocol, source port, destination port, sequence
info, checksums.

---

## Ports: many conversations, one address

One IP address can host hundreds of services. Ports (0–65535) separate them.

| Port | Service | Notes |
|---|---|---|
| 22 | SSH | remote shell |
| 80 | HTTP | web, unencrypted |
| 443 | HTTPS | web, encrypted |
| 53 | DNS | name lookup (TCP + UDP) |
| 25/587 | SMTP | sending mail |
| 3306 | MySQL | database |
| 5432 | PostgreSQL | database |
| 6379 | Redis | cache |
| 8080 | HTTP alt | app servers, proxies |

A **listening** port is a program waiting for connections. That is why `ss -tulpn` is the first command
when "something is not reachable": it shows what is actually waiting.

Ports below 1024 are **privileged** — only root can bind them. That is why web servers start as root and
then drop to a normal user.

---

## Protocols: the languages

| Protocol | Transport | Used for | Key property |
|---|---|---|---|
| **TCP** | connection-oriented | web, SSH, mail, databases | reliable, ordered, slower setup |
| **UDP** | connectionless | DNS, video, games, VoIP | fast, no guarantee |
| **ICMP** | — | `ping`, error messages | diagnostic |
| **HTTP/HTTPS** | TCP | web | request/response text |
| **SSH** | TCP | remote shells, file copy | encrypted |
| **DNS** | mostly UDP | name resolution | small query/answer |

**TCP vs UDP in one line each:** TCP tells the sender "I got piece 5, resend piece 6"; UDP just fires and
forgets. DNS uses UDP because a lost query can simply be asked again.

### The handshake you will see in logs: TCP three-way handshake
```
client → server : SYN
server → client : SYN-ACK
client → server : ACK            # connection established
```
After that: data, then `FIN`/`ACK` to close. Firewalls commonly drop the `SYN`, which shows up as
"connection timed out" rather than "refused".

---

## Layers, in plain language

You do not need to memorise OSI, but the idea is useful: each layer solves one problem and hands the
result to the next.

| Layer | Job | Examples |
|---|---|---|
| Application | what the data *means* | HTTP, SSH, DNS |
| Transport | which program, reliable or not | TCP, UDP, ports |
| Internet | addressing and routing | IP, ICMP |
| Link | the actual wire/radio | Ethernet, Wi-Fi, ARP |

Debugging works **bottom-up**: is the cable/Wi-Fi up? Do I have an IP? Can I reach the gateway? Can I
reach the internet? Does DNS work? Is the port open? Does the app answer? That order is the whole of
`07-troubleshooting-playbook.md`.

---

## LAN vs WAN vs the internet

- **LAN** (Local Area Network) — your home/office network, e.g. `192.168.1.0/24`. Fast, private.
- **WAN** — connects LANs over distance, usually via an ISP.
- **Internet** — the network of networks, glued together by **BGP** (routers telling each other which IP
  ranges they can reach).

Your home router is the border: inside it hands out private IPs with **DHCP**, and outside it has one
public IP with **NAT**.

## Public vs private IPs

| Range | Class | Where used |
|---|---|---|
| `10.0.0.0/8` | private | big corporate networks, cloud VPCs |
| `172.16.0.0/12` | private | Docker, some offices |
| `192.168.0.0/16` | private | home routers (192.168.1.x) |
| `127.0.0.0/8` | loopback | `127.0.0.1` = "this machine" |
| `169.254.0.0/16` | link-local | "I could not get DHCP" |
| `100.64.0.0/10` | CGNAT | carrier-grade NAT (some ISPs) |

Private addresses are **not routable on the internet**. Your router rewrites them via NAT.

`127.0.0.1` (localhost) never leaves your machine — perfect for `curl http://127.0.0.1:8080` testing a
local app.

---

## Names, and why DNS is the usual suspect

Humans use names (`example.com`); machines use addresses. **DNS** translates. It is a distributed database
of records, cached at many levels (browser, OS, router, ISP).

A huge share of "the internet is broken" reports are actually: Wi-Fi is fine, routing is fine, DNS is
broken. That is why `ping 8.8.8.8` working while `ping google.com` fails is a classic diagnostic pair.

More in `04-dns.md`.

---

## Prove you understood

1. What three things must be true for your browser to reach a website?
2. Why can two services (SSH and HTTP) run on one IP address?
3. A packet is lost. Which protocol asks for it again?
4. What does a "listening" port mean, and which command shows them?
5. Why can `ping 8.8.8.8` succeed while `ping google.com` fails?
6. Which private range does your home router most likely use?

<details>
<summary>Model answers</summary>

1. A reachable IP address, a route to it (gateway), and a listening program on the right port.
2. Because ports distinguish them: SSH on 22, HTTP on 80/443.
3. TCP (through retransmission). UDP does not.
4. A program is waiting for incoming connections on that port; `ss -tulpn`.
5. `8.8.8.8` tests routing/internet; `google.com` additionally requires DNS to resolve the name. If DNS
   fails, the IP test still works.
6. `192.168.0.0/16`, typically `192.168.1.0/24` or `192.168.0.0/24`.
</details>
