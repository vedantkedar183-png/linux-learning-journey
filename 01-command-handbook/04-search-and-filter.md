# 04 — Search and Filter: Find Anything, Shape Any Output

**The idea:** Linux gives you small tools that each do one thing. You connect them with pipes (`|`)
to answer real questions. This page is the difference between "a user" and "someone who is fast".

---

## Finding files

### `find` — search by name, size, time, type, permissions
```bash
$ find . -name "*.txt"                     # by name (case-sensitive), from here down
$ find . -iname "*.TXT"                    # case-insensitive
$ find /etc -type f -name "*.conf"         # only files with .conf
$ find . -type d -name "backup*"           # only folders
$ find . -size +10M                        # bigger than 10 MB
$ find . -mtime -7                         # modified in the last 7 days
$ find . -empty                            # empty files and folders
$ find . -name "*.tmp" -delete             # delete matches (test first with -print!)
$ find . -name "*.log" -exec wc -l {} \;   # run a command on each match
```

`find` is precise and works everywhere. `locate` is faster but relies on a database:
```bash
$ sudo updatedb          # refresh the index
$ locate nginx.conf
```

### `which`, `whereis`, `type` — where does this command live?
```bash
$ which python3          # path of the executable
$ whereis nano           # binary + man page + source
$ type cd                # is it a builtin, alias, or file?
```

---

## Searching inside files

### `grep` — print lines that match
```bash
$ grep "error" app.log                # basic
$ grep -i "error" app.log             # ignore case
$ grep -n "error" app.log             # show line numbers
$ grep -c "error" app.log             # count matching lines
$ grep -v "debug" app.log             # INVERT: lines that do NOT match
$ grep -r "timeout" /etc/             # recursive through a folder
$ grep -r -l "TODO" .                 # only file NAMES containing matches
$ grep -w "cat" file.txt              # whole word only (not "category")
$ grep -E "error|fail|critical" app.log   # extended regex: OR
$ grep -A2 -B2 "error" app.log        # 2 lines After and Before each match
```

Regex in 60 seconds:
| Pattern | Means |
|---|---|
| `^word` | line starts with "word" |
| `word$` | line ends with "word" |
| `w.rd` | any single character in the middle |
| `ab*c` | a, then any number of b, then c |
| `[0-9]+` | one or more digits (with `-E`) |
| `error\|fail` | error OR fail (with `-E`) |

---

## Shaping output with pipes

### `sort` — order lines
```bash
$ sort file.txt                # alphabetical
$ sort -n numbers.txt          # numeric
$ sort -h sizes.txt            # human sizes (K, M, G)
$ sort -r                      # reverse
$ sort -u                      # sort and remove duplicates
$ sort -k2 -n                  # sort by 2nd column, numerically
$ sort file.txt | uniq -c      # count duplicates (input must be sorted!)
```

### `uniq` — collapse repeated adjacent lines
```bash
$ uniq -c file.txt             # count occurrences
$ uniq -d file.txt             # only duplicated lines
$ sort access.log | uniq -c | sort -rn | head
```

### `cut` — take columns
```bash
$ cut -d: -f1 /etc/passwd      # field 1, split on ":"
$ cut -c1-10 file.txt          # first 10 characters
$ cut -d, -f2,4 data.csv       # fields 2 and 4 of a CSV
```

### `awk` — columns + logic (the Swiss army knife)
```bash
$ awk '{print $1}' file.txt                    # first whitespace-separated column
$ awk '{print $1, $3}' file.txt                # columns 1 and 3
$ awk -F: '{print $1, $7}' /etc/passwd         # custom separator
$ awk '{sum += $1} END {print sum}' numbers.txt   # total of column 1
$ awk '$3 > 100 {print $1}' data.txt           # rows where col 3 > 100
$ awk 'NR>1' data.csv                          # skip the header row
```

### `sed` — find and replace in a stream
```bash
$ sed 's/old/new/' file.txt            # replace first on each line
$ sed 's/old/new/g' file.txt           # replace all (global)
$ sed -i 's/8080/9090/g' config.conf   # edit the file in place
$ sed -n '10,20p' file.txt             # print only lines 10-20
$ sed '/^#/d' config.conf              # delete comment lines
```

### `tr`, `xargs`, `paste`
```bash
$ echo "Hello" | tr 'a-z' 'A-Z'              # HELLO
$ cat file.txt | tr -s ' '                   # squeeze repeated spaces
$ find . -name "*.tmp" | xargs rm            # turn lines into arguments
$ find . -name "*.log" -print0 | xargs -0 wc -l   # safe with spaces in names
$ paste -d, names.txt emails.txt             # join two files side by side
```

---

## The pipe recipes you will use forever

```bash
# 1. Top 10 IPs hitting your web server
$ awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10

# 2. Top 5 biggest files/folders here
$ du -sh * | sort -h | tail -5

# 3. Count errors per hour
$ grep ERROR app.log | cut -d' ' -f1-2 | sort | uniq -c

# 4. Every user with a real login shell
$ grep -v "nologin\|false" /etc/passwd | cut -d: -f1

# 5. Biggest 10 files on the system
$ sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

# 6. Which ports are listening
$ ss -tulpn | grep LISTEN

# 7. Unique file extensions in a folder
$ ls | awk -F. 'NF>1 {print $NF}' | sort | uniq -c | sort -rn

# 8. Lines present in file A but not in file B
$ grep -vxFf b.txt a.txt
```

Read a pipe **right to left** when confused: "take the biggest, show 5".

---

## Practice lab

```bash
$ cd ~/linux-lab
$ rm -rf practice/search && mkdir -p practice/search/data && cd practice/search
$ printf "alice,30,dev\nbob,25,ops\ncarol,41,dev\ndave,19,qa\n" > people.csv
$ seq 1 100 | sed 's/^/line /' > numbers.txt
$ echo "ERROR db down" > app.log
$ echo "info ok" >> app.log
$ echo "ERROR timeout" >> app.log
$ echo "warning slow" >> app.log
$ touch a.tmp b.tmp keep.txt
```

1. Find every `.tmp` file under `practice/search` and show its path.
2. Print the 3rd column (`dev`, `ops`, …) of `people.csv`.
3. Print names of people over 29. (Hint: `awk -F, '$2 > 29 {print $1}'`)
4. Count how many `ERROR` lines `app.log` has.
5. Show `app.log` lines that are not `info`.
6. Print lines 20–25 of `numbers.txt`.
7. Print all numbers in `numbers.txt` without the word "line".
8. Replace every `ERROR` with `CRITICAL` in `app.log` and save to `critical.log` (do not modify the
   original).
9. How many **different** words appear in column 3 of `people.csv`?
10. Delete only the `.tmp` files, but first list them.

<details>
<summary>Answers</summary>

```bash
find . -name "*.tmp"                        # 1
cut -d, -f3 people.csv                      # 2
awk -F, '$2 > 29 {print $1}' people.csv     # 3
grep -c ERROR app.log                       # 4
grep -v info app.log                        # 5
sed -n '20,25p' numbers.txt                 # 6
awk '{print $2}' numbers.txt                # 7
sed 's/ERROR/CRITICAL/g' app.log > critical.log   # 8
cut -d, -f3 people.csv | sort -u | wc -l    # 9 -> 3 (dev ops qa)
find . -name "*.tmp"                        # 10a: review
find . -name "*.tmp" -delete                # 10b
```
</details>

---

## One habit that will save you

Before any destructive `find ... -delete` or `find ... -exec rm`, run the **exact same command
without** the delete part and read the list. Then add the delete. Every single time.
