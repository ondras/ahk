#NoTrayIcon
SetWinDelay 0
CoordMode Mouse, Screen

IsFull(id) {
	WS_CAPTION := 0x00C00000
	WinGet, minmax, MinMax, ahk_id %id%
	WinGet, style, Style, ahk_id %id%
	return (minmax == 1 || !(style & WS_CAPTION))
}

#If not WinActive("ahk_class vncviewer")
!LButton::
	MouseGetPos mouse_x1, mouse_y1, win_id

	if IsFull(win_id) {
		return
	}

	WinGetPos win_x1, win_y1, , , ahk_id %win_id%

	While GetKeyState("LButton", "P") {
		MouseGetPos mouse_x2, mouse_y2
		x := win_x1 + (mouse_x2 - mouse_x1)
		y := win_y1 + (mouse_y2 - mouse_y1)
		WinMove ahk_id %win_id%, , %x%, %y%
	}
return

#If not WinActive("ahk_class vncviewer")
!RButton::
	MouseGetPos mouse_x1, mouse_y1, win_id

	if IsFull(win_id) {
		return
	}

	WinGetPos win_x1, win_y1, win_w1, win_h1, ahk_id %win_id%
	left_half := (mouse_x1 < win_x1 + win_w1 / 2)
	top_half  := (mouse_y1 < win_y1 + win_h1 / 2)

	While GetKeyState("RButton", "P") {
		MouseGetPos mouse_x2, mouse_y2

		x := win_x1 + (mouse_x2 - mouse_x1)*left_half
		y := win_y1 + (mouse_y2 - mouse_y1)*top_half
		w := win_w1 - (mouse_x2 - mouse_x1)*(2*left_half - 1)
		h := win_h1 - (mouse_y2 - mouse_y1)*(2*top_half  - 1)

		WinMove, ahk_id %win_id%, , x, y, w, h
	}
return
