#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function setup_pid_file () {
  $DBGP "$FUNCNAME"
  mkdir --parents -- "$(dirname "$PID_FILE")" || return $?
  local PREV_PID="$(read_pidfile)"
  [ -n "$PREV_PID" ] && kill -HUP "$PREV_PID" 2>/dev/null
  echo "$PROG_PID" >"$PID_FILE" || return $?
  return 0
}

function read_pidfile () {
  [ -f "$PID_FILE" ] || return 2
  <"$PID_FILE" tr '\n' : | grep -xPe '^[0-9]+:$' | tr -d :
  # ^-- tr/grep: newline required to ensure file wasn't truncated
}
