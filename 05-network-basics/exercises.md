# Network Exercises

Everything here is **safe and read-only**. No `sudo` needed except where marked.

**Setup:** none. Just open a terminal.

**How to work:** run the command, read the output, write one sentence about what it proved. A command you
ran without understanding is a command you did not learn.

---

## Part 1 — Know your own network (tasks 1–8)

1. Show all interfaces briefly with their IP addresses.
2. What is your loopback address, and what does it mean?
3. Show your default gateway. What device is it likely to be?
4. What is your DNS server? Where is it configured?
5. Is your IP assigned by DHCP or static? How can you tell?
6. Show the interface that carries your default route, and its MAC address.
7. What is your public IP as the internet sees you? (One command.)
8. Write a single sentence that fully describes your network: your address, your subnet size, your
   gateway, your DNS.

---

## Part 2 — Reachability (tasks 9–14)

9. Ping loopback 3 times. What does this prove?
10. Ping your gateway 3 times. What does this prove?
11. Ping `1.1.1.1` 3 times. What does this prove?
12. Ping `example.com` 3 times. What extra thing does this prove compared to task 11?
13. Which of the four pings had the highest latency? Why might that be?
14. Deliberately ping an address that should not answer (e.g. `192.0.2.1`, a reserved test range). How
    long did it take to give up? What message did you get?

---

## Part 3 — Routes and paths (tasks 15–18)

15. Trace the path to `1.1.1.1`, maximum 10 hops. How many hops are shown?
16. Which hop is your own network? Which is your ISP?
17. Run `ip route get 8.8.8.8`. Which interface and source address will be used?
18. Explain in one sentence the difference between a route to `192.168.1.0/24` and the default route.

---

## Part 4 — Ports and services (tasks 19–26)

19. List all listening TCP and UDP ports with process names. (May need `sudo` for names.)
20. Find any service listening on `0.0.0.0`. What does that mean for reachability?
21. Find any service listening on `127.0.0.1`. What does that mean for reachability?
22. Is anything listening on port 22? If yes, which program?
23. Start a temporary web server: `cd /tmp && python3 -m http.server 8000 &`. Confirm with `ss` that it
    listens on all interfaces. Then stop it with `kill %1`.
24. Start it again bound to `127.0.0.1:8001`. Confirm the difference with `ss`. Stop it.
25. Test whether `github.com:443` is reachable using `nc`. What message means success?
26. Read this and answer: a service shows `Connection refused`. Is the host reachable? Is the service
    running?

---

## Part 5 — DNS (tasks 27–34)

27. Resolve `example.com` and show only the IP.
28. Show the TTL for `example.com`. What does TTL mean?
29. Ask `8.8.8.8` directly for `example.com`. Same answer as your normal resolver?
30. Find the mail servers (MX) for `gmail.com`.
31. Find the name servers (NS) for `wikipedia.org`.
32. Reverse-resolve `1.1.1.1`.
33. Look up a domain that does not exist. What status do you get?
34. Look at `/etc/hosts` and `/etc/nsswitch.conf`. Which is checked first for a normal lookup?

---

## Part 6 — HTTP (tasks 35–42)

35. Fetch the headers of `https://example.com`. What is the status code?
36. Fetch only the status code of `https://example.com` and print it with `-w`.
37. Measure the time breakdown for `https://example.com`: DNS, connect, TLS, total. Which part is
    slowest?
38. Fetch `https://httpbin.org/status/403` and `.../404`. What codes do you get?
39. Fetch `https://httpbin.org/json` and identify two JSON fields.
40. Explain the difference between 403 and 404 in one sentence each.
41. Start your local python server and fetch a missing path. What code do you get, and where can you see
    the request logged?
42. Run `curl -v https://example.com` and identify the line where TLS verification succeeded.

---

## Part 7 — Troubleshooting reasoning (tasks 43–48)

43. Scenario: `ping 8.8.8.8` works, `ping google.com` fails. Which single step of the 8-step playbook is
    broken, and what are your first two diagnostic commands?
44. Scenario: `curl http://localhost:8080` works on the server, but from your laptop `nc -zv server 8080`
    times out. Which two causes are most likely?
45. Scenario: `nc -zv server 22` says "Connection refused". How is that different from "timed out", and
    what does each tell you?
46. Scenario: a service worked yesterday and fails today. List the four commands you run first.
47. Scenario: `dig example.com` returns `SERVFAIL`. What are two things you would try?
48. Write the 8-step playbook from memory, in order.

---

## Part 8 — Stretch (optional, needs sudo)

49. Install `traceroute` and `dnsutils` if missing. Which package provides `dig`?
50. Capture 5 ICMP packets with `tcpdump` while pinging in another terminal. Which direction do you see?
51. Set up SSH to `localhost` and log in with a key (see `05-ssh-and-remote-access.md`).
52. Create a local port forward with `ssh -L` and fetch the forwarded port with `curl`.

---

## Grading yourself

| Score | Meaning |
|---|---|
| 1–20 | Beginner: you can inspect, but not yet diagnose |
| 21–35 | Competent: you can find ports and resolve names |
| 36–42 | Confident: you can read web errors |
| 43–48 | Ready: you can diagnose in order, not by guessing |
| 49–52 | Advanced: you can verify at the packet level |

Answers and expected outputs: `solutions.md`.
