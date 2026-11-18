# Project 04 — User Onboarding Script

**Difficulty:** ⭐⭐⭐ · **Time:** 1.5 h
**Skills:** `useradd`, `usermod`, `chpasswd`, `chage`, groups, idempotence, CSV parsing

---

## Goal

Build `onboard.sh`: a script that creates users from a CSV, sets them up correctly (home, shell, groups,
password policy), and is safe to run twice.

This is a real task in every company. It is also where a careless script can lock out an admin or create
a security hole, so it is a good place to practise care.

**Run this only in a VM or WSL.** Create `labuser*` accounts, never real ones.

---

## Requirements

1. Usage: `sudo ./onboard.sh users.csv`
2. CSV format: `username,fullname,groups` with a header row.
3. Must be run as root (check `EUID`), exit `77` otherwise.
4. **Dry-run by default.** Apply only with `CONFIRM=yes ./onboard.sh users.csv`.
5. For each row:
   - skip the header and blank lines
   - skip users that already exist (idempotent), and count them
   - create the home directory, set the comment (full name) and shell `/bin/bash`
   - set a random 16-character password and print it **once**
   - force a password change at first login (`chage -d 0`)
   - add supplementary groups
6. Validate usernames with a regex (`^[a-z][a-z0-9_-]{2,31}$`).
7. Print a summary: created / skipped / invalid.
8. Exit `0` if all rows succeeded, `1` if any row failed.
9. Log the actions; never echo a password to a shared log file.

---

## Step by step

### Step 1 — Setup and sample data

```bash
mkdir -p ~/linux-lab/projects/04-onboarding && cd $_
cat > users.csv <<'EOF'
username,fullname,groups
labsmith,Alice Smith,devs
labjones,Bob Jones,devs,ops
labbrown,Carol Brown,
EOF
cat > groups.txt <<'EOF'
devs
ops
EOF
```
Create the groups first:
```bash
sudo groupadd devs 2>/dev/null || true
sudo groupadd ops  2>/dev/null || true
```

### Step 2 — Read the CSV properly

```bash
while IFS=, read -r user fullname groups; do
  [[ "$user" == "username" || -z "$user" ]] && continue
  echo "would create: $user | $fullname | ${groups:-none}"
done < "$file"
```
Test this alone first. CSV parsing bugs are subtle (trailing spaces, CRLF from Windows).

**CRLF warning:** if your CSV was saved on Windows, `groups` will end in `\r`. Strip it:
```bash
groups="${groups%$'\r'}"
```
This one line has saved many scripts.

### Step 3 — Idempotence

```bash
if id "$user" &>/dev/null; then
  echo "skip (exists): $user"
  skipped=$((skipped+1))
  continue
fi
```

### Step 4 — Create the user

```bash
useradd -m -c "$fullname" -s /bin/bash "$user"
```
Then the password:
```bash
pass=$(tr -dc 'A-Za-z0-9!@#' </dev/urandom | head -c 16)
echo "$user:$pass" | chpasswd
chage -d 0 "$user"
printf '  %s password: %s\n' "$user" "$pass"
```
`chpasswd` reads `user:password` on stdin — safer than putting the password on a command line where `ps`
can see it.

### Step 5 — Groups

```bash
[[ -n "$groups" ]] && usermod -aG "$groups" "$user"
```
Note `-aG`, never `-G` (this is the bug from lab 2, and it matters more here).

### Step 6 — Validate the username

```bash
if [[ ! "$user" =~ ^[a-z][a-z0-9_-]{2,31}$ ]]; then
  echo "invalid username: $user" >&2
  invalid=$((invalid+1))
  continue
fi
```
Why: `useradd` accepts some surprising names; a strict regex prevents spaces, uppercase, and leading
digits, which break other tools (mail, sudoers, web apps).

### Step 7 — Dry run

```bash
if [[ "${CONFIRM:-no}" != "yes" ]]; then
  echo "DRY RUN — re-run with: CONFIRM=yes sudo ./onboard.sh $file"
  exit 0
fi
```
Put this **after** reading and validating, so the dry run shows the real plan.

---

## Proof it works

```bash
# 1. Dry run shows the plan, creates nothing
sudo ./onboard.sh users.csv
id labs | head -1          # should say "no such user"

# 2. Apply
CONFIRM=yes sudo ./onboard.sh users.csv

# 3. Verify
id labsmith
ls -ld /home/labsmith
getent group devs
sudo chage -l labsmith | head -5     # "password must be changed"

# 4. Idempotence: run again, nothing breaks
CONFIRM=yes sudo ./onboard.sh users.csv   # all "skip (exists)"

# 5. Bad input
printf 'username,fullname,groups\nBAD NAME,x,\n' > bad.csv
CONFIRM=yes sudo ./onboard.sh bad.csv; echo "exit=$?"

# 6. Not root
./onboard.sh users.csv; echo "exit=$?"    # 77
```

### Cleanup (always!)
```bash
for u in labsmith labjones labbrown; do sudo deluser --remove-home "$u" 2>/dev/null; done
sudo groupdel devs 2>/dev/null; sudo groupdel ops 2>/dev/null
```

---

## Security checklist

- [ ] Passwords are random, not `password123`
- [ ] Passwords are never written to a log file
- [ ] `chage -d 0` forces a change at first login
- [ ] No user is added to `sudo` unless explicitly requested
- [ ] The script refuses to run as non-root instead of half-failing
- [ ] Idempotent: a second run cannot duplicate or overwrite
- [ ] The CSV is not world-readable (`ls -l users.csv` — chmod 600 if it contains anything sensitive)

---

## Stretch goals

1. Accept `--groups-from groups.txt` and create missing groups automatically.
2. Add `--remove` mode that deletes the users listed in the CSV.
3. Email each user their password (do not actually send mail in the lab — just print the command).
4. Write a report CSV: `username,status,groups`.
5. Add `set -x` debug mode behind a `-v` flag.

---

## Grading rubric

| Criterion | Points |
|---|---|
| Dry-run default, apply only with `CONFIRM=yes` | 15 |
| Users created with correct home, shell, comment | 15 |
| Random password + forced change at first login | 15 |
| Groups appended with `-aG` | 10 |
| Idempotent (second run changes nothing) | 15 |
| Username validation + root check | 15 |
| Clear summary and cleanup instructions | 15 |

**80+** = done.
