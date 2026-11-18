# Project 06 — Network Health Checker

**Difficulty:** ⭐⭐⭐ · **Time:** 1.5 h
**Skills:** `ip`, `ping`, `nc`, `curl`, `dig`, retries, timeouts, reporting

---

## Goal

Build `netcheck.sh`: one command that answers "is this machine's network healthy?" — interface up, gateway
reachable, DNS working, internet reachable, key ports open, HTTP responding. Each check gets a PASS/FAIL
and a sensible timeout.

This is the script you run first when a server "feels down". It turns the 8-step playbook into one command.

---

## Requirements

1. Usage: `./netcheck.sh [--host TARGET] [--port N] [--url URL] [--timeout SEC]`
2. Defaults: `TARGET=1.1.1.1`, `PORT=443`, `URL=https://example.com`, `TIMEOUT=5`.
3. Checks, in this order, stopping the chain when a prerequisite fails:
   1. loopback responds (`ping 127.0.0.1`)
   2. at least one non-loopback interface is `UP` and has an IPv4 address
   3. default gateway exists
   4. gateway responds to ping
   5. internet by IP responds (`$TARGET`)
   6. DNS resolves (`example.com`)
   7. TCP port open (`$TARGET:$PORT`)
   8. HTTP status returns (`$URL`)
4. Output format: `PASS`/`FAIL`/`SKIP` per check, aligned, with a one-line reason on failure.
5. Exit codes: `0` all pass, `1` a failure, `2` usage error.
6. Every network command must have a **timeout** so the script cannot hang.
7. `--quiet`: only print failures.
8. Never requires `sudo`.

---

## Step by step

### Step 1 — Setup

```bash
mkdir -p ~/linux-lab/projects/06-netcheck && cd $_
```

Write a tiny runner first:

```bash
pass() { printf '[ PASS ] %s\n' "$*"; }
fail() { printf '[ FAIL ] %s\n' "$*"; }
skip() { printf '[ SKIP ] %s\n' "$*"; }
```

### Step 2 — Loopback

```bash
ping -c1 -W"$TIMEOUT" 127.0.0.1 >/dev/null 2>&1 && pass "loopback" || fail "loopback (network stack down?)"
```
`-W` is a per-packet timeout in seconds. Without it, `ping` can wait a long time.

### Step 3 — Interface and address

```bash
# any UP, non-loopback interface with an IPv4 address?
if ip -4 -br addr show 2>/dev/null | awk '$1 != "lo" && $2 == "UP"' | grep -qE '([0-9]{1,3}\.){3}[0-9]{1,3}'; then
  pass "interface up with IPv4"
else
  fail "no UP interface with an IPv4 address"
fi
```
Test the pipeline piece by piece in your shell before trusting it.

### Step 4 — Gateway

```bash
gw=$(ip r | awk '/^default/ {print $3; exit}')
if [[ -n "$gw" ]]; then pass "gateway $gw present"; else fail "no default gateway"; fi
```

### Step 5 — Internet, DNS, port, HTTP

```bash
ping -c1 -W2 "$gw"        >/dev/null 2>&1 && pass "gateway reachable" || fail "gateway unreachable"
ping -c1 -W2 "$TARGET"    >/dev/null 2>&1 && pass "internet (IP)"      || fail "internet (IP) unreachable"

if dig +short +time=2 +tries=1 example.com 2>/dev/null | grep -qE '[0-9]'; then
  pass "DNS resolves example.com"
else
  fail "DNS resolution failed"
fi

nc -z -w "$TIMEOUT" "$TARGET" "$PORT" >/dev/null 2>&1 \
  && pass "tcp $TARGET:$PORT open" || fail "tcp $TARGET:$PORT closed/filtered"

code=$(curl -s -o /dev/null -m "$TIMEOUT" -w '%{http_code}' "$URL" || echo 000)
[[ "$code" =~ ^[1-5][0-9][0-9]$ ]] && pass "http $URL -> $code" || fail "http $URL no response"
```

### Step 6 — Don't hang, ever

Wrap anything that could block:
```bash
timeout 5 curl -sI "$URL" >/dev/null
```
`timeout` is the blunt instrument that saves you when a tool ignores its own timeouts.

### Step 7 — Exit status

```bash
failures=0
# ... increment in fail() by using a global
fail() { printf '[ FAIL ] %s\n' "$*"; ((failures++)); }
...
(( failures == 0 )) && exit 0
exit 1
```
Careful: if `fail()` is called from a subshell (a pipeline), the counter is lost. Keep the checks in the
main shell — no `| while` around them.

---

## Proof it works

```bash
# Healthy
./netcheck.sh; echo "exit=$?"                       # all PASS, 0

# Bad target: internet check fails fast
./netcheck.sh --host 192.0.2.1 --timeout 2; echo $? # FAIL on internet, 1

# Bad port
./netcheck.sh --port 9 --timeout 2                  # tcp check fails

# Bad URL
./netcheck.sh --url https://nonexistent.invalid      # http check fails

# Quiet mode prints only problems
./netcheck.sh --host 192.0.2.1 --quiet

# No hanging
time ./netcheck.sh --host 192.0.2.1 --timeout 2      # must finish in a few seconds
```

### Deliberate failures to test with

| Break this | How | Expected |
|---|---|---|
| DNS | temporarily add a bogus `nameserver` in a test netns/VM | DNS FAIL, later checks FAIL/SKIP |
| port | use `--port 9` | TCP FAIL |
| URL | `--url https://nonexistent.invalid` | HTTP FAIL |

Run the whole thing with `bash -x` once and follow the checks in order. That trace is a great study aid.

---

## Stretch goals

1. `--json` output for monitoring.
2. Measure and print latency per check.
3. `--record` writes results to a CSV so you can see trends.
4. Retry each failed check N times before declaring failure (flaky networks are normal).
5. Detect whether the failure is DNS by comparing "by IP" and "by name" results explicitly.

---

## Grading rubric

| Criterion | Points |
|---|---|
| All 8 checks implemented in the right order | 25 |
| PASS/FAIL/SKIP output is aligned and readable | 15 |
| Timeouts everywhere; script never hangs | 20 |
| Correct exit codes | 15 |
| `--quiet` works | 10 |
| Argument parsing + validation | 15 |

**80+** = done.
