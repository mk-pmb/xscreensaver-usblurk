#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function dict_updkv () {
  local DICT="$1"; shift
  if [ "$DICT" == - ]; then
    DICT="$1"
    local ARGS=()
    readarray -t ARGS
    "$FUNCNAME" "$DICT" "${ARGS[@]}"
    return $?
  fi
  while [ "$#" -ge 1 ]; do
    eval "$DICT"'["$1"]="$2"'
    shift 2
  done
  return 0
}

function arr_push () {
  local ARR="$1"; shift
  eval "$ARR"'+=( "$@" )'
}
