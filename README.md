
<!--#echo json="package.json" key="name" underline="=" -->
xscreensaver-usblurk
====================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
Watch USB devices being (un)plugged, in order to lock or unlock xscreensaver
based on whether configured token devices are present.
<!--/#echo -->



&nbsp;

Install
-------

1. Clone this repo.
1. Create the config directory `~/.config/xscreensaver/usblurk`.
    * In case of custom `XDG_CONFIG_HOME`, adapt accordingly.
    * The config folder name is derived from the program name,
      i.e. the name of the folder in which `lurk.sh` found itself
      when it was started.
      You can override it with the `XSCLURK_NAME` environment variable.
1. Save rules files (`*.rule.sh`) into your config dir.
    * Criteria functions are implemented in the [chk/](chk) folder,
    * An example rules file is provided in [docs/examples/](docs/examples).
    * Feel free to contribute better documentation.
1. Arrange for `lurk.sh` to be run at session startup.
    * One way to do so is to copy
      [docs/example/xsc-usblurk.desktop](docs/example/xsc-usblurk.desktop)
      to `~/.config/autostart/` (assuming defaults), then edit the copy to
      adjust the path to the repo.



&nbsp;

Test rules files
----------------

To verify your rules, you can run `lurk.sh` in debug mode:

```bash
DEBUGLEVEL=4 ./lurk.sh
```



&nbsp;

Caveats
-------

* While there are non-USB chk functions, usually they're only checked when
  USB devices appear or disappear (e.g. your memory thumb drive is plugged
  in or is withdrawn).



<!--#toc stop="scan" -->



&nbsp;

Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
