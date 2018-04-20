#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_usb_dev_props () {
  local USB_DEV=
  for USB_DEV in /sys/bus/usb/devices/*/[0-9]*/; do
    subchk_usb_dev_props__each "$USB_DEV" "$@" && return 0
  done
  return 3
}


function subchk_usb_dev_props__each () {
  echo "W: $FUNCNAME: stub!" >&2
  return 2
}
