#!/bin/bash

cat <<-END >> /usr/share/X11/xkb/symbols/ctrl
// Eliminate CapsLock, making it another Ctrl,
// and add Hangul to Ctrl.
partial modifier_keys
xkb_symbols "nocaps_and_add_ctrls" {
    replace key <HNGL> { [ Control_L ] };
    // the following line is for thinkpad keyboard
    replace key <HENK> { [ Control_L ] };
    replace key <CAPS> { [ Control_L, Control_L ] };
    modifier_map  Control { <CAPS>, <LCTL>, <HNGL>, <HENK>};
};
END

cat <<-END >> /usr/share/X11/xkb/symbols/shift

// add hangul_hanja to lshift
partial modifier_keys
xkb_symbols "hangul_hanja_to_lshift" {
    replace key <HJCV> { [ Shift_L ] };
};

// for external thinkpad keyboard
partial modifier_keys
xkb_symbols "muhenkan_to_lshift" {
    replace key <MUHE> { [ Shift_L ] };
};
partial modifier_keys
xkb_symbols "katahira_to_lshift" {
    replace key <HKTG> { [ Shift_L ] };
};
END


sed -i '/! option	=	symbols/a \ \ ctrl:nocaps_and_add_ctrls = +ctrl(nocaps_and_add_ctrls)' /usr/share/X11/xkb/rules/evdev
sed -i '/! option	=	symbols/a \ \ shift:hangul_hanja_to_lshift = +shift(hangul_hanja_to_lshift)' /usr/share/X11/xkb/rules/evdev
sed -i '/! option	=	symbols/a \ \ shift:muhenkan_to_lshift = +shift(muhenkan_to_lshift)' /usr/share/X11/xkb/rules/evdev
sed -i '/! option	=	symbols/a \ \ shift:katahira_to_lshift = +shift(katahira_to_lshift)' /usr/share/X11/xkb/rules/evdev
sed -i 's/^\s*XKBOPTIONS.*/XKBOPTIONS="ctrl:nocaps_and_add_ctrls,shift:hangul_hanja_to_lshift,shift:muhenkan_to_lshift,shift:katahira_to_lshift"/' /etc/default/keyboard
