#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_usb_dev_props () {
  local DEV="$1"
  [ "${DEV:0:1}" == / ] && shift
  if [ -z "$*" ]; then
    $DBGP "${DEV:-*}: no criteria"
    return 3
  fi
  if [ "${DEV:0:1}" != / ]; then
    $DBGP "* ?×$#"
    for DEV in /sys/bus/usb/devices/[0-9]*/[0-9]*/; do
      "$FUNCNAME" "$DEV" "$@" && return 0
    done
    return 2
  fi
  # $DBGP "$DEV ?×$#"
  [ -f "$DEV"/busnum ] || return 3
  [ -f "$DEV"/devnum ] || return 3
  local -A META=(
    [busaddr]="$(cat -- "$DEV"busnum):$(cat -- "$DEV"devnum)"
    )
  META[descr]="$(LANG=C lsusb -s "${META[busaddr]}")"
  # ^-- lsusb description: for devices that lack "manufacturer" or "product"
  META[descr]="${META[descr]#* ID * }"
  local OPT= ARG=
  for ARG in "$@"; do
    OPT="${ARG%=**}"; OPT="${OPT// /}"; ARG="${ARG#*=}"; ARG="${ARG# }"
    case "$OPT" in
      '' ) continue;;
      %* ) chk_core_eq "$DEV$OPT" "${META[${OPT#\%}]}" "$ARG" || return 2;;
      * ) chk_file_data_eq "$DEV$OPT" "$ARG" || return 2;;
    esac
  done
  return 0
}
