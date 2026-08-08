# Some {scripts,tools} that i {built,found}

Here is some of them with their usages.

### `log`

Logger utility for scripts with color-coded language support

```sh
. log.sh
log -b BANNER -c (r|g|b|y|w|m|c) "Hello world! [R]this is a red text.[] now default color, [G]green text.[] etc."
# works on log.bash, log.sh is not supports these yet.
source log.bash # source first
LOGQUIETMODE=0 # silence any log when set to 1
LOGALWAYSCOLOR=0 # force color output when set to 1
LOGNOCOLOR=0 # force no color output when set to 1
LOGLEVEL=0 # set levels to see upper level log messages
log -l1 "Level 1" # won't seen on LOGLEVEL=0
log -l2 "Level 2" # won't seen below LOGLEVEL=2 etc.
```

### `subtime`

Subtracts time while preserving formatting.

```bash
subtime 12:30:00 13:45:00
# Protip: Use '-' for current time
subtime - 15:00:00
```

### `tdk`

Turkish dictionary (TDK API) in terminal.

```bash
tdk kelime
```

### `utc`

Displays time for a specific timezone or country.

```bash
utc germany
```

### `paste2file`

Pastes clipboard content to a file.

```bash
paste2file output.txt
```

### `morse`

Live morse code transcriber with audio.

```bash
morse
# Start typing to hear morse code
```

### `ocrshotclip`

Performs OCR on a screenshot and copies result to clipboard.

```bash
ocrshotclip             # Uses most recent screenshot
ocrshotclip image.png eng
```

### `stats`

Real-time resource monitor (CPU, RAM, GPU, Network) on a single line.

```bash
stats 500  # 500ms interval
```

### `useful_aliases`

Handy shell aliases.

```bash
source useful_aliases
```

### `timerclock`

Timer and chronometer with optional notifications.

```bash
timerclock 60          # 60 seconds timer
timerclock -t 13:30    # Timer until 13:30
timerclock -r          # Chronometer mode
```

### `venv`

Interactively find and source Python virtual environments.

```bash
source venv
```

### `basicalarm`

Alarm script with notifications and audio.

```bash
basicalarm 600         # Alarm in 10 minutes
basicalarm at 15:00    # Alarm at specific time
```

### `import`

Modular script/function importing for Bash.

```bash
source import
import myfunc from script in ./lib as newfunc
```

## License

UNLICENSE

Do whatever you want with these.
