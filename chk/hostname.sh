#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_hostname () {
  case ",$*," in
    *,"$HOSTNAME",* )
      $DBGP "hostname '$HOSTNAME' found in whitelist"
      return 0;;
  esac
  $DBGP "hostname '$HOSTNAME' NOT found in whitelist"
  return 3
}
