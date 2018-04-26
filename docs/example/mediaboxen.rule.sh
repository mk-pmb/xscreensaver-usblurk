# -*- coding: utf-8, tab-width: 2 -*-

chk hostname moviebox,musicbox && \
xsc_score =-5    # lock by default

chk hostname moviebox && \
chk disk_prtn '
    label = unlock_movies
    uuid  = d3adbe3f-0000-1337-0000-000000000023
    id    = usb-Flash_Disk_DEADBEEF-0:0-part6
    ' && \
xsc_score +5

chk hostname musicbox && \
chk usb_dev_props '
    # comments supported for this chk
    # you can use `util/usb_dev_scan.sh` to find properties.
    idProduct     = 0000
    idVendor      = 0000
    manufacturer  = C-Media Electronics Inc.
    product       = USB PnP Sound Device
    serial |sha1  = 0000000000000000000000000000000000000000
    ' && \
xsc_score +5

return 0  # rule ok
