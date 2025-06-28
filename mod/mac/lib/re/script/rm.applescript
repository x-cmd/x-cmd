-- 删除指定提醒事项
-- osascript rm.applescript "提醒1"
on run argv
    tell application "Reminders"
        set reminderName to item 1 of argv
        set theReminders to reminders whose name is reminderName and completed is false
        repeat with r in theReminders
            delete r
        end repeat
        quit
        return "success"
    end tell
end run