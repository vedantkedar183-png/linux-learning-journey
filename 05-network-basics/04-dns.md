# 04 — DNS: How Names Become Addresses

## Why DNS exists

Humans remember `github.com`; routers need `140.82.121.4`. DNS is the distributed database that maps one
to the other. Without it, the internet still works — you would just have to memorise numbers.

It is also the **most common cause** of "the internet is down" that is not actually the internet.

---

## The resolution process, step by step

You type `www.example.com` in a browser:

1. **Browser cache** — checked first.
2. **OS cache / resolver** (`systemd-resolved`, `nscd`) — checked second.
3. **`/etc/hosts`** — local overrides, checked before DNS. (Yes, before.)
4. **Recursive resolver** — usually your router or your ISP's DNS. It now does the work:
   - asks a **root server**: "who handles `.com`?"
   - asks the `.com` **TLD server**: "who handles `example.com`?"
   - asks `example.com`'s **authoritative server**: "what is `www`?"
5. The answer is **cached** for the record's **TTL** (time to live) so the next request is instant.

That is why a DNS change can take minutes or hours to "propagate": caches keep the old answer until TTL
expires.

---

## Record types you will actually see

| Type | Answers | Example |
|---|---|---|
| `A` | IPv4 address | `example.com → 93.184.216.34` |
| `AAAA` | IPv6 address | `example.com → 2606:2800:…` |
| `CNAME` | an alias | `www.example.com → example.com` |
| `MX` | mail server | `example.com → mail.example.com (10)` |
| `TXT` | arbitrary text | SPF/DKIM/DMARC, domain verification |
| `NS` | which servers are authoritative | `example.com → a.iana-servers.net` |
| `PTR` | reverse lookup (IP → name) | `34.216.184.93 → …` |
| `SRV` | service location | `_sip._tcp.example.com` |

---

## Commands

### `dig` — the professional tool
```bash
$ dig example.com
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
;; QUESTION SECTION:
;example.com.                   IN      A
;; ANSWER SECTION:
example.com.            3600    IN      A       93.184.216.34
;; SERVER: 192.168.1.1#53(192.168.1.1)
```
Read three things: **status** (`NOERROR`), the **ANSWER SECTION**, and the **TTL** (3600 seconds).

```bash
$ dig example.com +short              # just the answer
$ dig example.com A +short            # IPv4 only
$ dig example.com AAAA +short         # IPv6
$ dig example.com MX +short           # mail
$ dig example.com NS +short           # name servers
$ dig @8.8.8.8 example.com +short     # ask a specific resolver
$ dig +trace example.com              # follow the whole delegation chain
$ dig -x 8.8.8.8 +short               # reverse lookup
```

### `nslookup` and `host` — simpler, sometimes the only tool installed
```bash
$ nslookup example.com
$ host example.com
$ host -t MX example.com
```

### `getent hosts` — respects the system's real order (`/etc/hosts` + DNS)
```bash
$ getent hosts example.com
```

### `resolvectl` — on systems using systemd-resolved
```bash
$ resolvectl status            # which DNS servers are actually in use
$ resolvectl query example.com
$ resolvectl flush-caches      # after changing DNS records
```

---

## Configuring DNS

| File | Purpose |
|---|---|
| `/etc/resolv.conf` | list of `nameserver` entries |
| `/etc/hosts` | static name→IP overrides, checked first |
| `/etc/nsswitch.conf` | the **order** of lookups (`files dns` = hosts then DNS) |
| `/etc/systemd/resolved.conf` | systemd-resolved settings |
| Netplan / NetworkManager | where DNS is usually configured nowadays |

On Ubuntu, `/etc/resolv.conf` is often a **symlink** to a `systemd-resolved` stub. Editing it directly may
be overwritten. Check first:
```bash
$ ls -l /etc/resolv.conf
$ resolvectl status | head -20
```

