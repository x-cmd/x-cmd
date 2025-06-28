-- 修改指定提醒事项
-- osascript update.applescript "提醒1" "提醒1.v2" "2025-06-25 20:30"
on run argv
    if (count of argv) is not 3 then
        return "Error: Missing arguments. Parameter format: \"Old Title\" \"New Title\" \"YYYY-MM-DD HH:MM\""
    end if

    set oldTitle to item 1 of argv
    set newTitle to item 2 of argv
    set newDateTime to item 3 of argv

    try
        set newDate to my convertDate(newDateTime)
    on error
        return "Error: Invalid datetime format. Use YYYY-MM-DD HH:MM"
    end try

    tell application "Reminders"
        set matchedReminders to reminders whose name is oldTitle

        if (count of matchedReminders) is 0 then
            return "Error: No reminder found with title \"" & oldTitle & "\""
        end if

        set currentReminder to last item of matchedReminders
        set name of currentReminder to newTitle
        set remind me date of currentReminder to newDate
    end tell

    return "Reminder updated: \"" & oldTitle & "\" → \"" & newTitle & "\" at " & newDateTime
end run

on convertDate(textDate)
    if length of textDate is not 16 then
        error "Invalid date length"
    end if

    try
        set yearPart to text 1 thru 4 of textDate as integer
        set monthPart to text 6 thru 7 of textDate as integer
        set dayPart to text 9 thru 10 of textDate as integer
        set hourPart to text 12 thru 13 of textDate as integer
        set minutePart to text 15 thru 16 of textDate as integer
    on error
        error "Failed to parse date parts"
    end try

    set resultDate to current date
    set year of resultDate to yearPart
    set month of resultDate to monthPart
    set day of resultDate to dayPart
    set time of resultDate to 0
    set hours of resultDate to hourPart
    set minutes of resultDate to minutePart

    return resultDate
end convertDate

