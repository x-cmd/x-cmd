-- 列出所有提醒事项
-- osascript ls.applescript
tell application "Reminders"
    set reminderList to {}
    if (count of (reminders whose completed is false)) > 0 then
        set reminderList to name of reminders whose completed is false
    end if

    quit
    return reminderList
end tell
