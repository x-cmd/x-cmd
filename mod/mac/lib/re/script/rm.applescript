-- e.g. osascript rm.applescript "提醒1"

on run argv
    if (count of argv) = 0 then
        return "Error: Missing reminder name."
    end if

    set reminderName to item 1 of argv
    set deletedCount to 0

    tell application "Reminders"
        set allReminders to reminders

        repeat with r in allReminders
            if (name of r) is equal to reminderName and (completed of r is false) then
                delete r
                set deletedCount to deletedCount + 1
            end if
        end repeat

        quit
    end tell

    if deletedCount = 0 then
        return "No matching reminder found."
    else
        return "Deleted " & deletedCount & " reminder(s)."
    end if
end run