### `/etc/hosts` — the fastest fix in the world
```
127.0.0.1   localhost
::1         localhost
10.0.0.5    db.internal db
192.168.1.50 staging.local
```
This wins over DNS. It is how you test a new server before DNS is ready, and (unfortunately) how malware
redirects sites. Always check it when names resolve "wrong".

### Changing DNS temporarily
```bash
$ sudo sh -c 'echo "nameserver 1.1.1.1" > /etc/resolv.conf'
# test, then restore. On systemd-resolved systems use resolvectl instead.
```

---

## Diagnosing DNS problems

### The classic pair
```bash
$ ping -c 2 8.8.8.8        # works → routing is fine
$ ping -c 2 google.com     # fails → the problem is name resolution
```

### Step by step
1. **Does it resolve at all?**
   ```bash
   $ dig example.com +short
   ```
   Empty answer + `status: NXDOMAIN` → the name does not exist (typo?).
   `status: SERVFAIL` → the resolver failed (try `@8.8.8.8`).
   No response at all → DNS server unreachable (firewall or wrong server).

2. **Is it my resolver or the domain?**
   ```bash
   $ dig @8.8.8.8 example.com +short       # public resolver
   $ dig @192.168.1.1 example.com +short   # my router
   ```
   If the public one works and yours does not, your configured DNS is the problem.

3. **Is it cached?**
   ```bash
   $ resolvectl flush-caches     # or: sudo systemd-resolve --flush-caches
   ```

4. **Is `/etc/hosts` interfering?**
   ```bash
   $ cat /etc/hosts
   $ getent hosts example.com
   ```

5. **Is the name right?** Check for typos and trailing dots. `example.com.` (with a dot) means "absolute".

### Error messages decoded
| Message | Meaning | Fix |
|---|---|---|
| `NXDOMAIN` | name does not exist | check spelling / the record exists |
| `SERVFAIL` | resolver could not complete | try another resolver, check DNSSEC |
| `connection timed out; no servers could be reached` | DNS server unreachable | check `resolv.conf`, firewall on 53 |
| `Temporary failure in name resolution` | resolver not configured/reachable | check `/etc/resolv.conf` |
| Resolves to `127.0.0.1` unexpectedly | `/etc/hosts` entry | edit `/etc/hosts` |

---

## TTL and propagation, in plain words

Every DNS answer carries a TTL in seconds. Your resolver keeps the answer for that long. So:
- Lower TTL (300s) **before** a planned change → the world picks up changes fast.
- Raise it again (86400s) after the change → fewer lookups, faster resolution.

"If it does not work immediately, wait for TTL" is real. `dig` shows the remaining TTL counting down.

---

## Practice

1. Resolve `example.com` — what is the TTL?
2. Ask `1.1.1.1` directly for `example.com`. Same answer?
3. What are the MX records for `gmail.com`?
4. What are the name servers for `wikipedia.org`?
5. Reverse-resolve `8.8.8.8`.
6. Add a temporary entry `127.0.0.1 mytest.local` to `/etc/hosts`, then `getent hosts mytest.local`.
   Remove it afterwards.
7. `dig +trace example.com | head -30` — can you see the root → TLD → authoritative chain?
8. Run `resolvectl status` (if available). Which DNS servers is your system actually using?
9. Look up a deliberately fake domain (`thisdoesnotexist-12345.com`). What status do you get?
10. Why would `ping 8.8.8.8` work while `ping google.com` says "Temporary failure in name resolution"?

<details>
<summary>Answers</summary>

1–5. `dig example.com`, `dig @1.1.1.1 example.com +short`, `dig gmail.com MX +short`,
`dig wikipedia.org NS +short`, `dig -x 8.8.8.8 +short`.
6. `echo "127.0.0.1 mytest.local" | sudo tee -a /etc/hosts`, test, then remove the line.
7. You should see referrals from a root server to `.com` servers and then the authoritative answer.
9. `status: NXDOMAIN`.
10. The IP path and routing work, but the resolver cannot turn names into addresses — DNS configuration or
    reachability of the DNS server is broken.
</details>

**Next:** `05-ssh-and-remote-access.md`.
