
usb_dev_scan
============


Field hints
-----------

* `bcdDevice`: firmware version.
  * "binary coded decimal", "Device Release Number",
    "bcdDevice […] is used to provide a device version number."
    – [USB in a nut shell](http://web.archive.org/web/20180501211845/https://beyondlogic.org/usbnutshell/usb5.shtml)
  * "will be shown in Windows and Linux systems as 'Firmware Revision'"
    – [arm KEIL](http://web.archive.org/web/20180501213232/http://www.keil.com/pack/doc/mw/usb/html/_u_s_b__device.html)
  * "The bcdDevice value indicates the device-defined revision number."
    – [Microsoft](http://web.archive.org/web/20180501211818/https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/usb-device-descriptors)

* `urbnum`: URB activity meter. Shows how much your computer has interacted
  with the USB device in this way since it was plugged in.
  * "number of URBs submitted for the whole device", i.e.
    "asynchronous calls for all kinds of data transfer,
    using request structures called 'URBs' (USB Request Blocks)."
    – [Linux USB API docs](http://web.archive.org/web/20180501213726/https://www.kernel.org/doc/html/latest/driver-api/usb/usb.html)

