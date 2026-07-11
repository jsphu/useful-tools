log() {
  local ESC=$'\033'
  local RED="${ESC}[31m" YLW="${ESC}[33m" GRN="${ESC}[32m" BLU="${ESC}[34m"
  local MAG="${ESC}[35m" CYN="${ESC}[36m" BOLD="${ESC}[1m" NC="${ESC}[0m"

  if [ "$LOGQUIETMODE" = "1" ]; then
    return 0
  fi

  local OPTIND=1 BANNER="$0" COLOR="$YLW" column=""
  while getopts "hb:c:e" opt; do
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
    *)
      echo "Invalid option: -$OPTARG" >&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

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
  if [ -n "$BANNER" ] && [ -n "$COLOR" ]; then
    if [ -n "$message" ]; then
      column=": "
    fi

    local COLOR_CLEAN=${COLOR//1/0}
    LC_ALL=C printf -v TIMESTAMP "%(%d-%m-%Y %H:%M:%S)T.%s" "$EPOCHSECONDS" "${EPOCHREALTIME##*,}"

    HEADER="${COLOR_CLEAN}[${TIMESTAMP}][${BANNER}]${column}"
  fi

  printf "%s%s%s%s\n" "$HEADER" "${BOLD}" "${message}" "${NC}"
}
