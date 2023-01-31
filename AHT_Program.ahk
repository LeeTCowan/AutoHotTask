#Include ".\MyUtils.ahk"
#Include ".\AHT_JSONParser_Lite.ahk"

class AHT_Program{
    Actions := {}
    Tasks := {}
    Window := {}
    AHTProgramDataPath := ""

    __New(AHTProgramDataPath){

        this.AHTProgramDataPath := AHTProgramDataPath

        progData := this.parse_prog_file()

        this.Actions := progData.actions
        this.Tasks := progData.tasks
        
        this.Window := this.getWindow(progData)

        
    }

    performTask(taskName){
        task := this.Tasks[taskName]

        WinActivate(this.Window.title) ; this.activateWindow()
        WinMove , , this.Window.defaultWidth, this.Window.defaultHeight, this.Window.title ; this.resizeWindow(this.Window.defaultWidth, this.Window.defaultHeight)

        for i, action in task {
            
            Switch action.actionType {
                Case "click":
                    MouseClick "left", action.x, action.y
                    Sleep 100
                Case "wait":
                    Sleep action.milliseconds
                Case "file_copy":
                    txtFile := FileOpen("C:\Users\leetc\OneDrive\Desktop\songurls.txt", "r")
                    A_ClipBoard := txtFile.Read()
                    txtFile.Close()
                Case "paste":
                    Sleep 100
                    Send "^v"
                    Sleep 500
                Case "image_search_bool":
                    ;ImageSearch &x, &y, action.x1, action.y1, action.x2, action.y2, action.ImageFile
                    ;MsgBox "" . x . " " . y
                Case "wait_image_check":
                    Loop action.maxTries {
                        Sleep action.waitDelay
                        if(this.imageFind(action.imageSearchInfo)){
                            MsgBox "Found!"
                        }
                    }
                Default:
                    MsgBox "action" . action.actionType . " not recognized!"
            }
        }
    }

    parse_prog_file(){
        parser := AHT_JSONParser_Lite(this.AHTProgramDataPath)
        
        return parser.parse()
    }

    getWindow(progData){
        if(!winTitle := WinGetTitle(progData.title)){
            MsgBox "No such Window!"
            return 
        }

        ;WinActivate(winTitle)
        ;WinGetClientPos(, , &w, &h, winTitle)

        ;Refactor this into a class?
        programWindow := {
            title: winTitle,
            winID: WinGetID(winTitle),
            defaultWidth: progData.defaultWidth,
            defaultHeight: progData.defaultHeight,
            ;activate: activateWindow,
            ;resize: resizeWindow
        }

        return programWindow
    }

    activateWindow(){
        WinActivate(this.Window.title)
    }

    resizeWindow(w, h){
        WinMove , , w, h, this.Window.title
    }

    imageFind(imgInfo){

        return ImageSearch(&x, &y, imgInfo.x1, imgInfo.y1, imgInfo.x2, imgInfo.y2, imgInfo.imageFile)
    }

}
