#SingleInstance Force
#Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir A_InitialWorkingDir ; Ensures a consistent starting directory.

class MyUtils{
    static printObj(obj){
        s := "{`n"
        s .= MyUtils.getObjString(obj)
        s .= "}"
        MsgBox s
    }

    static getObjString(obj){
        s := ""
        for name, val in obj.OwnProps(){
            s := s . name ": "
            t := Type(val)

            if(t = "String" || t = "Integer"){
                s := s . val
            }
            else{
                s := s . t ;"[Function]"
            }

            s := s . "`n"
        }

        return s
    }

    static printArr(arr){
        s := "[ "
        For index, val in arr{
            t := Type(val)

            ;s .= index . ": "

            if(t = "String" || t = "Integer"){
                s .= val
            }
            else if (t = "Object"){
                s .= MyUtils.getObjString(val)
            }
            else{
                s .= t ;"[Function]"
            }

            if index != arr.Length
                s .= ", "
        }

        s .= " ]"

        MsgBox s
    }

    static printUnknown(u){
        t := Type(u)

        Switch t {
            Case "Object":
                MyUtils.printObj(u)
            Case "Array":
                MyUtils.printArr(u)
            Case "String", "Integer":
                MsgBox u
            Default:
                MsgBox "Unknown type " . u . " could not be printed."

        }
    }

    static getObjPropCount(obj){
        return ObjOwnPropCount(obj)
    }

    static stringToCharArray(str){
        i := 1
        sub := ""
        arr := []

        Loop StrLen(str){
            arr.Push(SubStr(str, i, 1))
            i += 1
        }
    }
}