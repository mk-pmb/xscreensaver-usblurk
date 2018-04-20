# -*- coding: utf-8, tab-width: 2 -*-

function rescore () {
  local ITEM=
  for ITEM in "$CFG_DIR"/*.rule.sh; do
    [ -f "$ITEM" ] || continue
    source "$ITEM" && continue
    echo "E: score reset due to rule failure: $ITEM" >&2
    SCORE=0
    return 2
  done
}

function score_stable_accept () {
  local SCORE=
  local STABILITY=0
  while [ "$STABILITY" -lt 20 ]; do
    SCORE=0
    rescore
    $DBGP "score=$SCORE stability=$STABILITY"
    [ "$SCORE" -ge 1 ] || return 3
    sleep 0.1s
    let STABILITY="$STABILITY+1"
  done
  return 0
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
  chk_"${CHK_ARGS[@]}"; return $?
}

function vchk () {
  echo -n "$FUNCNAME:"; printf ' ‹%s›' "$@"; echo -n ': '
  chk "$@"
  local RV=$?
  echo "rv=$RV"
  return $RV
}
