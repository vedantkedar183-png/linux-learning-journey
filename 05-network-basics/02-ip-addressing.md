# 02 — IP Addressing, Subnets, Gateways, and NAT

This is the lesson that scares beginners. It should not: there are only four ideas.

1. An IP address identifies a machine.
2. A subnet mask says which part of the address is the **network** and which part is the **host**.
3. A gateway is the machine you send traffic to when the destination is **not** on your subnet.
4. NAT lets many private machines share one public address.

---

## 1. The IPv4 address

An IPv4 address is 32 bits, written as four numbers 0–255:
```
192 . 168 . 1 . 42
```
In binary:
```
11000000 . 10101000 . 00000001 . 00101010
```
That is the whole thing. The dots are just for humans.

**IPv6** is 128 bits, written in hex (`2001:db8::1`). It exists because we ran out of IPv4 addresses.
Concepts are the same; the notation is longer. This lesson focuses on IPv4 because it is what you will see
in most logs and examples.

---

## 2. Subnet mask: which part is the network?

A subnet mask is also 32 bits, made of a run of 1s followed by 0s:
```
255.255.255.0   =  11111111.11111111.11111111.00000000
                   └────── network ──────┘└─ hosts ─┘
```

With address `192.168.1.42` and mask `255.255.255.0`:
- network part = `192.168.1`
- host part = `42`
- so this host is on network `192.168.1.0/24`

**/24 is just a shorter way to write the mask.** It counts the 1 bits:

| CIDR | Mask | Hosts per subnet |
|---|---|---|
| `/8` | `255.0.0.0` | 16,777,214 |
| `/16` | `255.255.0.0` | 65,534 |
| `/24` | `255.255.255.0` | 254 |
| `/25` | `255.255.255.128` | 126 |
| `/26` | `255.255.255.192` | 62 |
| `/27` | `255.255.255.224` | 30 |
| `/28` | `255.255.255.240` | 14 |
| `/30` | `255.255.255.252` | 2 |

Why 254 and not 256? Two addresses in each subnet are reserved:
- the **network address** (all host bits 0) — `192.168.1.0`
- the **broadcast address** (all host bits 1) — `192.168.1.255`

---

## 3. Gateway: the way out

Two devices can talk directly only if they are on the **same subnet** (same network part).

If the destination is elsewhere, your machine sends the packet to the **default gateway** — usually your
router — which forwards it onward. That is what "default route" means.

```bash
$ ip r
default via 192.168.1.1 dev eth0 proto dhcp metric 100
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.42
```
Read it as:
- "anything not matched by a more specific route goes to `192.168.1.1` via `eth0`" (the default route),
- "`192.168.1.0/24` is directly reachable on `eth0`" (the local subnet).

Longest-prefix match: the most specific route wins. A `/32` host route beats a `/24`, which beats the
default.

**Same-subnet test:** is `192.168.1.42/24` on the same network as `192.168.1.99`? Yes — both are
`192.168.1.x`. Is it on the same network as `192.168.2.10`? No — so traffic goes via the gateway.

---

## 4. NAT: how your whole house shares one IP

Your ISP gives you one public IP. Inside, you have `192.168.1.x` addresses. **NAT** (Network Address
Translation) rewrites your source address to the router's public IP and remembers which internal machine
each reply belongs to.

```
laptop 192.168.1.42:51234  →  router rewrites  →  203.0.113.7:40001  →  internet
                                    ↑
                          translation table remembers
laptop ← 192.168.1.42:51234  ←  router rewrites back  ←  203.0.113.7:40001
```

Consequences you will actually experience:
- **You can reach out; outsiders cannot reach in** unless you forward a port.
- Two apps on different machines can both use port 8080 internally — the router maps them separately.
- Your public IP is shared with everyone on your network.
- `ip a` shows private addresses; use `curl ifconfig.me` to see your public IP.

