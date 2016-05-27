#!/usr/bin/env python2

"""
Python wrapper for some X-related stuff.
"""

from ctypes import CDLL, POINTER, c_void_p, Structure, byref
from ctypes import c_ulong, c_int, c_uint, c_short, c_ushort, c_ubyte, c_char_p


def _load_lib(*names):
	"""
	Tries multiple alternative names to load .so library.
	"""
	for l in names:
		try:
			return CDLL(l)
		except OSError:
			pass
	raise OSError("Failed to load %s, library not found" % (names[0],))


libXFixes = _load_lib('libXfixes.so', 'libXfixes.so.3')
libX11 = _load_lib('libX11.so', 'libX11.so.6')


# Types
XID = c_ulong
XserverRegion = c_ulong
Display = c_void_p

# Structures
class XRectangle(Structure):
	_fields_ = [
		('x', c_short),
		('y', c_short),
		('width', c_ushort),
		('height', c_ushort),
	]


class XkbStateRec(Structure):
	_fields_ = [
		('group', c_ubyte),
		('locked_group', c_ubyte),
		('base_group', c_ushort),
		('latched_group', c_ushort),
		('mods', c_ubyte),
		('base_mods', c_ubyte),
		('latched_mods', c_ubyte),
		('locked_mods', c_ubyte),
		('compat_state', c_ubyte),
		('grab_mods', c_ubyte),
		('compat_grab_mods', c_ubyte),
		('lookup_mods', c_ubyte),
		('compat_lookup_mods', c_ubyte),
		('ptr_buttons', c_ushort),
	]


# Consants
SHAPE_BOUNDING	= 0
SHAPE_CLIP		= 1
SHAPE_INPUT		= 2

XKBUSECOREKBD	= 0x0100


# Functions
create_region = libXFixes.XFixesCreateRegion
create_region.argtypes = [ c_void_p, POINTER(XRectangle), c_int ]
create_region.restype = XserverRegion
set_window_shape_region = libXFixes.XFixesSetWindowShapeRegion
set_window_shape_region.argtypes = [ c_void_p, XID, c_int, c_int, c_int, XserverRegion ]
destroy_region = libXFixes.XFixesDestroyRegion
destroy_region.argtypes = [ c_void_p, XserverRegion ]
open_display = libX11.XOpenDisplay
open_display.argtypes = [ c_char_p ]
open_display.restype = c_void_p
get_default_root_window = libX11.XDefaultRootWindow
get_default_root_window.argtypes = [ c_void_p ]
flush = libX11.XFlush
flush.argtypes = [ c_void_p ]
warp_pointer = libX11.XWarpPointer
warp_pointer.argtypes = [ c_void_p, XID, XID, c_int, c_int, c_int, c_int, c_int, c_int ]
query_pointer = libX11.XQueryPointer
query_pointer.argtypes = [ c_void_p, XID, POINTER(XID), POINTER(XID),
	POINTER(c_int), POINTER(c_int), POINTER(c_int), POINTER(c_int), POINTER(c_uint) ]

# Wrapped functions
_xkb_get_state = libX11.XkbGetState
_xkb_get_state.argtypes = [c_void_p, c_uint, POINTER(XkbStateRec)]

# Wrappers
def get_xkb_state(dpy):
	rec = XkbStateRec()
	_xkb_get_state(dpy, XKBUSECOREKBD, rec)
	return rec

def set_mouse_pos(dpy, x, y):
	root = get_default_root_window(dpy)
	warp_pointer(dpy, 0, root, 0, 0, 0, 0, x, y)
	flush(dpy)

def get_mouse_pos(dpy):
	root = get_default_root_window(dpy)
	root_return, child_return = XID(), XID()
	x, y = c_int(), c_int()
	child_x_return, child_y_return = c_int(), c_int()
	mask_return = c_uint()
	query_pointer(dpy, root, byref(root_return), byref(child_return),
		byref(x), byref(y),
		byref(child_x_return), byref(child_y_return), byref(mask_return))
	return x.value, y.value
