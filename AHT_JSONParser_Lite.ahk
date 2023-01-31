class AHT_JSONParser_Lite{

    f := unset ; FileOpen("./jsonfile.json", "r", "UTF-8")
    fileName := ""
    jsonData := unset

    __New(fileName){
        this.fileName := fileName
    }

    parse() {
        c := ""

        this.f := FileOpen(this.fileName, "r", "UTF-8")

        this.begin_parse()
        this.mapify()
        this.convert_tasks()

        this.f.Close()

        return this.jsonData
    }

    begin_parse(){
        c := this.seek_next_data_type()
        this.jsonData := this.parse_router(c)
    }

    mapify(){
        actionsMap := Map()
        tasksMap := Map()

        for obj in this.jsonData.actions
            actionsMap.Set(obj.actionName, obj)
        this.jsonData.actions := actionsMap

        
        for taskName, task in this.jsonData.tasks.OwnProps()
            tasksMap.Set(taskName, task)
        this.jsonData.tasks := tasksMap
    }

    ; TODO: Try-catch for when actionKeys do not match
    convert_tasks(){
        for taskName, taskArr in this.jsonData.tasks{
            for i, actionKey in taskArr{
                taskArr[i] := this.jsonData.actions[actionKey]
            }
        }

    }

    parse_router(c) {
        retval := unset

        Switch c {
            Case "{":
                retval := this.parse_object()
            Case "[":
                retval := this.parse_array()
            Case "`"":
                retval := this.parse_string()
            Case "t", "f":
                retval := this.parse_boolean(c)
            Case "n":
                retval := this.parse_null(c)
            Default:
                retval := this.parse_value(c)
        }

        return retval
    }

    seek_next_data_type() {
        charsToSkip := " `n`r`t"
        c := ""

        while !this.f.AtEOF {
            c := this.f.Read(1)

            if InStr(charsToSkip, c)
                Continue
            else if RegExMatch(c, RegexChars.ANY_TYPE_START){
                Break
            }
            else
                throw ValueError("Invalid JSON", "seek_next_data_type", "Expected a data type but instead got '" . c . "' at position: " . this.f.Pos)
        }

        return c
    }

    seek_next_valid_char(targetC := "", regex := ""){
        charsToSkip := " `n`r`t"
        foundValidChar := 0
        c := ""

        if regex != "" {
            while !this.f.AtEOF {
                c := this.f.Read(1)

                if InStr(charsToSkip, c)
                    Continue
                else if RegExMatch(c, regex){
                    foundValidChar := 1
                    Break
                }
                Else
                    throw ValueError("Invalid JSON", "seek_next_valid_char", "Found an invalid character (" . c .  ") while trying to match the regex: " . regex)
            }
        }
        else {
            while !this.f.AtEOF {
                c := this.f.Read(1)

                if InStr(charsToSkip, c)
                    Continue
                else if c = targetC {
                    foundValidChar := 1
                    Break
                }
                Else
                    throw ValueError("Invalid JSON", "seek_next_valid_char", "Found an invalid character (" . c .  ") while trying to match the character: " . targetC)
            }
        }

        if !foundValidChar{
            target := regex = "" ? targetC : regex
            throw ValueError("Invalid JSON", "seek_next_valid_char", "Reached EOF or could not find the requested character(s): " . target)
        }
        
        return c
    }

    parse_object() {
        obj := {}
        c := ""
        ;startPos := this.f.Pos

        ; Do a try-catch here (and record starting file position) to make better error messages
        c := this.seek_next_valid_char( , RegexChars.OBJ_PAIR_OR_END)

        if c = "`""
            this.parse_pairs(obj)

        return obj
    }

    ; TODO: validate AHK property names (strings) so that they'll be accepted
    parse_pairs(obj){
        c := ""
        property := ""
        value := unset
        tempArr := []

        property := this.parse_string()

        ; try-catch here for better error messages
        this.seek_next_valid_char(":")

        ; try-catch here for better error messages
        c := this.seek_next_data_type()

        value := this.parse_router(c)
        
        obj.%property% := value

        c := this.seek_next_valid_char( , RegexChars.COMMA_OR_OBJ_END)

        if c = ","{
            this.seek_next_valid_char("`"")
            this.parse_pairs(obj)
        }
    }

    parse_array() {
        arr := []
        element := unset
        c := ""

        while c != "]" {
            c := this.seek_next_valid_char( , RegexChars.ANY_TYPE_OR_ARR_END)

            if c != "]" {
                element := this.parse_router(c)
                arr.Push(element)

                c := this.seek_next_valid_char( , RegexChars.COMMA_OR_ARR_END)
            }
        }

        return arr
    }

    ; TODO: JSON Unicode escaped characters, JSON control escaped characters, AHK characters to reject/handle
    parse_string() {
        str := ""
        c := ""
        escapeNext := 0
        foundEndQuote := 0

        while !this.f.AtEOF && !foundEndQuote {
            c := this.f.Read(1)

            if escapeNext {
                Switch c {
                    Case "`"", "\", "/":
                        str .= c
                    Case "n":
                        str .= "`n"
                    Case "r":
                        str .= "`r"
                    Case "t":
                        str .= "`t"
                    Case "b":
                        str .= "`b"
                    Case "f":
                        str .= "`f"
                    Case "u":
                        throw ValueError("Invalid JSON", "parse_string()", "Unicode characters are not supported yet.") ; Uh, let's figure this out later
                    Default:
                        throw ValueError("Invalid JSON", "parse_string()", "Escape character (\) followed by an invalid character.")
                }

                escapeNext := 0
            }
            else if c = "\"{
                escapeNext := 1
            }
            else if c = "`""
                foundEndQuote := 1
            Else
                str .= c
        }

        if !foundEndQuote {
            throw ValueError("Invalid JSON", "parse_string()", "Could not find an ending quotation mark to a string.")
        }

        return str
    }

    parse_boolean(c) {
        bool := c
        retval := 0

        bool .= this.read_until_char("e", 4, 1)

        Switch bool {
            Case "true":
                retval := 1
            Case "false":
                retval := 0
            Default:
                throw ValueError("Invalid JSON", "parse_boolean(c)", "Expected `"true`" or `"false`" but instead got: " . bool)
        }

        return retval
    }

    parse_value(firstDigit) {
        numStr := firstDigit
        decimalPointCounter := 0
        d := 0

        while !this.f.AtEOF && decimalPointCounter <= 1{
            d := this.f.Read(1)

            if RegExMatch(d, "[\d]")
                numStr .= d
            else if d = "."
                if decimalPointCounter >= 1
                    throw ValueError("Invalid JSON", "parse_value(firstDigit)", "Multiple decimal points were found in a number.")
                Else
                    numStr .= d
            Else {
                this.f.Pos -= 1
                Break
            }

        }

        return numStr
    }

    ; TODO: properly ignore characters such as spaces/newlines. Also, what to return?
    parse_null(c) {
        str := c

        if this.f.Length < this.f.Pos + 2
            throw ValueError("Invalid JSON", "parse_null(c)", "Expeced `"null`" at position: " . this.f.Pos - 1)

        str .= this.f.Read(3)

        if str != "null"
            throw ValueError("Invalid JSON", "parse_null(c)", "Expeced `"null`" at position: " . this.f.Pos - 4)

        return str
    }

    read_until_char(targetC, maxReads, includeTarget := 0){
        str := ""
        targetFound := 0
        readCount := 0

        while !this.f.AtEOF && !targetFound && readCount < maxReads {
            c := this.f.Read(1)

            if c = targetC {
                targetFound := 1

                if includeTarget
                    str .= c
            }
            Else
                str .= c
        }

        if !targetFound {
            throw ValueError("Invalid JSON", "read_until_char", "Target character (" . targetC . ") was not found.")
        }

        return str
    }

}

class RegexChars{
    static COMMA_OR_ARR_END := "[,\]]"
    static COMMA_OR_OBJ_END := "[,\}]"
    static ANY_TYPE_OR_ARR_END := "[tfn\{\[\`"\d\]]"
    static OBJ_PAIR_OR_END := "[\`"\}]"
    static ANY_TYPE_START := "[tfn\{\[\`"\d]"
    static ANY_DIGIT := "[\d]"
}