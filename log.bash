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

  local OPTIND=1 COLOR="$BLU" column="" LEVEL=0 NEWLINE=$'\n'
  while getopts "hb:c:el:n" opt; do
    case "$opt" in
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

  printf "%s%s%b%s%b" "$HEADER" "${BOLD}" "$message" "${NC}" "$NEWLINE"
}
