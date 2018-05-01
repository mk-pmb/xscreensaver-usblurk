#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function usb_dev_scan () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd / || return $?
  source "$SELFPATH"/../src/sysfs_devpaths.lib.sh || return $?
  source "$SELFPATH"/../src/bash-util.lib.sh || return $?
  source "$SELFPATH"/../chk/usb_dev_props.sh || return $?

  local DEV=
  local KEY=
  local VAL=
  local BUS_ADDR=
  local DESCR=
  # ^-- lsusb description, for devices that lack "manufacturer" or "product"
  local KVFMT='    %- 20s = ‹%s›\n'
  local PRIO_KEYS=(
    manufacturer
    product
    serial
    idProduct
    idVendor
    removable
    )

  local MAYBE_DEVS=()
  readarray -t MAYBE_DEVS < <(sysfs_devpaths_suggest)
  for DEV in "${MAYBE_DEVS[@]}"; do
    [ -d "$DEV" ] || continue
    VAL="$(VNFMT=$'%\v' chk_usb_dev_props__custom_meta "$DEV" printf "$KVFMT")"
    [ -n "$VAL" ] || continue
    echo "$DEV"
    echo "$VAL"
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
      printf "$KVFMT" "$KEY" "$VAL"
    done
    echo
  done

  return 0
}











usb_dev_scan "$@"; exit $?
