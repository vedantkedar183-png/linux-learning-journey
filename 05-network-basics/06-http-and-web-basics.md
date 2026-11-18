# 06 — HTTP and Web Basics for Linux People

You do not need to be a web developer. But most Linux servers run web software, and most logs you will
read are web logs. This lesson gives you just enough to read them.

---

## The request/response model

HTTP is a text conversation over TCP:

```
CLIENT (curl)                                SERVER (nginx)
GET /index.html HTTP/1.1
Host: example.com
User-Agent: curl/8.5.0
Accept: */*
                              ──────▶
                                             HTTP/1.1 200 OK
                                             Content-Type: text/html
                                             Content-Length: 1256
                              ◀──────
                                             <html>...</html>
```

That is it. Everything else is headers.

---

## Methods

| Method | Meaning | Safe to repeat? |
|---|---|---|
| `GET` | read something | yes |
| `HEAD` | read headers only | yes |
| `POST` | create / submit data | **no** (may create duplicates) |
| `PUT` | replace a resource | yes (idempotent) |
| `PATCH` | partial update | not guaranteed |
| `DELETE` | remove | yes (idempotent) |

---

## Status codes you must recognise

| Code | Meaning | What you do |
|---|---|---|
| `200` | OK | nothing |
| `301` / `302` | moved permanently / temporarily | use `curl -L` to follow |
| `304` | not modified (cached) | nothing |
| `400` | bad request | your request is malformed |
| `401` | unauthorized | need credentials |
| `403` | forbidden | authenticated but not allowed (permissions!) |
| `404` | not found | wrong path or missing file |
| `500` | server error | check the app's logs |
| `502` | bad gateway | upstream app is down (nginx can't reach it) |
| `503` | service unavailable | overloaded or starting |
| `504` | gateway timeout | upstream too slow |

**The 403 vs 404 distinction is a permissions lesson:** 403 means "I found it but you may not have it".
In Linux, that is often a file mode problem (`644` vs `640`, or a folder missing `x`).

---

## Reading a URL

```
https://www.example.com:443/docs/page.html?lang=en#intro
└─┬─┘   └──────┬───────┘└┬┘└──────┬──────┘└───┬───┘└─┬─┘
scheme      host       port     path         query  fragment
```

- **scheme** — `http` (80) or `https` (443), plus TLS encryption
- **host** — resolved via DNS
- **port** — defaults to 80/443
- **path** — what the server maps to a file or route
- **query** — parameters, `?key=value&k2=v2`
- **fragment** — handled by the browser only; never sent to the server

---

## Headers worth knowing

Request headers:
```
Host: example.com                 # which site (many sites per IP)
User-Agent: curl/8.5.0            # client identity
Accept: application/json          # what I want back
Authorization: Bearer <token>     # credentials
Cookie: session=abc               # session state
Content-Type: application/json    # what I am sending (POST)
```

Response headers:
```
Content-Type: text/html; charset=UTF-8
Content-Length: 1256
Cache-Control: max-age=3600
Set-Cookie: session=xyz; HttpOnly; Secure
Location: /login                  # with 301/302
```

---

## TLS/HTTPS in one paragraph

HTTPS is HTTP inside a TLS tunnel. On connect, the server presents a **certificate** signed by a
**certificate authority**; your client checks the signature, the hostname, and the expiry. Then both sides
derive a shared session key, and everything after that is encrypted. `curl` fails with a certificate error
if any check fails — that is the system working, not a bug.

```bash
$ curl -vI https://example.com 2>&1 | grep -E "SSL|TLS|certificate"
$ openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null | openssl x509 -noout -dates -subject
```

---

## Web logs: what you will actually read

`/var/log/nginx/access.log` (combined format):
```
192.168.1.42 - - [16/Nov/2026:10:30:01 +0000] "GET /index.html HTTP/1.1" 200 1256 "-" "curl/8.5.0"
      │                        │                         │        │    │      │        │
      client IP                timestamp                 request  code bytes  referer  user agent
```

Useful recipes:
```bash
# top 10 client IPs
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# all 5xx responses
awk '$9 ~ /^5/ {print}' access.log | tail -20

# request count per path
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head

# requests per minute (rough)
cut -d: -f1-2 access.log | sort | uniq -c | tail
```

`error.log` is shorter and more useful when things break:
```
2026/11/16 10:31:02 [error] 900#900: *12 connect() failed (111: Connection refused)
    while connecting to upstream
```
Translation: nginx tried to reach your app (the "upstream") and nothing was listening. That is a 502 for
the user and a "start your app" for you.

---

## Running a test server in 20 seconds

```bash
$ cd ~/linux-lab/practice
$ mkdir -p webdemo && cd webdemo
$ echo "<h1>Hello from Linux</h1>" > index.html
$ python3 -m http.server 8000
Serving HTTP on 0.0.0.0 port 8000 ...
```
In another terminal:
```bash
$ curl -I http://localhost:8000
$ curl http://localhost:8000
$ curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/missing   # 404
```
Then look at the server terminal — you see the request lines appear live. That is an access log.

**Try binding to localhost only:**
```bash
$ python3 -m http.server 8001 --bind 127.0.0.1
```
Now `ss -tulpn | grep 8001` shows `127.0.0.1:8001`, and another machine cannot connect. Compare with
`0.0.0.0:8000`. This is the single most useful thing to understand about "it works locally but not
remotely".

**Stop the server** with `Ctrl+C`. (If you closed the terminal, `pkill -f "http.server"`.)

---

## A minimal nginx setup (optional)

```bash
$ sudo apt install nginx
$ sudo systemctl status nginx
$ curl -I http://localhost            # 200 from the default page
$ sudo nano /etc/nginx/sites-available/default
$ sudo nginx -t                       # ALWAYS test config first
$ sudo systemctl reload nginx
$ sudo tail -f /var/log/nginx/access.log
```

The `nginx -t` habit: one syntax error and reload fails or, worse, the service restarts broken. `-t`
checks before you commit.

---

## Checklist for "my site does not load"

```bash
$ systemctl status nginx                # 1. is the server running?
$ sudo nginx -t                         # 2. is the config valid?
$ ss -tulpn | grep -E ':80|:443'        # 3. is it listening, and on which address?
$ curl -I http://localhost              # 4. does it answer locally?
$ curl -I http://<public-ip>            # 5. does it answer from outside?
$ sudo ufw status                       # 6. is the firewall allowing 80/443?
$ sudo tail -20 /var/log/nginx/error.log # 7. what does the server say?
```

If step 4 works and step 5 does not, the problem is the network path (firewall, security group, NAT) — not
the web server.

---

## Practice

1. Start `python3 -m http.server 8000` and fetch `/` and a missing path. What codes do you get?
2. Start it bound to `127.0.0.1:8001`. Show with `ss` that it is not exposed.
3. `curl -I https://example.com` — list three response headers and what they mean.
4. Fetch `https://httpbin.org/status/418` and identify the code.
5. Use `curl -s -o /dev/null -w "%{http_code} %{time_total}\n"` on two sites. Which is faster?
6. Fetch a JSON API (`curl -s https://api.github.com/users/torvalds | head`) and identify one field.
7. Create one `access.log` sample line yourself and extract the IP and status code with `awk`.
8. Explain 403 vs 404 in one sentence each.
9. Why does a 502 usually mean "your app is not running", not "nginx is broken"?
10. Write the 7-step checklist above from memory.

<details>
<summary>Answers</summary>

1. `/` → `200`; missing path → `404`.
2. `ss -tlnp | grep 8001` shows `127.0.0.1:8001`.
3. e.g. `content-type: text/html` (format of the body), `cache-control` (caching rules),
   `content-length` (body size).
4. `418 I'm a teapot`.
5. `%{time_total}` gives seconds; lower is faster.
8. 403 = exists but you are not allowed; 404 = does not exist (or hidden deliberately).
9. nginx forwards to an upstream app; if nothing listens there, nginx returns 502 "bad gateway". nginx
   itself is fine — which is why `error.log` says "connect() failed while connecting to upstream".
</details>
