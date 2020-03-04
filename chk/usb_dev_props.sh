#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_usb_dev_props () {
  local DEV="$1"
  [ "${DEV:0:1}" == / ] && shift
  if [ -z "$*" ]; then
    $DBGP "device ${DEV:-(any)}: no criteria given!"
    return 3
  fi
  if [ "${DEV:0:1}" != / ]; then
    $DBGP "searching for any device matching these criteria: $*"
    local MAYBE_DEVS=()
    readarray -t MAYBE_DEVS < <(sysfs_devpaths_suggest)
    for DEV in "${MAYBE_DEVS[@]}"; do
      "$FUNCNAME" "$DEV" "$@" || continue
      $DBGP "Found acceptable device $DEV" || continue
      return 0
    done
    $DBGP "Found no such device." || continue
    return 2
  fi
  [ -d "$DEV" ] || return 2
  # $DBGP "$DEV ?×$#"
  local -A META=()
  local OPT= ARG=
  for ARG in "$@"; do
    OPT="${ARG%=**}"; OPT="${OPT// /}"; ARG="${ARG#*=}"; ARG="${ARG# }"
    case "$OPT" in
      '' ) continue;;
      %* )
        [ -n "${META[*]}" ] \
          || chk_usb_dev_props__custom_meta "$DEV" dict_updkv META || return $?
        chk_core_eq "$DEV$OPT" "${META[${OPT#\%}]}" "$ARG" || return 2;;
      * ) chk_file_data_eq "$DEV$OPT" "$ARG" || return 2;;
    esac
  done
  return 0
}


function chk_usb_dev_props__custom_meta () {
  local DEV="$1"; shift
  case "$DEV" in
    /* ) ;;
    * )
      echo "W: $FUNCNAME: device path must be absolute, not '$DEV'" >&2
      return 4;;
  esac
  [ -f "$DEV"/busnum ] || return 3
  [ -f "$DEV"/devnum ] || return 3

  [ -n "$VNFMT" ] || local VNFMT=$'\v'
  local PAIRS=()
  [ -n "$1" ] || PAIRS+=( printf '%s=%s\n' )
  local BUS_ADDR="$(cat -- "$DEV"/busnum):$(cat -- "$DEV"/devnum)"

  # lsusb description: for devices that lack "manufacturer" or "product"
  local DESCR="$(LANG=C lsusb -s "$BUS_ADDR")"
  DESCR="${DESCR#* ID }"
  DESCR="${DESCR# }"
  DESCR="${DESCR% }"
  PAIRS+=( "${VNFMT//$'\v'/descr}" "$DESCR" )

  # sort busaddr last beacuse least interesting
  PAIRS+=( "${VNFMT//$'\v'/busaddr}" "$BUS_ADDR" )
  "$@" "${PAIRS[@]}"
  return $?
}


