# 05 — Network Basics

**Goal:** understand how your machine talks to the internet, read network output without fear, and
diagnose "it doesn't connect" in a logical order.

| Lesson | Topic | Time |
|---|---|---|
| `01-network-fundamentals.md` | Hosts, packets, layers, ports | 25 min |
| `02-ip-addressing.md` | IP, subnet mask, gateway, CIDR, NAT | 30 min |
| `03-network-commands.md` | `ip`, `ping`, `ss`, `curl`, `traceroute` | 30 min |
| `04-dns.md` | How names become addresses | 25 min |
| `05-ssh-and-remote-access.md` | Keys, config, `scp`, `rsync`, tunnels | 30 min |
| `06-http-and-web-basics.md` | Requests, status codes, headers | 25 min |
| `07-troubleshooting-playbook.md` | The 8-step method | 20 min |
| `exercises.md` + `solutions.md` | Practice | 60 min |

**You need:** a working Linux terminal with internet access. All commands in the exercises are
read-only and safe.

---

## The 30-second mental model

Two computers talk because:
1. each has an **IP address** (like a street address),
2. they agree on a **protocol** (like a language),
3. they knock on a specific **port** (like an apartment number),
4. the receiver's program is listening on that port and answers.

Everything else — DNS, routing, subnets, NAT, firewalls — is about *finding* the address, *reaching* it,
and *being allowed* to knock.

```
 your app  →  your OS  →  your router  →  the internet  →  their router  →  their server
   :port         IP           gateway        many hops          IP           :port
```

---

## Why this matters even for a "Linux" class

Almost every real Linux task is remote: you SSH into a server, the web server listens on 443, the
database listens on 5432, the backup goes over `rsync`, and the logs are full of IP addresses. Networking
is not a separate subject — it is where Linux lives.

---

## How to use this module

1. Read each lesson in order — 02 depends on 01, 07 depends on everything.
2. Run **every** command in `03-network-commands.md` as you read it.
3. Do `exercises.md` with the terminal open.
4. When something fails, use `07-troubleshooting-playbook.md` **in order**. Never skip steps.

**Safety note:** all the testing commands (`ping`, `curl`, `dig`, `ss`, `ip`) are read-only and safe. Do
not run `nmap` against networks you do not own — that can be illegal.
