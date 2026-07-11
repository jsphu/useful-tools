log() {
  local RED="\033[1;31m" YLW="\033[1;33m" GRN="\033[1;32m" NC="\033[0m"
  local BLU="\033[1;34m" MAG="\033[1;35m" CYN="\033[1;36m"

  # Global Quiet Flag
  if [[ "$LOGQUIETMODE" == "1" ]]; then
    return 0
  fi

  local OPTIND=1 BANNER=SYSTEM COLOR="$YLW" HEADER column
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
    e) BANNER= COLOR= HEADER= ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  local message="$@"
  message="${message//\[R\]/${RED}}"
  message="${message//\[Y\]/${YLW}}"
  message="${message//\[G\]/${GRN}}"
  message="${message//\[B\]/${BLU}}"
  message="${message//\[M\]/${MAG}}"
  message="${message//\[C\]/${CYN}}"
  message="${message//\[\]/${NC}}"

  if [[ -n "$BANNER" && -n "$COLOR" ]]; then
    if [[ -n "$message" ]]; then
      column=": "
    fi
    printf -v HEADER '%b[%(%d-%m-%Y %H:%M:%S)T][%s]%s%b' "${COLOR/1/0}" "$EPOCHSECONDS" "${BANNER}" "$column" "${NC}"
  fi
  printf "%b%b%b\n" "$HEADER" "${message}" "${NC}"
}
