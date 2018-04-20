#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function chk_hostname () {
  case ",$*," in
    *,"$HOSTNAME",* ) return 0;;
  esac
  return 3
}
