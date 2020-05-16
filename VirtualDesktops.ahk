lib := A_ScriptDir . "\VirtualDesktopAccessor.dll"
global hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", lib, "Ptr")
if hVirtualDesktopAccessor == ""
{
	MsgBox % "Cannot load " lib
}

global GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
global RegisterPostMessageHookProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "RegisterPostMessageHook", "Ptr")
global IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnDesktopNumber", "Ptr")
global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
global HotkeysEnabled := False

DllCall(RegisterPostMessageHookProc, Int, hwnd, Int, 0x1400 + 30)
OnMessage(0x1400 + 30, "VWMess")
VWMess(wParam, lParam, msg, hwnd) {
	OnDesktopSwitch(lParam)
}

_GetCurrentDesktopNumber() {
	return DllCall(GetCurrentDesktopNumberProc, UInt)
}

_GetForemostWindowIdOnDesktop(n) {
	; winIDList contains a list of windows IDs ordered from the top to the bottom for each desktop.
	WinGet winIDList, list
	Loop % winIDList {
		windowID := % winIDList%A_Index%
		windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, WindowID, UInt, n)
		; Select the first (and foremost) window which is in the specified desktop.
		if (WindowIsOnDesktop == 1) {
			return WindowID
		}
	}
}

_ChangeDesktop(n) {
	WinActivate, ahk_class Shell_TrayWnd
	DllCall(GoToDesktopNumberProc, Int, n)
	foremostWindowId := _GetForemostWindowIdOnDesktop(n)
	WinActivate, ahk_id %foremostWindowId%
}

_MoveToDesktop(n) {
	WinGet, activeHwnd, ID, A
	DllCall(MoveWindowToDesktopNumberProc, UInt, activeHwnd, UInt, n)
}

onDesktopSwitch(n) {
	n := _GetCurrentDesktopNumber()+1
	Menu, Tray, Icon, %A_ScriptDir%/icons/%n%.ico
}

enableHotkeys() {
	HotkeysEnabled := True
	Menu, Tray, Check, Hotkeys enabled
}

disableHotkeys() {
	HotkeysEnabled := False
	Menu, Tray, Uncheck, Hotkeys enabled
}

SetTimer, checkWindow, 250
checkWindow() {
	active := WinActive("ahk_class" . "vncviewer")
	if not active and not HotkeysEnabled {
		enableHotkeys()
		return
	}

	WinGet, s, Style, A
	full := s == 0x160B0000
	if full and HotkeysEnabled {
		disableHotkeys()
	} else if not full and not HotkeysEnabled {
		enableHotkeys()
	}
}

Menu, Tray, NoStandard
Menu, Tray, Add, Desktop 1, _MenuDesktop0
Menu, Tray, Add, Desktop 2, _MenuDesktop1
Menu, Tray, Add, Desktop 3, _MenuDesktop2
Menu, Tray, Add, Desktop 4, _MenuDesktop3
Menu, Tray, Add, Hotkeys enabled, _MenuToggle
Menu, Tray, Add, Manage Desktops, _MenuManage
Menu, Tray, Default, Manage Desktops
Menu, Tray, Click, 1

onDesktopSwitch(_GetCurrentDesktopNumber())
enableHotkeys()

#If HotkeysEnabled
{
	!vk31::_ChangeDesktop(0)
	!vk32::_ChangeDesktop(1)
	!vk33::_ChangeDesktop(2)
	!vk34::_ChangeDesktop(3)

	^!vk31::_MoveToDesktop(0)
	^!vk32::_MoveToDesktop(1)
	^!vk33::_MoveToDesktop(2)
	^!vk34::_MoveToDesktop(3)
}

return

_MenuManage:
	Send #{Tab}
return

_MenuDesktop0:
	_ChangeDesktop(0)
return

_MenuDesktop1:
	_ChangeDesktop(1)
return

_MenuDesktop2:
	_ChangeDesktop(2)
return

_MenuDesktop3:
	_ChangeDesktop(3)
return

_MenuToggle:
	if (HotkeysEnabled) {
		DisableHotkeys()
	} else {
		EnableHotkeys()
	}
return
