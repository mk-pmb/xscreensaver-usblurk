#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_ipv4_mac () {
  local IP="$1"; shift
  local ACCEPT="$1"; shift
  case "$IP" in
    dfgw | default_gateway )
      IP="$(ip route list | grep -Pe '^default ' \
        | grep -oPe ' via \S+' | grep -oPe '\S+$')"
      $DBGP "$FUNCNAME: dfgw = $IP"
      ;;
  esac
  [ -n "$IP" ] || return 2
  local MACS="$(chk_ipv4_mac__list)"
  $DBGP "$FUNCNAME: macs: ${MACS//$'\n'/ }"
  <<<"$MACS" grep -m 1 -qxFe "$IP=$ACCEPT"
}


function chk_ipv4_mac__list () {
  LANG=C arp -n | LANG=C sed -nre 's~^(\S+)\s+ether\s+(\S+)\s.*$~\1=\2~p'
}
