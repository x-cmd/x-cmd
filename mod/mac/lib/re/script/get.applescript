-- 获取提醒事项的详细内容
-- osascript get.applescript "提醒1"
on run argv
  tell application "Reminders"
    set currentReminder to get due date of last reminder whose name is item 1 of argv

    quit
    return date string of currentReminder & " " & time string of currentReminder
  end tell
end run
