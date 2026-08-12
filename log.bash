log() {
  local ESC=$'\033'
  local RED="${ESC}[31m" YLW="${ESC}[33m" GRN="${ESC}[32m" BLU="${ESC}[34m"
  local MAG="${ESC}[35m" CYN="${ESC}[36m" BOLD="${ESC}[1m" NC="${ESC}[0m"
  if [[ "$LOGALWAYSCOLOR" != "1" && ! -t 1 || "$LOGNOCOLOR" == "1" ]]; then
    RED= YLW= GRN= BLU= MAG= CYN= BOLD= NC=
  fi

  if [ "$LOGQUIETMODE" = "1" ]; then
    return 0
  fi

  if [ -z "$LOGLEVEL" ]; then
    LOGLEVEL=0
  fi

  local BANNER="${LOGBANNER:-$0}"

  local OPTIND=1 COLOR="$BLU" column="" LEVEL=0 NEWLINE=$'\n' OUTPUT= REDIRECT_TO_STDERROR=false
  while getopts ":hb:c:el:no:E" opt; do
    case "$opt" in
    \-)
      break
      ;;
    h)
      echo "Usage: log [-he] [-b BANNER] [-c COLOR] <message> <message>..."
      return 0
      ;;
    b) BANNER="$OPTARG" ;;
    c)
      case "$OPTARG" in
      r) COLOR="$RED" ;;
      y) COLOR="$YLW" ;;
      g) COLOR="$GRN" ;;
      b) COLOR="$BLU" ;;
      m) COLOR="$MAG" ;;
      c) COLOR="$CYN" ;;
      *) COLOR="$NC" ;;
      esac
      ;;
    e) BANNER="" COLOR="" ;;
    l) LEVEL="$OPTARG" ;;
    n) NEWLINE="" ;;
    o) OUTPUT=">> $OPTARG" ;;
    E) REDIRECT_TO_STDERROR=true ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ "$LOGLEVEL" -lt "$LEVEL" ]]; then
    return 0
  fi

  local message="$*"

  message="${message//\[R\]/${RED}}"
  message="${message//\[Y\]/${YLW}}"
  message="${message//\[G\]/${GRN}}"
  message="${message//\[B\]/${BLU}}"
  message="${message//\[M\]/${MAG}}"
  message="${message//\[C\]/${CYN}}"
  message="${message//\[W\]/${NC}}"
  message="${message//\[\]/${COLOR}}"

  local HEADER=""
  if [ -n "$BANNER" ]; then
    if [ -n "$message" ]; then
      column=": "
    fi

    LC_ALL=C printf -v TIMESTAMP "%(%d-%m-%Y %H:%M:%S)T.%s" "$EPOCHSECONDS" "${EPOCHREALTIME##*,}"

    HEADER="${COLOR}[${TIMESTAMP}][${BANNER}]${column}"
  fi

  if [ "$REDIRECT_TO_STDERROR" = true ]; then
    printf "%s%s%b%s%b" "$HEADER" "${BOLD}" "$message" "${NC}" "$NEWLINE" ${OUTPUT} >&2
  else
    printf "%s%s%b%s%b" "$HEADER" "${BOLD}" "$message" "${NC}" "$NEWLINE" ${OUTPUT}
  fi
}

logread() {
  local OPTIND=1 LOGLINE="log " line= LEVEL=0 current_level=0
  local DEFAULT_LEVEL=0 DEFAULT_COLOR="B"
  while getopts eEb:l:L:c: opt; do
    case "$opt" in
    e) LOGLINE+="-e " ;;
    E) LOGLINE+="-E " ;;
    b) LOGLINE+="-b $OPTARG " ;;
    l) LEVEL="$OPTARG" ;;
    L) DEFAULT_LEVEL="$OPTARG" ;;
    c) DEFAULT_COLOR="${OPTARG^}" ;;
    esac
  done
  while read -r line; do
    current_level="$LEVEL"

    if [[ "$line" =~ ([[:space:]]|[^[:print:]]) ]]; then
      line="${line//$'\n'/'\n'}"
      line="${line//$'\r'/'\r'}"
      line="${line//$'\t'/'\t'}"
      line="${line//$'\b'/'\b'}"
      line="${line//$'\a'/'\a'}"
      line="${line//$'\v'/'\v'}"
      line="${line//$'\f'/'\f'}"
      line="${line//$'\e'/'\e'}"
      line="${line//$'\0'/'\0'}"
    fi

    case "${line,,}" in
    *warning* | *warn*)
      LOGLINE+="-cy "
      line="[Y]$line"
      ;;
    *error* | *no\ *\ found* | *not\ found* | *err\ * | *no\ such* | *fail* | *fatal* | *not\ allowed* | *cannot* | *denied* | *permission*)
      LOGLINE+="-cr "
      line="[R]$line"
      ;;
    *info* | *\ tip* | *hint*)
      LOGLINE+="-cc "
      ((current_level++))
      line="[C]$line"
      ;;
    *debug* | *trace*)
      LOGLINE+="-cm "
      ((current_level += 2))
      line="[M]$line"
      ;;
    *success* | *\ ok\ * | *\ okay\ * | *done* | *succeed* | *complete* | *finished*)
      LOGLINE+="-cg "
      line="[G]$line"
      ;;
    *)
      LOGLINE+="-cb "
      ((current_level += DEFAULT_LEVEL))
      line="[${DEFAULT_COLOR:0:1}]$line"
      ;;
    esac

    $LOGLINE -l $current_level $line
  done
}
