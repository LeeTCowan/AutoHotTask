#SingleInstance Force
#Include ".\AHT_Program.ahk"
#Include ".\MyUtils.ahk"
#Include ".\AHT_JSONParser_Lite.ahk"
#Warn  ; Enable warnings to assist with detecting common errors.
;DetectHiddenWindows 1
SetWorkingDir A_InitialWorkingDir ; Ensures a consistent starting directory.

Plexamp := {
    title: "Plexamp"
}

^!1::{
    
    prog := AHT_Program("C:\Users\leetc\OneDrive\Desktop\Autohotkey Programs\iSkysoft.json")

    prog.performTask("Download Youtube Music List")
    MsgBox "Hello?"
    return
}

^!2::{
    ;parser := JSONParser("./iSkysoft.json")

    ;iSkysoftProg := parser.parse()
    ;iSkysoftProg := mapifyProgramData(iSkysoftProg)

    ;MyUtils.printUnknown(parser.jsonData)

    ;PerformTask(iSkysoftProg, iSkysoftProg.tasks["Download Youtube Music List"])

    return
}

createCoords(x, y, t){
    return {x: x, y: y, t: t}
}
