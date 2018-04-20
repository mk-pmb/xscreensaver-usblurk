#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_usb_dev_props () {
  local DEV="$1"
  if [ "${DEV:0:1}" != / ]; then
    $DBGP "* ?×$#"
    for DEV in /sys/bus/usb/devices/*/[0-9]*/; do
      "$FUNCNAME" "$DEV" "$@" && return 0
    done
    return 2
  fi
  shift
  # $DBGP "$DEV ?×$#"
  if [ -z "$*" ]; then
    $DBGP "no criteria"
    return 3
  fi
  local OPT= ARG=
  for ARG in "$@"; do
    OPT="${ARG%=**}"; OPT="${OPT// /}"; ARG="${ARG#*=}"; ARG="${ARG# }"
    [ -n "$OPT" ] || continue
    chk_file_data_eq "$DEV$OPT" "$ARG" || return 2
  done
  return 4
}
