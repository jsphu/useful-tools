log() {
  ESC=$(printf '\033')
  RED="${ESC}[31m"
  YLW="${ESC}[33m"
  GRN="${ESC}[32m"
  BLU="${ESC}[34m"
  MAG="${ESC}[35m"
  CYN="${ESC}[36m"
  BOLD="${ESC}[1m"
  NC="${ESC}[0m"

  if [ "$LOGQUIETMODE" = "1" ]; then
    return 0
  fi

  OPTIND=1
  BANNER="$0"
  COLOR="$YLW"
  column=""

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

  message="$*"

  if [ -n "$message" ]; then
    message=$(echo "$message" | sed \
      -e "s/\[R\]/${RED}/g" \
      -e "s/\[Y\]/${YLW}/g" \
      -e "s/\[G\]/${GRN}/g" \
      -e "s/\[B\]/${BLU}/g" \
      -e "s/\[M\]/${MAG}/g" \
      -e "s/\[C\]/${CYN}/g" \
      -e "s/\[W\]/${NC}/g" \
      -e "s/\[\]/${COLOR}/g")
  fi

  HEADER=""
  if [ -n "$BANNER" ] && [ -n "$COLOR" ]; then
    if [ -n "$message" ]; then
      column=": "
    fi

    COLOR_CLEAN=$(echo "$COLOR" | sed 's/1/0/g')
    TIMESTAMP=$(date "+%d-%m-%Y %H:%M:%S")

    HEADER="${COLOR_CLEAN}[${TIMESTAMP}][${BANNER}]${column}"
  fi

  printf "%s%s%s%s\n" "$HEADER" "${BOLD}" "${message}" "${NC}"
}
