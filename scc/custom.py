#!/usr/bin/env python3
"""
SC-Controller - Custom module loader

Loads ~/.config/scc/custom.py, if present. This allows injecting custom action
classes by user and breaking everything in very creative ways.

load_custom_module function needs to be called by daemon and GUI, so it exists
in separate module.
"""

from scc.paths import get_config_path
import os

def load_custom_module(log, who_calls="daemon"):
	"""
	Loads and imports ~/.config/scc/custom.py, if it is present and displays
	big, fat warning in such case.
	
	Returns True if file exists.
	"""
	
	filename = os.path.join(get_config_path(), "custom.py")
	if os.path.exists(filename):
		log.warning("=" * 60)
		log.warning("Loading %s" % (filename, ))
		log.warning("If you don't know what this means or you haven't "
			"created it, stop daemon right now and remove this file.")
		log.warning("")
		log.warning("Also try removing it if %s crashes "
			"shortly after this message." % (who_calls,))
		# Changing imp in accordance with it being removed in Python 3.12
		import importlib.util
		import importlib.machinery
		def load_source(custom, filename):
			loader = importlib.machinery.SourceFileLoader(custom, filename)
			spec = importlib.util.spec_from_file_location(custom, filename, loader=loader)
			module = importlib.util.module_from_spec(spec)
			loader.exec_module(module)
			return module
		log.warning("=" * 60)
		return True
	return False
