#!/bin/bash

cat <<-END >> /usr/share/X11/xkb/symbols/ctrl
// Eliminate CapsLock, making it another Ctrl,
// and add Henkan to Ctrl.
partial modifier_keys
xkb_symbols "nocaps_and_add_ctrls" {
    replace key <MUHE> { [ Control_L ] };
    replace key <HKTG> { [ Control_L ] };
    replace key <CAPS> { [ Control_L, Control_L ] };
    modifier_map  Control { <CAPS>, <LCTL>, <MUHE>, <HKTG>};
};
END

cat <<-END >> /usr/share/X11/xkb/symbols/shift

partial modifier_keys
xkb_symbols "henkan_to_lshift" {
    replace key <HENK> { [ Shift_L ] };
};
END


sed -i '/! option	=	symbols/a \ \ ctrl:nocaps_and_add_ctrls = +ctrl(nocaps_and_add_ctrls)' /usr/share/X11/xkb/rules/evdev
sed -i '/! option	=	symbols/a \ \ shift:henkan_to_lshift = +shift(henkan_to_lshift)' /usr/share/X11/xkb/rules/evdev
sed -i 's/^\s*XKBOPTIONS.*/XKBOPTIONS="ctrl:nocaps_and_add_ctrls,shift:henkan_to_lshift"/' /etc/default/keyboard
