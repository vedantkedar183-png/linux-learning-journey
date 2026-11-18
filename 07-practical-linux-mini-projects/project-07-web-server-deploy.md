# Project 07 — Web Server Deployment

**Difficulty:** ⭐⭐⭐⭐ · **Time:** 2 h
**Skills:** `apt`, `systemctl`, nginx, `ufw`, DNS/hosts, TLS basics, logs

---

## Goal

Deploy a real web server on your Linux machine, serve a custom page, add a second site, control access,
and prove you can find the cause when it does not load.

**Do this in a VM or WSL**, never on a machine you cannot restore.

---

## Requirements

1. Install nginx and make it start at boot.
2. Serve your own page at `http://localhost/`.
3. Serve a **second** site at `http://mysite.local/` using a virtual host.
4. Make `mysite.local` resolve locally via `/etc/hosts`.
5. Restrict access to a `/private/` path with HTTP Basic Auth.
6. Enable the firewall and allow only the ports you need.
7. Configure a custom 404 page.
8. Show the access log lines for your own requests.
9. Write a `README.md` with the exact steps to reproduce the whole setup from scratch.
10. Produce a "break it and fix it" note: three failures you caused and how you diagnosed them.

---

## Step by step

### Step 1 — Install and verify

```bash
sudo apt update
sudo apt install -y nginx
systemctl status nginx --no-pager
curl -I http://localhost
ss -tulpn | grep -E ':80|:443'
```
If `curl` gives `200`, the baseline works. Do not change config until you have seen this.

### Step 2 — Your first page

```bash
sudo tee /var/www/html/index.html >/dev/null <<'EOF'
<!doctype html>
<html><head><title>Linux Lab</title></head>
<body><h1>It works — from my own nginx</h1></body></html>
EOF
curl -s http://localhost | head -5
```

### Step 3 — A second site (virtual host)

```bash
sudo mkdir -p /var/www/mysite
sudo tee /var/www/mysite/index.html >/dev/null <<'EOF'
<h1>mysite.local</h1><p>Second virtual host.</p>
EOF

sudo tee /etc/nginx/sites-available/mysite >/dev/null <<'EOF'
server {
    listen 80;
    server_name mysite.local;
    root /var/www/mysite;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/mysite
sudo nginx -t
sudo systemctl reload nginx
```

Local name resolution:
```bash
echo "127.0.0.1 mysite.local" | sudo tee -a /etc/hosts
curl -s http://mysite.local | head -3
```

**Why `nginx -t` every time:** one missing `;` and `reload` fails. `-t` tells you the file and line before
you break a working server. Never skip it.

### Step 4 — Basic auth on `/private/`

```bash
sudo apt install -y apache2-utils
sudo htpasswd -c /etc/nginx/.htpasswd student    # set a lab password
sudo mkdir -p /var/www/mysite/private
echo "secret area" | sudo tee /var/www/mysite/private/index.html
```
Add inside the `server` block:
```nginx
location /private/ {
    auth_basic "Restricted";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```
```bash
sudo nginx -t && sudo systemctl reload nginx
curl -I http://mysite.local/private/                 # 401
curl -u student:YOURPASS -I http://mysite.local/private/   # 200
```

### Step 5 — Custom 404

```nginx
error_page 404 /404.html;
location = /404.html {
    internal;
}
```
Create `/var/www/mysite/404.html`, reload, and check:
```bash
curl -s -o /dev/null -w "%{http_code}\n" http://mysite.local/nope   # 404
curl -s http://mysite.local/nope | head -3                          # your page
```

### Step 6 — Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status verbose
```
⚠️ On a remote machine, allow SSH **first** and confirm you can still log in from a second terminal before
closing the first one.

### Step 7 — Watch the logs

```bash
sudo tail -f /var/log/nginx/access.log
# in another terminal:
curl -s http://mysite.local/ >/dev/null
```
Then analyse them:
```bash
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -rn
```

---

## Proof it works

```bash
# 1. Main site
curl -s -o /dev/null -w "main:   %{http_code}\n" http://localhost/

# 2. Virtual host
curl -s -o /dev/null -w "mysite: %{http_code}\n" http://mysite.local/

# 3. Auth required
curl -s -o /dev/null -w "private (no auth): %{http_code}\n" http://mysite.local/private/   # 401
curl -s -o /dev/null -w "private (auth):    %{http_code}\n" -u student:PASS http://mysite.local/private/  # 200

# 4. Custom 404
curl -s -o /dev/null -w "404:    %{http_code}\n" http://mysite.local/nope
curl -s http://mysite.local/nope | grep -qi "not found\|404" && echo "custom page served"

# 5. Boot persistence
systemctl is-enabled nginx          # enabled

# 6. Firewall
sudo ufw status | grep -E '80|443'

# 7. Logs show your requests
sudo tail -5 /var/log/nginx/access.log
```

---

## Break it and fix it (required)

Cause each failure on purpose, write down the symptom, the command that diagnosed it, and the fix:

| # | Break it by | Diagnose with |
|---|---|---|
| 1 | remove a `;` in the site config, reload | `sudo nginx -t` |
| 2 | change `root` to a wrong path | `curl -I`, `/var/log/nginx/error.log` |
| 3 | `sudo systemctl stop nginx` | `systemctl status`, `ss -tulpn` |
| 4 | `sudo ufw deny 80/tcp` | `curl` timeout vs refused, `ufw status` |
| 5 | set `127.0.0.1:8080` in a proxy target with nothing listening | error log "connection refused", 502 |

For each: what was the **first** clue? That clue is the skill.

---

## Stretch goals

1. Add HTTPS with a self-signed certificate (`openssl req -x509 ...`), then explain the browser warning.
2. Reverse-proxy a Python app: `python3 -m http.server 9000` behind `proxy_pass http://127.0.0.1:9000;`.
3. Add rate limiting (`limit_req_zone`).
4. Write a `deploy.sh` that installs, configures, tests, and reloads — idempotently.
5. Add a `systemd` timer that rotates your custom log nightly.

---

## Grading rubric

| Criterion | Points |
|---|---|
| nginx installed, enabled at boot, serving a custom page | 20 |
| Second virtual host works via `mysite.local` | 20 |
| Basic auth works (401 without, 200 with) | 15 |
| Custom 404 page served | 10 |
| Firewall enabled with correct rules | 10 |
| Reproducible `README.md` | 15 |
| Break/fix notes show real diagnosis | 10 |

**80+** = done.
