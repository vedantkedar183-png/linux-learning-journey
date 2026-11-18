# 02 — Variables, Input, and Arguments

## Variables

A variable is a named box holding text. In Bash, **everything is text** — numbers are text that arithmetic
can interpret.

```bash
name="Linux"
version=6
greeting="Hello, $name"
echo "$greeting"        # Hello, Linux
```

Three critical syntax rules:

1. **No spaces around `=`.** `name = "Linux"` is an error (or worse, runs `name` with arguments).
2. **Use `$` to read, no `$` to assign.** `name="x"` assigns; `echo "$name"` reads.
3. **Quote when you read.** `"$name"` keeps spaces together.

```bash
$ name = "Linux"
bash: name: command not found        # bash tried to run the command "name"
```

### Variable naming
- lowercase or UPPER_CASE, digits and underscores: `backup_dir`, `MAX_RETRIES`
- must not start with a digit
- by convention, environment variables are UPPER_CASE (`HOME`, `PATH`), local script variables lowercase

### Useful built-in variables
```bash
$ echo "$HOME"      # /home/student
$ echo "$USER"      # student
$ echo "$PWD"       # current directory
$ echo "$SHELL"     # /bin/bash
$ echo "$$"         # PID of this shell
$ echo "$?"         # exit code of the last command
$ echo "$RANDOM"    # random number 0-32767
$ echo "$LINENO"    # current line number (good for debugging)
```

### Default values
```bash
target="${1:-/tmp}"        # use $1 if set, else /tmp
target="${1:?usage: script.sh TARGET}"   # exit with an error if $1 is unset
name="${NAME:-anonymous}"
```
`${var:-default}` is the idiom for optional settings. Learn it early; it removes half your `if` statements.

---

## Arguments: `$1`, `$2`, `$@`

When you run `./script.sh alpha beta`, the script receives:

| Variable | Value |
|---|---|
| `$0` | `./script.sh` (script name) |
| `$1` | `alpha` |
| `$2` | `beta` |
| `$#` | `2` (number of arguments) |
| `$@` | `alpha` `beta` (all arguments, as separate words) |
| `$*` | `alpha beta` (all arguments, as one word) |

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <name>" >&2
  exit 1
fi

echo "Hello, $1! You passed $# argument(s)."
```

```bash
$ ./greet.sh Alice
Hello, Alice! You passed 1 argument(s).
```

**`"$@"` vs `"$*"`:** always loop with `"$@"`. It preserves argument boundaries, so filenames with spaces
survive:
```bash
for arg in "$@"; do
  echo "arg: $arg"
done
```

### Shift: consume arguments one by one
```bash
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose) verbose=1; shift ;;
    -o|--output)  out="$2"; shift 2 ;;
    *)            file="$1"; shift ;;
  esac
done
```
This is how real command-line tools parse options.

---

## Reading input: `read`

```bash
#!/usr/bin/env bash
read -rp "What is your name? " name
echo "Hello, $name"
```

- `-r` — do not interpret backslashes (always use it).
- `-p "prompt"` — print a prompt.
- `-s` — silent (for passwords).
- `-n 1` — read one character.

```bash
read -rsp "Password: " pass; echo     # -s hides typing; echo adds the newline
read -rp "Continue? [y/N] " ans
case "$ans" in y|Y) echo "go" ;; *) echo "stop" ;; esac
```

### Reading a file line by line
```bash
while IFS= read -r line; do
  echo "LINE: $line"
done < "$file"
```
- `IFS=` prevents trimming leading/trailing spaces.
- `-r` prevents backslash mangling.
- `< "$file"` feeds the file as input.
This is the correct, standard idiom. Memorise it.

⚠️ **Do not use `for line in $(cat file)`** — it splits on spaces, breaks on `*`, and loads everything into
memory. It is the most common beginner bug in file processing.

---

## Arithmetic

```bash
a=5
b=3
echo $((a + b))         # 8
echo $((a * b))         # 15
echo $((a / b))         # 1   (integer division!)
echo $((a % b))         # 2
((a++))                 # increment; returns 0 if result non-zero
((total += 10))

# for decimals, use bc or awk
echo "scale=2; 10/3" | bc            # 3.33
awk 'BEGIN {printf "%.2f\n", 10/3}'  # 3.33
```

Bash has **no floating point**. For money, percentages, or measurements, use `bc` or `awk`.

---

## Environment variables vs shell variables

```bash
myvar="local"          # shell variable: this shell only
export MYVAR="shared"  # environment variable: inherited by child processes
```

```bash
$ myvar="x"; bash -c 'echo "myvar=$myvar"'      # empty — not exported
$ export MYVAR="x"; bash -c 'echo "MYVAR=$MYVAR"'   # x
```

That is why `PATH` works: it is exported. When you set a variable for a script, export it:
```bash
$ LOG_LEVEL=debug ./run.sh
$ LOG_LEVEL=debug bash run.sh
```

### Changing `PATH` for your scripts
```bash
$ mkdir -p ~/bin
$ echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
$ source ~/.bashrc
```
Then any executable in `~/bin` runs by name from anywhere.

---

## `local`: variables should not leak

```bash
count=0
increment() {
  local count=1        # a NEW variable, separate from the outer one
  echo "$count"        # 1
}
increment
echo "$count"          # 0 — untouched
```
Without `local`, the function would overwrite the caller's variable. Use `local` for every variable inside
a function. Always.

---

## Practice

Write `02-greeting.sh`:

1. Ask for the user's name with `read -rp`.
2. If the name is empty, use `anonymous` (with `${name:-anonymous}`).
3. Ask for their favourite Linux distro.
4. Print: `Hello <name>, your favourite distro is <distro>.`
5. Print the number of arguments the script received (`$#`).
6. Add a second mode: if `$1` is given, use it as the name instead of asking.

Then `02-args.sh`:

7. Accept exactly two arguments and print them in reverse order.
8. Exit with code `1` and a usage message if fewer than two are given.
9. Print `$0`, `$#`, and `"$@"` on separate lines.
10. Loop over `"$@"` and print each argument with its index.

<details>
<summary>Answers</summary>

```bash
#!/usr/bin/env bash
set -euo pipefail
name="${1:-}"
if [[ -z "$name" ]]; then
  read -rp "Your name: " name
fi
name="${name:-anonymous}"
read -rp "Favourite distro: " distro
echo "Hello $name, your favourite distro is $distro."
echo "Arguments received: $#"
```

```bash
#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <first> <second>" >&2
  exit 1
fi
echo "Second: $2"
echo "First:  $1"
echo "Script: $0"
echo "Count:  $#"
printf 'All:    %s\n' "$@"
i=0
for arg in "$@"; do
  i=$((i + 1))
  echo "$i: $arg"
done
```
</details>

## Cheat card

```bash
var="value"                 # assign (no spaces!)
echo "$var"                 # read, quoted
"${var:-default}"           # default if empty
"${var:?error message}"     # fail if empty
"${#var}"                   # length
"${var%.txt}"               # remove shortest suffix match
"${var%%.*}"                # remove longest suffix match
"${var#prefix}"             # remove shortest prefix match
"${var,,}" / "${var^^}"     # lowercase / uppercase
$((a + b))                  # arithmetic
$(command)                  # command substitution
read -rp "prompt" var       # input
"$1" "$2" ... "$@"          # arguments
$#                          # argument count
shift                       # drop $1, shift the rest down
```

Next: `03-conditionals.md`.
