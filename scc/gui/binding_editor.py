#!/usr/bin/env python2
"""
SC-Controller - BindingEditor

Base class for main application window and OSD Keyboard bindings editor.
"""
from __future__ import unicode_literals
from scc.tools import _

from scc.modifiers import ModeModifier, SensitivityModifier
from scc.modifiers import DoubleclickModifier, HoldModifier
from scc.macros import Macro, Repeat
from scc.actions import NoAction
from scc.gui.controller_widget import TRIGGERS, PADS, STICKS, GYROS, BUTTONS, PRESSABLE
from scc.gui.controller_widget import ControllerPad, ControllerStick, ControllerGyro
from scc.gui.controller_widget import ControllerButton, ControllerTrigger
from scc.gui.modeshift_editor import ModeshiftEditor
from scc.gui.ae.gyro_action import is_gyro_enable
from scc.gui.action_editor import ActionEditor
from scc.gui.macro_editor import MacroEditor


class BindingEditor(object):
	
	def __init__(self):
		self.button_widgets = {}
	
	
	def create_binding_buttons(self, use_icons=True, enable_press=True):
		"""
		Creates ControllerWidget instances for available Gtk.Buttons defined
		in glade file.
		"""
		for b in BUTTONS:
			w = self.builder.get_object("bt" + b.name)
			if w:
				self.button_widgets[b] = ControllerButton(self, b, use_icons, w)
		for b in TRIGGERS:
			w = self.builder.get_object("btTrigger" + b)
			if w:
				self.button_widgets[b] = ControllerTrigger(self, b, use_icons,w)
		for b in PADS:
			w = self.builder.get_object("bt" + b)
			if w:
				self.button_widgets[b] = ControllerPad(self, b, use_icons, enable_press, w)
		for b in STICKS:
			w = self.builder.get_object("bt" + b)
			if w:
				self.button_widgets[b] = ControllerStick(self, b, use_icons, enable_press, w)
		for b in GYROS:
			w = self.builder.get_object("bt" + b)
			if w:
				self.button_widgets[b] = ControllerGyro(self, b, use_icons, w)
	
	
	def set_action(self, profile, id, action):
		"""
		Stores action in profile.
		Returns formely stored action.
		"""
		before = NoAction()
		if id in BUTTONS:
			before, profile.buttons[id] = profile.buttons[id], action
			self.button_widgets[id].update()
		if id in PRESSABLE:
			before, profile.buttons[id] = profile.buttons[id], action
			self.button_widgets[id.name].update()
		elif id in TRIGGERS:
			before, profile.triggers[id] = profile.triggers[id], action
			self.button_widgets[id].update()
		elif id in GYROS:
			before, profile.gyro = profile.gyro, action
			self.button_widgets[id].update()
		elif id in STICKS + PADS:
			if id in STICKS:
				before, profile.stick = profile.stick, action
			elif id == "LPAD":
				before, profile.pads[Profile.LEFT] = profile.pads[Profile.LEFT], action
			else:
				before, profile.pads[Profile.RIGHT] = profile.pads[Profile.RIGHT], action
			self.button_widgets[id].update()
		return before
	
	
	def choose_editor(self, action, title):
		""" Chooses apropripate Editor instance for edited action """
		if isinstance(action, SensitivityModifier):
			action = action.action
		if isinstance(action, (ModeModifier, DoubleclickModifier, HoldModifier)) and not is_gyro_enable(action):
			e = ModeshiftEditor(self, self.on_action_chosen)
			e.set_title(_("Mode Shift for %s") % (title,))
		elif isinstance(action, Macro):
			e = MacroEditor(self, self.on_action_chosen)
			e.set_title(_("Macro for %s") % (title,))
		else:
			e = ActionEditor(self, self.on_action_chosen)
			e.set_title(title)
		return e
	
	
	def hilight(self, button):
		""" Hilights button on image. Overriden by app. """
		pass
	
	
	def show_editor(self, id, press=False):
		raise TypeError("show_editor not overriden")
