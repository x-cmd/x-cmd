-- 标记指定提醒事项为已完成
-- osascript comp.applescript "提醒1"
on run argv
  tell application "Reminders"
    set completed of (last reminder whose name contains item 1 of argv and completed is false) to true
    quit
    return "success"
  end tell
end run
