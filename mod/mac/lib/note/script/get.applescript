-- e.g. osascript get.applescript "note1"

on run argv
    if (count of argv) = 0 then
        return "Error: Please provide a note title."
    end if

    set inputTitle to item 1 of argv
    set outputText to ""
    set matchCount to 0

    tell application "Notes"
        set allNotes to every note

        repeat with n in allNotes
            set noteTitle to name of n
            if (my exactMatch(noteTitle, inputTitle)) then
                set editTime to my formatDate(modification date of n)
                set noteBodyHTML to body of n

                set outputText to outputText & editTime & linefeed & noteBodyHTML & linefeed
                set matchCount to matchCount + 1
            end if
        end repeat
    end tell

    if matchCount = 0 then
        return "No matching notes found."
    else
        return outputText
    end if
end run

on exactMatch(a, b)
    return (do shell script "test \"" & a & "\" = \"" & b & "\" && echo true || echo false") is "true"
end exactMatch

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
