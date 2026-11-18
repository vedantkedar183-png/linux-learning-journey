# 06 — Text Processing in Scripts

Most Linux automation is really **text** automation: read a log, extract a field, count things, rewrite a
config. This chapter is the toolbox inside scripts.

---

## The tools, and what each is for

| Tool | Job | Typical use |
|---|---|---|
| `grep` | find lines | filter a log |
| `cut` | take a column (fixed delimiter) | `cut -d: -f1` |
| `awk` | columns **and** logic | sum, filter, report |
| `sed` | find & replace in a stream | edit config text |
| `sort` | order lines | rankings, comparisons |
| `uniq` | collapse duplicates | counts per value |
| `tr` | translate characters | uppercase, squeeze spaces |
| `head`/`tail` | slice by position | first/last N |
| `wc` | count | lines/words/chars |
| `xargs` | lines → arguments | apply a command to many items |

---

## `grep` — filter

```bash
grep -c "ERROR" app.log              # count matching lines
grep -n "ERROR" app.log              # with line numbers
grep -v "DEBUG" app.log              # exclude
grep -i "error" app.log              # ignore case
grep -E "ERROR|FATAL" app.log        # OR
grep -q "ERROR" app.log && echo hit  # quiet: only exit status (perfect for `if`)
grep -o "user=[a-z0-9]*" app.log     # print only the matched part
grep -A2 -B2 "panic" app.log         # context lines
```

**`grep -q` is the idiomatic "does this file contain X?" test:**
```bash
if grep -q "ERROR" "$log"; then
  echo "errors found in $log"
fi
```

---

## `cut` — fixed columns

```bash
cut -d: -f1 /etc/passwd              # first field, ":" delimiter
cut -d, -f2,4 data.csv               # fields 2 and 4
cut -d' ' -f1 access.log             # first word (breaks on multiple spaces!)
cut -c1-19 access.log                # first 19 characters (a timestamp)
```
`cut` only understands **one** delimiter character and does not squeeze repeated spaces. If the input has
variable spacing, use `awk` instead.

---

## `awk` — the workhorse

`awk` reads input line by line, splits into fields, and runs a program:
```
awk 'PATTERN { ACTION }' file
```

```bash
awk '{print $1}' file                       # field 1 (whitespace-split)
awk '{print $NF}' file                      # last field
awk -F: '{print $1, $7}' /etc/passwd        # custom separator, two fields
awk -F, 'NR>1 {print $3}' data.csv          # skip header, print column 3
awk -F, '$4 > 100 {print $1}' data.csv      # filter by numeric condition
awk '{sum += $1} END {print sum}' nums.txt  # sum a column
awk 'END {print NR}' file                   # count lines
awk '{print NR": "$0}' file                 # number the lines
awk 'length > 80' file                      # lines longer than 80
awk -F: '$3 >= 1000 {print $1}' /etc/passwd # all real users (UID >= 1000)
```

Special variables:
| Var | Meaning |
|---|---|
| `$0` | the whole line |
| `$1`…`$NF` | fields |
| `NR` | line number (across all files) |
| `NF` | number of fields in this line |
| `FS` | field separator (or `-F`) |
| `OFS` | output separator |

Group and sum (very common):
```bash
awk -F, 'NR>1 {total[$3] += $4} END {for (k in total) printf "%-10s %8.2f\n", k, total[k]}' orders.csv
```

---

## `sed` — stream editor

```bash
sed 's/old/new/' file                # first occurrence per line
sed 's/old/new/g' file               # all occurrences
sed -i 's/old/new/g' file            # edit in place
sed -i.bak 's/old/new/g' file        # in place, keep a .bak
sed -n '10,20p' file                 # print lines 10-20
sed '/^#/d' file                     # delete comment lines
sed '/^$/d' file                     # delete blank lines
sed 's/^/    /' file                 # indent every line
sed -E 's/[0-9]+/N/g' file           # regex replace with -E
```

**Always test `sed -i` on a copy first.** There is no undo. `sed -n 's/x/y/p'` shows you what would be
replaced:
```bash
sed -n 's/8080/9090/p' config.conf     # preview
sed -i.bak 's/8080/9090/g' config.conf # do it, with a backup
```

---

## `sort`, `uniq`, `tr`, `xargs`

```bash
sort -n nums.txt                     # numeric
sort -h sizes.txt                    # human sizes (K/M/G)
sort -k2 -n data.txt                 # by column 2, numeric
sort -t: -k3 -n /etc/passwd          # by UID
sort -u file                         # unique, sorted

uniq -c                              # count adjacent duplicates (sort first!)
uniq -d                              # only duplicated lines

tr 'a-z' 'A-Z' < file                # uppercase
tr -d '\r' < file                    # strip CR (Windows files)
tr -s ' ' < file                     # squeeze repeated spaces

find . -name "*.tmp" | xargs rm      # apply to many
find . -name "*.log" -print0 | xargs -0 wc -l   # safe with spaces
echo "a b c" | xargs -n1 echo        # one argument per line
```

**The golden rule:** `uniq` only removes **adjacent** duplicates, so `sort | uniq -c` is the standard
combination, never `uniq` alone.

---

## Recipes you will reuse

