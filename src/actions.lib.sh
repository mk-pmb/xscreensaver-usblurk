# -*- coding: utf-8, tab-width: 2 -*-

function xsc_lock () {
  $DBGP "$FUNCNAME"
  # LANG=C xscreensaver-command -time | grep -Fe ' screen locked ' && return 0
  # ^-- nope: reports screen locked even after we kill-HUP-ed xsc,
  #     even if it was "-restart"ed
  $DBG xscreensaver-command -lock >/dev/null
  run_hooks lock
}

function xsc_unlock () {
  $DBG killall -HUP xscreensaver
  run_hooks unlock
}

function add_hook () {
  local EVENT="$1"; shift
  CFG[on_"$EVENT"]+=$'\n'"$*"$'\n'
  # Avoid any flow control directly inside the hook command.
  # ideally all args should be just names of functions that your
  # config file had declared earlier.
  #   * You can use flow control in your function
  #   * An easy way to avoid naming conflicts with xsc-usblurk internals
  #     is to start your function names with "cfg_".
  #     How to avoid naming conflicts between functions of multiple
  #     3rd-party configs/ruls is outside this project's scope.
}

function run_hooks () {
  export XSC_HOOK="$1"; shift
  local ITEM=
  cd "$CFG_DIR" || return $?
  eval "${CFG[on_"$XSC_HOOK"]}"
  cd "$CFG_DIR" || return $?
  for ITEM in ./*.on_"$XSC_HOOK".sh; do
    # ^-- ./ is to avoid searching $PATH
    [ -f "$ITEM" ] || continue
    $DBG source "$ITEM"
    cd "$CFG_DIR" || return $?
  done
  return 0
}
