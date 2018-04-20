#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

s!\-part[0-9]+$!!
s!\-[0-9]+:[0-9]+$!!
s!_[a-z0-9]+$!!ig
s!^(usb|ata)\-!!i
s!(0x)[0-9a-f]+([0-9a-f]{6})!\1…\2!ig
s!^[^a-z]+$!\L&\E!