### 1. Top 10 IPs in an access log
```bash
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

### 2. Count errors per hour
```bash
grep ERROR app.log | cut -d' ' -f2 | cut -d: -f1 | sort | uniq -c
```

### 3. Sum a CSV column, excluding the header
```bash
awk -F, 'NR>1 {s+=$4} END {printf "%.2f\n", s}' data.csv
```

### 4. List users with real shells
```bash
awk -F: '$7 !~ /nologin|false/ {print $1, $7}' /etc/passwd
```

### 5. Find the biggest files and print both name and size
```bash
find /var/log -type f -printf '%s %p\n' 2>/dev/null | sort -rn | head -5 |
  awk '{printf "%.1f MB  %s\n", $1/1024/1024, $2}'
```

### 6. Rewrite a config key (safe, with backup)
```bash
key=port
value=9090
sed -i.bak -E "s/^(${key}=).*/\1${value}/" app.conf
```

### 7. Convert CSV to a simple report
```bash
awk -F, 'NR>1 {printf "%-12s %-6s %8s\n", $3, $5, $4}' orders.csv | sort -k3 -rn
```

### 8. Deduplicate a list while keeping order
```bash
awk '!seen[$0]++' file
```
`!seen[$0]++` is a classic idiom: it prints the line only the first time it is seen.

---

## Inside scripts: the patterns that matter

### Capture a value
```bash
errors=$(grep -c ERROR "$log" || true)      # `|| true` because grep exits 1 when no match
[[ "$errors" =~ ^[0-9]+$ ]] || errors=0
```

⚠️ With `set -e`, a `grep` that finds nothing returns 1 and **kills your script**. Either add `|| true` or
put it in a condition:
```bash
if errors=$(grep -c ERROR "$log"); then :; else errors=0; fi
```
This trips up every beginner exactly once.

### Iterate over parsed fields
```bash
awk -F, 'NR>1 {print $1, $3}' data.csv | while read -r id name; do
  echo "id=$id name=$name"
done
```

### Avoid `cat | grep`
```bash
cat file | grep x        # wasteful (extra process)
grep x file              # same result, simpler
```
Use `cat` only when you genuinely need to concatenate files.

### Use `printf`, not `echo`, for formatted output
```bash
printf '%-20s %6d %s\n' "$name" "$count" "$status"
```
`echo` behaviour varies with flags and escapes; `printf` is predictable.

---

## Practice

Create `data.csv`:
```bash
cat > data.csv <<'EOF'
id,name,dept,amount,status
1,alice,dev,1200,paid
2,bob,ops,300,pending
3,carol,dev,780,paid
4,dave,qa,450,refunded
5,erin,dev,2200,paid
EOF
```

Write `06-report.sh` that prints:

1. Total number of records (excluding the header).
2. Total amount of all records.
3. Total amount **only** for `paid`.
4. The department with the highest total amount.
5. A per-department summary, sorted by amount descending, nicely aligned with `printf`.
6. A list of unique departments, one per line.
7. The name of the person with the highest single amount.
8. Everything above must use `awk`/`sort`/`cut`/`uniq` — no `python`.

Then write `06-log-summary.sh`:
9. Take a log file argument (default `app.log`).
10. Print counts of `ERROR`, `WARNING`, `INFO` lines.
11. Print the 3 most frequent messages (strip timestamps).
12. Exit `1` if there are any `ERROR` lines, `0` otherwise (useful for monitoring).

<details>
<summary>Answer: 06-report.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

file="${1:-data.csv}"
[[ -f "$file" ]] || { echo "no such file: $file" >&2; exit 1; }

echo "records:        $(awk 'NR>1' "$file" | wc -l)"
echo "total amount:   $(awk -F, 'NR>1 {s+=$4} END {printf "%.2f", s}' "$file")"
echo "paid total:     $(awk -F, 'NR>1 && $5=="paid" {s+=$4} END {printf "%.2f", s}' "$file")"

echo "top dept:       $(awk -F, 'NR>1 {t[$3]+=$4} END {for (d in t) print t[d], d}' "$file" |
                       sort -rn | head -1 | awk '{print $2" ("$1")"}')"

echo
echo "per-department:"
awk -F, 'NR>1 {t[$3]+=$4} END {for (d in t) printf "%-8s %10.2f\n", d, t[d]}' "$file" |
  sort -k2 -rn

echo
echo "departments:"
awk -F, 'NR>1 {print $3}' "$file" | sort -u

echo
echo "top single amount: $(awk -F, 'NR>1 && $4>max {max=$4; who=$2} END {print who" ("max")"}' "$file")"
```
</details>

<details>
<summary>Answer: 06-log-summary.sh</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail

log="${1:-app.log}"
[[ -f "$log" ]] || { echo "no such file: $log" >&2; exit 2; }

for level in ERROR WARNING INFO; do
  printf '%-8s %d\n' "$level" "$(grep -c "$level" "$log" || true)"
done

echo
echo "top messages:"
sed -E 's/^\[[^]]*\] *//; s/^[0-9-]+ [0-9:]+ *//' "$log" |
  sort | uniq -c | sort -rn | head -3

if grep -q "ERROR" "$log"; then
  exit 1
fi
exit 0
```
</details>

## Cheat card

```bash
grep -c / -n / -v / -i / -q / -E / -o
cut -d: -f1          awk -F, 'NR>1 {s+=$4} END {print s}'
sed -n '5,10p'       sed -i.bak 's/a/b/g'
sort -n / -h / -rn / -k2   sort | uniq -c | sort -rn
tr 'a-z' 'A-Z'       xargs -0
awk '!seen[$0]++'    means "print first occurrence only"
```

Next: `07-error-handling.md`.
