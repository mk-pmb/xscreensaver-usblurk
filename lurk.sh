#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function lurk () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
  cd / || return $?
  local RUNMODE="$1"; shift
  [ -n "$USER" ] || export USER="$(whoami)"
  [ -n "$HOSTNAME" ] || export HOSTNAME="$(hostname --short)"

  local DBG=
  [ "${DEBUGLEVEL:-0}" -ge 1 ] && DBG='debug_print'
  local DBGP="${DBG:-false}"
  local PROGNAME CFG_DIR; detect_config_dir || return $?

  local ITEM=
  cd "$CFG_DIR" || return $?
  for ITEM in "$SELFPATH"/{src/*.lib.sh,chk/*.sh} ''; do
    [ ! -f "$ITEM" ] || source "$ITEM" --lib || return $?
    cd "$CFG_DIR" || return $?
  done

  local PROG_PID=$$
  local PID_FILE="$HOME/.cache/var/run/$PROGNAME.pid"

  case "$RUNMODE" in
    '' | lurk ) ;;
    chk | vchk ) "$RUNMODE" "$@"; return $?;;
    vvchk ) DBGP='debug_print' vchk "$@"; return $?;;
    debug-do ) "$@"; return $?;;
    * ) echo "E: unknown runmode: '$RUNMODE'" >&2; return 2;;
  esac

  setup_pid_file || return $?

  local MON_PATHS=()
  local PREV_TOKEN_STATE=
  local -A CFG
  $DBGP "loop start"
  while lurk_loop; do
    sleep 0.2s  # <- opportunity for Ctrl+C even if lurk_loop fails rapidly
  done
  $DBGP "loop end"
  return 0
}


function detect_config_dir () {
  PROGNAME="$XSCLURK_NAME"
  [ -n "$PROGNAME" ] || PROGNAME="$(basename "$SELFPATH")"
  CFG_DIR="$PROGNAME"
  case "$CFG_DIR" in
    xscreensaver-* ) CFG_DIR="${CFG_DIR/-//}";;
  esac
  CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$CFG_DIR"
  [ -d "$CFG_DIR" ] || return 4$(
    echo "E: config directory missing: $CFG_DIR" >&2)
  return 0
}


function debug_print () { echo "D: $*" >&2; }


function lurk_lurk () {
  inotifywait --quiet --format '' "$@" "${MON_PATHS[@]}" >/dev/null
}


function lurk_loop () {
  local MON_PID=
  local SLEEP_PID=
  local MON_DURA_SEC=2
  local IDLE_LOOPS=0
  while [ "$IDLE_LOOPS" -le 2 ]; do
    if [ "$(read_pidfile)" != "$PROG_PID" ]; then
      $DBGP "pidfile changed => quit"
      [ -n "$MON_PID" ] && kill -HUP "$MON_PID"
      return 2
    fi
    if [ -z "$MON_PID" ]; then
      read_config || return $?
      lurk_lurk & MON_PID=$!
    fi
    sleep "$MON_DURA_SEC"s & SLEEP_PID=$!
    $DBGP "$FUNCNAME check (idle $IDLE_LOOPS, pid $MON_PID)"
    lurk_check_tokens_once
    wait "$SLEEP_PID"
    if kill -0 "$MON_PID"; then
      # no new activity
      let IDLE_LOOPS="$IDLE_LOOPS+1"
    else
      IDLE_LOOPS=0
      wait "$MON_PID"   # properly reap our dead child
      MON_PID=
    fi
  done
  $DBGP "$FUNCNAME wait"
  wait "$MON_PID"
  return 0
}


function read_config () {
  $DBGP "$FUNCNAME"
  MON_PATHS=(
    /dev/bus/usb/*/
    )
  mon_paths_add_1st_dir /dev/disk/by-{path,uuid}
    # ^-- Ubuntu trusty doesn't have path

  local ITEM=
  cd "$CFG_DIR" || return $?
  for ITEM in *.cfg.sh; do
    [ ! -f "$ITEM" ] || source "$ITEM" || return $?
    cd "$CFG_DIR" || return $?
  done
  return 0
}


function lurk_check_tokens_once () {
  score_stable_accept
  local TKN_ERR=$?
  if [ "$TKN_ERR" == "$PREV_TOKEN_STATE" ]; then
    $DBGP "token state unchanged, err=$TKN_ERR"
  elif [ "$TKN_ERR" == 0 ]; then
    xsc_unlock
  else
    xsc_lock
  fi
  PREV_TOKEN_STATE="$TKN_ERR"
  return 0
}


function mon_paths_add_1st_dir () {
  local ITEM=
  for ITEM in "$@"; do
    [ -d "$ITEM" ] && MON_PATHS+=( "$ITEM" )
  done
}



function chk () {
  echo "E: stub! chk $*" >&2
}














lurk "$@"; exit $?
