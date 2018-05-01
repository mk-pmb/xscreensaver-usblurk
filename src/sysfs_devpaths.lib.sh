# -*- coding: utf-8, tab-width: 2 -*-

function sysfs_devpaths_suggest () {
  local SBUD='/sys/bus/usb/devices/'

  printf '%s\n' "$SBUD"[0-9]*/[0-9]*/
  # ^-- Ubuntu trusty @ Lenovo Thinkpad T410

  printf '%s\n' "$SBUD"usb[0-9]*/[0-9]*/
  # ^-- Ubuntu trusty @ Asus Aspire One D255

  return 0
}
