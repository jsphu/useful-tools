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

  local OPTIND=1 COLOR="$BLU" LEVEL=0 NEWLINE=$'\n' OUTPUT= REDIRECT_TO_STDERROR=false TIMESTAMP="${LOGTIMESTAMP}" ENABLE_BANNER=true ENABLE_HEADER=true FORCE_NO_COLOR=false
  while getopts ":hb:c:el:no:O:Et:d" opt; do
    case "$opt" in
    d) ENABLE_BANNER=false ;;
    \-) break ;;
    h)
      echo "Usage: log [-heEnd] [-b BANNER] [-c COLOR] <message> <message>..."
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
    t) TIMESTAMP="$OPTARG" ;;
    e) ENABLE_HEADER=false ;;
    l) LEVEL="$OPTARG" ;;
    n) NEWLINE="" ;;
    o) OUTPUT="$OPTARG" ;;
    O)
      OUTPUT="$OPTARG"
      FORCE_NO_COLOR=true
      ;;
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

  if "$FORCE_NO_COLOR" || [[ -f "$OUTPUT" && "$LOGALWAYSCOLOR" != "1" ]]; then
    unset COLOR RED YLW GRN BLU MAG CYN BOLD NC
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

  if [ -n "$BANNER" ]; then
    BANNER="[$BANNER] "
  fi

  if [ -z "$TIMESTAMP" ]; then
    LC_ALL=C printf -v TIMESTAMP \
      "[%(%d-%m-%Y %H:%M:%S)T.%s%(%Z)T] " \
      "$EPOCHSECONDS" "${EPOCHREALTIME##*,}"

  elif [[ "$TIMESTAMP" =~ %\(.*\)T ]]; then
    TIMESTAMP="${TIMESTAMP#'['}"
    TIMESTAMP="${TIMESTAMP%']'}"
    LC_ALL=C printf -v TIMESTAMP "[$TIMESTAMP] "

  elif [[ "$TIMESTAMP" =~ % ]]; then
    LC_ALL=C printf -v TIMESTAMP "[%(${TIMESTAMP})T] "

  else
    TIMESTAMP=""
  fi

  local HEADER
  if $ENABLE_HEADER; then

    HEADER="${COLOR}${TIMESTAMP}"

    if $ENABLE_BANNER; then
      HEADER+="${BANNER}"
    fi
  fi

  if "$REDIRECT_TO_STDERROR"; then
    printf "%s%s%b%s%b" "$HEADER" "${BOLD}" "$message" "${NC}" "$NEWLINE" >&2 >>${OUTPUT:-/dev/stderr}
  else
    printf "%s%s%b%s%b" "$HEADER" "${BOLD}" "$message" "${NC}" "$NEWLINE" >>${OUTPUT:-/dev/stdout}
  fi
}

logread() {
  local OPTIND=1 LOGLINE="log " line= LEVEL=0 current_level=0
  local DEFAULT_LEVEL=0 DEFAULT_COLOR="B"
  while getopts eEb:l:L:c:t:d opt; do
    case "$opt" in
    d) LOGLINE+=" -d " ;;
    t) LOGLINE+=" -t $OPTARG " ;;
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
    *warn* | *caution* | *alert* | *notice* | \
      *be\ careful* | *watch\ out* | *look\ out* | *heads\ up*)
      LOGLINE+="-cy "
      line="[Y]$line"
      ;;
    *error* | *no\ *\ found* | \
      *not\ found* | *err\ * | \
      *no\ such* | *fail* | *fatal* | \
      *not\ allowed* | *cannot* | *denied* | \
      *permission* | *invalid* | *exception* | *abort* | \
      *crash* | *segmentation* | *core\ dumped* | \
      *unhandled* | *unrecognized* | *not\ supported* | \
      *not\ implemented* | *not\ available* | \
      *not\ permitted* | *not\ authorized* | *not\ accessible* | \
      *not\ reachable* | *not\ responding* | *not\ working* | \
      *not\ functioning* | *not\ operational* | *not\ active* | \
      *not\ running* | *not\ started* | *not\ initialized* | \
      *not\ configured* | *not\ installed* | *not\ loaded* | \
      *not\ connected* | *not\ detected* | *not\ recognized* | \
      *refused* | *unauthorized* | *forbidden*)
      LOGLINE+="-cr "
      line="[R]$line"
      ;;
    *info* | *\ tip* | *hint* | *note* | *suggestion* | \
      *recommendation* | *advice* | *guidance* | *instruction*)
      LOGLINE+="-cc "
      ((current_level++))
      line="[C]$line"
      ;;
    *debug* | *trace* | *verbose* | *detail* | \
      *diagnostic* | *tracing*)
      LOGLINE+="-cm "
      ((current_level += 2))
      line="[M]$line"
      ;;
    *success* | *\ ok\ * | *\ okay\ * | *done* | \
      *succeed* | *complete* | *finished* | \
      *passed* | *verified* | *validated* | \
      *confirmed* | *accepted* | *approved* | \
      *enabled* | *activated* | *installed* | \
      *loaded* | *connected* | *detected* | \
      *recognized* | *reachable* | *responding*)
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