### Port forwarding
To run a server at home, your router needs a rule: "incoming port 8080 → 192.168.1.42:8080". Most home
routers call this "Port Forwarding" or "Virtual Server". Without it, the server is unreachable from
outside.

---

## Reading your own configuration

```bash
$ ip -br a
lo        UNKNOWN  127.0.0.1/8
eth0      UP       192.168.1.42/24
```
- `lo` is loopback: always `127.0.0.1`, always up, never touches the network.
- `eth0` (or `wlan0`, `enp0s3`, `ens33`) is your real interface.
- `/24` here tells you the subnet.

```bash
$ ip r                       # default gateway
$ cat /etc/resolv.conf       # DNS servers
$ hostname -I                # my addresses, one line
$ curl -s ifconfig.me        # my public IP (asks an external service)
```

---

## DHCP: where those numbers come from

When you join a Wi-Fi network, your device asks for an address. A DHCP server replies with:
- an IP address,
- the subnet mask,
- the gateway,
- DNS servers,
- a lease time (how long you may keep it).

That is why `ip r` shows `proto dhcp` and why the address can change after a reboot. Servers usually use
a **static** address instead, configured in `/etc/netplan/*.yaml` (Ubuntu) or NetworkManager.

## Static vs dynamic

| | Static | DHCP |
|---|---|---|
| Address | fixed, you choose | assigned, can change |
| Used by | servers, printers, routers | laptops, phones |
| Risk | conflicts if you pick a used IP | address changes unexpectedly |
| Config | Netplan / NetworkManager / cloud-init | automatic |

Static config on Ubuntu (Netplan) looks like:
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.50/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```
Apply with `sudo netplan apply`. Getting this wrong on a remote server means losing access — always keep a
console open.

---

## Subnetting practice (do these on paper)

For `192.168.10.0/24`, answer:

1. How many usable host addresses?
2. What is the broadcast address?
3. Is `192.168.10.200` on this network?
4. Is `192.168.11.5` on this network?

For `10.0.0.0/8` split into `/16`s:

5. How many `/16` subnets fit inside it?
6. What is the first and last usable address of `10.5.0.0/16`?

For `172.16.4.0/22`:

7. What is the subnet mask in dotted decimal?
8. What is the broadcast address? (Hint: /22 = 4 × /24 → `172.16.4.0`–`172.16.7.255`.)

<details>
<summary>Answers</summary>

1. 254 (256 minus network and broadcast).
2. `192.168.10.255`.
3. Yes.
4. No — different third octet, different `/24` network.
5. 256.
6. `10.5.0.1` to `10.5.255.254`; broadcast `10.5.255.255`.
7. `255.255.252.0`.
8. `172.16.7.255`.
</details>

---

## The one-liner to remember

> **An IP address is who you are. The subnet mask is what neighbourhood you live in. The gateway is the
> road out of the neighbourhood. DNS is the phone book. Ports are apartment numbers.**

---

## Prove you understood

1. What does `/24` tell you that `255.255.255.0` also tells you?
2. Why can two hosts with `192.168.1.10/24` and `192.168.1.11/24` talk without a router?
3. Why does `192.168.1.10/24` need a gateway to reach `192.168.2.10`?
4. Why can a home network have dozens of devices but only one public IP?
5. Which command shows your default gateway?
6. What breaks if you set a static IP that another device is already using?

<details>
<summary>Model answers</summary>

1. Both mean the first 24 bits are the network part; the remaining 8 bits are hosts.
2. They are on the same subnet, so traffic is delivered directly via ARP/MAC, no routing needed.
3. Different network parts, so the packet must be handed to a router that knows how to reach that network.
4. NAT rewrites private source addresses to one public address, tracking connections in a table.
5. `ip r` (look for the `default via` line).
6. An **IP conflict**: both devices claim the same address, replies go to the wrong machine, and
   connectivity becomes intermittent or fails entirely.
</details>
