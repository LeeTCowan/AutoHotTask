#SingleInstance Force
#Include ./Gdip_All.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
	ExitApp
}
OnExit("ExitFunc")

MsgBox "WE MADE IT BOIS"

; Set the width and height we want as our drawing area, to draw everything in. This will be the dimensions of our bitmap
Width := 600, Height := 400

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
;AHK v1
;Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
;Gui, 1: Show, NA
Gui1 := Gui("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
Gui1.Show("NA")

; Get a handle to this window we have created in order to update it later
hwnd1 := WinExist()
MsgBox "hwnd1: " . hwnd1

; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
hbm := CreateDIBSection(Width, Height)

; Get a device context compatible with the screen
hdc := CreateCompatibleDC()

; Select the bitmap into the device context
obm := SelectObject(hdc, hbm)

; Get a pointer to the graphics of the bitmap, for use with drawing functions
G := Gdip_GraphicsFromHDC(hdc)

; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
Gdip_SetSmoothingMode(G, 4)

; Create a fully opaque red pen (ARGB = Transparency, red, green, blue) of width 3 (the thickness the pen will draw at) to draw a circle
pPen := Gdip_CreatePen(0xffff0000, 3)

; Draw an ellipse into the graphics of the bitmap (this being only the outline of the shape) using the pen created
; This pen has a width of 3, and is drawing from coordinates (100,50) an ellipse of 200x300
Gdip_DrawEllipse(G, pPen, 100, 50, 200, 300)

; Delete the pen as it is no longer needed and wastes memory
Gdip_DeletePen(pPen)

; Create a slightly transparent (66) blue pen (ARGB = Transparency, red, green, blue) to draw a rectangle
; This pen is wider than the last one, with a thickness of 10
pPen := Gdip_CreatePen(0x660000ff, 10)

; Draw a rectangle onto the graphics of the bitmap using the pen just created
; Draws the rectangle from coordinates (250,80) a rectangle of 300x200 and outline width of 10 (specified when creating the pen)
Gdip_DrawRectangle(G, pPen, 250, 80, 300, 200)

; Delete the brush as it is no longer needed and wastes memory
Gdip_DeletePen(pPen)

; Update the specified window we have created (hwnd1) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
; So this will position our gui at (0,0) with the Width and Height specified earlier
UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)


; Select the object back into the hdc
SelectObject(hdc, obm)

; Now the bitmap may be deleted
DeleteObject(hbm)

; Also the device context related to the bitmap may be deleted
DeleteDC(hdc)

; The graphics may now be deleted
Gdip_DeleteGraphics(G)
Return

;#######################################################################

ExitFunc(ExitReason, ExitCode)
{
   global
   ; gdi+ may now be shutdown on exiting the program
   Gdip_Shutdown(pToken)
}





^!1::{
    
    ExitApp
}

^!2::{
    MyGui := Gui("+AlwaysOnTop +LastFound -DPIScale E0x20" , "Transparent Window")
    ;WinSetTransColor(CustomColor " 150", MyGui)
    WinSetTransColor "EEAA99 150"
    MyGui.Opt("-Caption")
    MyGui.Show("Maximize")
    ; WinSetTransColor, then -Caption

    ;WinSetExStyle -0x20
    
}

test3(){
    Try 
        errorFunc2()
    Catch ValueError as err
        MsgBox Format("{1}: {2}.`n`nFile:`t{3}`nLine:`t{4}`nWhat:`t{5}`nStack:`n{6}"
            , type(err), err.Message, err.File, err.Line, err.What, err.Stack)
}

errorFunc(){
    throw ValueError("Value error!!!", "errorFunc", 5)
}

errorFunc2(){
    n := 1
    errorFunc()
}

test2(){ ; doesnt work - throws error
    obj := {}

    obj := unset

    return obj
}

test1(){
    f := FileOpen(".\test.json", "r")

    MsgBox f.POS

    while !f.AtEOF {
        c := f.Read(1)
    }

    MsgBox c
    MsgBox "Position: " . f.POS . "`nLength: " f.Length
    
    c := f.Read(1)
    
    if c = ""
        MsgBox "Yes."
}