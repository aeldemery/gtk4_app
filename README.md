<!--
 Copyright (c) 2020 Ahmed Eldemery
 
 This software is released under the MIT License.
 https://opensource.org/licenses/MIT
-->
# Building applications using Gtk4

This is a trial to implement the 
**Gtk4 application tutorial** [present 
at](https://developer.gnome.org/gtk4/3.98/ch01s06.html) 
in [**Vala Language**](https://wiki.gnome.org/Projects/Vala).

## Compile

* `meson build`
* `cd build`
* `ninja && ninja install`

### Note

There is unresolved issue, I'm not sure if its a bug with Gtk4 itself,
which is closing the window don't exit the process. You must use Ctrl-Q or 
the Menu Quit.

### Screenshots

Main Window

![Main Window](data/Screenshot 1.png)

Preferences Dialog

![PreferencesDialog](data/Screenshot 2.png)
