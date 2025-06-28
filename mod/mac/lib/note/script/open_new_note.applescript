-- 新建并打开一条备忘录
try
    tell application "Notes"
        make new note
        show (first item of notes)
    end tell
end try
