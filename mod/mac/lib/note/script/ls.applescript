-- e.g. osascript ls.applescript

on run
    set jsonText to "["

    tell application "Notes"
        set allNotes to every note

        repeat with i from 1 to count of allNotes
            set n to item i of allNotes

            set noteId to id of n
            set noteName to my escapeJson(name of n)
            -- set noteBody to my escapeJson(body of n)

            set mDate to my formatDate(modification date of n)

            set jsonText to jsonText & "{" & ¬
                "\"id\":\"" & noteId & "\"," & ¬
                "\"name\":\"" & noteName & "\"," & ¬
                "\"modification_date\":\"" & mDate & "\"" & ¬
            "}"

            if i is not (count of allNotes) then
                set jsonText to jsonText & ","
            end if
        end repeat
    end tell

    set jsonText to jsonText & "]"
    return jsonText
end run

-- Escape JSON special characters (only quote for now)
on escapeJson(txt)
    set AppleScript's text item delimiters to "\""
    set txt to text items of txt
    set AppleScript's text item delimiters to "\\\""
    set txt to txt as text
    set AppleScript's text item delimiters to ""
    return txt
end escapeJson

-- Format date as "YYYY-MM-DD HH:MM"
on formatDate(d)
    set y to year of d as string
    set m to my padWithZero((month of d as integer) as string)
    set dayPart to my padWithZero((day of d) as string)
    set h to my padWithZero((hours of d) as string)
    set min to my padWithZero((minutes of d) as string)

    return y & "-" & m & "-" & dayPart & " " & h & ":" & min
end formatDate

on padWithZero(n)
    if (length of n) = 1 then
        return "0" & n
    else
        return n
    end if
end padWithZero

