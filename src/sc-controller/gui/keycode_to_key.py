#!/usr/bin/env python3
"""
SC-Controller - KEYCODE_TO_KEY

Similar to GDK_TO_KEY, maps X11 keycodes to Keys.KEY_* constants.
Used by OSD keyboard
"""
from __future__ import unicode_literals

from scc.uinput import Keys
from gdk_to_key import KEYCODE_TO_KEY

KEY_TO_KEYCODE = { KEYCODE_TO_KEY[a] : a for a in KEYCODE_TO_KEY }
