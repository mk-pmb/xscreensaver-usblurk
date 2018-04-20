#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function usb_dev_scan () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd / || return $?

  local DEV=
  local KEY=
  local VAL=
  local PRIO_KEYS=(
    manufacturer
    product
    serial
    idProduct
    idVendor
    removable
    )
  for DEV in /sys/bus/usb/devices/*/[0-9]*/; do
    [ -d "$DEV" ] || continue
    echo "$DEV"
    for VAL in "${PRIO_KEYS[@]}" "$DEV"/*; do
      KEY="$(basename "$VAL")"
      case "${VAL:0:1} ${PRIO_KEYS[*]} " in
        /*" $KEY "* )
          # 2nd appearance of a prio key
          continue;;
        [a-z]* ) VAL="$DEV/$VAL";;
      esac
      [ -f "$VAL" ] || continue
      case "$KEY" in
        bAlternateSetting | \
        bInterface* | \
        busnum | \
        descriptors | \
        dev | \
        devnum | \
        modalias | \
        remove | \
        report_descriptor | \
        uevent ) continue;;
      esac
      VAL="$(cat -- "$DEV/$KEY")"
      VAL="${VAL//$'\n'/¶ }"
      printf '    %- 20s = ‹%s›\n' "$KEY" "$VAL"
    done
    echo
  done

  return 0
}










[ "$1" == --lib ] && return 0; usb_dev_scan "$@"; exit $?
