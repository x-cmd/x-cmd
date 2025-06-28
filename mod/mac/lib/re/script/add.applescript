-- 添加新的提醒事项
-- osascript add.applescript "提醒1" "2025-06-25" "18:00"
on run argv
    if (count of argv) is not 3 then
        return "Error: Missing arguments. Parameter format: \"Reminders title\" \"YYYY-MM-DD\" \"HH:MM\""
    end if

    set reminderTitle to item 1 of argv
    set reminderDate to item 2 of argv
    set reminderTime to item 3 of argv

    try
        set dateString to reminderDate & " " & reminderTime
        set remindDate to date dateString
    on error
        return "Error: Invalid date format. Please use YYYY-MM-DD and HH:MM."
    end try

    tell application "Reminders"
        make new reminder with properties {name:reminderTitle, remind me date:remindDate}
    end tell

    return "Reminder added successfully: " & reminderTitle & " at " & dateString
end run
