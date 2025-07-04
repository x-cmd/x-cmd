-- e.g. osascript ls.applescript

on run
    set jsonText to "["

    tell application "Reminders"
        set allReminders to reminders

        repeat with i from 1 to count of allReminders
            set r to item i of allReminders

            set itemId to id of r
            set itemName to my escapeJson(name of r)
            set isCompleted to completed of r as string

            -- Format date
            if (remind me date of r is not missing value) then
                set rawDate to remind me date of r
                set timeFormatted to my formatDate(rawDate)
            else
                set timeFormatted to ""
            end if

            -- Priority: 0 (None), 1 (Low), 5 (Medium), 9 (High)
            set priorityValue to priority of r

            set listName to my escapeJson(name of container of r)

            set jsonText to jsonText & "{" & ¬
                "\"id\":\"" & itemId & "\"," & ¬
                "\"name\":\"" & itemName & "\"," & ¬
                "\"completed\":" & isCompleted & "," & ¬
                "\"time\":\"" & timeFormatted & "\"," & ¬
                "\"list\":\"" & listName & "\"," & ¬
                "\"priority\":" & priorityValue & ¬
            "}"

            if i is not (count of allReminders) then
                set jsonText to jsonText & ","
            end if
        end repeat
    end tell

    set jsonText to jsonText & "]"
    return jsonText
end run

-- Escape double quotes in text
on escapeJson(txt)
    set AppleScript's text item delimiters to "\""
    set txt to text items of txt
    set AppleScript's text item delimiters to "\\\""
    set txt to txt as text
    set AppleScript's text item delimiters to ""
    return txt
end escapeJson

-- Format AppleScript date object to "YYYY-MM-DD HH:MM"
on formatDate(d)
    set y to year of d as string
    set m to my padWithZero((month of d as integer) as string)
    set dayPart to my padWithZero((day of d) as string)
    set h to my padWithZero((hours of d) as string)
    set min to my padWithZero((minutes of d) as string)

    return y & "-" & m & "-" & dayPart & " " & h & ":" & min
end formatDate

-- Ensure two-digit format
on padWithZero(n)
    if (length of n) = 1 then
        return "0" & n
    else
        return n
    end if
end padWithZero
