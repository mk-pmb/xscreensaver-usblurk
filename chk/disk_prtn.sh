#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_disk_prtn () {
  local OPT= ARG= DISK= SAME=
  for ARG in "$@"; do
    OPT="${ARG%=**}"; OPT="${OPT// /}"; ARG="${ARG#*=}"; ARG="${ARG# }"
    DISK=
    case "$OPT" in
      '' ) continue;;
      uuid | label | id ) DISK="/dev/disk/by-$OPT/$ARG";;
    esac
    if [ ! -e "$DISK" ]; then
      $DBGP "$FUNCNAME: $OPT $ARG not found"
      return 4
    fi
    DISK="$(readlink -m "$DISK")"
    $DBGP "$FUNCNAME: $OPT $ARG = $DISK"
    if [ -z "$SAME" ]; then
      SAME="$DISK"
    elif [ "$SAME" != "$DISK" ]; then
      $DBGP "$FUNCNAME: != $SAME"
      return 5
    fi
  done
  [ -n "$SAME" ] || return 6
  return 0
}
