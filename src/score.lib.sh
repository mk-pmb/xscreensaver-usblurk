# -*- coding: utf-8, tab-width: 2 -*-

function rescore () {
  local ITEM=
  SCORE=0
  for ITEM in "$CFG_DIR"/*.rule.sh; do
    [ -f "$ITEM" ] || continue
    source -- "$ITEM" && continue
    echo "E: score reset due to rule failure: $ITEM" >&2
    SCORE=0
    return 2
  done
  $DBGP "score=$SCORE stability=$STABILITY"
}

function score_stable_accept () {
  local SCORE=
  local STABILITY=0
  local MIN_STAB="${XSCLURK_ACCEPTABLE_SCORE_STABILITY:-4}"
  while [ "$STABILITY" -lt "$MIN_STAB" ]; do
    rescore
    [ "$SCORE" -ge 1 ] || return 3
    sleep 0.5s
    let STABILITY="$STABILITY+1"
  done
}

function xsc_score () {
  $DBGP "$FUNCNAME $*"
  let SCORE="$SCORE ${*#=}" 1 && return 0
  echo "E: score reset due to unsupported score formula: $1" >&2
  # :TODO: stack trace
  SCORE=0
  return 2
}

function chk () {
  local CHK_ARGS=()
  IFS= readarray -t CHK_ARGS < <(printf '%s\n' "$@")
  local CHK_NAME="${CHK_ARGS[0]}"; shift
  CHK_ARGS=( "${CHK_ARGS[@]:1}" )
  DBGP="$DBGP $CHK_NAME:" chk_"$CHK_NAME" "${CHK_ARGS[@]}"; return $?
}

function vchk () {
  echo -n "$FUNCNAME:"; printf ' ‹%s›' "$@"; echo :
  chk "$@"
  local RV=$?
  echo "rv=$RV"
  return $RV
}

function chk_core_eq () {
  local SUBJ="$1"; shift
  local HAVE="$1"; shift
  local WANT="$1"; shift
  if [ "$HAVE" == "$WANT" ]; then
    $DBGP "$SUBJ: = '$WANT'"
    return 0
  fi
  $DBGP "$SUBJ: '$HAVE' != '$WANT'"
  return 2
}
