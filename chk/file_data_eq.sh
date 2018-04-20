#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_file_data_eq () {
  local FILE="$1"; shift
  local WANT="$1"; shift
  local CODEC="${FILE##*|}"
  [ "$CODEC" == "$FILE" ] && CODEC=
  FILE="${FILE%|*}"
  if [ ! -f "$FILE" ]; then
    $DBGP "$FILE: file not found"
    return 10
  fi
  local DATA=
  case "$CODEC" in
    '' )
      DATA="$(cat -- "$FILE")";;
    base64 )
      DATA="$(base64 --wrap=0 -- "$FILE")";;
    sha1 | sha256 | sha512 | \
    md5 | binsum:* )
      CODEC="${CODEC#*:}"
      DATA="$("$CODEC"sum --binary -- "$FILE")"
      DATA="${DATA%% *}";;
    * )
      echo "W: $CHK_NAME: $FILE: unsupported codec '$CODEC'" >&2
      return 11;;
  esac
  if [ "$DATA" == "$WANT" ]; then
    $DBGP "$FILE: = '$WANT'"
    return 0
  fi
  $DBGP "$FILE: '$DATA' != '$WANT'"
  return 12
}
