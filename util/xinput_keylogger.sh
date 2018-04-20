#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function xinput_keylogger () {
  # Capture key events even while xscreensaver is running.
  # Not fit for use as a secret spying tool in an unlocked session
  # becasue xinput will open a window for capturing the events.
  # Can be used to watch for alternate passwords, to allow unlocking
  # the screensaver with different passwords depending on which token
  # is plugged, and independent from the main account password.

  local KBD_NAME="$1"; shift
  local PRINT_PID=
  local DFLT_KBD='Virtual core keyboard'
  case "$KBD_NAME" in
    '' ) KBD_NAME="$DFLT_KBD";;
    --n-keys | \
    --sed )
      KBD_NAME="${KBD_NAME#--}"
      KBD_NAME="${KBD_NAME//-/_}"
      "$FUNCNAME"__"$KBD_NAME" "$@"
      return $?;;
  esac
  "$FUNCNAME"__sed <(LANG=C xinput test-xi2 "$KBD_NAME")
  return ${PIPESTATUS[0]}
}


function xinput_keylogger__n_keys () {
  local N_KEYS="$1"; shift
  [ "${N_KEYS:-0}" -ge 1 ] || return 0
  KBD="${1:-$DFLT_KBD}" LANG=C sh -c 'echo $$; exec xinput test-xi2 "$KBD"' | (
    local XI_PID
    read -rs XI_PID
    grep -Pe '^\+' -m "$N_KEYS" -- <("${FUNCNAME%%__*}"__sed)
    kill -HUP "$XI_PID"
    )
  # :TODO: Bug: xinput won't discover grep's pipe close until it tries
  #   to report another (n+1)th keystroke. Only then will it quit.
}


function xinput_keylogger__sed () {
  LANG=C sed -urf <(echo '
    # ensure blank line after events
    s~^\S~\n&~
    $s~$~\n\n~
  ') -- "$@" | LANG=C sed -nurf <(echo '
    : skip
      /^EVENT /b event
    n;b skip

    : event
      N
      /\n\s*$/!b event
      s~\s+$~~g
      s!^EVENT type 13 \(RawKeyPress\)\n!+\a!
      s!^EVENT type 14 \(RawKeyRelease\)\n!-\a!
      s~\n\s+~\n~g
      s~^(\+|\-)\a.*\ndetail:\s+(\S+)\n.*$~\a\1\2~
    '
    [ "${DEBUGLEVEL:-0}" -ge 2 ] && echo '/^\a/!{s~\n~¶ ~g;p}'
    echo '
      /^\a/{
        s~^\a~~
        '"$XISED_BELL_EXTRA"'
        p
      }
      n
    b skip
    ')
}










[ "$1" == --lib ] && return 0; xinput_keylogger "$@"; exit $?
